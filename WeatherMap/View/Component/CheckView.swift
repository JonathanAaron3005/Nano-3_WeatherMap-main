//
//  NavigationView.swift
//  WeatherMap
//
//  Created by hendra on 15/07/24.
//

import SwiftUI
import MapKit

struct IdentifiablePlace: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var title: String?
}

class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate, ObservableObject {
    @Published var suggestions: [MKLocalSearchCompletion] = []
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.suggestions = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error retrieving search suggestions: \(error.localizedDescription)")
    }
}

struct CheckView: View {
    @State private var destination: String = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var annotation: IdentifiablePlace?
    @ObservedObject private var searchCompleterDelegate = SearchCompleterDelegate()
    
    private var completer = MKLocalSearchCompleter()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your destination", text: $destination)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: destination) { newValue in
                        completer.queryFragment = newValue
                    }
                
                List(searchCompleterDelegate.suggestions, id: \.self) { suggestion in
                    Text(suggestion.title)
                        .onTapGesture {
                            searchDestination(for: suggestion)
                        }
                }
                
                Map(coordinateRegion: $region, annotationItems: annotation != nil ? [annotation!] : []) { place in
                    MapPin(coordinate: place.coordinate)
                }
                .edgesIgnoringSafeArea(.all)
            }
            .navigationTitle("Destination Finder")
            .onAppear {
                completer.delegate = searchCompleterDelegate
            }
        }
    }
    
    private func searchDestination(for suggestion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestion)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, let item = response.mapItems.first else {
                return
            }
            
            let coordinate = item.placemark.coordinate
            let newAnnotation = IdentifiablePlace(coordinate: coordinate, title: item.name)
            annotation = newAnnotation
            
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
}

#Preview {
    CheckView()
}
