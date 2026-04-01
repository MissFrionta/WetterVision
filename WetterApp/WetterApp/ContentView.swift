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
                        radius: GlobeBuilder.globeRadius + GlobeBuilder.stickHeight + 0.015
                    )
                    attachment.position = labelPos
                    attachment.components.set(BillboardComponent())
                    attachment.components.set(InputTargetComponent(allowedInputTypes: .indirect))
                    attachment.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.025)]))
                    attachment.components.set(HoverEffectComponent(.highlight(.init(color: .white, strength: 1.0))))
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

            // Show/hide snow globe
            updateSnowGlobe(content: content, attachments: attachments)

            // Apply snow globe rotation + scale (search scene graph, don't rely on @State ref)
            if let root = globeEntity?.parent {
                if let sg = root.children.first(where: { $0.name.hasPrefix("snowglobe-") }) {
                    sg.orientation = snowGlobeRotation
                    sg.scale = SIMD3<Float>(repeating: snowGlobeScale)

                    // Counter-scale particle emitters — same approach as master (confirmed working)
                    if let effects = sg.children.first(where: { $0.name == "weather-effects" }) {
                        let s = snowGlobeScale
                        let inv = 1.0 / s
                        for child in effects.children where child.name == "snow" || child.name == "rain" || child.name == "drizzle" || child.name == "wind" {
                            child.scale = SIMD3<Float>(repeating: inv)
                            if var emitter = child.components[ParticleEmitterComponent.self] {
                                let shapeH: Float = child.name == "wind" ? 0.14 : 0.01
                                emitter.emitterShapeSize = SIMD3<Float>(0.10 * s, shapeH * s, 0.10 * s)
                                let baseRate: Float = child.name == "snow" ? 350 : (child.name == "drizzle" ? 80 : (child.name == "wind" ? 80 : 300))
                                emitter.mainEmitter.birthRate = baseRate * s * s
                                // Wind needs full 3D acceleration, others only Y
                                if child.name == "wind" {
                                    emitter.mainEmitter.acceleration = SIMD3<Float>(0.7 * s, -0.03 * s, 0)
                                } else {
                                    let baseAccel: Float = child.name == "snow" ? -0.12 : (child.name == "drizzle" ? -0.3 : -0.5)
                                    emitter.mainEmitter.acceleration = SIMD3<Float>(0, baseAccel * s, 0)
                                }
                                child.components.set(emitter)
                            }
                        }
                    }

                    // Position weather panel in front of snow globe, aligned at base level
                    if let panel = root.children.first(where: { $0.name == "weather-panel" }) {
                        let s = snowGlobeScale
                        let panelY: Float = -0.19 * s  // base level of snow globe
                        let panelZ: Float = 0.17 * s + 0.05  // in front of glass sphere
                        panel.position = SIMD3<Float>(0.20, panelY, panelZ)
                    }
                }
            }
        } attachments: {
            ForEach(cities) { city in
                Attachment(id: "label-\(city.name)") {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(city.pinColor))
                            .frame(width: 8, height: 8)
                        Text(city.name)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(city.pinColor).opacity(0.6), lineWidth: 1.5)
                    )
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
                }
            }

            if let city = selectedCity {
                Attachment(id: "weather-panel") {
                    WeatherPanelView(city: city)
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
                        // Snow globe: only yaw (Y-axis) — stays upright like on a table
                        snowGlobeRotation = yaw * snowGlobeDragStart
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
                    // Ignore taps on the snow globe (allows drag/pinch without interference)
                    if isDragOnSnowGlobe(value.entity) {
                        return
                    }

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
                        } else {
                            // Tap on globe surface — deselect city
                            selectedCity = nil
                        }
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
                        snowGlobeScale = min(max(newScale, 0.4), 1.2)
                    } else {
                        let newScale = globePinchStart * magnification
                        globeScale = min(max(newScale, 0.5), 1.5)
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

    /// Find and remove any snow globe entities from the scene by name.
    private func removeSnowGlobe(root: Entity?) {
        guard let root = root else { return }
        let snowGlobes = root.children.filter { $0.name.hasPrefix("snowglobe-") }
        for sg in snowGlobes {
            sg.isEnabled = false
            sg.children.forEach { $0.removeFromParent() }
            sg.removeFromParent()
        }
    }

    private func updateSnowGlobe(content: RealityViewContent, attachments: RealityViewAttachments) {
        let root = globeEntity?.parent

        if let city = selectedCity {
            let targetName = "snowglobe-\(city.name)"

            // Check if correct snow globe already exists (by searching scene graph)
            if root?.children.contains(where: { $0.name == targetName }) == true {
                return // Same city, nothing to do
            }

            // Remove any existing snow globe
            removeSnowGlobe(root: root)

            // Create new snow globe with weather condition
            let condition = CityData.dummyWeather[city.name]?.condition ?? .cloudy
            let newGlobe = VoxelBuilder.buildSnowGlobe(for: city.name, condition: condition)
            newGlobe.position = SIMD3<Float>(0.20, 0.0, 0.0)
            newGlobe.scale = SIMD3<Float>(repeating: snowGlobeScale)

            root?.addChild(newGlobe)

            // Attach weather panel to scene root (not snow globe, so it doesn't rotate with it)
            if let panel = attachments.entity(for: "weather-panel") {
                panel.name = "weather-panel"
                let s = snowGlobeScale
                let panelY: Float = -0.19 * s
                let panelZ: Float = 0.17 * s + 0.05
                panel.position = SIMD3<Float>(0.20, panelY, panelZ)
                panel.components.set(BillboardComponent())
                root?.addChild(panel)
            }
        } else {
            removeSnowGlobe(root: root)
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
        case .sunny:   return "sun.max.fill"
        case .cloudy:  return "cloud.fill"
        case .drizzle: return "cloud.drizzle.fill"
        case .rainy:   return "cloud.rain.fill"
        case .snowy:   return "cloud.snow.fill"
        case .windy:   return "wind"
        case .stormy:  return "cloud.bolt.fill"
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
}
