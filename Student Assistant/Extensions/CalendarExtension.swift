//
//  CalendarExtension.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 16.10.2024.
//

import Foundation

// MARK: - Calendar Extension
/// This extension adds utility methods to the `Calendar` type for date comparisons.
extension Calendar {
    
    // MARK: - Last Week Check
    /// Checks if a given date is within the last 7 days.
    /// - Parameter date: The date to check.
    /// - Returns: `true` if the date is within the last 7 days, otherwise `false`.
    func isDateInLastWeek(_ date: Date) -> Bool {
        guard let lastWeek = self.date(byAdding: .day, value: -7, to: Date()) else { return false }
        return date >= lastWeek && date <= Date()
    }
    
    // MARK: - Last Month Check
    /// Checks if a given date is within the last month.
    /// - Parameter date: The date to check.
    /// - Returns: `true` if the date is within the last month, otherwise `false`.
    func isDateInLastMonth(_ date: Date) -> Bool {
        guard let lastMonth = self.date(byAdding: .month, value: -1, to: Date()) else { return false }
        return date >= lastMonth && date <= Date()
    }
    
    // MARK: - Last Year Check
    /// Checks if a given date is within the last year.
    /// - Parameter date: The date to check.
    /// - Returns: `true` if the date is within the last year, otherwise `false`.
    func isDateInLastYear(_ date: Date) -> Bool {
        guard let lastYear = self.date(byAdding: .year, value: -1, to: Date()) else { return false }
        return date >= lastYear && date <= Date()
    }
}
