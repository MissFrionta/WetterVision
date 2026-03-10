import SwiftUI
import RealityKit

struct ContentView: View {

    @State private var cities = CityData.defaultCities
    @State private var selectedCity: City?

    // Globe rotation
    @State private var globeRotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))
    @State private var globeDragStart: simd_quatf = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))

    // Snow globe rotation (separate from earth globe)
    @State private var snowGlobeRotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))
    @State private var snowGlobeDragStart: simd_quatf = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))

    // Scale tracking (pinch gesture)
    @State private var globeScale: Float = 1.0
    @State private var globePinchStart: Float = 1.0
    @State private var snowGlobeScale: Float = 0.85  // base scale for snow globe
    @State private var snowGlobePinchStart: Float = 0.85

    @State private var globeEntity: Entity?
    @State private var snowGlobeEntity: Entity?

    var body: some View {
        RealityView { content, attachments in
            let root = Entity()
            root.name = "scene-root"

            // -- Globe --
            let globe = GlobeBuilder.buildGlobe(cities: cities)
            globe.name = "globe-container"
            globeEntity = globe
            root.addChild(globe)

            // City name labels
            for city in cities {
                if let attachment = attachments.entity(for: "label-\(city.name)") {
                    let labelPos = GlobeBuilder.latLonToPosition(
                        lat: city.latitude,
                        lon: city.longitude,
                        radius: GlobeBuilder.globeRadius + 0.045
                    )
                    attachment.position = labelPos
                    attachment.components.set(BillboardComponent())
                    globe.addChild(attachment)
                }
            }

            content.add(root)
        } update: { content, attachments in
            // Apply globe rotation + position + scale
            if let globe = globeEntity {
                globe.orientation = globeRotation
                globe.position.x = selectedCity != nil ? -0.20 : 0.0
                globe.scale = SIMD3<Float>(repeating: globeScale)
            }

            // Apply snow globe rotation + scale
            if let sg = snowGlobeEntity {
                sg.orientation = snowGlobeRotation
                sg.scale = SIMD3<Float>(repeating: snowGlobeScale)
            }

            // Show/hide snow globe
            updateSnowGlobe(content: content, attachments: attachments)
        } attachments: {
            ForEach(cities) { city in
                Attachment(id: "label-\(city.name)") {
                    Text(city.name)
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(6)
                }
            }

            if let city = selectedCity {
                Attachment(id: "weather-panel") {
                    WeatherPanelView(city: city)
                }
            }
        }
        // Drag gesture — rotates whichever entity is dragged
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    let translation = value.translation3D
                    let hAngle = Float(translation.x) * 0.01
                    let vAngle = Float(translation.y) * 0.01
                    let yaw = simd_quatf(angle: hAngle, axis: SIMD3(0, 1, 0))
                    let pitch = simd_quatf(angle: vAngle, axis: SIMD3(1, 0, 0))

                    if isDragOnSnowGlobe(value.entity) {
                        snowGlobeRotation = yaw * pitch * snowGlobeDragStart
                    } else {
                        globeRotation = yaw * pitch * globeDragStart
                    }
                }
                .onEnded { value in
                    if isDragOnSnowGlobe(value.entity) {
                        snowGlobeDragStart = snowGlobeRotation
                    } else {
                        globeDragStart = globeRotation
                    }
                }
        )
        // Tap gesture for pin selection
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    let tappedName = value.entity.name
                    if tappedName.hasPrefix("pin-head-") {
                        let cityName = String(tappedName.dropFirst("pin-head-".count))
                        selectCity(named: cityName)
                    } else if tappedName.hasPrefix("pin-") && !tappedName.hasPrefix("pin-head-") {
                        let cityName = String(tappedName.dropFirst("pin-".count))
                        selectCity(named: cityName)
                    } else {
                        // Tap on globe itself — deselect city
                        selectedCity = nil
                    }
                }
        )
        // Pinch gesture — scales whichever entity is pinched
        .gesture(
            MagnifyGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    let magnification = Float(value.magnification)
                    if isDragOnSnowGlobe(value.entity) {
                        let newScale = snowGlobePinchStart * magnification
                        snowGlobeScale = min(max(newScale, 0.4), 1.5)
                    } else {
                        let newScale = globePinchStart * magnification
                        globeScale = min(max(newScale, 0.5), 2.0)
                    }
                }
                .onEnded { value in
                    if isDragOnSnowGlobe(value.entity) {
                        snowGlobePinchStart = snowGlobeScale
                    } else {
                        globePinchStart = globeScale
                    }
                }
        )
    }

    // MARK: - Helpers

    private func selectCity(named cityName: String) {
        // Reset snow globe rotation + scale when switching cities
        snowGlobeRotation = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))
        snowGlobeDragStart = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))
        snowGlobeScale = 0.85
        snowGlobePinchStart = 0.85
        selectedCity = cities.first { $0.name == cityName }
    }

    /// Check if the dragged entity belongs to the snow globe (by walking up the hierarchy).
    private func isDragOnSnowGlobe(_ entity: Entity) -> Bool {
        var current: Entity? = entity
        while let e = current {
            if e.name.hasPrefix("snowglobe-") || e.name == "globe-glass" {
                return true
            }
            current = e.parent
        }
        return false
    }

    // MARK: - Snow Globe Management

    private func removeSnowGlobe() {
        if let existing = snowGlobeEntity {
            // Recursively remove all children first to free memory
            existing.children.forEach { $0.removeFromParent() }
            existing.removeFromParent()
            snowGlobeEntity = nil
        }
    }

    private func updateSnowGlobe(content: RealityViewContent, attachments: RealityViewAttachments) {
        if let city = selectedCity {
            // Only rebuild if city actually changed
            let targetName = "snowglobe-\(city.name)"
            if let existing = snowGlobeEntity {
                if existing.name == targetName {
                    return // Same city, nothing to do
                }
                removeSnowGlobe()
            }

            // Create new snow globe
            let newGlobe = VoxelBuilder.buildSnowGlobe(for: city.name)
            newGlobe.position = SIMD3<Float>(0.20, 0.0, 0.0)
            newGlobe.scale = SIMD3<Float>(repeating: snowGlobeScale)

            if let root = globeEntity?.parent {
                root.addChild(newGlobe)
            }
            snowGlobeEntity = newGlobe

            // Attach weather panel
            if let panel = attachments.entity(for: "weather-panel") {
                panel.position = SIMD3<Float>(0, -0.22, 0.18)
                panel.components.set(BillboardComponent())
                newGlobe.addChild(panel)
            }
        } else {
            removeSnowGlobe()
        }
    }
}

// MARK: - Weather Info Panel

struct WeatherPanelView: View {
    let city: City

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(Color(city.pinColor))
                    .frame(width: 10, height: 10)
                Text(city.name)
                    .font(.headline)
            }

            if let weather = CityData.dummyWeather[city.name] {
                HStack(spacing: 16) {
                    Label("\(weather.temperature)°C", systemImage: "thermometer")
                    Label(weather.condition.rawValue, systemImage: weatherIcon(weather.condition))
                }
                .font(.subheadline)

                HStack(spacing: 16) {
                    Label("\(weather.humidity)%", systemImage: "humidity")
                    Label("\(weather.windSpeed) km/h", systemImage: "wind")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Text(weather.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .frame(width: 200)
    }

    private func weatherIcon(_ condition: WeatherCondition) -> String {
        switch condition {
        case .sunny:  return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rainy:  return "cloud.rain.fill"
        case .snowy:  return "cloud.snow.fill"
        case .stormy: return "cloud.bolt.fill"
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
}
