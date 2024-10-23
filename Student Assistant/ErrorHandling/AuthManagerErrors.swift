//
//  AuthManagerErrors.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 23.10.2024.
//

enum AuthManagerErrors: Error {
    case signUpFailed
    case signInFailed
    case signOutFailed
    case sendResetPasswordFailed
    case unknownError
}
