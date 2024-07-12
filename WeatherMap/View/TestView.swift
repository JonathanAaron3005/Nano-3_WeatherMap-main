//
//  TestView.swift
//  WeatherMap
//
//  Created by Natasha Radika on 12/07/24.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct TestView: View {
    let weatherManager = WeatherManager.shared
    @StateObject private var viewModel = LocationViewModel()

   @State private var currentWeather: CurrentWeather?
    @State private var hourWeather: HourWeather?

    @State private var isLoading = false

    let coordinate = CLLocation(latitude: 32.151533,  longitude: -80.760289)
    let locationCoordinate = GetLocData()


    var body: some View {
        VStack {
            Text("test")
            if isLoading {
                ProgressView()
                Text("Fetching weather...")
            } else {
                if let currentWeather {
                    if let errorMessage = viewModel.errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                        } else {
                            Text("Place Name: \(viewModel.placeName)")
                        }
                    Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                    Text(Date.now.formatted(date: .omitted, time: .shortened))
                    Image(systemName: currentWeather.symbolName)
                    let temp = weatherManager.temperatureFormatter.string(from: currentWeather.temperature)
                    Text(temp).font(.title2)
                    Text(currentWeather.condition.description).font(.title3)
                }
            }
        }
        .padding()
        .task {
            isLoading = true
//            let specificDate = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date()) ?? Date()
//            Task.detached { @MainActor in
//                hourWeather = await weatherManager.getWeather(for: coordinate, at: specificDate)
//                
//
//            }
            Task.detached { @MainActor in
                currentWeather = await weatherManager.currentWeather(for: CLLocation(latitude: 32.151533,  longitude: -80.760289))
            }
            isLoading = false
        }
        .onAppear {
                    viewModel.fetchPlaceName(latitude: 32.151533, longitude: -80.760289)
                }
    }
}

#Preview {
    TestView()
}
