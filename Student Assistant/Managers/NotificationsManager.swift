//
//  NotificationsManager.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 07.11.2024.
//

import Foundation
import UserNotifications

final class NotificationsManager {
    static func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Permission granted")
            } else if let error = error {
                print("Permission denied: \(error.localizedDescription)")
            }
        }
    }
    
    static func scheduleNotification(for assignment: Assignment) {
        let content = UNMutableNotificationContent()
        content.title = "Assignment Reminder"
        content.body = "The assignment \"\(assignment.assignmentTitle ?? "Title")\" is due in 24 hours."
        content.sound = .default
        
        // Calculate trigger date (24 hours before due date)
        if let dueDate = assignment.assignmentDate,
           let triggerDate = Calendar.current.date(byAdding: .hour, value: -24, to: dueDate) {
            print(triggerDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
            
            // Use the assignment's unique identifier to manage this notification
            let request = UNNotificationRequest(identifier: assignment.assignmentID!.uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    static func cancelNotification(for assignmentID: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [assignmentID])
    }
}


