
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
        VStack(spacing: 20) {
            
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
            
            Divider()
            if let coordinates {
                VStack {
                    Map(position: $cameraPosition) {
                        Marker("\(exam.examSubject ?? "Exam")", coordinate: coordinates)
                    }
                    .frame(height: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .cornerRadius(12)
                    .padding(.horizontal, 10)
                    
                    Spacer()
                    
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
                    
                    Spacer()
                }
            }
        }
        .padding(.top, 20)
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

//#Preview {
//    DetailedExamsView(exam: Exam.sample, animation: Namespace().wrappedValue)
//        .environmentObject(ExamListViewModel())
//}
