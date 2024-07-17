//
//  WeatherViewModel.swift
//  WeatherMap
//
//  Created by Natasha Radika on 13/07/24.
// test

import Foundation
import CoreLocation
import WeatherKit
import SwiftUI

class WeatherViewModel: ObservableObject {
    @Published var weather: HourWeather?
    @Published var precipitationProbability: Double?
    @Published var precipitationAmount: Measurement<UnitLength>?
    @Published var errorMessage: String?

    private let weatherManager = WeatherManager()

    func fetchWeather(for location: CLLocation, at date: Date) {
        Task {
            do {
                if let fetchedWeather = await weatherManager.getWeather(for: location, at: date) {
                    DispatchQueue.main.async {
                        self.weather = fetchedWeather
                        self.errorMessage = nil
                        self.precipitationProbability = fetchedWeather.precipitationChance
                        self.precipitationAmount = fetchedWeather.precipitationAmount
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Weather data not available."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
                }
            }
        }
    }
}
