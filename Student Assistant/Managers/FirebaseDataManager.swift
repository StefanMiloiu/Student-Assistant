//
//  FirebaseDataManager.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 24.10.2024.
//

import Foundation
import FirebaseFirestore

/// Protocol defining methods for managing Firestore data interactions.
protocol FirebaseDataManagerProtocol {
    /// Saves an encodable document to a specified Firestore collection.
    func saveDocument<T: Encodable>(data: T, to collection: String, completion: @escaping (Result<Void, Error>) -> Void)
    
    /// Fetches all documents from a specified Firestore collection and decodes them into the specified type.
    func fetchDocuments<T: Decodable>(from collection: String, completion: @escaping (Result<[T], Error>) -> Void)
    
    /// Fetches documents from a Firestore collection based on an email field match and decodes them into the specified type.
    func fetchDocumentsByEmail<T: Decodable>(from collection: String, email: String, completion: @escaping (Result<[T], Error>) -> Void)
    
    /// Deletes a document with a specified ID from a Firestore collection.
    func deleteDocument(from collection: String, with documentID: String, completion: @escaping (Result<Void, Error>) -> Void)
}

/// Class responsible for Firestore data management, implementing FirebaseDataManagerProtocol.
class FirebaseDataManager: FirebaseDataManagerProtocol {
    /// Reference to the Firestore database instance.
    let db = Firestore.firestore()

    /// Saves a document of any encodable type to the specified Firestore collection.
    /// - Parameters:
    ///   - data: The data object to save to Firestore.
    ///   - collection: The Firestore collection name where data will be saved.
    ///   - completion: Closure returning either success or failure if an error occurs.
    func saveDocument<T: Encodable>(data: T, to collection: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            // Attempting to add the document to the Firestore collection.
            let _ = try db.collection(collection).addDocument(from: data) { error in
                // Handle completion if an error occurs or upon successful save.
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            // Handle encoding errors when converting `data` to Firestore format.
            completion(.failure(error))
        }
    }

    /// Fetches all documents from the specified Firestore collection.
    /// - Parameters:
    ///   - collection: The Firestore collection name to fetch from.
    ///   - completion: Closure returning either an array of fetched documents or an error.
    func fetchDocuments<T: Decodable>(from collection: String, completion: @escaping (Result<[T], Error>) -> Void) {
        db.collection(collection).getDocuments { snapshot, error in
            if let error = error {
                // Return failure if there's an error fetching documents.
                completion(.failure(error))
            } else {
                // Attempt to decode documents; returns an empty array if decoding fails.
                let documents: [T] = snapshot?.documents.compactMap { try? $0.data(as: T.self) } ?? []
                completion(.success(documents))
            }
        }
    }
    
    /// Fetches documents by matching a specific email field in a Firestore collection.
    /// - Parameters:
    ///   - collection: The Firestore collection name to search in.
    ///   - email: The email to match in the document field.
    ///   - completion: Closure returning either an array of matching documents or an error.
    func fetchDocumentsByEmail<T: Decodable>(from collection: String, email: String, completion: @escaping (Result<[T], Error>) -> Void) {
        db.collection(collection)
            .whereField("assignmentEmail", isEqualTo: email)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    // Decodes documents matching the email criteria; returns empty array if none.
                    let documents: [T] = snapshot.documents.compactMap { try? $0.data(as: T.self) }
                    completion(.success(documents))
                } else {
                    // Return an error if no documents were found (snapshot is nil).
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No documents found."])))
                }
            }
    }

    /// Deletes a specific document by its ID from the specified Firestore collection.
    /// - Parameters:
    ///   - collection: The Firestore collection name where the document exists.
    ///   - documentID: The ID of the document to delete.
    ///   - completion: Closure returning either success or an error if deletion fails.
    func deleteDocument(from collection: String, with documentID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collection).document(documentID).delete { error in
            if let error = error {
                // Return failure if there's an error during deletion.
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
