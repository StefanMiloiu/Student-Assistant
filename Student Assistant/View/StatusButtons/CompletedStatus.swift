//
//  CompletedStatus.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct CompletedStatus: View {
    
    @ObservedObject var vm = AssignmentListViewModel()
    @Binding var showStatusButtons: Bool
    var assignment: Assignment
    
    var body: some View {
        Button(action: {
            vm.changeStatus(for: assignment, newStatus: .completed)
            showStatusButtons.toggle()
        }) {
            Image(systemName: "checkmark.diamond")
                .foregroundStyle(.white)
                .frame(width: 60, height: 40)
                .aspectRatio(contentMode: .fit)
                .background(Color.green.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }    }
}

