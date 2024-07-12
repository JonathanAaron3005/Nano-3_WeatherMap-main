import SwiftUI
import WeatherKit
import CoreLocation
import MapKit

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

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var lastMapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @State private var transportType: TransportType = .automobile
    @ObservedObject private var locationManager = LocationManager()
    @State private var additionalSearchTexts = [String]()
    @State private var searchTextIndex: Int?
    @State private var selectedResult = [MKMapItem]()
    
    var body: some View {
        VStack {
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
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                }
                
                ForEach(selectedResult, id: \.self) { item in
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                }
                
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 6)
                }
            }
            .overlay(alignment: .top) {
                VStack(spacing: -15) {
                    Form {
                        TextField("Current Location", text: $locationManager.locationName)
                            .font(.subheadline)
                            .background(Color.clear)
                            .onSubmit {
                                
                            }
                        
                        TextField("Search for a location...", text: $searchText)
                            .font(.subheadline)
                            .background(Color.clear)
                            .onSubmit {
                                Task { await searchPlaces(searchText: self.searchText) }
                            }
                        
                        ForEach(0..<additionalSearchTexts.count, id: \.self) { index in
                            TextField("Search for a location...", text: Binding(
                                get: { additionalSearchTexts[index] },
                                set: { newValue in
                                    additionalSearchTexts[index] = newValue
                                    searchTextIndex = index
                                }
                            ))
                            .font(.subheadline)
                            .background(Color.clear)
                            .onSubmit {
                                if let index = searchTextIndex {
                                    searchAndAddPlaces(index: index)
                                }
                            }
                        }
                        Button(action: {
                            additionalSearchTexts.append("")
                        }) {
                            Text("Add Stop")
                                .font(.subheadline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .background(.white)
                    .cornerRadius(20)
                    .frame(height: 200)
                    .padding()
                    .shadow(radius: 10)
                    
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
}

extension ContentView {
    func searchPlaces(searchText: String) async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        self.results += results?.mapItems ?? []
    }
    
    func searchAndAddPlaces(index: Int) {
        let searchText = additionalSearchTexts[index]
        Task {
            await searchPlaces(searchText: searchText)
        }
    }
    
    func fetchRoute() {
        if let mapSelection {
            
            let request = MKDirections.Request()
            if lastMapSelection == nil {
                request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
            } else {
                request.source = lastMapSelection
            }
            request.destination = mapSelection
            request.transportType = transportType.mkTransportType
            
            lastMapSelection = mapSelection
            
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
                
                self.selectedResult.append(mapSelection)
                self.results = []
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
