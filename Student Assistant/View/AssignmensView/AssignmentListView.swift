//
//  AssignmentListView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import SwiftUI

struct AssignmentListView: View {
    @StateObject var viewModel = AssignmentListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.assignments, id: \.assignmentID) { assignment in
                        NavigationLink(destination: DetailedAssignmentsView(assignment: assignment)) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Circle()
                                        .fill(assignment.assignmentStatus.getColor())
                                        .frame(width: 15, height: 15)
                                    Text(assignment.assignmentTitle ?? "No title")
                                        .font(.headline)
                                }
                                Text(assignment.assignmentDescription ?? "No title" )
                                    .font(.subheadline)
                                Text("Due: \(assignment.assignmentDate ?? Date(), formatter: dateFormatter)")
                            }
                        }
                        .tint(.red)  // Apply tint here
                    }
                    .onDelete(perform: deleteAssignment)
                }
            }
            .navigationTitle("Assignments")
            .navigationBarItems(leading: EditButton())
            .navigationBarItems(trailing:
                                    NavigationLink(destination: AddAssignmentView()) {
                Image(systemName: "plus")
            }
            .tint(.red)  // Apply tint here
            )
            .onAppear {
                viewModel.fetchAssignments() // Load assignments on appear
            }
        }
        .tint(.red)
    }
    
    private func deleteAssignment(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteAssignment(at: index)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

#Preview {
    AssignmentListView()
}
