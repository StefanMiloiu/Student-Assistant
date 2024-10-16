//
//  FailedStatus.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct FailedStatus: View {
    
    @ObservedObject var vm = AssignmentListViewModel()
    @Binding var showStatusButtons: Bool
    var assignment: Assignment
    
    var body: some View {
        Button(action: {
            vm.changeStatus(for: assignment, newStatus: .failed)
            showStatusButtons.toggle()
        }) {
            Image(systemName: "x.square.fill")
                .foregroundStyle(.white)
                .frame(width: 60, height: 40)
                .aspectRatio(contentMode: .fit)
                .background(Color.red.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

