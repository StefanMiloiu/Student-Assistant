//
//  LShapedDashboard.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 28.10.2024.
//

import SwiftUI
import MapKit

struct ExamsMap: View {
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        var body: some View {
            Map {
                
            }
        }
}

#Preview {
    ExamsMap()
}
