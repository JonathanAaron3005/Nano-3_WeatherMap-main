//
//  WeatherFetchView.swift
//  WeatherMap
//
//  Created by Natasha Radika on 16/07/24.
//

import SwiftUI
import CoreLocation

struct WeatherFetchView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var selectedDate = Date()
    
   //  -6.212922, 106.848723
    // -2.556158, 140.692735
    private let location = CLLocation(latitude: -2.556158, longitude: 140.692735) // Example location

    var body: some View {
        VStack {
            DatePicker("", selection: $selectedDate)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()

            if let weather = viewModel.weather {
                Text("Weather at \(selectedDate):")
                Text("Temperature: \(weather.temperature.value, specifier: "%.1f") \(weather.temperature.unit.symbol)")
                Text("Condition: \(weather.condition.description)")
                
                if let precipitationProbability = viewModel.precipitationProbability {
                    Text("Precipitation Probability: \(Int(precipitationProbability * 100))%")
                }
                if let precipitationAmount = viewModel.precipitationAmount {
                    Text("Precipitation Amount: \(precipitationAmount.converted(to: .millimeters).value) mm")
                }
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
    WeatherFetchView()
}
