//
//  TimeTrackHistory.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 15.10.2024.
//

import SwiftUI

struct TimeTrackHistory: View {

    @StateObject var vm = TrackTimeListViewModel()

    var body: some View {
        List {
            ForEach(vm.times, id: \.trackTimeID) {time in
                NavigationLink {
                    TimeTrackDetailView(time: time)
                } label: {
                    VStack(alignment: .leading) {
                        Text(time.trackTimeSubject ?? "Could not get subject.")
                            .font(.headline)
                        Text(time.getStudiedTime() ?? "Currently studying..." )
                            .font(.subheadline)
                    }
                }
            }
        }
        .listStyle(PlainListStyle()) // Use a plain list style
        .background(Color.clear) // Set the list background to clear
        .onAppear {
            vm.fetchTimes()
        }
    }
}

#Preview {
    TimeTrackHistory()
}
