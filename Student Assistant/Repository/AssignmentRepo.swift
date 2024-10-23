//
//  AssignmentRepo.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import Foundation
import CoreData
import CloudKit
// MARK: - Assignment Repository
/// `AssignmentRepo` handles assignment-related data operations such as adding, fetching, deleting, and updating assignments.
/// It conforms to `DataManagerProtocol` to interact with Core Data.
struct AssignmentRepo: DataManagerProtocol {
    
    let dataManager: DataManagerProtocol
    
    // MARK: - Initializer
    /// Initializes the repository with a data manager. Defaults to `DataManager.shared`.
    /// - Parameter dataManager: A `DataManagerProtocol` instance. Defaults to `DataManager.shared`.
    init(dataManager: DataManagerProtocol = DataManager.shared) {
        self.dataManager = dataManager
    }
    
    // MARK: - Context Management
    /// Saves the Core Data context using the `DataManager`.
    func saveContext() {
        dataManager.saveContext()
    }
    
    // MARK: - Fetch Assignments
    /// Fetches all `Assignment` objects from Core Data.
    /// - Returns: An array of fetched `Assignment` objects.
    func fetchObject<Assignment>() -> [Assignment] where Assignment: NSManagedObject {
        return dataManager.fetchObject()
    }
    
    // MARK: - Delete Assignment
    /// Deletes a specified `Assignment` object from Core Data.
    /// - Parameter object: The `Assignment` object to delete.
    func deleteObject<Assignment>(object: Assignment) where Assignment: NSManagedObject {
        dataManager.deleteObject(object: object)
    }
    
    /// Returns the current Core Data context.
    func getContext() -> NSManagedObjectContext {
        return dataManager.getContext()
    }
    
    // MARK: - Add Assignment
    /// Adds a new `Assignment` object to Core Data.
    /// - Parameters:
    ///   - title: The title of the assignment.
    ///   - description: A description of the assignment.
    ///   - dueDate: The due date of the assignment.
    func addAssignment(title: String, description: String, dueDate: Date) {
        let context = DataManager.shared.persistentContainer.viewContext
        let assignment = Assignment(context: context)
        assignment.assignmentID = UUID()
        assignment.assignmentTitle = title
        assignment.assignmentDescription = description
        assignment.assignmentDate = dueDate
        assignment.assignmentStatus = .pending
        saveContext() // Save the context after adding the assignment
    }
    
    // MARK: - Update Assignment Status
    /// Updates the status of a given `Assignment`.
    /// - Parameters:
    ///   - assignment: The `Assignment` object whose status needs to be updated.
    ///   - status: The new `Status` to set.
    func updateStatus(assignment: Assignment, status: Status) {
        assignment.assignmentStatus = status
        saveContext() // Save the context after updating the status
    }
    
    // MARK: - Verify Overdue Assignments
    /// Checks all assignments and marks overdue ones as `failed` if they are pending or in progress.
    func verifyAssignmentsOverDue() {
        let assignments: [Assignment] = fetchObject()
        for assignment in assignments {
            if (assignment.assignmentStatus == .pending || assignment.assignmentStatus == .inProgress),
               let assignmentDate = assignment.assignmentDate, assignmentDate < Date() {
                updateStatus(assignment: assignment, status: .failed)
            }
        }
    }
}
