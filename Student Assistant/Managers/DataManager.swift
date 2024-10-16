//
//  DataManager.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import Foundation
import CoreData

protocol DataManagerProtocol {
    func saveContext()
    func fetchObject<T: NSManagedObject>() -> [T]
    func deleteObject<T: NSManagedObject>(object: T)
    func getContext() -> NSManagedObjectContext
}

class DataManager: DataManagerProtocol {
    static let shared = DataManager()
    public let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "StudentAssistant")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    // Save context
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Fetch all assignments
    func fetchObject<T: NSManagedObject>() -> [T] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            return []
        }
    }
    
    // Delete an assignment
    func deleteObject<T: NSManagedObject>(object: T) {
        let context = persistentContainer.viewContext
        context.delete(object)
        saveContext() // Save the context
    }
    
    func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func deleteAllObjects<T: NSManagedObject>(ofType type: T.Type, in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        
        do {
            let objects = try context.fetch(fetchRequest)
            
            // Delete all fetched objects
            objects.forEach { context.delete($0) }
            
            // Save the context to persist the changes
            try context.save()
            print("Successfully deleted all objects of type \(T.self).")
        } catch {
            print("Failed to fetch or delete objects: \(error.localizedDescription)")
        }
    }

}
