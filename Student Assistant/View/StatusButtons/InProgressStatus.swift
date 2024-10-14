//
//  InProgressStatus.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct InProgressStatus: View {
    
    @ObservedObject var vm = AssignmentListViewModel()
    @Binding var showStatusButtons: Bool
    var assignment: Assignment
    
    var body: some View {
        Button(action: {
            vm.changeStatus(for: assignment, newStatus: .inProgress)
            showStatusButtons.toggle()
        }) {
            Image(systemName: "progress.indicator")
                .foregroundStyle(.white)
                .frame(width: 60, height: 40)
                .aspectRatio(contentMode: .fit)
                .background(Color.yellow.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
