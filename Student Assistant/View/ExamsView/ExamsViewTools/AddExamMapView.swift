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
    @StateObject private var searchCompleter = SearchCompleter()
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 46.78, longitude: 23.559444),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))
    @State private var locationManager = LocationManager()
    @State private var searchQuery: String = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var searchLocation: CLLocationCoordinate2D? = nil
    @State private var isSearchFocused: Bool = false
    
    @Binding var examSubject: String
    @Binding var examLocation: String
    @Binding var examTime: Date
    @Binding var currentDate: Date
    
    var body: some View {
        
        VStack {
            // Map view
            Map(position: $cameraPosition) {
                if let searchLocation = searchLocation {
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
        .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always))
        .searchSuggestions {
            if !searchCompleter.suggestions.isEmpty {
                ForEach(searchCompleter.suggestions, id: \.self) { suggestion in
                    Button(action: {
                        handleSearchCompletion(suggestion)
                    }) {
                        Text(suggestion.title) // Display suggestion title
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .onChange(of: searchQuery) {
            searchCompleter.updateQuery(searchQuery)
        }
        .onChange(of: searchQuery) {
            if searchQuery != "" {
                fetchSuggestions(query: searchQuery)
            }
        }
        .onSubmit(of: .search) {
            performSearch(query: searchQuery)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: addExamLocation) {
                    Text("Done")
                }
            }
        }
        .onAppear {
            let location = locationManager.lastKnownLocation
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: location?.latitude ?? 46.78, longitude: location?.longitude ?? 3.559444),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        }
    }
    
    private func handleSearchCompletion(_ completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let error = error {
                print("Error with search completion: \(error.localizedDescription)")
                return
            }
            if let mapItem = response?.mapItems.first {
                let coordinate = mapItem.placemark.coordinate
                searchLocation = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                cameraPosition = .region(MKCoordinateRegion(
                    center: searchLocation!,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        }
    }
    
    /// Set a pin at the long-pressed location
    private func setMapPin(at location: CGPoint) {
        // Approximate translation of CGPoint to coordinates based on the camera position's region
        let mapRegion = cameraPosition.region
        let mapWidth = UIScreen.main.bounds.width
        let mapHeight = UIScreen.main.bounds.height
        
        if let mapRegion {
            let latDelta = mapRegion.span.latitudeDelta / 2
            let lonDelta = mapRegion.span.longitudeDelta / 2
            
            let latitude = mapRegion.center.latitude + (latDelta * (1 - 2 * location.y / mapHeight))
            let longitude = mapRegion.center.longitude + (lonDelta * (2 * location.x / mapWidth - 1))
            
            searchLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            cameraPosition = .region(MKCoordinateRegion(
                center: searchLocation!,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    
    /// Fetch suggestions within a specific area without placing a pin
    private func fetchSuggestions(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Set the region to the current camera position's region to get local results
        if let region = cameraPosition.region {
            let expandedRegion = MKCoordinateRegion(
                center: region.center,
                span: MKCoordinateSpan(
                    latitudeDelta: region.span.latitudeDelta * 2,
                    longitudeDelta: region.span.longitudeDelta * 2
                )
            )
            searchRequest.region = expandedRegion
        }
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
        let search = MKLocalSearch(request: searchRequest)
            search.start { response, error in
                if let error = error {
                    print("Error fetching suggestions: \(error.localizedDescription)")
                    return
                }
                
                guard let response = response else {
                    print("No suggestions found")
                    return
                }
                
                // Update search results for suggestions
                searchResults = response.mapItems
            }
        }
    }
    
    /// Select a search result and place a pin on the map
    private func selectSearchResult(_ item: MKMapItem) {
        if let coordinate = item.placemark.location?.coordinate {
            searchLocation = coordinate
            cameraPosition = .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
            searchResults = [] // Clear suggestions immediately
            searchQuery = ""
            isSearchFocused = false // Dismiss search focus
        }
    }
    
    /// Perform search on submit to find and center the map on the first result
    private func performSearch(query: String) {
        guard !query.isEmpty else { return }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let error = error {
                print("Error during search: \(error.localizedDescription)")
                return
            }
            
            guard let response = response, let firstResult = response.mapItems.first else {
                print("No results found")
                return
            }
            
            // Update the pin location and map region
            selectSearchResult(firstResult)
        }
    }
    
    func addExamLocation() {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        
        let timeComponents = calendar.dateComponents([.hour, .minute], from: examTime)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        // Combine the date and time into `currentDate`
        if let combinedDate = calendar.date(from: dateComponents) {
            currentDate = combinedDate
        }
        
        // Add the exam to the view model
        let response = viewModel.addExam(subject: examSubject,
                                         date: currentDate,
                                         location: examLocation,
                                         locationCoordinates: searchLocation!)
        if response {
            print("Exam added successfully")
        }
        
        // Pop the current view
        appCoordinator.pop()
        appCoordinator.pop()
    }
}

//#Preview {
//    AddExamMapView
//}
