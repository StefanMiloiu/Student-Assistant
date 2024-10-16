//
//  TrackTime+CoreDataProperties.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 15.10.2024.
//
//

import Foundation
import CoreData


extension TrackTime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackTime> {
        return NSFetchRequest<TrackTime>(entityName: "TrackTime")
    }

    @NSManaged public var trackTimeID: UUID?
    @NSManaged public var trackTimeStart: Date?
    @NSManaged public var trackTimeEnd: Date?
    @NSManaged public var trackTimeSubject: String?
    @NSManaged public var trackTimeNotes: String?

}

extension TrackTime : Identifiable {

}
