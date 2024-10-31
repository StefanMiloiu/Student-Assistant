//
//  LogInView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 23.10.2024.
//

import SwiftUI

struct LogInView: View {

    @State var email: String = ""
    @State var password: String = ""
    @State var alertIsPresented: Bool = false
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @EnvironmentObject var assignmentsViewModel: AssignmentListViewModel

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
            .padding(.top)
            .padding(.bottom, 75)

            Text("Start your journey with us by connecting to your account.")
                .multilineTextAlignment(.center)
                .font(.title3)
                .foregroundStyle(.gray)
                .padding(.horizontal, 50)
                .padding(.bottom, 25)

            // MARK: - Email and Password fields
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 2))
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
                .padding(.bottom, 10)

            HStack {
                Text("Forgot your password?")
                Button(action: {
                    appCoordinator.push(.forgotPassword)
                }) {
                    Text("Click Here")
                        .tint(.blue)
                }
            }

            Spacer()

            // MARK: - Log In With Apple
            LogInWithApple()
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal, 50)
            // MARK: - Log In Button
            Button {
                Task {
                    do {
                        try await AuthManager.shared.signIn(email: email, password: password)
                        appCoordinator.path = NavigationPath() // This clears all previous views
                        assignmentsViewModel.fetchAssignments()
                    } catch {
                        alertIsPresented.toggle()
                    }
                }
            } label: {
                Text("Login")
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal, 50)
            }

            // MARK: - Sign Up Button and text
            Text("No Account? Create your account by ")
                .padding(.horizontal, 50)
            Button {
                appCoordinator.push(.signUp)
            } label: {
                Text("Sign Up")
                    .padding(.horizontal, 50)
                    .buttonStyle(.borderless)
                    .tint(.blue)
            }

        }
        .alert(isPresented: $alertIsPresented) {
            Alert(title: Text("Invalid Crendentials"), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    LogInView()
        .environmentObject(AppCoordinatorImpl())
}
