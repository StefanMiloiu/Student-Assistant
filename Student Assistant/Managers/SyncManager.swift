//
//  SyncManager.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 24.10.2024.
//

import Foundation

import CoreData
import OSLog

class SyncManager {
    
    private let context: NSManagedObjectContext
    private let firebaseRepo: AssignmentRepoFirebase
    private let assignmentRepo: AssignmentRepo
    private let examsFirebaseRepo: ExamRepoFirebase
    private let examsRepo: ExamRepo
    private let logger: Logger = Logger()
    
    init(context: NSManagedObjectContext = DataManager.shared.persistentContainer.viewContext,
         firebaseRepo: AssignmentRepoFirebase = AssignmentRepoFirebase(),
         assignmentRepo: AssignmentRepo = AssignmentRepo(),
         examsFirebaseRepo: ExamRepoFirebase = ExamRepoFirebase(),
         examsRepo: ExamRepo = ExamRepo()) {
        self.context = context
        self.firebaseRepo = firebaseRepo
        self.assignmentRepo = assignmentRepo
        self.examsFirebaseRepo = examsFirebaseRepo
        self.examsRepo = examsRepo
    }
    
    //MARK: - Mutual
    func onLogInSync() {
        /// Sync for Assignments and Exams
        assignmentRepo.fetchObject().forEach { (assignment: Assignment) in
            assignmentRepo.deleteObject(object: assignment)
        }
        examsRepo.deleteAllExams()
        
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
        
        examsFirebaseRepo.fetchDocumentsByEmail(email: UserDefaults().userName!) { [weak self] (result: Result<[ExamFirebase], Error>) in
            switch result {
            case .success(let exams):
                exams.forEach { exam in
                    if let subject = exam.examSubject,
                       let date = exam.examDate,
                       let location = exam.examLocation,
                       let latitude = exam.examLatitude,
                       let longitude = exam.examLongitude {
                        
                        let _ = self?.examsRepo.addExam(subject: subject,
                                                        date: date,
                                                        location: location,
                                                        latitude: latitude,
                                                        longitude: longitude)
                    } else {
                        // Log an error or handle cases where data is missing
                        print("Incomplete exam data: \(exam)")
                    }
                }
            case .failure(let error):
                print("Error fetching exams from Firebase: \(error)")
            }
        }
    }
    
    //MARK: - Assignments
    func syncAssignments(completion: @escaping (Bool) -> Void) {
        guard UserDefaults().userName != nil else { return }
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
                if local.lastUpdated ?? Date() < remote.lastUpdated ?? Date() {
                    // Update local assignment
                    remote.lastSynced = Date()
                    remote.isSynced = true
                    updateLocalAssignment(local, with: remote)
                } else if local.lastUpdated ?? Date() > remote.lastUpdated ?? Date() {
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
                if remote.lastUpdated != nil  {
                    if remote.isRemoved != nil && remote.isRemoved == false {
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
    
    private func updateLocalAssignment(_ local: Assignment, with remote: AssignmentFirebase) {
        local.assignmentTitle = remote.assignmentTitle
        local.assignmentDescription = remote.assignmentDescription
        local.assignmentDate = remote.assignmentDate
        local.assignmentGotDate = remote.assignmentGotDate
        local.assignmentStatus = remote.assignmentStatus
        local.lastUpdated = remote.lastUpdated
        local.lastSynced = remote.lastSynced
        local.isSynced = true
        do {
            try context.save()
        } catch {
            print("Could not update local assignment: \(error.localizedDescription)")
        }
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
        do {
            try context.save()
        } catch {
            print("Could not save local assignment: \(error.localizedDescription)")
        }
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
    
    //MARK: - Exams
    func syncExams(completion: @escaping (Bool) -> Void) {
        examsFirebaseRepo.fetchDocumentsByEmail(email: UserDefaults().userName ?? "") { [weak self] (result: Result<[ExamFirebase], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let firebaseExams):
                // Fetch all local exams
                let localExams = self.fetchAllLocalExams()
                
                // Create dictionaries keyed by examID
                var firebaseDict = [UUID: ExamFirebase]()
                for exam in firebaseExams {
                    if let id = exam.examID {
                        firebaseDict[id] = exam
                    }
                }
                
                var localDict = [UUID: Exam]()
                for exam in localExams {
                    if let id = exam.examID {
                        localDict[id] = exam
                    }
                }
                
                // Process exams
                self.processExams(localDict: localDict, firebaseDict: firebaseDict) {
                    self.examsRepo.saveContext()
                    completion(true)
                }
                
            case .failure(let error):
                print("Error fetching exams from Firebase: \(error)")
                completion(false)
            }
        }
    }
    
    private func processExams(localDict: [UUID: Exam], firebaseDict: [UUID: ExamFirebase], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        logger.info("Processing exams")
        let localExamIDs = Set(localDict.keys)
        let firebaseExamIDs = Set(firebaseDict.keys)
        let allExamIDs = localExamIDs.union(firebaseExamIDs)
        
        for examID in allExamIDs {
            let localExam = localDict[examID]
            let firebaseExam = firebaseDict[examID]
            
            if let local = localExam, var remote = firebaseExam {
                logger.info("Exam \(examID) exists in both databases")
                if local.examDate ?? Date() < Date() {
                    deleteLocalExam(examID)
                    dispatchGroup.enter()
                    print("Entered delete exam firebase")
                    deleteExamFromFirebase(examID) {
                        dispatchGroup.leave()
                    }
                }
                if local.lastUpdated ?? Date() < remote.lastUpdated ?? Date() {
                    remote.lastSynced = Date()
                    remote.isSynced = true
                    updateLocalExam(local, with: remote)
                } else if local.lastUpdated ?? Date() > remote.lastUpdated ?? Date() {
                    local.lastSynced = Date()
                    local.isSynced = true
                    dispatchGroup.enter()
                    pushLocalExamToFirebase(local) {
                        dispatchGroup.leave()
                    }
                }
            } else if let local = localExam {
                logger.info("Exam \(examID) exists only in the local database")
                if local.lastUpdated != nil {
                    if local.lastSynced == nil {
                        dispatchGroup.enter()
                        local.isSynced = true
                        local.lastSynced = Date()
                        pushLocalExamToFirebase(local) {
                            dispatchGroup.leave()
                        }
                    } else {
                        deleteLocalExam(examID)
                    }
                }
            } else if var remote = firebaseExam {
                logger.info("Exam \(examID) exists only in the cloud database")
                if remote.lastUpdated != nil {
                    if remote.isRemoved != nil && remote.isRemoved == false {
                        print("Entered create exam local")
                        remote.lastSynced = Date()
                        remote.isSynced = true
                        createLocalExam(from: remote)
                    } else {
                        dispatchGroup.enter()
                        print("Entered delete exam firebase")
                        deleteExamFromFirebase(examID) {
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
    
    private func updateLocalExam(_ local: Exam, with remote: ExamFirebase) {
        local.examSubject = remote.examSubject
        local.examDate = remote.examDate
        local.examLocation = remote.examLocation
        local.examLatitude = remote.examLatitude ?? 27.40
        local.examLongitude = remote.examLongitude ?? 49.599774
        local.lastUpdated = remote.lastUpdated
        local.lastSynced = remote.lastSynced
        local.isSynced = true
        do {
            try context.save()
        } catch {
            print("Could not update local exam: \(error.localizedDescription)")
        }
    }
    
    private func createLocalExam(from remote: ExamFirebase) {
        let newExam = Exam(context: context)
        newExam.examID = remote.examID
        newExam.examSubject = remote.examSubject
        newExam.examDate = remote.examDate
        newExam.examLocation = remote.examLocation
        newExam.examLatitude = remote.examLatitude ?? 27.40
        newExam.examLongitude = remote.examLongitude ?? 49.599774
        newExam.lastSynced = remote.lastSynced
        newExam.lastUpdated = remote.lastUpdated
        newExam.isSynced = true
        do {
            try context.save()
        } catch {
            print("Could not save local exam: \(error.localizedDescription)")
        }
    }
    
    private func pushLocalExamToFirebase(_ local: Exam, completion: @escaping () -> Void) {
        let data = ExamFirebase(from: local)
        examsFirebaseRepo.fetchAndSaveDocumentWithID(data: data, byField: "examID", ID: data.examID?.uuidString ?? "") { result in
            switch result {
            case .success:
                local.isSynced = true
            case .failure(let error):
                print("Error pushing to Firebase: \(error)")
            }
        }
    }
    
    private func deleteExamFromFirebase(_ examID: UUID, completion: @escaping () -> Void) {
        examsFirebaseRepo.deleteDocumentWithID(examID: examID.uuidString) { result in
            if case .failure(let error) = result {
                print("Error deleting from Firebase: \(error)")
            }
            completion()
        }
    }
    
    private func deleteLocalExam(_ examID: UUID) {
        if let exam = examsRepo.fetchExamByID(id: examID) {
            context.delete(exam)
        }
    }
    
    private func fetchAllLocalExams() -> [Exam] {
        let request: NSFetchRequest<Exam> = Exam.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching local exams: \(error)")
            return []
        }
    }
}
