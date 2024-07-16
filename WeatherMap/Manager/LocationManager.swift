import MapKit
import Foundation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    @Published var locationName: String = "Unknown"
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var errorMessage: String?

    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocationAccess()
    }

    private func requestLocationAccess() {
        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            errorMessage = "Location access is restricted or denied. Please enable it in settings."
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        @unknown default:
            errorMessage = "Unknown location authorization status."
        }
    }

    private func getLocationName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }

            if let error = error {
                self.errorMessage = "Failed to get location name: \(error.localizedDescription)"
                self.locationName = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
                return
            }

            if let placemark = placemarks?.first {
                self.locationName = [
                    placemark.name,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
            } else {
                self.locationName = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let twoDimensionLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.location = twoDimensionLocation
            getLocationName(from: location)
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Failed to find user's location: \(error.localizedDescription)"
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        requestLocationAccess()
    }
}
