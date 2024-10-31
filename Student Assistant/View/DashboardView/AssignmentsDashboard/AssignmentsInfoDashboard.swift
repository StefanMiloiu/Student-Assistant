//
//  AssignmentsInfoDashboard.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 26.10.2024.
//

import SwiftUI

struct AssignmentsInfo: View {
    @EnvironmentObject var viewModel: AssignmentListViewModel
    let status: Status

    var body: some View {
        HStack {
            Circle()
                .fill(color(for: status))
                .frame(width: 14, height: 14)
            Text(infoText(for: status))
                .font(.body)
                .foregroundColor(.primary)
        }
    }

    private func color(for status: Status) -> Color {
        switch status {
        case .completed: return .green
        case .failed: return .red
        default: return .yellow
        }
    }

    private func infoText(for status: Status) -> String {
        switch status {
        case .completed:
            return "\(viewModel.fetchCompletedAssignments().count) completed"
        case .failed:
            return "\(viewModel.fetchFailedAssignments().count) failed"
        default:
            return "\(viewModel.fetchCurrentAssignments().count) in-progress "
        }
    }
}

#Preview {
    AssignmentsInfo(status: .completed)
}
