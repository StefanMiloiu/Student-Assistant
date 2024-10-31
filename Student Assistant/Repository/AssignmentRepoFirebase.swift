//
//  AssignmentRepoFirebase.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 24.10.2024.
//

import Foundation
import FirebaseFirestore

struct AssignmentRepoFirebase: FirebaseDataManagerProtocol {

    let firebaseDataManager: FirebaseDataManagerProtocol
    var testLeaks: Bool = false

    // MARK: - Initializer
    /// Initializes the repository with a data manager. Defaults to `DataManager.shared`.
    /// - Parameter dataManager: A `DataManagerProtocol` instance. Defaults to `DataManager.shared`.
    init(firebaseDataManager: FirebaseDataManagerProtocol = FirebaseDataManager()) {
        self.firebaseDataManager = firebaseDataManager
    }

    func saveDocument<AssignmentFirebase>(data: AssignmentFirebase,
                                          to collection: String = "",
                                          completion: @escaping (Result<Void, any Error>) -> Void) where AssignmentFirebase: Encodable {
        firebaseDataManager.saveDocument(data: data, to: "assignments") { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchAndSaveDocumentWithID<AssignmentFirebase>(data: AssignmentFirebase,
                                                        byField field: String,
                                                        ID: String,
                                                        completion: @escaping (Result<Void, Error>) -> Void) where AssignmentFirebase: Encodable {
        let collection = Firestore.firestore().collection("assignments")

        // Query Firestore for documents with the specified field and value
        collection.whereField(field, isEqualTo: ID).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Check if any documents match the query
            if let document = querySnapshot?.documents.first {
                // Document exists, update it
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
                // Document does not exist, create a new one with the specified ID
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
    func fetchDocuments<AssignmentFirebase>(from collection: String = "",
                                            completion: @escaping (Result<[AssignmentFirebase], Error>) -> Void) where AssignmentFirebase: Decodable {
        firebaseDataManager.fetchDocuments(from: "assignments") { (result: Result<[AssignmentFirebase], Error>) in
            switch result {
            case .success(let assignments):
                completion(.success(assignments))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Fetch only documents for a specific email
    func fetchDocumentsByEmail<AssignmentFirebase>(from collection: String = "",
                                                   email: String,
                                                   completion: @escaping (Result<[AssignmentFirebase], Error>) -> Void) where AssignmentFirebase: Decodable {
        firebaseDataManager.fetchDocumentsByEmail(from: "assignments",
                                                  email: email) { (result: Result<[AssignmentFirebase], Error>) in
            switch result {
            case .success(let assignments):
                completion(.success(assignments))
            case .failure(let error):
                completion(.failure(error))
            }
        }

    }

    // MARK: - Delete Document
    func deleteDocument(from collection: String = "",
                        with documentID: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        firebaseDataManager.deleteDocument(from: "assignments", with: documentID) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteDocumentWithID(assignmentID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let collection = db.collection("assignments")

        // Find the document with the specific assignmentID
        collection.whereField("assignmentID", isEqualTo: assignmentID).getDocuments { snapshot, error in
            if let error = error {
                // If there was an error in fetching documents, pass it to the completion
                completion(.failure(error))
                return
            }

            guard let snapshot = snapshot, !snapshot.documents.isEmpty else {
                // No document found with the given assignmentID
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                return
            }

            // Delete each document with the given assignmentID (if there could be duplicates)
            let batch = db.batch()
            snapshot.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }

            // Commit the batch delete
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
