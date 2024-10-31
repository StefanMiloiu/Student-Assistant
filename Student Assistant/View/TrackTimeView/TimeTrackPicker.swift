//
//  TimeTrackPicker.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 15.10.2024.
//

import SwiftUI

struct TimeTrackPicker: View {

    @Binding var pickerSelection: String

    var body: some View {
        Picker("Pick", selection: $pickerSelection) {
            Text("Stopwatch")
                .tag("Stopwatch")
            Text("Past studies")
                .tag("Past studies")
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    TimeTrackPicker(pickerSelection: .constant(""))
}
