//
//  Place.swift
//  WeatherMap
//
//  Created by Jonathan Aaron Wibawa on 10/07/24.
//

import Foundation
import MapKit
import SwiftData

@Model
class Place : Identifiable {
    @Attribute(.unique) var id: UUID
    var startLatitude: Double
    var startLongitude: Double
    var destinationLatitude: Double
    var destinationLongitude: Double
    var title: String?
    var subtitle: String?
    
    init(id: UUID = UUID(), startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        self.id = id
        self.startLatitude = startCoordinate.latitude
        self.startLongitude = startCoordinate.longitude
        self.destinationLatitude = destinationCoordinate.latitude
        self.destinationLongitude = destinationCoordinate.longitude
        self.title = title
        self.subtitle = subtitle
    }
    
    var startCoordinate: CLLocationCoordinate2D {
        get {
            CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude)
        }
        set {
            startLatitude = newValue.latitude
            startLongitude = newValue.longitude
        }
    }
    
    var destinationCoordinate: CLLocationCoordinate2D {
        get {
            CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude)
        }
        set {
            destinationLatitude = newValue.latitude
            destinationLongitude = newValue.longitude
        }
    }
}
