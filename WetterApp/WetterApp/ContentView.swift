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
            let globe = await GlobeBuilder.buildGlobe(cities: cities)
            globe.name = "globe-container"
            globeEntity = globe
            root.addChild(globe)

            // City labels (tappable, floating above markers)
            for city in cities {
                if let attachment = attachments.entity(for: "label-\(city.name)") {
                    attachment.name = "label-\(city.name)"
                    let labelPos = GlobeBuilder.latLonToPosition(
                        lat: city.latitude,
                        lon: city.longitude + GlobeBuilder.lonOffset,
                        radius: GlobeBuilder.globeRadius + GlobeBuilder.stickHeight + 0.018
                    )
                    attachment.position = labelPos
                    attachment.components.set(BillboardComponent())
                    attachment.components.set(InputTargetComponent(allowedInputTypes: .indirect))
                    attachment.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.045)]))
                    attachment.components.set(HoverEffectComponent())
                    globe.addChild(attachment)
                }
            }

            content.add(root)
        } update: { content, attachments in
            // Apply globe rotation + position + scale
            if let globe = globeEntity {
                globe.orientation = globeRotation
                let hasSnowGlobe = selectedCity != nil || snowGlobeEntity != nil
                globe.position.x = hasSnowGlobe ? -0.20 : 0.0
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
                    Button {
                        selectCity(named: city.name)
                    } label: {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(city.pinColor))
                                .frame(width: 10, height: 10)
                            Text(city.name)
                                .font(.system(size: 13, weight: .semibold))
                        }
                    }
                    .buttonBorderShape(.roundedRectangle(radius: 10))
                }
            }

            if let city = selectedCity {
                Attachment(id: "weather-panel") {
                    WeatherPanelView(city: city)
                }
                Attachment(id: "close-button") {
                    Button {
                        selectedCity = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .buttonStyle(.borderless)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
        // Drag gesture — rotates whichever entity is dragged
        .simultaneousGesture(
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
        // Tap gesture for city selection (labels or markers)
        .simultaneousGesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    let tappedName = value.entity.name
                    // Check for marker tap
                    if tappedName.hasPrefix("marker-") {
                        let cityName = String(tappedName.dropFirst("marker-".count))
                        selectCity(named: cityName)
                    } else {
                        // Check if a label attachment was tapped (walk up hierarchy to find city name)
                        let cityMatch = cities.first { city in
                            var current: Entity? = value.entity
                            while let e = current {
                                if e.name == "label-\(city.name)" { return true }
                                current = e.parent
                            }
                            return false
                        }
                        if let city = cityMatch {
                            selectCity(named: city.name)
                        }
                        // Tap on globe itself does nothing — use close button on snow globe instead
                    }
                }
        )
        // Pinch gesture — scales whichever entity is pinched
        .simultaneousGesture(
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

            // Attach close button (top-right of snow globe)
            if let closeBtn = attachments.entity(for: "close-button") {
                closeBtn.position = SIMD3<Float>(0.14, 0.14, 0.10)
                closeBtn.components.set(BillboardComponent())
                closeBtn.components.set(InputTargetComponent(allowedInputTypes: .indirect))
                closeBtn.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.025)]))
                closeBtn.components.set(HoverEffectComponent())
                newGlobe.addChild(closeBtn)
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
