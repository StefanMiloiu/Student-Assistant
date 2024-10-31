//
//  SignUpView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 23.10.2024.
//
import SwiftUI

struct SignUpView: View {

    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var alertIsPresented: Bool = false
    @State var alertMessage: String = ""
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl

    var body: some View {
        VStack {
            ZStack {
                Image("Icon")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fit)
                    .shadow(radius: 20)
                    .padding()
            }
            .padding(.bottom, 75)

            Text("Create your account to start your journey.")
                .multilineTextAlignment(.center)
                .font(.title3)
                .foregroundStyle(.gray)
                .padding(.horizontal, 50)
                .padding(.bottom, 25)

            // MARK: - Email, Password, and Confirm Password Fields
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 2)) // Custom border
                .padding(.bottom, 10)
                .textFieldStyle(.plain)
                .padding(.horizontal, 50)
                .padding(.vertical, 10)

            SecureField("Password", text: $password)
                .textInputAutocapitalization(.never)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 2)) // Custom border
                .padding(.bottom, 10)
                .textFieldStyle(.plain)
                .padding(.horizontal, 50)
                .padding(.vertical, 10)

            SecureField("Confirm Password", text: $confirmPassword)
                .textInputAutocapitalization(.never)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 2)) // Custom border
                .padding(.bottom, 10)
                .textFieldStyle(.plain)
                .padding(.horizontal, 50)
                .padding(.vertical, 10)

            Spacer()

            // MARK: - Sign Up Button
            Button {
                if EmailValidation().isValidEmail(email) {
                    if password == confirmPassword {
                        Task {
                            do {
                                try await AuthManager.shared.signUp(email: email, password: password)
                                appCoordinator.path = NavigationPath() // Clear previous views
                                appCoordinator.push(.logIn) // Navigate to logIn after successful sign up
                            } catch {
                                alertMessage = "Email already used."
                                alertIsPresented.toggle()
                            }
                        }
                    } else {
                        alertMessage = "Passwords don't match."
                        alertIsPresented.toggle()
                    }
                } else {
                    alertMessage = "Invalid email format."
                    alertIsPresented.toggle()
                }
            } label: {
                Text("Sign Up")
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal, 50)
            }

            // MARK: - Back to Log In Button and text
            Text("Already have an account? ")
                .padding(.horizontal, 50)
            Button {
                appCoordinator.pop()           // Go back to LogIn
            } label: {
                Text("Log In")
                    .padding(.horizontal, 50)
                    .buttonStyle(.borderless)
                    .tint(.blue)
            }

        }
        .alert(isPresented: $alertIsPresented) {
            Alert(title: Text("Oops"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AppCoordinatorImpl())
}
