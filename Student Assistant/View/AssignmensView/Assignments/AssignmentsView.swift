//
//  AssignmentsView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 16.10.2024.
//

import SwiftUI

// MARK: - AssignmentsView
struct AssignmentsView: View {
    
    // MARK: - Properties
    @EnvironmentObject var viewModel: AssignmentListViewModel
    @State private var selectedStatus: String = "In Progress"

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // MARK: - Navigation Link to Completed Assignments
                    Section {
                        NavigationLink {
                            CompletedAssignmentsView()
                                .navigationTitle("Completed Assignments")
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            Text("Assignments History")
                        }
                        
                        Button(action: {
                            viewModel.syncAssignments()
                        }) {
                            HStack(spacing: 0) { // Adjust spacing between text and icon
                                Text("Synchronize Assignments")
                                Spacer()
                                Image(systemName: "arrow.down.circle.dotted")
                            }
                            .frame(maxWidth: .infinity) // Make the HStack take up the full width
                            .multilineTextAlignment(.center) // Center text and icon within HStack
                        }
                    }

                    // MARK: - Assignment Status Picker
                    Section {
                        PickerAssignments(selectedStatus: $selectedStatus)
                            .padding(.horizontal, -15)

                        // MARK: - No Assignments Message
                        if (viewModel.assignments.isEmpty || viewModel.fetchCurrentAssignments().isEmpty) && selectedStatus == "In Progress" {
                            emptyStateView(message: "No assignments in progress", imageName: "newspaper", color: .red.opacity(0.1))
                        }

                        if selectedStatus == "Failed" && viewModel.fetchFailedAssignments().isEmpty {
                            emptyStateView(message: "No failed assignments", imageName: "newspaper", color: .green.opacity(0.1))
                        }
                    }
                    .listRowBackground(Color.clear) // Remove the background color
                    .listRowSeparator(.hidden)

                    // MARK: - Assignment List
                    Section {
                        AssignmentListView(selectedStatus: $selectedStatus, filteredForDate: nil)
                    }
                }
            }
            .navigationTitle("Assignments")
            .navigationBarItems(leading: EditButton())
            .navigationBarItems(trailing: addButton)
            .onAppear {
                viewModel.fetchAssignments() // Load assignments on appear
            }
        }
        .tint(.red) // Set tint for the navigation view
    }
    
    // MARK: - Add Button
    private var addButton: some View {
        NavigationLink(destination: AddAssignmentView()) {
            Image(systemName: "plus")
        }
        .tint(.red) // Apply tint here
    }

    // MARK: - Empty State View
    private func emptyStateView(message: String, imageName: String, color: Color) -> some View {
        VStack {
            Text(message)
                .font(.headline)
                .padding()

            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50)
        }
        .frame(width: 350, height: 300, alignment: .center)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 50))
        .padding(.horizontal, 50)
    }

    // MARK: - Delete Assignment Function
    private func deleteAssignment(at offsets: IndexSet) {
        offsets.forEach { index in
            let assignment = viewModel.assignments[index] // Get the assignment from the filtered list
            viewModel.deleteAssignment(assignment) // Call delete function with the assignment instance
        }
    }
}

// MARK: - Preview
#Preview {
    AssignmentsView()
        .environmentObject(AssignmentListViewModel())
}
