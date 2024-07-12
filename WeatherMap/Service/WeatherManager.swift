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
        let hourlyWeather = await Task.detached(priority: .userInitiated) {
            let forecast = try? await self.service.weather(for: location, including: .hourly)
            return forecast
        }.value
        
        guard let hourlyWeather = hourlyWeather else {
            return nil
        }
        
        // Find the closest hour forecast to the specified date
        if let closestHourWeather = hourlyWeather.first(where: { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .hour) }) {
            return closestHourWeather
        }
        
        return nil
    }
    
}
