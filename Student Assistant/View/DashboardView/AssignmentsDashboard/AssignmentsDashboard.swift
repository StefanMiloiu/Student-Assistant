//
//  AssignmentsDashboard.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 26.10.2024.
//

import SwiftUI

struct AssignmentsDashboard: View {
    
    @EnvironmentObject var viewModel: AssignmentListViewModel
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.gray.opacity(0.1)
            VStack{
                Text("Assignments")
                    .font(.title2)
                    .fontWeight(.semibold)
                HStack { // Add spacing between elements
                    AssignmentsPieChart()
                        .frame(width: 100, height: 70) // Adjust the pie chart frame as needed
                        
                    VStack(alignment: .leading) {
                        AssignmentsInfo(status: .inProgress)
                        AssignmentsInfo(status: .completed)
                        AssignmentsInfo(status: .failed)
                    }
                }
            }
        }
        .onChange(of: viewModel.assignments) {
            viewModel.fetchAssignments()
        }
        .frame(width: 250, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}


#Preview {
    AssignmentsDashboard()
        .environmentObject(AssignmentListViewModel())
}
