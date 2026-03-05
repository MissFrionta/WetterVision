import SwiftUI
import RealityKit

struct ContentView: View {

    @State private var cities = CityData.defaultCities
    @State private var selectedCity: City?

    // Globe rotation tracking
    @State private var currentRotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))
    @State private var dragStartRotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))

    @State private var globeEntity: Entity?
    @State private var snowGlobeEntity: Entity?

    var body: some View {
        RealityView { content, attachments in
            let root = Entity()
            root.name = "scene-root"

            // -- Globe (left side when snow globe is visible, centered otherwise) --
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
            // Apply globe rotation
            if let globe = globeEntity {
                globe.orientation = currentRotation

                // Shift globe left when a city is selected, center when not
                let targetX: Float = selectedCity != nil ? -0.20 : 0.0
                globe.position.x = targetX
            }

            // Show/hide snow globe
            updateSnowGlobe(content: content, attachments: attachments)
        } attachments: {
            // City name labels on globe
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

            // Weather info panel (attached to snow globe)
            if let city = selectedCity {
                Attachment(id: "weather-panel") {
                    WeatherPanelView(city: city)
                }
            }
        }
        // Drag gesture for globe rotation
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    let translation = value.translation3D
                    let horizontalAngle = Float(translation.x) * 0.005
                    let verticalAngle = Float(translation.y) * -0.005

                    let yawRotation = simd_quatf(angle: horizontalAngle, axis: SIMD3(0, 1, 0))
                    let pitchRotation = simd_quatf(angle: verticalAngle, axis: SIMD3(1, 0, 0))

                    currentRotation = yawRotation * pitchRotation * dragStartRotation
                }
                .onEnded { _ in
                    dragStartRotation = currentRotation
                }
        )
        // Tap gesture for pin selection
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    let tappedName = value.entity.name
                    if tappedName.hasPrefix("pin-head-") {
                        let cityName = String(tappedName.dropFirst("pin-head-".count))
                        withAnimation(.easeInOut(duration: 0.4)) {
                            selectedCity = cities.first { $0.name == cityName }
                        }
                    } else if tappedName.hasPrefix("pin-") && !tappedName.hasPrefix("pin-head-") {
                        let cityName = String(tappedName.dropFirst("pin-".count))
                        withAnimation(.easeInOut(duration: 0.4)) {
                            selectedCity = cities.first { $0.name == cityName }
                        }
                    }
                }
        )
    }

    // MARK: - Snow Globe Management

    private func updateSnowGlobe(content: RealityViewContent, attachments: RealityViewAttachments) {
        if let city = selectedCity {
            // Remove old snow globe if city changed
            if let existing = snowGlobeEntity, existing.name != "snowglobe-\(city.name)" {
                existing.removeFromParent()
                snowGlobeEntity = nil
            }

            // Create new snow globe if needed
            if snowGlobeEntity == nil {
                let newGlobe = VoxelBuilder.buildSnowGlobe(for: city.name)
                newGlobe.position = SIMD3<Float>(0.20, 0.0, 0.0) // right side
                newGlobe.scale = SIMD3<Float>(repeating: 0.85)

                if let root = globeEntity?.parent {
                    root.addChild(newGlobe)
                }
                snowGlobeEntity = newGlobe

                // Attach weather panel below snow globe
                if let panel = attachments.entity(for: "weather-panel") {
                    panel.position = SIMD3<Float>(0, -0.24, 0)
                    panel.components.set(BillboardComponent())
                    newGlobe.addChild(panel)
                }
            }
        } else {
            // No city selected — remove snow globe
            snowGlobeEntity?.removeFromParent()
            snowGlobeEntity = nil
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
