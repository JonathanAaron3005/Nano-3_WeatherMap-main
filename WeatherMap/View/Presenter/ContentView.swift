import SwiftUI
import WeatherKit
import CoreLocation
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        latitudinalMeters: 10000,
        longitudinalMeters: 10000
    ))
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
    @State private var myLocation: MKMapItem?
    @State private var selectedResult = [MKMapItem]()
    @State private var results = [MKMapItem]()
    @State private var date = Date()
    @State var weatherBadges = [(routeIndex: Int, stepIndex: Int, time: String, icon: String)]()
    
    var body: some View {
        VStack {
            MapView(cameraPosition: $cameraPosition, mapSelection: $mapSelection, results: $results, routes: $routes, selectedResult: $selectedResult, routeDisplaying: $routeDisplaying, myLocation: $myLocation, weatherBadges: $weatherBadges)
                .overlay(alignment: .top) {
                    VStack(spacing: -15) {
                        SearchFormView(searchText: $searchText, additionalSearchTexts: $additionalSearchTexts, searchTextIndex: $searchTextIndex, locationManager: locationManager, selectedResult: $selectedResult, myLocation: $myLocation, date: $date, transportType: $transportType, routeDisplaying: $routeDisplaying, routes: $routes, fetchRoute: fetchRoute)
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
        .onAppear {
            if let location = locationManager.location {
                myLocation = MKMapItem(placemark: .init(coordinate: location))
                let twoDimensionMyLocation = CLLocationCoordinate2D(latitude: (myLocation?.placemark.coordinate.latitude)!, longitude: (myLocation?.placemark.coordinate.longitude)!)
                cameraPosition = .region(.init(center: twoDimensionMyLocation, latitudinalMeters: 10000, longitudinalMeters: 10000))
                if myLocation?.name == "Unknown Location" {
                    myLocation?.name = "Your Location"
                }
                
            } else {
                ProgressView()
            }
        }
    }
    
    func searchPlaces(searchText: String) async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let twoDimensionMyLocation = CLLocationCoordinate2D(latitude: (myLocation?.placemark.coordinate.latitude)!, longitude: (myLocation?.placemark.coordinate.longitude)!)
        request.region = .init(center: twoDimensionMyLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        let results = try? await MKLocalSearch(request: request).start()
        self.results += results?.mapItems ?? []
    }
    
//    func fetchRoute() {
//        var stops = selectedResult.map { $0 }
//        stops.insert(myLocation!, at: 0)
//        
//        Task {
//            for i in 0..<stops.count - 1 {
//                let request = MKDirections.Request()
//                request.source = stops[i]
//                request.destination = stops[i + 1]
//                request.transportType = transportType.mkTransportType
//                
//                let result = try? await MKDirections(request: request).calculate()
//                if let route = result?.routes.first {
//                    routes.append(route)
//                    
//                    let eta = route.expectedTravelTime
//                    print("Estimated Travel Time: \(eta / 60) minutes")
//                    
//                    for step in route.steps {
//                        let coordinate = step.polyline.coordinate
//                        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//                        await fetchWeatherData(for: location)
//                    }
//                }
//            }
//            
//            self.results = []
//            self.selectedResult = stops
//            
//            withAnimation(.snappy) {
//                routeDisplaying = true
//                showDetails = false
//                
//                print(routes.first?.polyline)
//                if let rect = routes.first?.polyline.boundingMapRect, routeDisplaying {
//                    cameraPosition = .rect(rect)
//                }
//            }
//        }
//    }
    
    func fetchRoute() {
        let startTime = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!
        var stops = selectedResult.map { $0 }
        stops.insert(myLocation!, at: 0)
        weatherBadges.removeAll()

        Task {
            var currentTime = startTime
            
            for (routeIndex, _) in stops.enumerated() {
                guard routeIndex < stops.count - 1 else { break }

                let request = MKDirections.Request()
                request.source = stops[routeIndex]
                request.destination = stops[routeIndex + 1]
                request.transportType = transportType.mkTransportType

                let result = try? await MKDirections(request: request).calculate()
                if let route = result?.routes.first {
                    routes.append(route)

                    let totalTravelTime = route.expectedTravelTime
                    let totalDistance = route.distance
                    let averageSpeed = totalDistance / totalTravelTime // speed in meters per second

                    print("Average Speed: \(averageSpeed) m/s")

                    let totalSteps = route.steps.count
                    let indices = calculateWeatherBadgeIndices(totalTime: Int(totalTravelTime), totalSteps: totalSteps)

                    for (stepIndex, step) in route.steps.enumerated() {
                        let coordinate = step.polyline.coordinate
                        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

                        // Calculate the distance between steps
                        let stepDistance = step.distance // distance in meters

                        // Calculate the travel time based on average speed
                        let stepTravelTime = stepDistance / averageSpeed

                        // Calculate the estimated arrival time for each step
                        let stepArrivalTime = currentTime.addingTimeInterval(stepTravelTime)

                        if indices.contains(stepIndex) {
                            // Fetch the weather data for the estimated arrival time
                            if let precipitationChance = await fetchWeatherData(for: location, at: stepArrivalTime) {
                                // Create a weather badge
                                let timeFormatter = DateFormatter()
                                timeFormatter.dateFormat = "HH:mm"
                                let timeString = timeFormatter.string(from: stepArrivalTime)

                                let weatherIcon = getWeatherIcon(precipitationChance: precipitationChance)

                                weatherBadges.append((routeIndex: routeIndex, stepIndex: stepIndex, time: timeString, icon: weatherIcon))
                            }
                        }

                        // Update the current time for the next step
                        currentTime = stepArrivalTime
                    }
                }
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

    func fetchWeatherData(for location: CLLocation, at date: Date) async -> Double? {
        let weatherService = WeatherService.shared
        do {
            let weather = try await weatherService.weather(for: location)
            let hourlyForecasts = weather.hourlyForecast

            // Ensure the hourlyForecasts is not nil


            let hourlyForecast = hourlyForecasts.first { hour in
                Calendar.current.isDate(hour.date, equalTo: date, toGranularity: .hour)
            }

            if let hourlyForecast = hourlyForecast {
                let precipitationChance = hourlyForecast.precipitationChance
                print("Precipitation chance at \(location.coordinate.latitude), \(location.coordinate.longitude): \(precipitationChance * 100)%")
                return precipitationChance
            } else {
                print("No precipitation data available at \(location.coordinate.latitude), \(location.coordinate.longitude)")
                return nil
            }
        } catch {
            print("Failed to fetch weather data: \(error.localizedDescription)")
            return nil
        }
    }

    func calculateWeatherBadgeIndices(totalTime: Int, totalSteps: Int) -> [Int] {
        var indices = [0]
        
        if totalSteps > 2 {
            indices.append(Int(ceil(Double(totalSteps) / 2.0)))
        }
        
        indices.append(totalSteps - 1)
        
        return indices
    }

    func getWeatherIcon(precipitationChance: Double) -> String {
        switch precipitationChance {
        case 0..<0.2:
            return "sun.max.fill"
        case 0.2..<0.5:
            return "cloud.sun.fill"
        case 0.5..<0.8:
            return "cloud.rain.fill"
        case 0.8...1:
            return "cloud.heavyrain.fill"
        default:
            return "questionmark"
        }
    }
    
//    func fetchWeatherData(for location: CLLocation) async {
//        do {
//            let weatherService = WeatherService.shared
//            let weather = try await weatherService.weather(for: location)
//            
//            if let hourlyForecast = weather.hourlyForecast.first {
//                let precipitationChance = hourlyForecast.precipitationChance
//                print("Precipitation chance at \(location.coordinate.latitude), \(location.coordinate.longitude): \(precipitationChance * 100)%")
//            } else {
//                print("No precipitation data available at \(location.coordinate.latitude), \(location.coordinate.longitude)")
//            }
//        } catch {
//            print("Failed to fetch weather data: \(error.localizedDescription)")
//        }
//    }
}

#Preview {
    ContentView()
}
