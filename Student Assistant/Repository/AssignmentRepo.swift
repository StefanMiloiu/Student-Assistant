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
        assignment.assignmentGotDate = Date() // Current date when the assignment is created
        assignment.assignmentDate = dueDate
        assignment.assignmentStatus = .pending
        assignment.isSynced = false
        assignment.lastUpdated = Date() // Setting lastUpdated to the current date
        assignment.lastSynced = nil // Not synced yet

        saveContext() // Save the context after adding the assignment
    }

    func addAssignment(_ assignment: AssignmentFirebase) {
        let context = DataManager.shared.persistentContainer.viewContext
        let assignmentCoreData = Assignment(context: context)

        assignmentCoreData.assignmentID = assignment.assignmentID
        assignmentCoreData.assignmentTitle = assignment.assignmentTitle
        assignmentCoreData.assignmentDescription = assignment.assignmentDescription
        assignmentCoreData.assignmentGotDate = assignment.assignmentGotDate
        assignmentCoreData.assignmentStatus = assignment.assignmentStatus
        assignmentCoreData.assignmentDate = assignment.assignmentDate
        assignmentCoreData.isSynced = assignment.isSynced ?? false
        assignmentCoreData.lastUpdated = assignment.lastUpdated
        assignmentCoreData.lastSynced = assignment.lastSynced

        saveContext()
    }

    func fetchAssignmentByID(assignmentID: UUID) -> Assignment? {
        let context = dataManager.getContext()
        let request: NSFetchRequest<Assignment> = Assignment.fetchRequest()
        request.predicate = NSPredicate(format: "assignmentID == %@", assignmentID as CVarArg)

        do {
            return try context.fetch(request).first // Fetch the first matching assignment, if any
        } catch {
            print("Error fetching assignment by ID: \(error)")
            return nil
        }
    }

    // MARK: - Update Assignment Status
    /// Updates the status of a given `Assignment`.
    /// - Parameters:
    ///   - assignment: The `Assignment` object whose status needs to be updated.
    ///   - status: The new `Status` to set.
    func updateStatus(assignment: Assignment, status: Status) {
        assignment.assignmentStatus = status
        assignment.isSynced = false // Mark as unsynced on status change
        assignment.lastUpdated = Date() // Update lastUpdated to reflect the modification time

        saveContext() // Save the context after updating the status
    }

    // MARK: - Verify Overdue Assignments
    /// Checks all assignments and marks overdue ones as `failed` if they are pending or in progress.
    func verifyAssignmentsOverDue() {
        let assignments: [Assignment] = fetchObject()
        for assignment in assignments {
            if assignment.assignmentStatus == .pending || assignment.assignmentStatus == .inProgress,
               let assignmentDate = assignment.assignmentDate, assignmentDate < Date() {
                updateStatus(assignment: assignment, status: .failed)
            }
        }
    }
}
