//
//  AssignmentFirebase.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 24.10.2024.
//

import Foundation

struct AssignmentFirebase: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.assignmentID = try container.decodeIfPresent(UUID.self, forKey: .assignmentID)
        self.assignmentEmail = try container.decodeIfPresent(String.self, forKey: .assignmentEmail)
        self.assignmentTitle = try container.decodeIfPresent(String.self, forKey: .assignmentTitle)
        self.assignmentDescription = try container.decodeIfPresent(String.self, forKey: .assignmentDescription)
        self.assignmentGotDate = try container.decodeIfPresent(Date.self, forKey: .assignmentGotDate)
        self.assignmentDate = try container.decodeIfPresent(Date.self, forKey: .assignmentDate)
        self.assignmentStatus = try container.decode(Status.self, forKey: .assignmentStatus)
        self.lastUpdated = try container.decodeIfPresent(Date.self, forKey: .lastUpdated)
        self.lastSynced = try container.decodeIfPresent(Date.self, forKey: .lastSynced)
        self.isSynced = try container.decodeIfPresent(Bool.self, forKey: .isSynced)
        self.isRemoved = try container.decodeIfPresent(Bool.self, forKey: .isRemoved)
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
        self.isRemoved = assignment.isRemoved
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
    public var isRemoved: Bool?

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
