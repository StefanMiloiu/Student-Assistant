//
//  DetailedAssignmentsView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import SwiftUI

// MARK: - DetailedAssignmentsView
struct DetailedAssignmentsView: View {
    
    // MARK: - Properties
    var assignment: Assignment // The assignment object passed as a parameter
    @ObservedObject var vm: AssignmentListViewModel // The view model for managing assignments
    @State var showStatusButtons: Bool = false // State to toggle the visibility of status buttons
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            // Display the title of the assignment
            Text(assignment.assignmentTitle ?? "No Title")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30)
            
            // HStack for showing the assignment dates and status
            HStack {
                // Display completion or due date, along with time
                Text("\(assignment.assignmentStatus == .completed ? "Completion Date" : "Due Date") \n \(assignment.assignmentDate ?? Date(), formatter: dateFormatter) \n \(assignment.getTime())")
                Spacer()
                // Display the assignment status
                Text("\(assignment.assignmentStatus.toString())")
            }
            .fontWeight(.bold)
            .padding(.horizontal, 30)
            .frame(width: 300, height: 100)
            .background(assignment.assignmentStatus.getColor()) // Background color based on assignment status
            .clipShape(RoundedRectangle(cornerRadius: 10)) // Rounded corners for the background
            .font(.subheadline)
            .multilineTextAlignment(.center) // Center-align text
            .padding(.horizontal, 40)
            
            // Scrollable view for the assignment description
            ScrollView {
                Text(assignment.assignmentDescription ?? "Could not get assignment description") // Display assignment description
                    .font(.body)
                    .multilineTextAlignment(.leading) // Align text to the left for readability
                    .lineLimit(nil) // Allow multiline text
            }
            .padding(.horizontal, 40)
            Spacer()
            
            // Button to change the status of the assignment
            MainButtonForStatus(showStatusButtons: $showStatusButtons)
            
            // Show status buttons if toggled on
            if showStatusButtons {
                StatusButtonsView(assignment: assignment, vm: vm, showStatusButtons: $showStatusButtons) // View for changing the assignment status
            }
        }
        .padding() // General padding for the entire view
    }
}

// MARK: - Date Formatter
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium // Set date style to medium
    formatter.timeStyle = .none // Do not display time
    return formatter
}()

// MARK: - Preview
//#Preview {
//    let assignment = Assignment(context: DataManager.shared.persistentContainer.viewContext)
//    assignment.assignmentTitle = "Assignment Title"
//    assignment.assignmentDescription = "Am fost la magazing sa merg pana la baie ca imi era foame si cosmu stim cu totii ce face in timpul liber... Assignment "
//    assignment.assignmentDate = Date()
//    assignment.assignmentStatus = .inProgress
//
//    return DetailedAssignmentsView(assignment: assignment)
//}
