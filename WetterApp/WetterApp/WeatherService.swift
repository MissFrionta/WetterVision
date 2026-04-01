import Foundation

/// Fetches real weather data from the Open-Meteo API (free, no API key needed).
@Observable
class WeatherService {

    var weather: [String: WeatherInfo] = [:]
    var forecasts: [String: [DayForecast]] = [:]
    var lastFetch: Date?

    /// Fetch weather for all cities. Safe to call multiple times (caches for 10 min).
    func fetchAll(cities: [City]) async {
        // Don't refetch within 10 minutes
        if let last = lastFetch, Date().timeIntervalSince(last) < 600 {
            return
        }

        for city in cities {
            do {
                let (info, daily) = try await fetchWeather(lat: city.latitude, lon: city.longitude)
                await MainActor.run {
                    weather[city.name] = info
                    forecasts[city.name] = daily
                }
            } catch {
                print("WeatherService: failed to fetch \(city.name): \(error)")
                if weather[city.name] == nil {
                    await MainActor.run {
                        weather[city.name] = CityData.dummyWeather[city.name]
                    }
                }
            }
        }

        await MainActor.run {
            lastFetch = Date()
        }
    }

    private func fetchWeather(lat: Float, lon: Float) async throws -> (WeatherInfo, [DayForecast]) {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=7"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)

        // Current weather
        let condition = mapWMOCode(response.current.weather_code)
        let info = WeatherInfo(
            condition: condition,
            temperature: Int(response.current.temperature_2m),
            humidity: Int(response.current.relative_humidity_2m),
            windSpeed: Int(response.current.wind_speed_10m),
            description: condition.rawValue
        )

        // 7-day forecast
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var daily: [DayForecast] = []
        for i in 0..<response.daily.time.count {
            let date = dateFormatter.date(from: response.daily.time[i]) ?? Date()
            let dayCondition = mapWMOCode(response.daily.weather_code[i])
            daily.append(DayForecast(
                date: date,
                condition: dayCondition,
                tempHigh: Int(response.daily.temperature_2m_max[i]),
                tempLow: Int(response.daily.temperature_2m_min[i])
            ))
        }

        return (info, daily)
    }

    /// Maps Open-Meteo WMO weather codes to our WeatherCondition enum.
    /// https://open-meteo.com/en/docs — WMO Weather interpretation codes
    private func mapWMOCode(_ code: Int) -> WeatherCondition {
        switch code {
        case 0:           return .sunny
        case 1, 2, 3:     return .cloudy
        case 45, 48:      return .cloudy
        case 51, 53, 56:  return .drizzle
        case 55, 57:      return .drizzle
        case 61, 63:      return .rainy
        case 65, 66, 67:  return .rainy
        case 71, 73, 75:  return .snowy
        case 77:          return .snowy
        case 80, 81, 82:  return .rainy
        case 85, 86:      return .snowy
        case 95:          return .stormy
        case 96, 99:      return .stormy
        default:          return .cloudy
        }
    }
}

// MARK: - Open-Meteo JSON Response

private struct OpenMeteoResponse: Decodable {
    let current: CurrentWeather
    let daily: DailyWeather
}

private struct CurrentWeather: Decodable {
    let temperature_2m: Double
    let relative_humidity_2m: Double
    let weather_code: Int
    let wind_speed_10m: Double
}

private struct DailyWeather: Decodable {
    let time: [String]
    let weather_code: [Int]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
}
