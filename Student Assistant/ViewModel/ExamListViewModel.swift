//
//  ExamListViewModel.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import Foundation
import MapKit
import SwiftUI

// MARK: - Observable object ExamListViewModel
class ExamListViewModel: ObservableObject {
    @Published var exams: [Exam] = []
    
    // Repositories and SyncManager
    private let examRepo: ExamRepo
    private let syncManager: SyncManager
    
    // MARK: - Initializer
    /// Initializes the ExamListViewModel with dependencies.
    /// - Parameters:
    ///   - examRepo: Repository for managing exams in Core Data.
    ///   - syncManager: Manager for handling synchronization between Firebase and Core Data.
    init(examRepo: ExamRepo = Injection.shared.container.resolve(ExamRepo.self)!,
         syncManager: SyncManager = SyncManager()) {
        self.examRepo = examRepo
        self.syncManager = syncManager
        fetchExams() // Fetch initial exams from Core Data
    }
    
    // MARK: - Sync Exams
    /// Synchronizes exams between Firebase and Core Data.
    func syncExams() {
        syncManager.syncExams { [weak self] result in
            if result {
                self?.fetchExams() // Refresh local exams after sync
            }
        }
    }
    
    // MARK: - Fetch Exams
    /// Populates the exams list with the objects from Core Data.
    func fetchExams() {
        self.exams.removeAll()
        self.exams = examRepo.fetchObject()
        sortExams()
    }
    
    // MARK: - Sort Exams
    /// Sorts the exams list by date.
    func sortExams() {
        exams.sort(by: { $0.examDate! < $1.examDate! })
    }
    
    // MARK: - Add Exam
    /// Adds a new exam to Core Data and initiates synchronization.
    /// - Parameters:
    ///   - subject: The subject of the exam.
    ///   - date: The date and time of the exam.
    ///   - location: The location of the exam.
    ///   - locationCoordinates: The latitude and longitude of the exam location.
    /// - Returns: `true` if the exam was added successfully, `false` otherwise.
    func addExam(subject: String, date: Date, location: String, locationCoordinates: CLLocationCoordinate2D) -> Bool {
        guard !subject.isEmpty, !location.isEmpty else { return false }
        
        let latitude = locationCoordinates.latitude
        let longitude = locationCoordinates.longitude
        _ = examRepo.addExam(subject: subject, date: date, location: location, latitude: latitude, longitude: longitude)
        
        fetchExams() // Refresh local list
        syncExams() // Sync with Firebase
        return true
    }
    
    // MARK: - Fetch Exam by Date
    /// Fetches exams for a specific date.
    /// - Parameters:
    ///   - day: The day of the date.
    ///   - month: The month of the date.
    ///   - year: The year of the date.
    /// - Returns: An array of exams scheduled on the specified date.
    func fetchExam(day: Int, month: Int, year: Int) -> [Exam] {
        var dateComponents = DateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        
        let calendar = Calendar.current
        if let date = calendar.date(from: dateComponents) {
            let dateWithoutTime = calendar.startOfDay(for: date)
            fetchExams() // Refresh local list
            
            return exams.filter { exam in
                if let examDate = exam.examDate {
                    let examDateWithoutTime = calendar.startOfDay(for: examDate)
                    return examDateWithoutTime == dateWithoutTime
                }
                return false
            }
        } else {
            print("Invalid date.")
            return []
        }
    }
    
    // MARK: - Generate Date with Time
    /// Generates a full date with specific day, month, year, and time.
    /// - Parameters:
    ///   - day: The day of the date.
    ///   - month: The month of the date.
    ///   - year: The year of the date.
    ///   - time: The time for the date.
    /// - Returns: A `Date` object with the specified date and time.
    func generateDate(day: Int, month: Int, year: Int, time: Date) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        components.hour = calendar.component(.hour, from: time)
        components.minute = calendar.component(.minute, from: time)
        
        return calendar.date(from: components)
    }
    
    // MARK: - Delete Exams
    /// Deletes all exams from Core Data and refreshes the local list.
    func deleteAllExams() {
        examRepo.deleteAllExams()
        fetchExams()
    }
    
    /// Deletes a specific exam from Core Data and refreshes the local list.
    /// - Parameter exam: The `Exam` object to be deleted.
    func deleteExam(_ exam: Exam) {
        var examToBeSaved = ExamFirebase(from: exam)
        examToBeSaved.isRemoved = true
        ExamRepoFirebase().fetchAndSaveDocumentWithID(data: examToBeSaved,
                                                      byField: "examID",
                                                      ID: examToBeSaved.examID?.uuidString ?? "Invali ID" ) { [weak self] Result in
            self?.examRepo.deleteObject(object: exam)
            self?.fetchExams()
        }
        syncManager.syncExams { [weak self] result in
            if result {
                self?.fetchExams()
            }
        }
    }
    
    /// Deletes all past exams from Core Data.
    func deletePastExams() {
        examRepo.deletePastExams()
    }
}
