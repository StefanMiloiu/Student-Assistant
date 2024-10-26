//
//  SyncManager.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 24.10.2024.
//

import Foundation

import Foundation
import CoreData
import OSLog

class SyncManager {
    
    private let context: NSManagedObjectContext
    private let firebaseRepo: AssignmentRepoFirebase
    private let assignmentRepo: AssignmentRepo
    private let logger: Logger = Logger()
    
    init(context: NSManagedObjectContext = DataManager.shared.persistentContainer.viewContext,
         firebaseRepo: AssignmentRepoFirebase = AssignmentRepoFirebase(),
         assignmentRepo: AssignmentRepo = AssignmentRepo()) {
        self.context = context
        self.firebaseRepo = firebaseRepo
        self.assignmentRepo = assignmentRepo
    }
    
    func syncAssignments(completion: @escaping (Bool) -> Void) {
        firebaseRepo.fetchDocumentsByEmail(email: UserDefaults().userName!) { [weak self] (result: Result<[AssignmentFirebase], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let firebaseAssignments):
                // Fetch all local assignments
                let localAssignments = self.fetchAllLocalAssignments()
                
                // Create dictionaries keyed by assignmentID
                var firebaseDict = [UUID: AssignmentFirebase]()
                for assignment in firebaseAssignments {
                    if let idString = assignment.assignmentID, let id = UUID(uuidString: idString.uuidString) {
                        firebaseDict[id] = assignment
                    }
                }
                
                var localDict = [UUID: Assignment]()
                for assignment in localAssignments {
                    if let id = assignment.assignmentID {
                        localDict[id] = assignment
                    }
                }
                
                // Process assignments
                self.processAssignments(localDict: localDict, firebaseDict: firebaseDict) {
                    self.assignmentRepo.saveContext()
                    completion(true)
                }
                
            case .failure(let error):
                print("Error fetching assignments from Firebase: \(error)")
                completion(false)
            }
        }
    }

    private func processAssignments(localDict: [UUID: Assignment], firebaseDict: [UUID: AssignmentFirebase], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        logger.info("Processing assignments")
        // Sets of assignment IDs
        let localAssignmentIDs = Set(localDict.keys)
        let firebaseAssignmentIDs = Set(firebaseDict.keys)
        let allAssignmentIDs = localAssignmentIDs.union(firebaseAssignmentIDs)
        
        for assignmentID in allAssignmentIDs {
            let localAssignment = localDict[assignmentID]
            let firebaseAssignment = firebaseDict[assignmentID]
            
            /// Check if there is the same assignment in both databases
            if let local = localAssignment, var remote = firebaseAssignment {
                logger.info("Assignment \(assignmentID) exists in both databases")
                // Assignment exists both locally and in Firebase
                if local.lastUpdated! < remote.lastUpdated! {
                    logger.info("Assignment \(String(describing: remote)) is newer in local database")
                    // Update local assignment
                    remote.lastSynced = Date()
                    remote.isSynced = true
                    updateLocalAssignment(local, with: remote)
                } else if local.lastUpdated! > remote.lastUpdated! {
                    logger.info("Assignment \(String(describing: local)) is newer in Firebase database")
                    // Update Firebase assignment
                    local.lastSynced = Date()
                    local.isSynced = true
                    dispatchGroup.enter()
                    pushLocalAssignmentToFirebase(local) {
                        dispatchGroup.leave()
                    }
                }
                // else, timestamps are equal, no action needed
            /// Check if the assignment is only in the local database
            } else if let local = localAssignment {
                logger.info("Assignment \(assignmentID) exists only in the local database")
                // Assignment exists only locally
                // Could be new or deleted in Firebase
                if local.lastUpdated != nil {
                    if local.lastSynced == nil {
                        logger.info("Assignment \(assignmentID) is new in local db")
                        // New local assignment; push to Firebase
                        dispatchGroup.enter()
                        local.isSynced = true
                        local.lastSynced = Date()
                        pushLocalAssignmentToFirebase(local) {
                            dispatchGroup.leave()
                        }
                    } else {
                        logger.info("Assignment \(assignmentID) was deleted in local db")
                        // Assignment was deleted in Firebase; delete locally
                        deleteLocalAssignment(assignmentID)
                    }
                }
            /// Check if the assignment is only in the cloud database
            } else if var remote = firebaseAssignment {
                logger.info("Assignment \(assignmentID) exists only in the cloud database")
                // Assignment exists only in Firebase
                // Could be new or deleted locally
                if remote.lastUpdated != nil {
                    if localDict[assignmentID] != nil && remote.assignmentEmail == UserDefaults().userName {
                        // New assignment in Firebase; create locally
                        logger.info("Entered createLocalAssignment")
                        remote.lastSynced = Date()
                        remote.isSynced = true
                        createLocalAssignment(from: remote)
                    } else {
                        // Assignment was deleted locally; delete from Firebase
                        logger.info("Entered deleteAssignmentFromFirebase")
                        dispatchGroup.enter()
                        deleteAssignmentFromFirebase(assignmentID) {
                            dispatchGroup.leave()
                        }
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    func onLogInSync() {
        /// Sync for Assignments
        assignmentRepo.fetchObject().forEach { (assignment: Assignment) in
            assignmentRepo.deleteObject(object: assignment)
        }
        
        firebaseRepo.fetchDocumentsByEmail(email: UserDefaults().userName ?? "No email found", completion: { [weak self] (result: Result<[AssignmentFirebase], Error>) in
            switch result {
            case .success(let assignments):
                assignments.forEach {
                    self?.assignmentRepo.addAssignment($0)
                }
            case .failure:
                break
            }
        })
    }


    private func updateLocalAssignment(_ local: Assignment, with remote: AssignmentFirebase) {
        local.assignmentTitle = remote.assignmentTitle
        local.assignmentDescription = remote.assignmentDescription
        local.assignmentDate = remote.assignmentDate
        local.assignmentGotDate = remote.assignmentGotDate
        local.assignmentStatus = remote.assignmentStatus
        local.lastUpdated = remote.lastUpdated
        local.lastSynced = remote.lastSynced
        local.isSynced = true
    }

    private func createLocalAssignment(from remote: AssignmentFirebase) {
        let newAssignment = Assignment(context: context)
        newAssignment.assignmentID = UUID(uuidString: remote.assignmentID!.uuidString)
        newAssignment.assignmentTitle = remote.assignmentTitle
        newAssignment.assignmentDescription = remote.assignmentDescription
        newAssignment.assignmentDate = remote.assignmentDate
        newAssignment.assignmentGotDate = remote.assignmentGotDate
        newAssignment.assignmentStatus = remote.assignmentStatus
        newAssignment.lastSynced = remote.lastSynced
        newAssignment.lastUpdated = remote.lastUpdated
        newAssignment.isSynced = true
    }

    private func pushLocalAssignmentToFirebase(_ local: Assignment, completion: @escaping () -> Void) {
        do {
            let data = try AssignmentFirebase(from: local)
            firebaseRepo.fetchAndSaveDocumentWithID(data: data, byField: "assignmentID",
                                                    ID: data.assignmentID?.uuidString ?? "No ID found") { result in
                switch result {
                case .success:
                    local.isSynced = true
                case .failure(let error):
                    print("Error pushing to Firebase: \(error)")
                }
                completion()
            }
        } catch {
            print("Error converting Assignment to AssignmentFirebase: \(error)")
            completion()
        }
    }

    private func deleteAssignmentFromFirebase(_ assignmentID: UUID, completion: @escaping () -> Void) {
        firebaseRepo.deleteDocumentWithID(assignmentID: assignmentID.uuidString) { result in
            if case .failure(let error) = result {
                print("Error deleting from Firebase: \(error)")
            }
            completion()
        }
    }

    private func deleteLocalAssignment(_ assignmentID: UUID) {
        if let assignment = assignmentRepo.fetchAssignmentByID(assignmentID: assignmentID) {
            context.delete(assignment)
        }
    }

    private func fetchAllLocalAssignments() -> [Assignment] {
        let request: NSFetchRequest<Assignment> = Assignment.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching local assignments: \(error)")
            return []
        }
    }
}
