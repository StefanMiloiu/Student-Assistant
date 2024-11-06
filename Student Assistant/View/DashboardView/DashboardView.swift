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
                    VStack {
                        HStack {
                            AssignmentsDashboard()
                                .padding(.leading, 10)
                            
                            ZStack(alignment: .center) {
                                Color.gray.opacity(0.1)
                                VStack {
                                    Text("Upcoming Exam")
                                 Image(systemName: "arrow.turn.right.down")
                                }
                            }
                            .frame(width: 125, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.trailing, 10)
                        }
                        .padding(.top)
                        ExamsMap()
                            .padding(.horizontal, 10)
                            .allowsHitTesting(false)
                    }

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
                            .tint(.primary)
                    }
                }
            }
            .navigationTitle("Dashboard") // Optional: Set the title of the navigation bar
            .onAppear {
                assignmentsVM.fetchAssignments()
                assignmentsVM.syncAssignments()
            }
            .tint(.accentColor)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AssignmentListViewModel())
        .environmentObject(ExamListViewModel())
}
