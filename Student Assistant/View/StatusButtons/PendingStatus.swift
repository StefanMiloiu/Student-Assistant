//
//  PendingStatus.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct PendingStatus: View {
    
    @ObservedObject var vm = AssignmentListViewModel()
    @Binding var showStatusButtons: Bool
    var assignment: Assignment
    
    var body: some View {
        Button(action: {
            vm.changeStatus(for: assignment, newStatus: .pending)
            showStatusButtons.toggle()
        }) {
            Image(systemName: "clock.arrow.circlepath")
                .foregroundStyle(.white)
                .frame(width: 60, height: 40)
                .aspectRatio(contentMode: .fit)
                .background(Color.lightBlue.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

