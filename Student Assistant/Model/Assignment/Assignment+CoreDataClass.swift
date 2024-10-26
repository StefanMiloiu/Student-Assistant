//
//  Assignment+CoreDataClass.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//
//

import Foundation
import CoreData

// MARK: - Assignment Class
/// `Assignment` is a Core Data class that represents an assignment entity with custom helper methods for checking status and formatting the assignment date.
@objc(Assignment)
public class Assignment: NSManagedObject {
    
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
        return dateFormatter.string(from: self.assignmentDate ?? Date())
    }
    
    //MARK: - Sync need check
    /// - Returns: `true` if needs sync, otherwise `false`
    func needsSync() -> Bool {
        guard let lastSynced = self.lastSynced else { return true } // If never synced, needs sync
        return self.lastUpdated ?? Date() > lastSynced
    }
}
