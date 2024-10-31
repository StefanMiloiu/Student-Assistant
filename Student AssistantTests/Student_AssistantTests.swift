//
//  Student_AssistantTests.swift
//  Student AssistantTests
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import XCTest
@testable import Student_Assistant
import CoreData

final class StudentAssistantTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        // Setup Core Data stack for testing
        let persistentContainer = NSPersistentContainer(name: "StudentAssistant")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
        context = persistentContainer.viewContext
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    func testAssignmentCreation() {
        let assignment = Assignment(context: context)
        assignment.assignmentID = UUID()
        assignment.assignmentTitle = "Math Homework"
        assignment.assignmentDescription = "Complete exercises from chapter 3"
        assignment.assignmentDate = Date()
        assignment.assignmentStatus = .pending

        XCTAssertNotNil(assignment.assignmentID)
        XCTAssertEqual(assignment.assignmentTitle, "Math Homework")
        XCTAssertEqual(assignment.assignmentDescription, "Complete exercises from chapter 3")
        XCTAssertEqual(assignment.assignmentStatus, .pending)
    }

    func testCheckIfCompleted() {
        let assignment = Assignment(context: context)
        assignment.assignmentStatus = .completed
        XCTAssertTrue(assignment.checkIfCompleted())
    }

    func testCheckIfOverdue() {
        let assignment = Assignment(context: context)
        assignment.assignmentStatus = .inProgress
        assignment.assignmentDate = Date().addingTimeInterval(-86400) // 1 day in the past
        XCTAssertTrue(assignment.checkIfOverdue())
    }

    func testCheckIfNotOverdue() {
        let assignment = Assignment(context: context)
        assignment.assignmentStatus = .pending
        assignment.assignmentDate = Date().addingTimeInterval(86400) // 1 day in the future
        XCTAssertFalse(assignment.checkIfOverdue())
    }

    func testFirebaseRepo() {
        let repo = AssignmentRepoFirebase()
        repo.fetchDocumentsByEmail(email: "miloius@yahoo.com") { (result: Result<[AssignmentFirebase], Error>) in
            print(result)
        }

        repo.fetchDocuments(from: "assignments") { (result: Result<[AssignmentFirebase], Error>) in
            print("Result: \(result)")
        }
    }
}
