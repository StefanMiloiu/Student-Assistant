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
    @State private var selectedTab: Int = 0  // Tracks the selected tab
    @State private var showSmartSummarize: Bool = false  // Tracks whether to show the Smart Summarize view

    // MARK: - Navigation Views

    /// A view for assignments.
    var assignmentsView: some View {
        appCoordinator.build(.assignments)
    }

    /// A view for exams.
    var examsView: some View {
        appCoordinator.build(.exams)
    }

    /// A view for the dashboard.
    var dashboardView: some View {
        appCoordinator.build(.dashboard)
    }
    
    /// A view for the Smart Assistant.
    var smartAssistantView: some View {
        appCoordinator.build(.smartAssistantMainView)
    }
    
    /// The Smart Summarize view (accessed via the floating button).
    var smartSummarizeView: some View {
        appCoordinator.build(.OCRAndAIView)
    }

    /// The main body of the view.
    var body: some View {
        ZStack {
            // Main TabView
            TabView(selection: $selectedTab) {
                dashboardView
                    .tabItem {
                        Label("Dashboard", systemImage: "house")
                    }
                    .tag(0)
                
                smartAssistantView
                    .tabItem {
                        Label("Assistant", systemImage: "graduationcap")
                    }
                    .tag(1)
                
                // Placeholder for the middle tab (Smart Summarize)
                Text("")
                    .tabItem {
                        EmptyView()  // No label or icon for the middle tab
                    }
                    .tag(2)
                
                assignmentsView
                    .tabItem {
                        Label("Assignments", systemImage: "note.text")
                    }
                    .tag(3)
                
                examsView
                    .tabItem {
                        Label("Exams", systemImage: "calendar")
                    }
                    .tag(4)
            }
            .tint(.appJordyBlue)
            .navigationBarTitleDisplayMode(.inline)

            // Floating Plus Button
            VStack {
                Spacer()  // Push to the bottom
                HStack {
                    Spacer()
                    
                    // Centered Floating Button
                    Button(action: {
                        showSmartSummarize.toggle()
                    }) {
                        ZStack {
                            Circle()
                                .fill(.appJordyBlue)
                                .frame(width: 60, height: 60)
                                .shadow(radius: 4)
                            
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 25, weight: .bold))
                        }
                    }
                    .offset(y: -5)  // Lift the button above the TabView
                    .sheet(isPresented: $showSmartSummarize) {
                        smartSummarizeView
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AppCoordinatorImpl())  // Injecting environment object for preview
}
