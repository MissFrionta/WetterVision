import Foundation

/// Fetches real weather data from the Open-Meteo API (free, no API key needed).
@Observable
class WeatherService {

    var weather: [String: WeatherInfo] = [:]
    var lastFetch: Date?

    /// Fetch weather for all cities. Safe to call multiple times (caches for 10 min).
    func fetchAll(cities: [City]) async {
        // Don't refetch within 10 minutes
        if let last = lastFetch, Date().timeIntervalSince(last) < 600 {
            return
        }

        for city in cities {
            do {
                let info = try await fetchWeather(lat: city.latitude, lon: city.longitude)
                await MainActor.run {
                    weather[city.name] = info
                }
            } catch {
                print("WeatherService: failed to fetch \(city.name): \(error)")
                // Keep dummy data as fallback
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

    private func fetchWeather(lat: Float, lon: Float) async throws -> WeatherInfo {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)

        let condition = mapWMOCode(response.current.weather_code)
        return WeatherInfo(
            condition: condition,
            temperature: Int(response.current.temperature_2m),
            humidity: Int(response.current.relative_humidity_2m),
            windSpeed: Int(response.current.wind_speed_10m),
            description: condition.rawValue
        )
    }

    /// Maps Open-Meteo WMO weather codes to our WeatherCondition enum.
    /// https://open-meteo.com/en/docs — WMO Weather interpretation codes
    private func mapWMOCode(_ code: Int) -> WeatherCondition {
        switch code {
        case 0:           return .sunny      // Clear sky
        case 1, 2, 3:     return .cloudy     // Mainly clear, partly cloudy, overcast
        case 45, 48:      return .cloudy     // Fog
        case 51, 53, 56:  return .drizzle    // Drizzle (light, moderate, freezing)
        case 55, 57:      return .drizzle    // Drizzle (dense, freezing dense)
        case 61, 63:      return .rainy      // Rain (slight, moderate)
        case 65, 66, 67:  return .rainy      // Rain (heavy, freezing)
        case 71, 73, 75:  return .snowy      // Snow (slight, moderate, heavy)
        case 77:          return .snowy      // Snow grains
        case 80, 81, 82:  return .rainy      // Rain showers
        case 85, 86:      return .snowy      // Snow showers
        case 95:          return .stormy     // Thunderstorm
        case 96, 99:      return .stormy     // Thunderstorm with hail
        default:          return .cloudy
        }
    }
}

// MARK: - Open-Meteo JSON Response

private struct OpenMeteoResponse: Decodable {
    let current: CurrentWeather
}

private struct CurrentWeather: Decodable {
    let temperature_2m: Double
    let relative_humidity_2m: Double
    let weather_code: Int
    let wind_speed_10m: Double
}
