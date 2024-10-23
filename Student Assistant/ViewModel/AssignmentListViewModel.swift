//
//  AssignmentListViewModel.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import Foundation
import SwiftUI

class AssignmentListViewModel: ObservableObject {
    @Published var assignments: [Assignment] = []
    private let assignmentRepo: AssignmentRepo
    
    init(assignmentRepo: AssignmentRepo = Injection.shared.container.resolve(AssignmentRepo.self)!) {
        self.assignmentRepo = assignmentRepo
        fetchAssignments()
    }
    
    // Fetch assignments
    func fetchAssignments() {
        assignments.removeAll()
        assignmentRepo.verifyAssignmentsOverDue()
        assignments = assignmentRepo.fetchObject()
        sortAssignments()
    }
    
    func fetchCompletedAssignments() {
        assignments.removeAll()
        assignments = assignmentRepo.fetchObject().filter {$0.assignmentStatus == .completed}
        sortAssignments()
    }
    
    // Sorts assignments list
    func sortAssignments() {
        self.assignments = assignments.sorted(by: {$0.assignmentDate! < $1.assignmentDate!})
    }
    
    // Add a new assignment
    func addAssignment(title: String, description: String, dueDate: Date) -> Bool{
        guard title != "",
              description != "" else { return false }
        assignmentRepo.addAssignment(title: title, description: description, dueDate: dueDate)
        fetchAssignments() // Refresh assignments after adding
        return true
    }
    
    // Delete an assignment
    func deleteAssignment(at index: Int) {
        let assignmentToDelete = assignments[index]
        assignmentRepo.deleteObject(object: assignmentToDelete) // Call repo method to delete
        fetchAssignments() // Refresh assignments after deletion
    }
    
    func changeStatus(for assignment: Assignment, newStatus: Status) {
        assignmentRepo.updateStatus(assignment: assignment, status: newStatus)
        fetchAssignments()
    }
    
    func fetchCurrentAssignments() -> [Assignment]{
        return assignmentRepo.fetchObject().filter {$0.assignmentStatus == .inProgress || $0.assignmentStatus == .pending}
    }
    
    func fetchFailedAssignments() -> [Assignment]{
        return assignmentRepo.fetchObject().filter {$0.assignmentStatus == .failed}
    }
}
