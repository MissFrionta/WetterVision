import Foundation
import UIKit

struct City: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Float   // degrees
    let longitude: Float  // degrees
    let pinColor: UIColor
}

/// Dummy weather data — real API integration comes later.
struct WeatherInfo {
    let condition: WeatherCondition
    let temperature: Int      // °C
    let humidity: Int          // %
    let windSpeed: Int         // km/h
    let description: String
}

enum WeatherCondition: String, CaseIterable {
    case sunny   = "Sonnig"
    case cloudy  = "Bewölkt"
    case drizzle = "Nieselregen"
    case rainy   = "Regnerisch"
    case snowy   = "Schnee"
    case windy   = "Windig"
    case stormy  = "Gewitter"
}

/// Central data source for cities and weather.
struct CityData {
    static let defaultCities: [City] = [
        City(name: "Berlin",   latitude: 52.52,  longitude: 13.41,   pinColor: UIColor(red: 0.90, green: 0.25, blue: 0.20, alpha: 1)),
        City(name: "New York", latitude: 40.71,  longitude: -74.01,  pinColor: UIColor(red: 0.20, green: 0.60, blue: 0.95, alpha: 1)),
        City(name: "Tokio",    latitude: 35.68,  longitude: 139.69,  pinColor: UIColor(red: 0.95, green: 0.80, blue: 0.20, alpha: 1)),
    ]

    /// Dummy weather for each city — keyed by city name.
    static let dummyWeather: [String: WeatherInfo] = [
        // --- TEST: Alle Städte auf gleiches Wetter zum Testen ---
        "Berlin":   WeatherInfo(condition: .cloudy, temperature: 12, humidity: 65, windSpeed: 15, description: "Bewölkt"),
        "New York": WeatherInfo(condition: .cloudy, temperature: 14, humidity: 60, windSpeed: 12, description: "Bewölkt"),
        "Tokio":    WeatherInfo(condition: .cloudy, temperature: 18, humidity: 70, windSpeed: 10, description: "Bewölkt"),
        "London":   WeatherInfo(condition: .cloudy, temperature: 10, humidity: 80, windSpeed: 25, description: "Stark bewölkt"),
    ]
}
