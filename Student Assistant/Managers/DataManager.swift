//
//  DataManager.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import Foundation
import CoreData

// MARK: - DataManager Protocol
/// Protocol defining the methods for Core Data management.
protocol DataManagerProtocol {
    func saveContext()
    func fetchObject<T: NSManagedObject>() -> [T]
    func deleteObject<T: NSManagedObject>(object: T)
    func getContext() -> NSManagedObjectContext
}

// MARK: - DataManager Class
/// Singleton class for managing Core Data operations.
class DataManager: DataManagerProtocol {
    // MARK: - Singleton Instance
    static let shared = DataManager()
    // MARK: - Core Data Stack
    public let persistentContainer: NSPersistentContainer
    // MARK: - Initialization
    /// Private initializer to create the persistent container and load stores.
    private init() {
        persistentContainer = NSPersistentContainer(name: "StudentAssistant")
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    // MARK: - Core Data Save
    /// Saves the current context if there are any changes.
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

    // MARK: - Fetch Objects
    /// Generic method to fetch all objects of a specific NSManagedObject type.
    /// - Returns: Array of fetched objects of type T.
    func fetchObject<T: NSManagedObject>() -> [T] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as? NSFetchRequest<T> ?? NSFetchRequest<T>()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Delete Object
    /// Deletes a given object from the context.
    /// - Parameter object: The NSManagedObject to be deleted.
    func deleteObject<T: NSManagedObject>(object: T) {
        let context = persistentContainer.viewContext
        context.delete(object)
        saveContext() // Save the context
    }

    // MARK: - Get Context
    /// Provides access to the NSManagedObjectContext.
    /// - Returns: The current view context.
    func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Delete All Objects
    /// Deletes all objects of a specific NSManagedObject type from the context.
    /// - Parameters:
    ///   - type: The NSManagedObject type to delete.
    ///   - context: The context in which the deletion will occur.
    func deleteAllObjects<T: NSManagedObject>(ofType type: T.Type, in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as? NSFetchRequest<T> ?? NSFetchRequest<T>()

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
