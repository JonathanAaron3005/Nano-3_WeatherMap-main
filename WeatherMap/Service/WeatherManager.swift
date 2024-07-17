//
//  WeatherManager.swift
//  WeatherMap
//
//  Created by Natasha Radika on 11/07/24.
//

import Foundation
import WeatherKit
import CoreLocation

class WeatherManager {
    static let shared = WeatherManager()
    let service = WeatherService.shared
    
    var temperatureFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
    
    func currentWeather(for location: CLLocation) async -> CurrentWeather? {
            let currentWeather = await Task.detached(priority: .userInitiated) {
                let forecast = try? await self.service.weather(
                    for: location,
                    // ganti ke minute hour atau yg lain
                    including: .current
                )
                return forecast
            }.value
            return currentWeather
        }
    
    
    func getWeather(for location: CLLocation, at date: Date) async -> HourWeather? {
            // Ensure the date is within the range of available forecast data
            guard let hourlyForecast = try? await service.weather(for: location, including: .hourly) else {
                return nil
            }

            // Find the forecast closest to the specified date
            let closestForecast = hourlyForecast.forecast.closest(to: date)

            return closestForecast
        }

    
}

extension Array where Element == HourWeather {
    func closest(to date: Date) -> HourWeather? {
        return self.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
    }
}
