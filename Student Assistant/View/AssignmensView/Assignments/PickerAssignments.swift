//
//  PickerAssignments.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 16.10.2024.
//

import SwiftUI

/// A view that presents a segmented picker to select assignment statuses.
struct PickerAssignments: View {
    
    /// The binding to the selected assignment status.
    @Binding var selectedStatus: String
    
    var body: some View {
        Picker("Select Assignment Status", selection: $selectedStatus) {
            Text("In Progress")
                .tag("In Progress")
            Text("Failed")
                .tag("Failed")
        }
        .pickerStyle(.segmented) // Using a segmented style for better visual distinction
        .accessibilityLabel("Picker for assignment status") // Adding an accessibility label
    }
}

#Preview {
    PickerAssignments(selectedStatus: .constant("In Progress")) // Preview with a constant value
}
