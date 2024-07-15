//
//  TransportTypePicker.swift
//  WeatherMap
//
//  Created by Jonathan Aaron Wibawa on 15/07/24.
//

import SwiftUI

struct TransportTypePicker: View {
    @Binding var transportType: TransportType
    @Binding var routeDisplaying: Bool
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
                fetchRoute()
            }
        }
    }
}



