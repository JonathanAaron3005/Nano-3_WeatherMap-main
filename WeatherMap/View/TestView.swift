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
    @StateObject private var viewModel = WeatherViewModel()
    @State private var selectedDate = Date()
    private let location = CLLocation(latitude: 37.7749, longitude: -122.4194) // Example location

    var body: some View {
        VStack {
            DatePicker("Select Date and Time", selection: $selectedDate)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

            if let weather = viewModel.weather {
                Text("Weather at \(selectedDate):")
                Text("Temperature: \(weather.temperature.value, specifier: "%.1f") \(weather.temperature.unit.symbol)")
                Text("Condition: \(weather.condition.description)")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                Text("Select a date and time to see the weather.")
            }
        }
        .onAppear {
            viewModel.fetchWeather(for: location, at: selectedDate)
        }
        .onChange(of: selectedDate) { newDate in
            viewModel.fetchWeather(for: location, at: newDate)
        }
    }
}


#Preview {
    TestView()
}
