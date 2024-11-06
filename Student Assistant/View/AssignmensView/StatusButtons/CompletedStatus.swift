//
//  CompletedStatus.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct CompletedStatus: View {

    @EnvironmentObject var vm: AssignmentListViewModel
    @Binding var showStatusButtons: Bool
    var assignment: Assignment

    var notChangeable: Bool {
        return assignment.checkIfCompleted() || assignment.checkIfOverdue() || assignment.checkIfFailed()    }

    var body: some View {
        Button(action: {
            if !notChangeable {
                assignment.assignmentDate = Date()
                vm.changeStatus(for: assignment, newStatus: .completed)
                showStatusButtons.toggle()
            }
        }) {
            Image(systemName: "checkmark.diamond")
                .foregroundStyle(.white)
                .frame(width: 60, height: 40)
                .aspectRatio(contentMode: .fit)
                .background(!notChangeable ? Color.appCambridgeBlue.opacity(0.7) : Color.gray.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }    }
}
