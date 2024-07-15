import SwiftUI
import WeatherKit
import CoreLocation
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var searchTextIndex: Int?
    @State private var additionalSearchTexts = [String]()
    @State private var mapSelection: MKMapItem?
    @State private var lastMapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var routes = [MKRoute]()
    @State private var routeDestination: MKMapItem?
    @State private var transportType: TransportType = .automobile
    @ObservedObject private var locationManager = LocationManager()
    @State private var selectedResult = [MKMapItem]()
    @State private var results = [MKMapItem]()
    
    var body: some View {
        VStack {
            MapView(cameraPosition: $cameraPosition, mapSelection: $mapSelection, results: $results, routes: $routes, selectedResult: $selectedResult, routeDisplaying: $routeDisplaying)
                .overlay(alignment: .top) {
                    VStack(spacing: -15) {
                        SearchFormView(searchText: $searchText, additionalSearchTexts: $additionalSearchTexts, searchTextIndex: $searchTextIndex, locationManager: locationManager, searchPlaces: searchPlaces)
                        TransportTypePicker(transportType: $transportType, routeDisplaying: $routeDisplaying, fetchRoute: fetchRoute)
                    }
                }
                .onChange(of: getDirections) { _, newValue in
                    fetchRoute()
                }
                .onChange(of: mapSelection) { _, newValue in
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
    
    func searchPlaces(searchText: String) async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        self.results += results?.mapItems ?? []
    }
    
    func fetchRoute() {
        guard let mapSelection = mapSelection else { return }
        
        selectedResult.append(mapSelection)
        
        var stops = selectedResult.map { $0 }
        stops.insert(MKMapItem(placemark: .init(coordinate: .userLocation)), at: 0)
        for stop in stops {
            print(stop)
        }
        
        Task {
            for i in 0..<stops.count - 1 {
                let request = MKDirections.Request()
                request.source = stops[i]
                request.destination = stops[i + 1]
                request.transportType = transportType.mkTransportType
                
                let result = try? await MKDirections(request: request).calculate()
                if let route = result?.routes.first {
                    routes.append(route)
                    
                    for step in route.steps {
                        let coordinate = step.polyline.coordinate
                        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        await fetchWeatherData(for: location)
                    }
                }
            }
            
            if let firstRoute = routes.first {
                let eta = firstRoute.expectedTravelTime
                print("Estimated Travel Time: \(eta / 60) minutes")
            }
            
            self.results = []
            self.selectedResult = stops
            
            withAnimation(.snappy) {
                routeDisplaying = true
                showDetails = false
                
                print(routes.first?.polyline)
                if let rect = routes.first?.polyline.boundingMapRect, routeDisplaying {
                    cameraPosition = .rect(rect)
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
