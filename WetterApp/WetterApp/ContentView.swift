import SwiftUI
import RealityKit

struct ContentView: View {

    @State private var cities = CityData.defaultCities
    @State private var selectedCity: City?

    // Rotation tracking
    @State private var currentRotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))
    @State private var dragStartRotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))

    // Reference to the globe root for applying rotation
    @State private var globeEntity: Entity?

    var body: some View {
        RealityView { content, attachments in
            let globe = GlobeBuilder.buildGlobe(cities: cities)
            globeEntity = globe
            content.add(globe)

            // Add city name labels as SwiftUI attachments
            for city in cities {
                if let attachment = attachments.entity(for: city.name) {
                    let labelPos = GlobeBuilder.latLonToPosition(
                        lat: city.latitude,
                        lon: city.longitude,
                        radius: GlobeBuilder.globeRadius + 0.045
                    )
                    attachment.position = labelPos
                    // Make label always face the user
                    attachment.components.set(BillboardComponent())
                    globe.addChild(attachment)
                }
            }
        } update: { content, attachments in
            // Apply rotation to globe
            if let globe = globeEntity {
                globe.orientation = currentRotation
            }
        } attachments: {
            // City name labels
            ForEach(cities) { city in
                Attachment(id: city.name) {
                    Text(city.name)
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(6)
                }
            }
        }
        // Drag gesture for rotation
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
                    // Check if tapped entity is a pin or pin-head
                    if tappedName.hasPrefix("pin-head-") {
                        let cityName = String(tappedName.dropFirst("pin-head-".count))
                        selectedCity = cities.first { $0.name == cityName }
                    } else if tappedName.hasPrefix("pin-") {
                        let cityName = String(tappedName.dropFirst("pin-".count))
                        selectedCity = cities.first { $0.name == cityName }
                    }
                }
        )
        .overlay(alignment: .bottom) {
            if let city = selectedCity {
                selectedCityOverlay(city: city)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: selectedCity?.id)
            }
        }
    }

    // Temporary overlay showing selected city — will be replaced by snow globe later
    @ViewBuilder
    private func selectedCityOverlay(city: City) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(city.pinColor))
                .frame(width: 12, height: 12)
            Text(city.name)
                .font(.headline)
            if let weather = CityData.dummyWeather[city.name] {
                Text("· \(weather.temperature)°C · \(weather.condition.rawValue)")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding(.bottom, 20)
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
}
