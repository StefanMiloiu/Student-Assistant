//
//  AuthManager.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 23.10.2024.
//

import Foundation
import FirebaseAuth

// Singleton struct to manage Firebase Authentication functions like sign up, sign in, and sign out.
struct AuthManager {
    
    /// Shared instance of the AuthManager for global access.
    static let shared = AuthManager()
    
    /// Private initializer to prevent multiple instances from being created.
    private init(){}
    
    
    //MARK: - Authentification methods
    /// Asynchronous function to sign up a new user with Firebase.
    /// Takes an email and password, and throws an error if the sign-up fails.
    func signUp(email: String, password: String) async throws {
        do {
            // Try to create a new user with the provided email and password.
            // `await` ensures this call is asynchronous and non-blocking.
            let _ = try await Auth.auth().createUser(withEmail: email, password: password)
            
        } catch let error as NSError {
            // Handle specific Firebase authentication errors using Firebase's error codes.
            if let errorCode = AuthErrorCode(rawValue: error.code) {
                // Switch between possible error cases, and print relevant error messages.
                switch errorCode {
                case .emailAlreadyInUse:
                    print("Error: Email is already in use.")
                case .invalidEmail:
                    print("Error: Invalid email address.")
                case .weakPassword:
                    print("Error: The password is too weak.")
                default:
                    // Handle any other error that doesn't match predefined cases.
                    print("Error: \(error.localizedDescription)")
                }
            }
            // Throw a custom error if sign-up fails.
            throw AuthManagerErrors.signUpFailed
        }
    }
    
    /// Asynchronous function to sign in an existing user with Firebase.
    /// Takes an email and password, and throws an error if sign-in fails.
    func signIn(email: String, password: String) async throws {
        do {
            // Try to sign in the user with the provided email and password.
            try await Auth.auth().signIn(withEmail: email, password: password)
            
            // Save login state and user details to UserDefaults after a successful sign-in.
            UserDefaults().isLoggedIn = true
            UserDefaults().userName = email
        } catch {
            // Throw a custom error if sign-in fails.
            throw AuthManagerErrors.signInFailed
        }
    }
    
    /// Asynchronous function to sign out the current user.
    func signOut() async throws {
        do {
            // Try to sign out the user.
            try Auth.auth().signOut()
            
            // Reset login state and user details in UserDefaults.
            UserDefaults().isLoggedIn = false
            UserDefaults().userName = ""
        } catch {
            // Throw a custom error if sign-out fails.
            throw AuthManagerErrors.signOutFailed
        }
    }
    
    /// Asynchronous function to send a password reset email to the provided email address.
    func resetPassword(for email: String) async throws {
        // Request Firebase to send a password reset email to the user.
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
