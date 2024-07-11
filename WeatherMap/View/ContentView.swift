//
//  ContentView.swift
//  WeatherMap
//
//  Created by hendra on 09/07/24.
//

import SwiftUI
import WeatherKit
import CoreLocation
import MapKit

//test

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

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @State private var transportType: TransportType = .automobile
    
    var body: some View {
        VStack {
            Picker("Transport Type", selection: $transportType) {
                Text("Automobile").tag(TransportType.automobile)
                Text("Walking").tag(TransportType.walking)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: transportType) { newValue in
                if routeDisplaying {
                    fetchRoute()
                }
            }
            
            Map(position: $cameraPosition, selection: $mapSelection) {
                Annotation("My Location", coordinate: .userLocation) {
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
                ForEach(results, id: \.self) { item in
                    if routeDisplaying {
                        if item == routeDestination {
                            let placemark = item.placemark
                            Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                        }
                    } else {
                        let placemark = item.placemark
                        Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                    }
                }
                
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 6)
                }
            }
            .overlay(alignment: .top) {
                TextField("Search for a location...", text: $searchText)
                    .font(.subheadline)
                    .padding(12)
                    .background(.white)
                    .padding()
                    .shadow(radius: 10)
            }
            .onSubmit(of: .text) {
                Task { await searchPlaces() }
            }
            .onChange(of: getDirections) { oldValue, newValue in
                if newValue {
                    fetchRoute()
                }
            }
            .onChange(of: mapSelection) { oldValue, newValue in
                showDetails = newValue != nil
            }
            .sheet(isPresented: $showDetails) {
                LocationDetailsView(mapSelection: $mapSelection, show: $showDetails, getDirections: $getDirections)
                    .presentationDetents([.height(340)])
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                    .presentationCornerRadius(12)
            }
            .mapControls {
                MapCompass()
                MapPitchToggle()
                MapUserLocationButton()
            }
        }
    }
}

extension ContentView {
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
    
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
            request.destination = mapSelection
            request.transportType = transportType.mkTransportType
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                
                if let route {
                    let eta = route.expectedTravelTime
                    print("Estimated Travel Time: \(eta / 60) minutes")
                    
                    for step in route.steps {
                        let coordinate = step.polyline.coordinate
                        print("longitude: \(coordinate.longitude), latitude: \(coordinate.latitude)")
                        
                        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        await fetchWeatherData(for: location)
                    }
                }
                
                routeDestination = mapSelection
                
                withAnimation(.snappy) {
                    routeDisplaying = true
                    showDetails = false
                    
                    if let rect = route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(rect)
                    }
                }
            }
        }
    }
}

func fetchWeatherData(for location: CLLocation) async {
    do {
        let weatherService = WeatherService.shared
        let weather = try await weatherService.weather(for: location)
        
        if let hourlyForecast = weather.hourlyForecast.first {
            let precipitationChance = hourlyForecast.precipitationChance
            print("Precipitation chance at \(location.coordinate.latitude), \(location.coordinate.longitude): \(precipitationChance * 100)%")
        } else {
            print("No precipitation data available at \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    } catch {
        print("Failed to fetch weather data: \(error.localizedDescription)")
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 25.7602, longitude: -80.1959)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}

#Preview {
    ContentView()
}
