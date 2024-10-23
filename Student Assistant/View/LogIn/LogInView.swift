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
    
    var body: some View {
        VStack {
            ZStack {
                Color.gray
                    .ignoresSafeArea()
                    .frame(height: 100)
                Text("Student")
                    .foregroundStyle(.white)
                    .font(.title)
                    .padding(.top, 50)
            }
            HStack {
                Spacer()
                Image("Icon")
                    .resizable()
                    .frame(width: 75, height: 75)
                    .aspectRatio(contentMode: .fit)
                    
                Spacer()

                Text("Assistant")
                    .font(.title)
                    .foregroundStyle(.gray)
                Spacer()
            }
            .padding(.bottom, 100)
            
            Text("Start your journey with us by connecting to your account.")
                .multilineTextAlignment(.center)
                .font(.title3)
                .foregroundStyle(.gray)
                .padding(.horizontal, 50)
                .padding(.bottom, 25)
            
            
            
            //MARK: - Email and Password fields
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
            
            //MARK: - Log In Button
            Button {
                Task {
                    do{
                        try await AuthManager.shared.signIn(email: email, password: password)
                        appCoordinator.path = NavigationPath() // This clears all previous views
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
            
            //MARK: - Sign Up Button and text
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
