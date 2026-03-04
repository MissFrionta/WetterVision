import SwiftUI
import RealityKit
import Spatial

enum AppMode: String, CaseIterable {
    case classic = "Klassisch"
    case diorama = "Diorama"
}

class WeatherViewModel: ObservableObject {
    @Published var appMode: AppMode?
    @Published var selectedCityIndex: Int = 0
    @Published var dioramaRotation: Rotation3D = .identity
    @Published var dioramaScale: Double = 1.0

    // Base values stored when gesture ends
    var baseRotation: Rotation3D = .identity
    var baseScale: Double = 1.0

    let cities = DummyWeatherProvider.cities

    var currentWeather: WeatherData {
        cities[selectedCityIndex]
    }

    func selectCity(at index: Int) {
        guard index >= 0 && index < cities.count else { return }
        selectedCityIndex = index
    }

    func updateRotation(by delta: Rotation3D) {
        dioramaRotation = baseRotation.rotated(by: delta)
    }

    func commitRotation() {
        baseRotation = dioramaRotation
    }

    func updateScale(by magnification: Double) {
        let newScale = baseScale * magnification
        dioramaScale = min(max(newScale, 0.5), 2.0)
    }

    func commitScale() {
        baseScale = dioramaScale
    }
}
