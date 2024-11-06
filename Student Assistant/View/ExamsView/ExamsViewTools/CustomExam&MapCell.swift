//
//  CustomExam&MapCell.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 02.11.2024.
//

import SwiftUI
import MapKit


struct CustomExam_MapCell: View {
    
    let exam: Exam
    
    @State private var coordinates: CLLocationCoordinate2D = .init()
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 46.78, longitude: 23.559444),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appCambridgeBlue
                .frame(height: 225)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack {
                Map(position: $cameraPosition) {
                    Marker("\(exam.examSubject ?? "Exam")", coordinate: coordinates)
                }
                .frame(height: 175)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .fixedSize(horizontal: false, vertical: true) // Ensures the map doesn't expand unexpectedly
                
                Text("\(exam.examLocation ?? "Location")")
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                
                Text("\(exam.examDate?.formatted(date: .abbreviated, time: .shortened) ?? Date().formatted(date: .abbreviated, time: .standard) )")
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
            
        }
        .frame(height: 225)
        .onAppear {
            coordinates = CLLocationCoordinate2D(latitude: exam.examLatitude,
                                                 longitude: exam.examLongitude)
            cameraPosition = .region(
                MKCoordinateRegion(center: CLLocationCoordinate2D(
                    latitude: exam.examLatitude,
                    longitude: exam.examLongitude),
                                   span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            )
        }
    }
}

#Preview {
//    CustomExam_MapCell(exam: nil)
}
