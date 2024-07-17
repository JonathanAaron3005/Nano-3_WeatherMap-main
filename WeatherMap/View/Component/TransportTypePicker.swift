//
//  TransportTypePicker.swift
//  WeatherMap
//
//  Created by Jonathan Aaron Wibawa on 15/07/24.
//

import SwiftUI
import MapKit

struct TransportTypePicker: View {
    @Binding var transportType: TransportType
    @Binding var routeDisplaying: Bool
<<<<<<< HEAD
=======
    @Binding var routes: [MKRoute]
    
>>>>>>> dev-merge
    var fetchRoute: () -> Void
    
    var body: some View {
        Picker("Transport Type", selection: $transportType) {
            Text("Automobile").tag(TransportType.automobile)
            Text("Walking").tag(TransportType.walking)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        .onChange(of: transportType) { _, newValue in
            if routeDisplaying {
<<<<<<< HEAD
=======
                routes.removeAll()
>>>>>>> dev-merge
                fetchRoute()
            }
        }
    }
}

<<<<<<< HEAD
enum TransportType: String, Hashable {
    case automobile
    case walking
    
    var mkTransportType: MKDirectionsTransportType {
        switch self {
        case .automobile:
            return .automobile
        case .walking:
            return .walking
        }
    }
}
=======
>>>>>>> dev-merge



