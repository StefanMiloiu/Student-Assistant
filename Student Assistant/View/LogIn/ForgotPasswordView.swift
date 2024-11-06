//
//  ForgotPassword.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 23.10.2024.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {

    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @State var verificationEmail: String = ""
    @State var alert: Bool = false
    @State var alertMessage: String = ""
    var body: some View {
        VStack {

            TextField("Enter your email", text: $verificationEmail)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()
                .background(.appJordyBlue.opacity(0.5))
                .cornerRadius(10)
                .padding()

            Button(action: {
                Task {
                    do {
                        try await AuthManager.shared.resetPassword(for: verificationEmail)
                        verificationEmail = ""
                        appCoordinator.pop()
                    } catch let error as AuthErrorCode {
                        switch error {
                        case .userNotFound:
                            alert.toggle()
                            alertMessage = "User not found."
                        default:
                            alert.toggle()
                            alertMessage = "Something went wrong. Please try again later."
                        }
                        alert.toggle()
                    }
                }
            }) {
                Text("Send Verification Email")
                    .tint(.appJordyBlue)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text("\(alertMessage)"))
        }
    }
}

#Preview {
    ForgotPasswordView()
}
