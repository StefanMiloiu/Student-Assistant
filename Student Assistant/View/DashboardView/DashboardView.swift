//
//  DashboardView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 23.10.2024.
//

import SwiftUI

struct DashboardView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    
    var body: some View {
        NavigationView {
            VStack {
                
            }
            .toolbar {
                // Sign Out button
                ToolbarItem(placement: .navigationBarTrailing) {
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
            .navigationTitle("Dashboard") // Optional: Set the title of the navigation bar
        }
    }
}

#Preview {
    DashboardView()
}
