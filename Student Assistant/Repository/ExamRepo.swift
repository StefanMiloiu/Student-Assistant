//
//  ExamRepository.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import Foundation
import CoreData

// MARK: - Exam Repository
/// `ExamRepo` handles exam-related data operations such as adding, fetching, deleting, and updating exams.
/// It conforms to `DataManagerProtocol` to interact with Core Data.
struct ExamRepo: DataManagerProtocol {
    let dataManager: DataManagerProtocol

    // MARK: - Initializer
    /// Initializes the repository with a data manager. Defaults to the resolved `DataManager` instance from the dependency injection container.
    /// - Parameter dataManager: A `DataManagerProtocol` instance. Defaults to the injected `DataManager`.
    init(dataManager: DataManagerProtocol = DataManager.shared) {
        self.dataManager = dataManager
    }

    // MARK: - Context Management
    /// Saves the Core Data context using the `DataManager`.
    func saveContext() {
        dataManager.saveContext()
    }

    // MARK: - Fetch Exams
    /// Fetches all `Exam` objects from Core Data after deleting past exams.
    /// - Returns: An array of fetched `Exam` objects.
    func fetchObject<Exam>() -> [Exam] where Exam: NSManagedObject {
        deletePastExams() // Clean up past exams before fetching
        return dataManager.fetchObject()
    }
    
    func fetchExamByID(id: UUID) -> Exam? {
        let context = dataManager.getContext()
        let request: NSFetchRequest<Exam> = Exam.fetchRequest()
        request.predicate = NSPredicate(format: "examID == %@", id as CVarArg)
        
        do {
            return try context.fetch(request).first! // Fetch the first matching assignment, if any
        } catch {
            print("Error fetching assignment by ID: \(error)")
            return nil
        }
    }

    // MARK: - Delete Exam
    /// Deletes a specified `Exam` object from Core Data.
    /// - Parameter object: The `Exam` object to delete.
    func deleteObject<Exam>(object: Exam) where Exam: NSManagedObject {
        dataManager.deleteObject(object: object)
    }

    /// Returns the current Core Data context.
    func getContext() -> NSManagedObjectContext {
        return dataManager.getContext()
    }

    // MARK: - Add Exam
    /// Adds a new `Exam` object to Core Data.
    /// - Parameters:
    ///   - subject: The subject of the exam.
    ///   - date: The date of the exam.
    ///   - location: The location of the exam.
    /// - Returns: A boolean value indicating whether the exam was successfully added.
    func addExam(subject: String, date: Date, location: String, latitude: Double, longitude: Double) -> Bool {
        let context = dataManager.getContext()
        let exam = Exam(context: context)

        // Set the values for the exam
        exam.examID = UUID()
        exam.examDate = date
        exam.examLocation = location
        exam.examSubject = subject
        exam.examLatitude = latitude
        exam.examLongitude = longitude
        exam.lastSynced = nil
        exam.lastUpdated = Date()
        exam.isSynced = false
        exam.isRemoved = false

        saveContext() // Save the context after adding the exam
        return true
    }

    // MARK: - Delete All Exams
    /// Deletes all `Exam` objects from Core Data.
    func deleteAllExams() {
        dataManager.deleteObject(object: Exam())
    }

    // MARK: - Delete Past Exams
    /// Deletes all exams that have already passed (exam date is earlier than the current date).
    func deletePastExams() {
        do {
            let context = dataManager.getContext()
            let request: NSFetchRequest<Exam> = Exam.fetchRequest()

            // Set the predicate to fetch only past exams
            request.predicate = NSPredicate(format: "examDate < %@", Date() as CVarArg)
            let exams = try? context.fetch(request)

            // Delete each past exam
            exams?.forEach { context.delete($0) }
            try context.save()
        } catch {
            print("Failed to fetch or delete objects: \(error.localizedDescription)")
        }
    }
}
