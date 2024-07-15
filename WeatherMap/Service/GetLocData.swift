//
//  LocationManager.swift
//  WeatherMap
//
//  Created by Natasha Radika on 12/07/24.
//

import CoreLocation

class GetLocData: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getLocationName(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String?, Error?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let placemarks = placemarks, let placemark = placemarks.first else {
                completion(nil, NSError(domain: "No placemarks found", code: 0, userInfo: nil))
                return
            }
            
            if let placeName = placemark.name {
                completion(placeName, nil)
            } else {
                completion(nil, NSError(domain: "Place name not found", code: 0, userInfo: nil))
            }
        }
    }
    
    // Additional methods for CLLocationManagerDelegate can be implemented here
}


class LocationViewModel: ObservableObject {
    @Published var placeName: String = ""
    @Published var errorMessage: String?
    
    private let locationManager = GetLocData()
    
    func fetchPlaceName(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        locationManager.getLocationName(latitude: latitude, longitude: longitude) { [weak self] placeName, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if let placeName = placeName {
                    self?.placeName = placeName
                } else {
                    self?.errorMessage = "Unknown error"
                }
            }
        }
    }
}
