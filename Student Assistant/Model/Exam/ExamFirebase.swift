//
//  ExamFirebase.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 07.11.2024.
//

import Foundation

struct ExamFirebase: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.examID = try container.decodeIfPresent(UUID.self, forKey: .examID)
        self.examEmail = try container.decodeIfPresent(String.self, forKey: .examEmail)
        self.examDate = try container.decodeIfPresent(Date.self, forKey: .examDate)
        self.examSubject = try container.decodeIfPresent(String.self, forKey: .examSubject)
        self.examLocation = try container.decodeIfPresent(String.self, forKey: .examLocation)
        self.examLatitude = try container.decodeIfPresent(Double.self, forKey: .examLatitude)
        self.examLongitude = try container.decodeIfPresent(Double.self, forKey: .examLongitude)
        self.lastUpdated = try container.decodeIfPresent(Date.self, forKey: .lastUpdated)
        self.lastSynced = try container.decodeIfPresent(Date.self, forKey: .lastSynced)
        self.isSynced = try container.decodeIfPresent(Bool.self, forKey: .isSynced)
        self.isRemoved = try container.decodeIfPresent(Bool.self, forKey: .isRemoved)
    }
    
    init(from exam: Exam) {
        self.examID = exam.examID
        self.examEmail = UserDefaults().userName
        self.examSubject = exam.examSubject
        self.examDate = exam.examDate
        self.examLocation = exam.examLocation
        self.examLatitude = exam.examLatitude
        self.examLongitude = exam.examLongitude
        self.lastUpdated = exam.lastUpdated
        self.lastSynced = exam.lastSynced
        self.isSynced = exam.isSynced
        self.isRemoved = exam.isRemoved
    }
    
    public var examID: UUID?
    public var examEmail: String?
    public var examDate: Date?
    public var examSubject: String?
    public var examLocation: String?
    public var examLatitude: Double?
    public var examLongitude: Double?
    public var lastUpdated: Date?
    public var lastSynced: Date?
    public var isSynced: Bool?
    public var isRemoved: Bool?
    
    // MARK: - Time Formatter
    /// Formats the `examDate` into a date and time string.
    /// - Returns: A string representing the date in "dd MMM yyyy, HH:mm" format.
    func getFormattedDateTime() -> String {
        guard let date = self.examDate else { return "No Date" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Location Check
    /// Checks if the location is set (both latitude and longitude are present).
    /// - Returns: `true` if both latitude and longitude are set, otherwise `false`.
    func isLocationSet() -> Bool {
        return examLatitude != nil && examLongitude != nil
    }
    
}
