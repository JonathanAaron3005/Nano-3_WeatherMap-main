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
    @State private var weatherData: [Int: WeatherData] = [:]
    
    var body: some View {
        VStack {
            MapView(cameraPosition: $cameraPosition, mapSelection: $mapSelection, results: $results, routes: $routes, selectedResult: $selectedResult, routeDisplaying: $routeDisplaying, myLocation: $myLocation, weatherBadges: $weatherBadges, weatherData: $weatherData)
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
    
    func fetchPlaceName(at coordinate: CLLocationCoordinate2D) async -> String? {
        return await withCheckedContinuation { continuation in
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Failed to fetch place name: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                } else if let placemark = placemarks?.first {
                    let placeName = placemark.name ?? placemark.locality ?? "Unknown Location"
                    continuation.resume(returning: placeName)
                } else {
                    continuation.resume(returning: "Unknown Location")
                }
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
    
    func fetchRoute() {
        routes.removeAll()
        var stops = selectedResult.map { $0 }

        // Check if the array contains an item with the same placemark name as myLocation
        if let myLocation = myLocation, !stops.contains(where: { $0.name == myLocation.name }) {
            stops.insert(myLocation, at: 0)
        }
        weatherBadges.removeAll()

        Task {
            var currentTime = date
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            
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
                        let location = stops[routeIndex + 1] // Use the next stop as the location

                        // Calculate the distance between steps
                        let stepDistance = step.distance // distance in meters

                        // Calculate the travel time based on average speed
                        let stepTravelTime = stepDistance / averageSpeed

                        // Calculate the estimated arrival time for each step
                        let stepArrivalTime = currentTime.addingTimeInterval(stepTravelTime)

                        if indices.contains(stepIndex) {
                            let placeName = await fetchPlaceName(at: coordinate)
                            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                            let addedLocation = MKMapItem(placemark: placemark)
                                                addedLocation.name = placeName ?? "Location \(stepIndex)"
                            if let weatherData = await fetchWeatherData(for: addedLocation, at: stepArrivalTime, stepIndex: stepIndex, timeString: timeFormatter.string(from: stepArrivalTime)) {
                                // Create a weather badge with the destination name
                                weatherBadges.append((routeIndex: routeIndex, stepIndex: stepIndex, time: weatherData.time, icon: weatherData.weatherIcon))

                                // Save the weather data for the step
                                self.weatherData[stepIndex] = weatherData
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

                if let rect = routes.first?.polyline.boundingMapRect, routeDisplaying {
                    cameraPosition = .rect(rect)
                }
            }
        }
    }

    func fetchWeatherData(for location: MKMapItem, at date: Date, stepIndex: Int, timeString: String) async -> WeatherData? {
        let weatherService = WeatherService.shared
        do {
            let weather = try await weatherService.weather(for: CLLocation(latitude: location.placemark.coordinate.latitude, longitude: location.placemark.coordinate.longitude))
            let hourlyForecasts = weather.hourlyForecast

            let hourlyForecast = hourlyForecasts.first { hour in
                Calendar.current.isDate(hour.date, equalTo: date, toGranularity: .hour)
            }

            if let hourlyForecast = hourlyForecast {
                let precipitationChance = hourlyForecast.precipitationChance
                let temperatureMeasurement = hourlyForecast.temperature
                let temperature = Int(temperatureMeasurement.converted(to: .celsius).value)
                let weatherDescription = getWeatherDescription(from: hourlyForecast.symbolName)
                
                let locationName = location.placemark.name ?? "Location \(stepIndex)"

                return WeatherData(
                    location: locationName,
                    weatherDescription: weatherDescription,
                    probability: precipitationChance,
                    precipitation: Int(precipitationChance * 100),
                    temperature: temperature,
                    time: timeString, weatherIcon: hourlyForecast.symbolName
                )
            } else {
                print("No weather data available at \(location.placemark.name)")
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
    
    func getWeatherDescription(from symbolName: String) -> String {
        print("Weather Symbol Name: \(symbolName)")
        let weatherDescriptions: [String: String] = [
            "clear_sky": "Clear Sky",
            "few_clouds": "Few Clouds",
            "scattered_clouds": "Scattered Clouds",
            "broken_clouds": "Broken Clouds",
            "shower_rain": "Shower Rain",
            "rain": "Rain",
            "thunderstorm": "Thunderstorm",
            "snow": "Snow",
            "mist": "Mist",
            "sun.max": "Sunny"
        ]

        return weatherDescriptions[symbolName] ?? "Unknown Weather"
    }
}

#Preview {
    ContentView()
}
