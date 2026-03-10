import RealityKit
import RealityKitContent
import UIKit

/// Builds a 3D globe with city markers.
struct GlobeBuilder {

    // Visual radius of the Earth model at scale 1.1 — adjust if pins float or sink
    static let globeRadius: Float = 0.165
    // Longitude offset to align pins with the Earth texture (adjust as needed)
    static let lonOffset: Float = 0.0
    // Small sphere marker on the surface
    static let markerRadius: Float = 0.004

    // MARK: - Public API

    /// Builds the full globe entity with small sphere markers for each city.
    static func buildGlobe(cities: [City]) async -> Entity {
        let root = Entity()
        root.name = "globe-root"

        // -- Earth globe from USDZ model --
        if let earthEntity = try? await Entity(named: "Earth", in: realityKitContentBundle) {
            earthEntity.scale = SIMD3<Float>(repeating: 1.1)
            earthEntity.name = "globe-sphere"

            earthEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
            earthEntity.components.set(CollisionComponent(shapes: [.generateSphere(radius: globeRadius)]))
            earthEntity.components.set(HoverEffectComponent())

            root.addChild(earthEntity)
        } else {
            // Fallback: blue placeholder sphere
            let globeMesh = MeshResource.generateSphere(radius: globeRadius)
            var globeMat = SimpleMaterial()
            globeMat.color = .init(tint: UIColor(red: 0.15, green: 0.40, blue: 0.75, alpha: 1.0))
            globeMat.metallic = .init(floatLiteral: 0.3)
            globeMat.roughness = .init(floatLiteral: 0.7)
            let globeEntity = ModelEntity(mesh: globeMesh, materials: [globeMat])
            globeEntity.name = "globe-sphere"
            globeEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
            globeEntity.components.set(CollisionComponent(shapes: [.generateSphere(radius: globeRadius)]))
            globeEntity.components.set(HoverEffectComponent())
            root.addChild(globeEntity)
        }

        // -- City markers (small colored spheres on surface) --
        let markerMesh = MeshResource.generateSphere(radius: markerRadius)
        for city in cities {
            let mat = SimpleMaterial(color: city.pinColor, isMetallic: false)
            let marker = ModelEntity(mesh: markerMesh, materials: [mat])
            marker.name = "marker-\(city.name)"

            let surfacePos = latLonToPosition(
                lat: city.latitude,
                lon: city.longitude + lonOffset,
                radius: globeRadius + markerRadius
            )
            marker.position = surfacePos
            root.addChild(marker)
        }

        return root
    }

    // MARK: - Coordinate Conversion

    /// Converts latitude/longitude (degrees) to a 3D position on a sphere.
    static func latLonToPosition(lat: Float, lon: Float, radius: Float) -> SIMD3<Float> {
        let latRad = lat * .pi / 180.0
        let lonRad = lon * .pi / 180.0
        return SIMD3<Float>(
            radius * cos(latRad) * sin(lonRad),   // X: east-west
            radius * sin(latRad),                   // Y: up (north pole)
            radius * cos(latRad) * cos(lonRad)     // Z: toward camera (prime meridian)
        )
    }
}
