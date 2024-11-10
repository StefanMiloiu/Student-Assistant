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
    @State private var selectedTab = 0


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
    
    var smartAssistantView: some View {
        appCoordinator.build(.smartAssistantMainView)
    }

    /// The main body of the view.
    var body: some View {
        TabView {
            dashboardView
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            
            smartAssistantView
                .tabItem {
                    Label {
                        Text("Assistant")
                    } icon: {
                        Image(systemName: "graduationcap")
                    }

                }
            assignmentsView
                .tabItem {
                    Label("Assignments", systemImage: "note.text")
                }
                

            examsView
                .tabItem {
                    Label("Exams", systemImage: "calendar")
                }
        }
        .tint(.appJordyBlue)
        .navigationBarTitleDisplayMode(.inline)

    }
}

#Preview {
    MainView()
        .environmentObject(ExamListViewModel())  // Injecting environment object for preview
}
