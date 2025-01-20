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
        let currentDate = self.startOfDay(for: Date())
        let lastWeek = self.date(byAdding: .day, value: -7, to: currentDate)!
        let targetDate = self.startOfDay(for: date)
        return targetDate >= lastWeek && targetDate <= currentDate
    }

    // MARK: - Last Month Check
    /// Checks if a given date is within the last month.
    /// - Parameter date: The date to check.
    /// - Returns: `true` if the date is within the last month, otherwise `false`.
    func isDateInLastMonth(_ date: Date) -> Bool {
        let currentDate = self.startOfDay(for: Date())
        let lastMonth = self.date(byAdding: .month, value: -1, to: currentDate)!
        let targetDate = self.startOfDay(for: date)
        return targetDate >= lastMonth && targetDate <= currentDate
    }

    // MARK: - Last Year Check
    /// Checks if a given date is within the last year.
    /// - Parameter date: The date to check.
    /// - Returns: `true` if the date is within the last year, otherwise `false`.
    func isDateInLastYear(_ date: Date) -> Bool {
        let currentDate = self.startOfDay(for: Date())
        let lastYear = self.date(byAdding: .year, value: -1, to: currentDate)!
        let targetDate = self.startOfDay(for: date)
        return targetDate >= lastYear && targetDate <= currentDate
    }
}
