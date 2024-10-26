//
//  AssignmentsDashboard.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 26.10.2024.
//

import SwiftUI
import Charts

struct AssignmentsPieChart: View {
    
    @EnvironmentObject var viewModel: AssignmentListViewModel
    
    // Group assignments by status and calculate count per status
    private var aassignmentData: [(status: String, count: Double)] {
        let statuses = viewModel.assignments.map { $0.assignmentStatus.toString() }
        let counts = Dictionary(grouping: statuses, by: { $0 })
            .mapValues { Double($0.count) }
        
        return counts.map { (status: $0.key, count: $0.value) }
    }
    
    private var assignmentData: [(status: String, count: Double, color: Color)] {
        let completedCount = viewModel.assignments.filter { $0.assignmentStatus == .completed }.count
        let inProgressCount = viewModel.assignments.filter {
            $0.assignmentStatus == .inProgress
            || $0.assignmentStatus == .pending
        }.count
        let failedCount = viewModel.assignments.filter { $0.assignmentStatus == .failed }.count
        
        return [
               (status: "Completed", count: Double(completedCount), color: .green),
               (status: "In Progress", count: Double(inProgressCount), color: .yellow),
               (status: "Failed", count: Double(failedCount), color: .red)
           ]
    }
    
    
    
    var body: some View {
        Chart(assignmentData, id: \.status) { data in
            SectorMark(
                angle: .value("Assignment Count", data.count),
                innerRadius: .ratio(0.65), // Optional: adjust to create a donut effect
                outerRadius: .ratio(0.95),
                angularInset: 10
            )
            .foregroundStyle(data.color)
        }
        .chartLegend(position: .automatic)
    }
}

#Preview {
    AssignmentsPieChart()
        .environmentObject(AssignmentListViewModel())
}
