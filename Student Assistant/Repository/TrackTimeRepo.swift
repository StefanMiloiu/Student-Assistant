//  TrackTimeRepo.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 15.10.2024.
//

import Foundation
import CoreData

/*
 A repository struct that manages `TrackTime` Core Data operations.
 This struct conforms to the `DataManagerProtocol` and uses a dependency injection approach
 to access the Core Data manager. It provides methods to save, fetch, and delete data,
 while interacting with the Core Data context.
*/
struct TrackTimeRepo: DataManagerProtocol {

    // MARK: - Properties
    /*
     The data manager responsible for Core Data operations.
    */
    let dataManager: DataManagerProtocol

    /*
     Initializes the repository with a default `DataManager` using dependency injection.
     - Parameter dataManager: A `DataManagerProtocol` implementation, defaulting to the resolved `DataManager` from the injection container.
    */
    init(dataManager: DataManagerProtocol = Injection.shared.container.resolve(DataManager.self)!) {
        self.dataManager = dataManager
    }

    // MARK: - Core Data Operations
    /*
     Saves changes to the Core Data context.
     This method ensures any changes made to the Core Data objects are persisted to the database.
    */
    func saveContext() {
        dataManager.saveContext()
    }

    /*
     Fetches objects of type `TrackTime` from Core Data.
     - Returns: An array of `TrackTime` objects.
    */
    func fetchObject<TrackTime>() -> [TrackTime] where TrackTime: NSManagedObject {
        dataManager.fetchObject()
    }

    /*
     Deletes a specified `TrackTime` object from Core Data.
     - Parameter object: The `TrackTime` object to delete.
    */
    func deleteObject<TrackTime>(object: TrackTime) where TrackTime: NSManagedObject {
        dataManager.deleteObject(object: object)
    }

    /*
     Retrieves the current Core Data context.
     - Returns: The `NSManagedObjectContext` instance for interacting with Core Data.
    */
    func getContext() -> NSManagedObjectContext {
        dataManager.getContext()
    }

    /*
     Starts tracking time for a specific subject.
     This function creates a new `TrackTime` object in the context, sets a unique ID,
     and assigns the start date and subject.
     - Parameters:
        - startDate: The date and time when the tracking starts.
        - subject: The subject being studied.
    */
    func startTimeTrack(startDate: Date, subject: String) {
        let context = getContext()
        let trackTime = TrackTime(context: context)
        trackTime.trackTimeID = UUID()
        trackTime.trackTimeStart = startDate
        trackTime.trackTimeSubject = subject

        // Save the newly created tracking object
        saveContext()
    }

    /*
     Ends the current tracking session.
     This function fetches the last started `TrackTime` object and assigns the end date and any notes provided.
     - Parameters:
        - endDate: The date and time when the tracking ends.
        - notes: Optional notes about the study session.
    */
    func endTimeTrack(endDate: Date, notes: String? = nil) {
        let trackTime: TrackTime = fetchObject().last!
        trackTime.trackTimeEnd = endDate
        trackTime.trackTimeNotes = notes

        // Save the updates to the tracking object
        saveContext()
    }

    /*
     Fetches the currently active `TrackTime` object.
     This method looks for any `TrackTime` object where the `trackTimeEnd` is still `nil`,
     meaning the session hasn't been completed yet.
     - Returns: An optional `TrackTime` object, or `nil` if no session is active.
    */
    func fetchStartedTrackTime() -> TrackTime? {
        if let timer: TrackTime = fetchObject().filter( {$0.trackTimeEnd == nil}).first {
            return timer
        }
        return nil
    }

}
