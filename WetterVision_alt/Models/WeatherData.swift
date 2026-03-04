import Foundation

struct WeatherData: Identifiable {
    let id = UUID()
    let cityName: String
    let temperature: Double
    let condition: WeatherCondition
    let humidity: Int
    let windSpeed: Double
}
