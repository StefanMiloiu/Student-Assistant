//
//  DashboardView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 23.10.2024.
//

import SwiftUI

struct DashboardView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @EnvironmentObject var assignmentsVM: AssignmentListViewModel
    @State var showConfirmationAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    AssignmentsDashboard()
                        .padding(.horizontal, 10)
                    Spacer()
                }
                Spacer()
            }
            .alert(isPresented: $showConfirmationAlert) {
                Alert(title: Text("Do you want to sign out?"),
                      primaryButton: .destructive(Text("Yes")) {
                    Task {
                        do {
                            try await AuthManager.shared.signOut()  // Sign out user
                            appCoordinator.popToRoot()  // Navigate back to root
                        } catch {
                            print("Failed")  // Handle sign out error
                        }
                    }
                }
                      , secondaryButton: .cancel()
                )
            }
            .toolbar {
                // Sign Out button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showConfirmationAlert.toggle()
                    } label: {
                        Image(systemName: "door.right.hand.open")
                    }
                }
            }
            .navigationTitle("Dashboard") // Optional: Set the title of the navigation bar
            .onAppear {
                assignmentsVM.fetchAssignments()
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AssignmentListViewModel())
}
