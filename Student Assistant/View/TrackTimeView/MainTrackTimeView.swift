//
//  MainTrackTimeView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 15.10.2024.
//

import SwiftUI

struct MainTrackTimeView: View {

    @State var pickerSelection: String = "Stopwatch"

    var body: some View {
        NavigationView {
            VStack {
                TimeTrackPicker(pickerSelection: $pickerSelection)
                    .padding()
                if pickerSelection == "Stopwatch" {
                    StopwatchView()
                } else {
                    TimeTrackHistory()
                }
            }
            .frame(width: 350, height: 350, alignment: .center)
            .background(.gray.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 30))
        }
    }
}

#Preview {
    MainTrackTimeView()
}
