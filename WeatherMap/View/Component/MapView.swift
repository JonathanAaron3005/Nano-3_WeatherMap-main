//
//  MapView.swift
//  WeatherMap
//
//  Created by Jonathan Aaron Wibawa on 15/07/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var cameraPosition: MapCameraPosition
    @Binding var mapSelection: MKMapItem?
    @Binding var results: [MKMapItem]
    @Binding var routes: [MKRoute]
    @Binding var selectedResult: [MKMapItem]
    @Binding var routeDisplaying: Bool
    @Binding var myLocation: MKMapItem?
    @Binding var weatherBadges: [(routeIndex: Int, stepIndex: Int, time: String, icon: String)]
    
    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection) {
            if let myLocation = myLocation {
                Annotation("My Location", coordinate: myLocation.placemark.coordinate) {
                    ZStack {
                        Circle()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.blue.opacity(0.25))
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white)
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(.blue)
                    }
                }
            }
            //            ForEach(results, id: \.self) { item in
            //                let placemark = item.placemark
            //                Marker(placemark.name ?? "", coordinate: placemark.coordinate)
            //            }
            ForEach(selectedResult, id: \.self) { item in
                let placemark = item.placemark
                Marker(placemark.name ?? "", coordinate: placemark.coordinate)
            }
            
            ForEach(routes.indices, id: \.self) { routeIndex in
                let route = routes[routeIndex]
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
                
                ForEach(weatherBadges.filter { $0.routeIndex == routeIndex }, id: \.stepIndex) { badge in
                    Annotation("Weather Badge", coordinate: route.steps[badge.stepIndex].polyline.coordinate) {
                        WeatherBadge(time: .constant(badge.time), icon: .constant(badge.icon))
                    }
                }
            }
            
            ForEach(routes, id: \.self) { route in
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
            }
            
        }
    }
}
