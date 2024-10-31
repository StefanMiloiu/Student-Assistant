////
////  MapView.swift
////  Student Assistant
////
////  Created by Stefan Miloiu on 28.10.2024.
////
//
//
//import SwiftUI
//import MapKit
//
//struct SavedPin: Identifiable {
//    let id = UUID()
//    var coordinate: CLLocationCoordinate2D
//}
//
//
//struct MapView: View {
//    @StateObject private var locationManager = LocationManager()
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
//        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//    )
//    @State private var savedPins: [SavedPin] = []
//
//    var body: some View {
//        VStack {
//            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: savedPins) { pin in
//                MapPin(coordinate: pin.coordinate, tint: .red)
//            }
//            .onAppear {
//                if let location = locationManager.location {
//                    region = MKCoordinateRegion(
//                        center: location,
//                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//                    )
//                }
//            }
//            .gesture(
//                DragGesture(minimumDistance: 0)
//                    .onEnded { value in
//                        let location = convertToMapCoordinate(from: value.location)
//                        addPin(at: location)
//                    }
//            )
//            .frame(height: 300)
//            .cornerRadius(10)
//            .padding()
//
//            Button("Save Pins") {
//                savePins()
//            }
//            .padding()
//        }
//    }
//
//    // Function to add a pin at a specific location
//    private func addPin(at location: CLLocationCoordinate2D) {
//        let newPin = SavedPin(coordinate: location)
//        savedPins.append(newPin)
//    }
//
//    // Helper function to convert screen coordinates to map coordinates
//    private func convertToMapCoordinate(from point: CGPoint) -> CLLocationCoordinate2D {
//        let mapView = MKMapView()
//        mapView.region = region
//        return mapView.convert(point, toCoordinateFrom: mapView)
//    }
//
//    // Function to save pins (implementation depends on where you want to save them)
//    private func savePins() {
//        // Example: print saved pins' coordinates
//        for pin in savedPins {
//            print("Saved Pin Location: \(pin.coordinate.latitude), \(pin.coordinate.longitude)")
//        }
//        // Here, you could save pins to UserDefaults, CoreData, or any other storage option.
//    }
//}
//
//
//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
