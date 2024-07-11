//
//  AddPlaceView.swift
//  WeatherMap
//
//  Created by hendra on 10/07/24.
//

import SwiftUI
import MapKit

struct AddPlaceView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PlaceViewModel
    
    @State private var title: String = ""
    @State private var subtitle: String = ""
    @State private var startLatitude: String = ""
    @State private var startLongitude: String = ""
    @State private var destinationLatitude: String = ""
    @State private var destinationLongitude: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Title", text: $title)
                }
                
                Section(header: Text("Subtitle")) {
                    TextField("Subtitle", text: $subtitle)
                }
                
                Section(header: Text("Start Coordinate")) {
                    TextField("Latitude", text: $startLatitude)
                        .keyboardType(.decimalPad)
                    TextField("Longitude", text: $startLongitude)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Destination Coordinate")) {
                    TextField("Latitude", text: $destinationLatitude)
                        .keyboardType(.decimalPad)
                    TextField("Longitude", text: $destinationLongitude)
                        .keyboardType(.decimalPad)
                }
                
                Button(action: addPlace) {
                    Text("Add Place")
                }
            }
            .navigationTitle("New Place")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func addPlace() {
        guard let startLat = Double(startLatitude),
              let startLon = Double(startLongitude),
              let destLat = Double(destinationLatitude),
              let destLon = Double(destinationLongitude) else {
            // Handle invalid input
            return
        }
        
        let startCoordinate = CLLocationCoordinate2D(latitude: startLat, longitude: startLon)
        let destinationCoordinate = CLLocationCoordinate2D(latitude: destLat, longitude: destLon)
        
        viewModel.addPlace(startCoordinate: startCoordinate, destinationCoordinate: destinationCoordinate, title: title, subtitle: subtitle)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlaceView(viewModel: PlaceViewModel())
    }
}
