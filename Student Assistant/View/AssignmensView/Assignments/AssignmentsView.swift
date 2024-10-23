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
    @ObservedObject var viewModel = AssignmentListViewModel()
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
                        AssignmentListView(viewModel: viewModel, selectedStatus: $selectedStatus, filteredForDate: nil)
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
        .frame(width: 325, height: 300, alignment: .center)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 50))
        .padding(.horizontal, 50)
    }

    // MARK: - Delete Assignment
    private func deleteAssignment(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteAssignment(at: index)
        }
    }
}

// MARK: - Preview
#Preview {
    AssignmentsView()
}
