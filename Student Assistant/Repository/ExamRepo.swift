//
//  ExamRepository.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import Foundation
import CoreData

struct ExamRepo: DataManagerProtocol {
    let dataManager: DataManagerProtocol
    
    init(dataManager: DataManagerProtocol = Injection.shared.container.resolve(DataManager.self)!) {
        self.dataManager = dataManager
    }
    
    
    func saveContext() {
        dataManager.saveContext()
    }
    
    func fetchObject<Exam>() -> [Exam] where Exam : NSManagedObject {
        deletePastExams()
        return dataManager.fetchObject()
    }
    
    func deleteObject<Exam>(object: Exam) where Exam : NSManagedObject {
        dataManager.deleteObject(object: object)
    }
    
    func getContext() -> NSManagedObjectContext {
        return dataManager.getContext()
    }
    
    func addExam(subject: String, date: Date, location: String) -> Bool {
        let context = dataManager.getContext()
        let exam = Exam(context: context)
        /* exam.setValue(UUID(), forKey: "examID")
         exam.setValue(subject, forKey: "examSubject")
         exam.setValue(date, forKey: "examDate")
         exam.setValue(location, forKey: "examLocation") */
        exam.examID = UUID()
        exam.examDate = date
        exam.examLocation = location
        exam.examSubject = subject
        saveContext()
        return true
    }
    
    func deleteAllExams() {
        dataManager.deleteObject(object: Exam())
    }
    
    func deletePastExams() {
        do {
            let context = dataManager.getContext()
            let request: NSFetchRequest<Exam> = Exam.fetchRequest()
            request.predicate = NSPredicate(format: "examDate < %@", Date() as CVarArg)
            let exams = try? context.fetch(request)
            exams?.forEach { context.delete($0) }
            try context.save()
            print("Successfully deleted all objects of type \(Exam.self).")
        } catch {
            print("Failed to fetch or delete objects: \(error.localizedDescription)")
        }
        
    }
    
    
}
