//
//  DetailedAssignmentsView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import SwiftUI

struct DetailedAssignmentsView: View {
    
    
    var assignment: Assignment // Pass the assignment as a parameter
    @ObservedObject var vm = AssignmentListViewModel()
    
    @State var showStatusButtons: Bool = false
    
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text(assignment.assignmentTitle ?? "No Title")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30)
            
            HStack {
                Text("Due Date \n \(assignment.assignmentDate ?? Date(), formatter: dateFormatter) \n \(assignment.getTime())")
                Spacer()
                Text("\(assignment.assignmentStatus.toString())")
            }
            .fontWeight(.bold)
            .padding(.horizontal, 30)
            .frame(width: 300, height: 100)
            .background(assignment.assignmentStatus.getColor())
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            
            ScrollView {
                Text(assignment.assignmentDescription ?? "Could not get assignment description")
                    .font(.body)
                    .multilineTextAlignment(.leading) // Optional: Aligns text to the left for readability
                    .lineLimit(nil)
            }
            .padding(.horizontal, 40)
            Spacer()
            
            MainButtonForStatus(showStatusButtons: $showStatusButtons)
            
            if showStatusButtons {
                StatusButtonsView(assignment: assignment, showStatusButtons: $showStatusButtons)
            }
        }
        .padding()
        
    }
}

// Date formatter
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

//#Preview {
//    let assignment = Assignment(context: DataManager.shared.persistentContainer.viewContext)
//    assignment.assignmentTitle = "Assignment Title"
//    assignment.assignmentDescription = "Am fost la magazing sa merg pana la baie ca imi era foame si cosmu stim cu totii ce face in timpul liber... Assignment "
//    assignment.assignmentDate = Date()
//    assignment.assignmentStatus = .inProgress
//    
//    return DetailedAssignmentsView(assignment: assignment)
//}
