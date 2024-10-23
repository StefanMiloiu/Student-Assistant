//
//  TimeTrackDetailView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 20.10.2024.
//

import SwiftUI

struct TimeTrackDetailView: View {
    
    let time: TrackTime?
    
    var body: some View {
        VStack {
            Text("\(String(describing: time?.trackTimeSubject ?? "Could not find subject"))")
            
            Text("\(String(describing: time?.trackTimeNotes ?? "No notes for this time"))")
            
            Text("Studied : \(String(describing: time?.getStudiedTime() ?? "Currently studying..."))")
        }
    }
}
