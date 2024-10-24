//
//  Exam+CoreDataProperties.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//
//

import Foundation
import CoreData


extension Exam {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exam> {
        return NSFetchRequest<Exam>(entityName: "Exam")
    }

    @NSManaged public var examSubject: String?
    @NSManaged public var examID: UUID?
    @NSManaged public var examDate: Date?
    @NSManaged public var examLocation: String?

}

extension Exam : Identifiable {

}
