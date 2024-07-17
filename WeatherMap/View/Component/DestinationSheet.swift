//
//  DestinationSheet.swift
//  WeatherMap
//
//  Created by hendra on 16/07/24.
//

import SwiftUI
import MapKit

struct DestinationSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @Binding var title: String
    @Binding var selectedResult: [MKMapItem]
    @Binding var myLocation: MKMapItem?
    
    @ObservedObject private var searchCompleterDelegate = SearchCompleterDelegate()
    
    private var searchCompleter = MKLocalSearchCompleter()
    var fetchRoute: () -> Void

    init(title: Binding<String>, selectedResult: Binding<[MKMapItem]>, fetchRoute: @escaping () -> Void, myLocation: Binding<MKMapItem?>) {
        _selectedResult = selectedResult
        _title = title
        _myLocation = myLocation
        self.fetchRoute = fetchRoute
        searchCompleter.delegate = searchCompleterDelegate
    }

    var body: some View {
        NavigationView {
            VStack {
                List(searchCompleterDelegate.suggestions, id: \.self) { suggestion in
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .foregroundColor(.orange)
                        VStack(alignment: .leading) {
                            Text(suggestion.title)
                            Text(suggestion.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        // Handle the selection of a search result
                        selectDestination(suggestion)
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .onChange(of: searchText) { newValue in
                    searchCompleter.queryFragment = newValue
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func selectDestination(_ suggestion: MKLocalSearchCompletion) {
        // Implement the selection action, e.g., navigate to the destination or update the state
        let searchRequest = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, let mapItem = response.mapItems.first else { return }
            print("Selected destination: \(mapItem.name ?? "Unknown") at \(mapItem.placemark.coordinate)")
            if (title == "Your Location") {
                myLocation = mapItem
            }else {
                selectedResult.append(mapItem)
                fetchRoute()
            }
            
            dismiss()
            // Handle the selected destination, e.g., update map region or annotation
        }
    }
}

#Preview {
    DestinationSheet(title: .constant(""), selectedResult: .constant([MKMapItem]()), fetchRoute: {
        print("tes")
    }, myLocation: .constant(MKMapItem()))
}
