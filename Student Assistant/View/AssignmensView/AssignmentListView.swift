//
//  AssignmentListView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import SwiftUI

// MARK: - AssignmentListView
struct AssignmentListView: View {
    // MARK: - Properties
    @EnvironmentObject var viewModel: AssignmentListViewModel // The view model to manage assignments
    @Binding var selectedStatus: String // The currently selected status filter for assignments
    var filteredForDate: [Assignment]? // Optional filtered assignments based on a date range

    // MARK: - Computed Property
    var filteredList: [Assignment] {
        // Filter the list based on the selected status and any date filtering
        if let filteredForDate, !filteredForDate.isEmpty {
            return filteredForDate.filter { $0.assignmentStatus == .completed } // Filter completed assignments if date is provided
        }

        // Return assignments based on the selected status
        if selectedStatus == "Failed" {
            return viewModel.assignments.filter { $0.assignmentStatus == .failed }
        } else if selectedStatus == "In Progress" {
            return viewModel.assignments.filter { !($0.assignmentStatus == .failed || $0.assignmentStatus == .completed) }
        }
        // Default to completed assignments if no specific status is selected
        return viewModel.assignments.filter { $0.assignmentStatus == .completed }
    }

    // MARK: - Body
    var body: some View {
        List {
            // Iterate over the filtered list of assignments
            ForEach(filteredList, id: \.assignmentID) { assignment in
                NavigationLink(destination: DetailedAssignmentsView(assignment: assignment)) {
                    VStack(alignment: .leading) {
                        HStack {
                            // Display the assignment status color
                            Circle()
                                .fill(assignment.assignmentStatus.getColor()) // Color based on assignment status
                                .frame(width: 15, height: 15)
                            // Display the assignment title
                            Text(assignment.assignmentTitle ?? "No title")
                                .font(.headline)
                        }
                        // Display the assignment description
                        Text(assignment.assignmentDescription ?? "No description")
                            .font(.subheadline)
                        // Display the assignment date with a formatted string
                        Text("\(assignment.assignmentStatus == .completed ? "Completion:" : "Due:") \(assignment.assignmentDate ?? Date(), formatter: dateFormatter)")
                    }
                }
                .tint(.red)  // Apply a tint color to the navigation link
            }
            .onDelete(perform: deleteAssignment) // Enable deletion of assignments
        }
    }

    // MARK: - Delete Assignment Function
    // MARK: - Delete Assignment Function
    private func deleteAssignment(at offsets: IndexSet) {
        offsets.forEach { index in
            let assignment = filteredList[index] // Get the assignment from the filtered list
            viewModel.deleteAssignment(assignment) // Call delete function with the assignment instance
        }
    }
}

// MARK: - Date Formatter
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short // Set the date style to short
    formatter.timeStyle = .none  // Do not display time
    return formatter
}()

// MARK: - Preview
#Preview {
    AssignmentListView(selectedStatus: .constant("In Progress"))
}
