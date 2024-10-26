//
//  AssignmentListViewModel.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import Foundation
import SwiftUI

class AssignmentListViewModel: ObservableObject {
    @Published var assignments: [Assignment] = [] // Use Core Data Assignment model
    private let assignmentRepo: AssignmentRepo
    private let assignmentFirestore: AssignmentRepoFirebase
    private let syncManager: SyncManager
    
    init(assignmentRepo: AssignmentRepo = Injection.shared.container.resolve(AssignmentRepo.self)!,
         syncManager: SyncManager = SyncManager(),
         assignmentFirestore: AssignmentRepoFirebase = AssignmentRepoFirebase()) {
        self.assignmentRepo = assignmentRepo
        self.syncManager = syncManager
        self.assignmentFirestore = assignmentFirestore
        fetchAssignments() // Initially fetch assignments from Firestore
    }
    
    func syncAssignments() {
        syncManager.syncAssignments { [weak self] result in
            if result {
                self?.fetchAssignments()
            }
        }
    }
    
    // Fetch assignments from Firestore
    func fetchAssignments() {
        assignments.removeAll()
        assignmentRepo.verifyAssignmentsOverDue()
        assignments = assignmentRepo.fetchObject()
        sortAssignments()
    }
    
    // Fetch completed assignments
    func fetchCompletedAssignments() -> [Assignment] {
        return assignments.filter { $0.assignmentStatus == .completed }
    }
    
    // Fetch current assignments
    func fetchCurrentAssignments() -> [Assignment] {
        return assignments.filter { $0.assignmentStatus == .inProgress || $0.assignmentStatus == .pending }
    }
    
    // Fetch failed assignments
    func fetchFailedAssignments() -> [Assignment] {
        return assignments.filter { $0.assignmentStatus == .failed }
    }
    
    // Add a new assignment to Firestore and Core Data
    func addAssignment(title: String, description: String, dueDate: Date) -> Bool {
        guard !title.isEmpty, !description.isEmpty else { return false }
        
        assignmentRepo.addAssignment(title: title,
                                     description: description,
                                     dueDate: dueDate)
        syncManager.syncAssignments { [weak self] result in
            if result {
                self?.fetchAssignments()
            }
        }
        return true
    }
    
    // Delete an assignment from Firestore and Core Data
    func deleteAssignment(_ assignment: Assignment) {
        assignmentRepo.deleteObject(object: assignment) // Also delete from Core Data
        syncManager.syncAssignments { [weak self] result in
            if result {
                self?.fetchAssignments()
            }        }
    }
    
    // Change the status of an assignment in Firestore and Core Data
    func changeStatus(for assignment: Assignment, newStatus: Status) {
        self.assignmentRepo.updateStatus(assignment: assignment, status: newStatus) // Update in Core Data
        syncManager.syncAssignments { [weak self] result in
            if result {
                self?.fetchAssignments()
            }        }
    }
    
    // Sort assignments list
    func sortAssignments() {
        self.assignments.sort(by: { $0.assignmentDate! < $1.assignmentDate! })
    }
    
    // Helper method to map Firestore model to Core Data model
    private func mapFirebaseToCoreData(_ firebaseAssignment: AssignmentFirebase) -> Assignment {
        let coreDataAssignment = Assignment(context: DataManager.shared.getContext())
        coreDataAssignment.assignmentID = firebaseAssignment.assignmentID
        coreDataAssignment.assignmentTitle = firebaseAssignment.assignmentTitle
        coreDataAssignment.assignmentDescription = firebaseAssignment.assignmentDescription
        coreDataAssignment.assignmentGotDate = firebaseAssignment.assignmentGotDate
        coreDataAssignment.assignmentDate = firebaseAssignment.assignmentDate
        coreDataAssignment.assignmentStatus = firebaseAssignment.assignmentStatus
        return coreDataAssignment
    }
}
