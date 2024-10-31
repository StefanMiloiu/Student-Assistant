//
//  Date+Utils.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 31.10.2024.
//

import Foundation

extension Date {
    static func getPercentageDone(_ assignment: Assignment) -> Float {
        // Get the starting and ending dates as time intervals since 1970
        guard let startingDate = assignment.assignmentGotDate?.timeIntervalSince1970,
              let endingDate = assignment.assignmentDate?.timeIntervalSince1970 else {
            return 0.0 // Return 0 if dates are not available
        }
        
        // Current date as time interval since 1970
        let currentDate = Date().timeIntervalSince1970
        
        // Calculate the total duration of the assignment
        let totalDuration = endingDate - startingDate
        
        // Calculate the elapsed time from the starting date to the current date
        let elapsedTime = currentDate - startingDate
        
        // Calculate the percentage done
        let percentage = totalDuration > 0 ? (elapsedTime / totalDuration) : 0.0
        
        // Ensure the percentage is clamped between 0 and 1
        return max(0.0, min(1.0, Float(percentage)))
    }
}
