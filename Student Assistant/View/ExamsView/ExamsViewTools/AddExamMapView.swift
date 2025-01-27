//
//  AddExamMapView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 02.11.2024.
//
import SwiftUI
import MapKit

struct AddExamMapView: View {
    
    @EnvironmentObject var viewModel: ExamListViewModel
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    
    /// Handles live suggestions
    @StateObject private var searchCompleter = SearchCompleter()

    /// Manages the map’s camera
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 46.78, longitude: 23.559444),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    @State private var locationManager = LocationManager()
    
    /// Search bar text
    @State private var searchQuery: String = ""
    
    /// Chosen location coordinate
    @State private var searchLocation: CLLocationCoordinate2D? = nil
    
    /// Whether the system's search UI is active (iOS16+)
    @State private var isSearchActive = false
    
    /// Bound exam details
    @Binding var examSubject: String
    @Binding var examLocation: String
    @Binding var examTime: Date
    @Binding var currentDate: Date
    
    var body: some View {
        VStack {
            // Main map
            Map(position: $cameraPosition) {
                if let searchLocation {
                    Annotation(examSubject, coordinate: searchLocation) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 20, height: 20)
                            Text("📍")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .gesture(
                LongPressGesture(minimumDuration: 0.5)
                    .sequenced(before: DragGesture(minimumDistance: 0))
                    .onEnded { value in
                        switch value {
                        case .second(true, let drag):
                            if let dragLocation = drag?.location {
                                setMapPin(at: dragLocation)
                            }
                        default:
                            break
                        }
                    }
            )
        }
        .navigationTitle("Add Exam Location")
        .navigationBarTitleDisplayMode(.inline)
        
        // Use only the completer’s suggestions
        .searchable(
            text: $searchQuery,
            isPresented: $isSearchActive,
            placement: .navigationBarDrawer(displayMode: .automatic)
        )
        .searchSuggestions {
            // Show suggestions from the completer
            if !searchCompleter.suggestions.isEmpty {
                ForEach(searchCompleter.suggestions, id: \.self) { suggestion in
                    // Display both title and subtitle to differentiate duplicates
                    Button {
                        handleSearchCompletion(suggestion)
                    } label: {
                        Text("\(suggestion.title), \(suggestion.subtitle)")
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        // Update the completer whenever searchQuery changes
        .onChange(of: searchQuery) {
            searchCompleter.updateQuery(searchQuery)
        }
        // If user hits Return, do a direct search
        .onSubmit(of: .search) {
            performSearch(searchQuery)
            isSearchActive = false
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    addExamLocation()
                }
            }
        }
        .onAppear {
            // Check location authorization
            locationManager.checkLocationAuthorization()
            
            // If we have a known user location, center the map there
            let location = locationManager.lastKnownLocation
            let center = CLLocationCoordinate2D(
                latitude: location?.latitude ?? 46.78,
                longitude: location?.longitude ?? 23.559444
            )
            cameraPosition = .region(MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
            
            // Optionally localize the completer results
            if let region = cameraPosition.region {
                searchCompleter.setRegion(region)
            }
        }
    }
    
    // MARK: - Completion Handling
    
    private func handleSearchCompletion(_ completion: MKLocalSearchCompletion) {
        // If user taps a suggestion, do a final search to get coordinates
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Error with search completion: \(error.localizedDescription)")
                return
            }
            guard let mapItem = response?.mapItems.first else { return }
            
            let coordinate = mapItem.placemark.coordinate
            searchLocation = coordinate
            cameraPosition = .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
            
            isSearchActive = false
        }
    }
    
    // MARK: - Manual Search if user hits Return
    private func performSearch(_ query: String) {
        guard !query.isEmpty else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        // Localize to camera region if desired
        if let region = cameraPosition.region {
            request.region = region
        }
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Error on manual search: \(error.localizedDescription)")
                return
            }
            guard let response = response, let firstResult = response.mapItems.first else {
                print("No results found for query: \(query)")
                return
            }
            
            let coord = firstResult.placemark.coordinate
            searchLocation = coord
            cameraPosition = .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    
    // MARK: - Long Press -> Pin
    private func setMapPin(at location: CGPoint) {
        guard let mapRegion = cameraPosition.region else { return }
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let latDelta = mapRegion.span.latitudeDelta / 2
        let lonDelta = mapRegion.span.longitudeDelta / 2
        
        let latitude = mapRegion.center.latitude + (latDelta * (1 - 2 * location.y / screenHeight))
        let longitude = mapRegion.center.longitude + (lonDelta * (2 * location.x / screenWidth - 1))
        
        searchLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        cameraPosition = .region(MKCoordinateRegion(
            center: searchLocation!,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    // MARK: - Add Exam
    private func addExamLocation() {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        
        let timeComponents = calendar.dateComponents([.hour, .minute], from: examTime)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        // Combine date and time into currentDate
        if let combinedDate = calendar.date(from: dateComponents) {
            currentDate = combinedDate
        }
        
        // Add the exam to the view model
        if let coordinate = searchLocation {
            let success = viewModel.addExam(
                subject: examSubject,
                date: currentDate,
                location: examLocation,
                locationCoordinates: coordinate
            )
            if success {
                print("Exam added successfully")
            }
        }
        
        // Pop the current view
        appCoordinator.pop()
        appCoordinator.pop()
    }
}

//#Preview {
//    AddExamMapView(
//        examSubject: .constant("Math"),
//        examLocation: .constant("Some Location"),
//        examTime: .constant(Date()),
//        currentDate: .constant(Date())
//    )
//}
