//
//  TrackTimeListViewModel.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 15.10.2024.
//

import Foundation

/*
 ViewModel class responsible for managing the list of tracked time entries.
 This class interacts with the `TrackTimeRepo` repository to perform Core Data operations.
 It conforms to the `ObservableObject` protocol to allow views to observe changes.
*/
class TrackTimeListViewModel: ObservableObject {

    // MARK: - Properties
    /*
     Observed list of `TrackTime` items.
     This property is marked with `@Published`, so any updates to the list
     will notify the observing views.
    */
    @Published var times: [TrackTime] = []

    /*
     Repository for `TrackTime` Core Data operations.
    */
    let trackTimeRepo: TrackTimeRepo

    /*
     Initializes the `TrackTimeListViewModel` with a `TrackTimeRepo`.
     Uses dependency injection to resolve the repository instance from the shared `Injection` container.
     - Parameter trackTimeRepo: A repository for managing `TrackTime`, defaulting to the resolved instance from `Injection`.
    */
    init(trackTimeRepo: TrackTimeRepo = Injection.shared.container.resolve(TrackTimeRepo.self)!) {
        self.trackTimeRepo = trackTimeRepo
    }

    // MARK: - Methods
    /*
     Fetches all `TrackTime` entries from the repository.
     Populates the `times` array and then sorts them in ascending order based on the end time.
    */
    func fetchTimes() {
        self.times = trackTimeRepo.fetchObject()
        sortTimes()
    }

    /*
     Sorts the `TrackTime` entries by their end time.
     The entries are sorted in ascending order, meaning older entries come first.
    */
    func sortTimes() {
        self.times.sort(by: { $0.trackTimeEnd ?? Date() < $1.trackTimeEnd ?? Date() })
    }

    /*
     Starts tracking time for a given subject and start date.
     If the subject is empty, the function returns `false` indicating failure to start.
     - Parameters:
        - startDate: The date and time when tracking should start.
        - subject: The subject being tracked.
     - Returns: A `Bool` indicating whether the tracking was successfully started.
    */
    func startTimeTrack(startDate: Date, subject: String) -> Bool {
        guard subject != "" else { return false }

        trackTimeRepo.startTimeTrack(startDate: startDate, subject: subject)
        fetchTimes() // Refresh the list after adding a new entry
        return true
    }

    /*
     Stops the ongoing time tracking session.
     Sets the end time and optionally adds notes to the tracked session.
     - Parameters:
        - endDate: The date and time when tracking should stop.
        - notes: Optional notes about the session.
    */
    func stopTimeTrack(endDate: Date, notes: String? = nil) {
        trackTimeRepo.endTimeTrack(endDate: endDate, notes: notes)
        fetchTimes() // Refresh the list after updating the entry
    }

    /*
     Fetches the currently active `TrackTime` object.
     - Returns: An optional `TrackTime` object, or `nil` if no session is active.
    */
    func fetchStartedTimes() -> TrackTime? {
        return trackTimeRepo.fetchStartedTrackTime()
    }

    /*
     Fetches the time and trsnforms it into a String.
     - Returns: An optional `String` object, "10:10:10" or nil if no object found
     */
    func fetchStopWatchTimes() -> String? {
        let time = fetchStartedTimes()
        if let time {
            let currentDifference = Date().timeIntervalSince((time.trackTimeStart)!)
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = .pad
            return formatter.string(from: TimeInterval(currentDifference))
        }
        return nil
    }

    /*
     Deletes started time traking session
     */
    func deleteStartedSession() {
        guard let time = fetchStartedTimes() else { return }
        trackTimeRepo.deleteObject(object: time)
    }

}
