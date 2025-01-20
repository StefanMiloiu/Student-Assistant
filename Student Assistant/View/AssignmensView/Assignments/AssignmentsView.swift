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
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
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
                            Text("Assignments History (\(viewModel.fetchCompletedAssignments().count))")
                        }

                        Button(action: {
                            viewModel.syncAssignments()
                        }) {
                            HStack(spacing: 0) { // Adjust spacing between text and icon
                                Text("Synchronize Assignments")
                                Spacer()
                                Image(systemName: "arrow.down.circle.dotted")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.appTiffanyBlue)
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
                            emptyStateView(message: "No assignments in progress", imageName: "AssignmentsImage", color: .red.opacity(0.1))
                        }

                        if selectedStatus == "Failed" && viewModel.fetchFailedAssignments().isEmpty {
                            emptyStateView(message: "No failed assignments", imageName: "AssignmentsImage", color: .appCambridgeBlue.opacity(0.1))
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
            .navigationBarItems(leading: EditButton().tint(.accentColor))
            .navigationBarItems(trailing: addButton)
            .onAppear {
                viewModel.fetchAssignments() // Load assignments on appear
            }
        }
        .tint(.primary) // Set tint for the navigation view
    }

    // MARK: - Add Button
    private var addButton: some View {
        Button {
            appCoordinator.pushCustom(AddAssignmentView())
        } label: {
            Image(systemName: "plus")
                .tint(.accentColor) // Apply tint here
        }
    }

    // MARK: - Empty State View
    private func emptyStateView(message: String, imageName: String, color: Color) -> some View {
        VStack {
            Text(message)
                .foregroundStyle(.appTiffanyBlue)
                .font(.headline)
                .padding(.horizontal)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 275, height: 275, alignment: .center)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .padding(.horizontal, 25)
        }
        .frame(width: 350, height: 350, alignment: .center)
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
