//
//  AssignmentRepo.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import Foundation
import CoreData

struct AssignmentRepo: DataManagerProtocol {
    
    let dataManager: DataManagerProtocol
    
    init(dataManager: DataManagerProtocol = DataManager.shared) {
        self.dataManager = dataManager
    }
    
    func saveContext() {
        dataManager.saveContext()
    }
    
    func fetchObject<Assignment>() -> [Assignment] where Assignment : NSManagedObject {
        return dataManager.fetchObject()
    }
    
    func deleteObject<Assignment>(object: Assignment) where Assignment : NSManagedObject {
        dataManager.deleteObject(object: object)
    }
    
    func getContext() -> NSManagedObjectContext {
        return dataManager.getContext()
    }
    // Add a new assignment
    func addAssignment(title: String, description: String, dueDate: Date) {
        let context = DataManager.shared.persistentContainer.viewContext
        let assignment = Assignment(context: context)
        assignment.assignmentID = UUID()
        assignment.assignmentTitle = title
        assignment.assignmentDescription = description
        assignment.assignmentDate = dueDate
        assignment.assignmentStatus = .pending
        saveContext() // Save the context
    }
    
    func updateStatus(assignment: Assignment, status: Status){
        assignment.assignmentStatus = status
        saveContext()
    }
    
    
}
