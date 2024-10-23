//
//  ForgotPassword.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 23.10.2024.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @State var verificationEmail: String = ""
    @State var alert: Bool = false
    
    var body: some View {
        VStack {
            
            TextField("Enter your email", text: $verificationEmail)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color.secondary.opacity(0.5))
                .cornerRadius(10)
                .padding()
            
            Button(action: {
                Task {
                    do {
                        try await AuthManager.shared.resetPassword(for: verificationEmail)
                        verificationEmail = ""
                        appCoordinator.pop()
                    } catch {
                        alert.toggle()
                    }
                }
                        
            }){
                Text("Send Verification Email")
                    .tint(.blue)
            }
            Spacer()
        }
        .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text("Something went wrong. Please try again later."))
        }
    }
}

#Preview {
    ForgotPasswordView()
}
