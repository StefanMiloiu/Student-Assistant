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
                            Text("Assignment")
                                .lineLimit(1)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                            Text("\(String(describing: nextAssignment!.assignmentTitle ?? "Title"))")
                                .lineLimit(1)
                                .padding(.horizontal, 10)
                                .fontWeight(.semibold)
                            ZStack {
                                Color.gray.opacity(0.1)
                                VStack {
                                    Text("Must be  completed in \(timeRemaining(until: nextAssignment!.assignmentDate ?? Date()))")
                                        .fontWeight(.semibold)
                                    ProgressView(value: Date.getPercentageDone(nextAssignment!))
                                        .padding(.horizontal, 10)
                                        .tint(nextAssignment!.assignmentStatus.getColor())
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
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.turn.right.down")
                                        .font(.title3)
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
                            .tint(.appJordyBlue)
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
    
    func timeRemaining(until dueDate: Date) -> String {
        let now = Date()
        let interval = dueDate.timeIntervalSince(now)
        
        guard interval > 0 else { return "0 days and 0 hours" }
        
        let days = Int(interval) / (60 * 60 * 24)
        let hours = (Int(interval) % (60 * 60 * 24)) / (60 * 60)
        
        if days == 0 && hours == 0 {
            return "less than 1 hour"
        }
        
        if days == 0 && hours > 0 {
            return "less than \(hours) hours"
        }
        
        return "\(days) days and \(hours) hours"
    }
}

#Preview {
    DashboardView()
        .environmentObject(AssignmentListViewModel())
        .environmentObject(ExamListViewModel())
        .environmentObject(LocationManager())
}
