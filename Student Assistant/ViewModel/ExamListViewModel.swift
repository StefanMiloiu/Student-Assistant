//
//  ExamListViewModel.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import Foundation
import MapKit

// MARK: - Observable object ExamListViewModel
class ExamListViewModel: ObservableObject {
    @Published var exams: [Exam] = []

    // init with Swinject
    private let examRepo: ExamRepo
    init(examRepo: ExamRepo = Injection.shared.container.resolve(ExamRepo.self)!) {
        self.examRepo = examRepo
    }

    // Populates the exams list with the objects
    func fetchExams() {
        self.exams.removeAll()
        self.exams = examRepo.fetchObject()
        sortExams()
    }

    // Sorts the exams list
    func sortExams() {
        exams.sort(by: {$0.examDate! < $1.examDate!})
    }

    // Function to add a new exam
    func addExam(subject: String, date: Date, location: String, locationCoordinates: CLLocationCoordinate2D) -> Bool {
        guard !subject.isEmpty,
              !location.isEmpty else { return false }
        let latitude = locationCoordinates.latitude
        let longitude = locationCoordinates.longitude
        _ = examRepo.addExam(subject: subject, date: date, location: location, latitude: latitude, longitude: longitude)
        self.fetchExams()
        return true
    }

    func fetchExam(day: Int, month: Int, year: Int) -> [Exam] {
        var dateComponents = DateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year

        let calendar = Calendar.current
        if let date = calendar.date(from: dateComponents) {
            // Remove the time component from both dates for comparison
            let dateWithoutTime = calendar.startOfDay(for: date)

            self.fetchExams()

            return self.exams.filter { exam in
                if let examDate = exam.examDate {
                    let examDateWithoutTime = calendar.startOfDay(for: examDate)
                    return examDateWithoutTime == dateWithoutTime
                }
                return false
            }
        } else {
            print("Invalid date.")
        }

        return []
    }

    func generateDate(day: Int, month: Int, year: Int, time: Date) -> Date? {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time) // Extract time components

        // Combine the date components (day, month, year) with the time components (hour, minute, second)
        var calendarComponents = DateComponents()
        calendarComponents.day = day
        calendarComponents.month = month
        calendarComponents.year = year
        calendarComponents.hour = timeComponents.hour
        calendarComponents.minute = timeComponents.minute

        return calendar.date(from: calendarComponents) // Generate the full date with time
    }

    func deleteAllExams() {
        examRepo.deleteAllExams()
        fetchExams()
    }

    func deleteExam(_ exam: Exam) {
        examRepo.deleteObject(object: exam)
        fetchExams()
    }

    func deletePastExams() {
        examRepo.deletePastExams()
    }
}
