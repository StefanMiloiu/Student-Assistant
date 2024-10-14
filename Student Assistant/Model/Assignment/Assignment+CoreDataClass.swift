//
//  Assignment+CoreDataClass.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//
//

import Foundation
import CoreData

@objc(Assignment)
public class Assignment: NSManagedObject {
    
    
    func checkIfOverdue() -> Bool {
        guard assignmentDate != nil else { return false }
        return self.assignmentDate!.timeIntervalSinceNow < 0 && (self.assignmentStatus == .inProgress || self.assignmentStatus == .pending)
    }
    
    func checkIfCompleted() -> Bool {
        return self.assignmentStatus == .completed
    }
    
    func getTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self.assignmentDate!)
    }
    
    
}
