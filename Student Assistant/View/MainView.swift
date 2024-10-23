//
//  MainView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

/// The main view of the Student Assistant app.
struct MainView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl  // Access to the app's navigation coordinator
    @State var selectedTimer: Bool = false  // State variable to track if the timer view is selected
    
    // MARK: - Navigation Views

    /// A view for navigating to the assignments screen.
    var assignmentNavigationView: some View {
        Button {
            appCoordinator.push(.assignments)  // Navigate to assignments
        } label: {
            CustomAssignmentIcon()  // Custom icon for assignments
        }
    }
    
    /// A view for navigating to the exams screen.
    var examNavigationView: some View {
        Button {
            appCoordinator.push(.exams)  // Navigate to exams
        } label: {
            CustomExamIcon()  // Custom icon for exams
        }
    }
    
    /// The main body of the view.
    var body: some View {
        ZStack {
            // Background Setup
            ZStack {
                // Linear gradient for the background
                LinearGradient(colors: [.white, .gray.opacity(0.9)], startPoint: .bottom, endPoint: .top)
                    .ignoresSafeArea()
                    .padding(.bottom, 725)  // Adjust padding for background
                
                Image("BackgroundImage")  // Background image
                    .resizable()
                    .scaleEffect(1.2)
                    .aspectRatio(contentMode: .fit)
                    .ignoresSafeArea()
                    .padding(.top, 50)
                    .blur(radius: 5)  // Apply blur to background image
            }
            
            VStack {
                HStack(spacing: 40) {
                    assignmentNavigationView  // Assignment button
                        .tint(.red)
                    
                    examNavigationView  // Exam button
                        .tint(.lightBlue)
                }
                .padding(.top)
                .toolbar {
                    // Customizing the navigation title appearance
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Home")  // Title text
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                    
                    // Sign Out button
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Sign Out") {
                            Task {
                                do {
                                    try await AuthManager.shared.signOut()  // Sign out user
                                    appCoordinator.popToRoot()  // Navigate back to root
                                } catch {
                                    print("Failed")  // Handle sign out error
                                }
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)  // Title display mode
                .colorScheme(.light)  // Force light mode
                
                Spacer()
                
                // Track Time Button and View
                ZStack {
                    if !selectedTimer {
                        Button(action: {
                            selectedTimer.toggle()  // Toggle timer view
                        }) {
                            CustomTrackTimeIcon()  // Custom icon for tracking time
                                .transition(.opacity)  // Use opacity transition
                        }
                    } else {
                        MainTrackTimeView()  // Main view for tracking time
                            .transition(.opacity)  // Use opacity transition
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: selectedTimer)  // Animation for view transition
                
                // Back Button
                Button(action: {
                    withAnimation {
                        selectedTimer.toggle()  // Toggle timer view
                    }
                }) {
                    if selectedTimer == true {
                        HStack {
                            Text("Back ")  // Back text
                            Image(systemName: "arrowshape.turn.up.backward")  // Back icon
                        }
                        .foregroundStyle(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.6))  // Background color
                        .cornerRadius(10)  // Rounded corners
                    }
                }
                .padding(.bottom, 115)  // Bottom padding
                
                Spacer()
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(ExamListViewModel())  // Injecting environment object for preview
}
