//
//  TrackTime+CoreDataClass.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 15.10.2024.
//
//

import Foundation
import CoreData

@objc(TrackTime)
public class TrackTime: NSManagedObject {
    
    
    
    /** Calculates the total time spent studying and formats it as a string in `HH:mm:ss` format.
     This function takes the start and end times of the study session, calculates the time
     and returns it in a human-readable format with hours, minutes, and
     
     Returns: A formatted string representing the duration of the study session in `HH:mm:ss`.
     */
    
    func getStudiedTime() -> String? {
        if let start = self.trackTimeStart,
           let end = self.trackTimeEnd {
            let timeInterval = end.timeIntervalSince(start)
            
            // Convert time interval to hours, minutes, and seconds
            let hours = Int(timeInterval) / 3600
            let minutes = (Int(timeInterval) % 3600) / 60
            let seconds = Int(timeInterval) % 60
            
            let timeIntervalString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
            return timeIntervalString
        }
        return nil
    }
    
}
