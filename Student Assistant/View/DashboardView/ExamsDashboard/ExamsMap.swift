//
//  LShapedDashboard.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 28.10.2024.
//

import SwiftUI
import MapKit

struct ExamsMap: View {
    @EnvironmentObject var viewModel: ExamListViewModel
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 46.78, longitude: 23.559444),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    @State var coordinates: CLLocationCoordinate2D?
    
    var body: some View {
        ZStack {
            if let firstExam = viewModel.exams.first {
                CustomExam_MapCell(exam: firstExam)
            } else {
                ZStack(alignment: .top) {
                    Color.appCambridgeBlue
                        .frame(height: 225)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack {
                        Map(position: $cameraPosition)
                        .frame(height: 175)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .fixedSize(horizontal: false, vertical: true) // Ensures the map doesn't expand unexpectedly
                        
                        Text("No exams coming up 📄")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .onAppear {
            locationManager.checkLocationAuthorization()
            coordinates = locationManager.lastKnownLocation
            if let coordinates {
                cameraPosition = .region(MKCoordinateRegion(center: coordinates,
                                                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
            }
            viewModel.fetchExams()
        }
    }
}

#Preview {
    ExamsMap()
}
