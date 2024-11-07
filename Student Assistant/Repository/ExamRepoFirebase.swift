//
//  ExamRepoFirebase.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 07.11.2024.
//

import Foundation
import FirebaseFirestore

struct ExamRepoFirebase: FirebaseDataManagerProtocol {
    
    let firebaseDataManager: FirebaseDataManagerProtocol
    
    // MARK: - Initializer
    /// Initializes the repository with a data manager. Defaults to `DataManager.shared`.
    /// - Parameter dataManager: A `DataManagerProtocol` instance. Defaults to `DataManager.shared`.
    init(firebaseDataManager: FirebaseDataManagerProtocol = FirebaseDataManager()) {
        self.firebaseDataManager = firebaseDataManager
    }
    
    // MARK: - Save Document
    func saveDocument<ExamFirebase>(data: ExamFirebase,
                                    to collection: String = "exams",
                                    completion: @escaping (Result<Void, Error>) -> Void) where ExamFirebase: Encodable {
        firebaseDataManager.saveDocument(data: data, to: collection) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch Document by ID and Save
    func fetchAndSaveDocumentWithID<ExamFirebase>(data: ExamFirebase,
                                                  byField field: String,
                                                  ID: String,
                                                  completion: @escaping (Result<Void, Error>) -> Void) where ExamFirebase: Encodable {
        let collection = Firestore.firestore().collection("exams")
        
        collection.whereField(field, isEqualTo: ID).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let document = querySnapshot?.documents.first {
                let documentID = document.documentID
                do {
                    let encodedData = try Firestore.Encoder().encode(data)
                    collection.document(documentID).setData(encodedData) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                do {
                    let encodedData = try Firestore.Encoder().encode(data)
                    collection.document(ID).setData(encodedData) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Fetch Documents
    func fetchDocuments<ExamFirebase>(from collection: String = "exams",
                                      completion: @escaping (Result<[ExamFirebase], Error>) -> Void) where ExamFirebase: Decodable {
        firebaseDataManager.fetchDocuments(from: collection) { (result: Result<[ExamFirebase], Error>) in
            switch result {
            case .success(let exams):
                completion(.success(exams))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch Documents by Email
    func fetchDocumentsByEmail<ExamFirebase>(from collection: String = "exams",
                                             email: String,
                                             completion: @escaping (Result<[ExamFirebase], Error>) -> Void) where ExamFirebase: Decodable {
        firebaseDataManager.fetchDocumentsByEmail(from: collection, email: email) { (result: Result<[ExamFirebase], Error>) in
            switch result {
            case .success(let exams):
                completion(.success(exams))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Delete Document by ID
    func deleteDocument(from collection: String = "exams",
                        with documentID: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        firebaseDataManager.deleteDocument(from: collection, with: documentID) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteDocumentWithID(examID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let collection = db.collection("exams")
        
        collection.whereField("examID", isEqualTo: examID).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, !snapshot.documents.isEmpty else {
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                return
            }
            
            let batch = db.batch()
            snapshot.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            
            batch.commit { batchError in
                if let batchError = batchError {
                    completion(.failure(batchError))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
