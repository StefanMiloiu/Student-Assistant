
//
//  DetailedExamsView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 14.10.2024.
//

import SwiftUI
import MapKit

struct DetailedExamsView: View {
    @EnvironmentObject var vm: ExamListViewModel
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 46.78, longitude: 23.559444),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    @State var coordinates: CLLocationCoordinate2D?
    let exam: Exam
    var animation: Namespace.ID // Pass the same Namespace
    
    var body: some View {
        ZStack {
            // Map in the background
            if let coordinates {
                Map(position: $cameraPosition) {
                    Marker("\(exam.examSubject ?? "Exam")", coordinate: coordinates)
                }
                .frame(height: 500)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .cornerRadius(12)
                .padding(.horizontal, 10)
                .padding(.top, -50)
            }
            
            // VStack with text on top of the map
            VStack(spacing: 20) {
                VStack {
                    Text(exam.examSubject ?? "Subject")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Scheduled for \(formattedDate(exam.examDate))")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    if let location = exam.examLocation {
                        Text("Location: \(location)")
                            .font(.title3)
                            .padding(.top)
                    }
                }
                .frame(height: 200)
                .background(Color.appCambridgeBlue.opacity(1))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 35)
                .padding(.top)
                
                Spacer()
                Text("To navigate to the exam location, tap the button below.")
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                Button(action: openInMaps) {
                    Text("Get Directions")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.appCambridgeBlue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            coordinates = CLLocationCoordinate2D(latitude: exam.examLatitude, longitude: exam.examLongitude)
            if let coordinates {
                cameraPosition = .region(MKCoordinateRegion(center: coordinates,
                                                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
            }
        }
        .navigationTitle("Exam Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func openInMaps() {
        guard let coordinates = coordinates else { return }
        let url = URL(string: "maps://?daddr=\(coordinates.latitude),\(coordinates.longitude)&dirflg=d")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
