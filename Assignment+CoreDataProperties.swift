//
//  Assignment+CoreDataProperties.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//
//

import Foundation
import CoreData

extension Assignment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assignment> {
        return NSFetchRequest<Assignment>(entityName: "Assignment")
    }

}

extension Assignment: Identifiable {

}
