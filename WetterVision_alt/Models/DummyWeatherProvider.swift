import Foundation

struct DummyWeatherProvider {
    static let cities: [WeatherData] = [
        WeatherData(
            cityName: "Berlin",
            temperature: 24.0,
            condition: .sunny,
            humidity: 40,
            windSpeed: 12.0
        ),
        WeatherData(
            cityName: "Hamburg",
            temperature: 14.0,
            condition: .rainy,
            humidity: 85,
            windSpeed: 25.0
        ),
        WeatherData(
            cityName: "München",
            temperature: -2.0,
            condition: .snowy,
            humidity: 70,
            windSpeed: 8.0
        ),
        WeatherData(
            cityName: "Köln",
            temperature: 18.0,
            condition: .cloudy,
            humidity: 60,
            windSpeed: 15.0
        ),
        WeatherData(
            cityName: "Frankfurt",
            temperature: 20.0,
            condition: .stormy,
            humidity: 75,
            windSpeed: 45.0
        )
    ]
}
