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
    @State var progress: Float = 0
    @State private var nextAssignment: Assignment?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ZStack {
                    Color.gray.opacity(0.1)
                    VStack {
                        if nextAssignment != nil {
                            Text("\(String(describing: nextAssignment!.assignmentTitle ?? "Title"))")
                                .lineLimit(1)
                                .padding(.horizontal, 10)
                                .fontWeight(.semibold)
                            Text("\(String(describing: nextAssignment!.assignmentDescription ?? "Description"))")
                                .lineLimit(1)
                                .padding(.horizontal, 10)
                            ZStack {
                                Color.gray.opacity(0.1)
                                VStack {
                                    ProgressView(value: Date.getPercentageDone(nextAssignment!))
                                        .padding(.horizontal, 10)
                                        .tint(nextAssignment!.assignmentStatus.getColor())
                                    
                                    let customFormatter: DateFormatter = {
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"  // Example format: "2024-11-07 at 14:30"
                                        return formatter
                                    }()
                                    
                                    Text("Due \(customFormatter.string(from: nextAssignment!.assignmentDate ?? Date()))")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            Text("No assignment to complete")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .frame(height: 105)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 10)
                .padding(.top)
                
                HStack {
                    VStack {
                        HStack {
                            AssignmentsDashboard()
                                .padding(.leading, 10)
                            
                            ZStack(alignment: .center) {
                                Color.gray.opacity(0.1)
                                VStack {
                                    Text("Upcoming Exam")
                                        .multilineTextAlignment(.center)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.turn.right.down")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(width: 130, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.trailing, 10)
                            
                        }
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
                nextAssignment = assignmentsVM.fetchCurrentAssignments().first
            }
            .tint(.accentColor)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AssignmentListViewModel())
        .environmentObject(ExamListViewModel())
        .environmentObject(LocationManager())
}
