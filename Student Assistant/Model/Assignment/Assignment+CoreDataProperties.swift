//
//  Assignment+CoreDataProperties.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//
//

import Foundation
import CoreData
import SwiftUICore

@objc public enum Status: Int16, Codable {
    case pending = 0
    case inProgress = 1
    case completed = 2
    case failed = 3
    
    func toString() -> String {
        switch self {
        case .pending:
            return "Not started"
        case .completed:
            return "Completed"
        case .failed:
            return "Failed"
        case .inProgress:
            return "InProgress"
        }
    }
    
    func getColor() -> Color {
        switch self {
        case .pending:
            return Color(red: 0.24, green: 0.67, blue: 0.97) // Color using RGB
        case .completed:
            return Color(red: 0.34, green: 0.62, blue: 0.17) // Color using RGB
        case .failed:
            return Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.66) // Semi-transparent red
        case .inProgress:
            return Color(red: 0.97, green: 0.78, blue: 0.35) // Color using RGB
        }
    }
}


extension Assignment {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assignment> {
        return NSFetchRequest<Assignment>(entityName: "Assignment")
    }
    
    @NSManaged public var assignmentID: UUID?
    @NSManaged public var assignmentTitle: String?
    @NSManaged public var assignmentDescription: String?
    @NSManaged public var assignmentGotDate: Date?
    @NSManaged public var assignmentDate: Date?
    @NSManaged public var assignmentStatus: Status
    @NSManaged public var isSynced: Bool
    @NSManaged public var lastSynced: Date?
    @NSManaged public var lastUpdated: Date?
}

extension Assignment : Identifiable {
    
}
