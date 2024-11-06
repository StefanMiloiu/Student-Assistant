//
//  LogInWithApple.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 28.10.2024.
//

import SwiftUI
import AuthenticationServices

struct LogInWithApple: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl

    var body: some View {
        Group {
            if colorScheme == .dark {
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: handleAuthorization
                )
                .signInWithAppleButtonStyle(.white)
            } else {
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: handleAuthorization
                )
                .signInWithAppleButtonStyle(.black)
            }
        }
    }

    private func handleAuthorization(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    do {
                        try await AuthManager.shared.authenticateWithFirebase(credential: appleIDCredential)
                        appCoordinator.path = NavigationPath() // This clears all previous views
                    } catch {
                        print(error)
                    }
                }
            }
        case .failure(let error):
            print("Authorization failed: \(error.localizedDescription)")
        }
    }
}
