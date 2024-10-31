//
//  StatusButtonsView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct StatusButtonsView: View {

    var assignment: Assignment
    @EnvironmentObject var vm: AssignmentListViewModel
    @Binding var showStatusButtons: Bool

    var body: some View {
        HStack {
            CompletedStatus(showStatusButtons: $showStatusButtons, assignment: assignment)

            FailedStatus(showStatusButtons: $showStatusButtons, assignment: assignment)

            InProgressStatus(showStatusButtons: $showStatusButtons, assignment: assignment)

            PendingStatus(showStatusButtons: $showStatusButtons, assignment: assignment)
        }
        .frame(width: 280, height: 50)
        .background(.gray.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
