//
//  SearchCompleter.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 19.01.2025.
//


import Combine
import Foundation
import MapKit

class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var suggestions: [MKLocalSearchCompletion] = []
    private let completer = MKLocalSearchCompleter()
    private var debounceTimer: AnyCancellable?

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address // Specify the types of results you want (e.g., .pointOfInterest, .query, etc.)
    }
    
    func updateQuery(_ query: String) {
        // Cancel any ongoing timer
        debounceTimer?.cancel()
        
        // Debounce the request for 0.5 seconds
        debounceTimer = Just(query)
            .delay(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] debouncedQuery in
                self?.completer.queryFragment = debouncedQuery
            }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.suggestions = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error with MKLocalSearchCompleter: \(error.localizedDescription)")
    }
}
