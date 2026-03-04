import Foundation

enum WeatherCondition: String, CaseIterable, Identifiable {
    case sunny = "Sonnig"
    case cloudy = "Bewölkt"
    case rainy = "Regen"
    case snowy = "Schnee"
    case stormy = "Gewitter"

    var id: String { rawValue }

    var sfSymbol: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .stormy: return "cloud.bolt.rain.fill"
        }
    }
}
