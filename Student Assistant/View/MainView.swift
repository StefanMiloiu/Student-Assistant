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
    
    /// A view for assignments.
    var assignmentsView: some View {
        appCoordinator.build(.assignments)
    }
    
    /// A view for exams.
    var examsView: some View {
        appCoordinator.build(.exams)
    }
    
    var dashboardView: some View {
        appCoordinator.build(.dashboard)
    }
    
    /// A view for tracking time.
    var trackTimeView: some View {
        VStack {
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
            
            // Back Button
            Button(action: {
                withAnimation {
                    selectedTimer.toggle()  // Toggle timer view
                }
            }) {
                if selectedTimer {
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
        }
    }
    
    /// The main body of the view.
    var body: some View {
        TabView {
            dashboardView
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            assignmentsView
                .tabItem {
                    Label("Assignments", systemImage: "note.text")
                }
            
            examsView
                .tabItem {
                    Label("Exams", systemImage: "calendar")
                }
            
            trackTimeView
                .tabItem {
                    Label("Track Time", systemImage: "clock")
                }
        }
        .navigationBarTitleDisplayMode(.inline)  // Title display mode
        .colorScheme(.light)  // Force light mode
    }
}

#Preview {
    MainView()
        .environmentObject(ExamListViewModel())  // Injecting environment object for preview
}
