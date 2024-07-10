//
//  Place.swift
//  WeatherMap
//
//  Created by Jonathan Aaron Wibawa on 10/07/24.
//

import Foundation
import MapKit

class Place : Identifiable {
    var id = UUID()
    var startCoordinate: CLLocationCoordinate2D
    var DestinationCoordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(id: UUID = UUID(), startCoordinate: CLLocationCoordinate2D, DestinationCoordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        self.id = id
        self.startCoordinate = startCoordinate
        self.DestinationCoordinate = DestinationCoordinate
        self.title = title
        self.subtitle = subtitle
    }
}
