//
//  AssignmentFirebase.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 24.10.2024.
//

import Foundation

struct AssignmentFirebase: Codable {
    init(assignmentID: UUID? = nil, assignmentEmail: String? = nil, assignmentTitle: String? = nil, assignmentDescription: String? = nil,
         assignmentGotDate: Date? = nil, assignmentDate: Date? = nil, assignmentStatus: Status, lastUpdated: Date? = nil, lastSynced: Date? = nil, isSynced: Bool? = nil) {
        self.assignmentID = assignmentID
        self.assignmentEmail = assignmentEmail
        self.assignmentTitle = assignmentTitle
        self.assignmentDescription = assignmentDescription
        self.assignmentGotDate = assignmentGotDate
        self.assignmentDate = assignmentDate
        self.assignmentStatus = assignmentStatus
        self.lastUpdated = lastUpdated
        self.lastSynced = lastSynced
        self.isSynced = isSynced
    }

    init(from assignment: Assignment) throws {
        self.assignmentID = assignment.assignmentID
        self.assignmentEmail = UserDefaults().userName
        self.assignmentTitle = assignment.assignmentTitle
        self.assignmentDescription = assignment.assignmentDescription
        self.assignmentGotDate = assignment.assignmentGotDate
        self.assignmentDate = assignment.assignmentDate
        self.assignmentStatus = assignment.assignmentStatus
        self.lastUpdated = assignment.lastUpdated
        self.lastSynced = assignment.lastSynced
        self.isSynced = assignment.isSynced
    }

    public var assignmentID: UUID?
    public var assignmentEmail: String?
    public var assignmentTitle: String?
    public var assignmentDescription: String?
    public var assignmentGotDate: Date?
    public var assignmentDate: Date?
    public var assignmentStatus: Status
    public var lastUpdated: Date?
    public var lastSynced: Date?
    public var isSynced: Bool?

    // MARK: - Overdue Check
    /// Checks if the assignment is overdue.
    /// - Returns: `true` if the assignment is overdue and still in progress or pending, otherwise `false`.
    func checkIfOverdue() -> Bool {
        guard assignmentDate != nil else { return false }
        return self.assignmentDate!.timeIntervalSinceNow < 0 && (self.assignmentStatus == .inProgress || self.assignmentStatus == .pending)
    }

    // MARK: - Failed Check
    /// Checks if the assignment is marked as failed.
    /// - Returns: `true` if the assignment has failed status, otherwise `false`.
    func checkIfFailed() -> Bool {
        return self.assignmentStatus == .failed
    }

    // MARK: - Completed Check
    /// Checks if the assignment is completed.
    /// - Returns: `true` if the assignment has completed status, otherwise `false`.
    func checkIfCompleted() -> Bool {
        return self.assignmentStatus == .completed
    }

    // MARK: - Time Formatter
    /// Formats the `assignmentDate` into a time string (HH:mm).
    /// - Returns: A string representing the time in "HH:mm" format.
    func getTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self.assignmentDate!)
    }
}
