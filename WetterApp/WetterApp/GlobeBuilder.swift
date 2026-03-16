import RealityKit
import RealityKitContent
import UIKit

/// Builds a 3D globe with city pin markers.
struct GlobeBuilder {

    // Visual radius of the Earth model at scale 1.1 — adjust if pins float or sink
    static let globeRadius: Float = 0.108
    // Longitude offset to align pins with the Earth texture (shift west)
    static let lonOffset: Float = -80.0
    // Pin dimensions
    static let markerRadius: Float = 0.003
    static let stickHeight: Float = 0.015
    static let stickRadius: Float = 0.001

    // MARK: - Public API

    /// Builds the full globe entity with pin markers for each city.
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

        // -- City pins (stick + colored sphere head) --
        let stickMesh = MeshResource.generateCylinder(height: stickHeight, radius: stickRadius)
        let stickMat = SimpleMaterial(color: UIColor(white: 0.95, alpha: 1), isMetallic: false)
        let headMesh = MeshResource.generateSphere(radius: markerRadius)

        for city in cities {
            let pinRoot = Entity()
            pinRoot.name = "pin-\(city.name)"

            // Stick (thin white cylinder)
            let stick = ModelEntity(mesh: stickMesh, materials: [stickMat])
            stick.position = SIMD3<Float>(0, stickHeight / 2, 0)
            pinRoot.addChild(stick)

            // Head (colored sphere on top)
            let headMat = SimpleMaterial(color: city.pinColor, isMetallic: false)
            let head = ModelEntity(mesh: headMesh, materials: [headMat])
            head.position = SIMD3<Float>(0, stickHeight + markerRadius, 0)
            head.name = "marker-\(city.name)"
            pinRoot.addChild(head)

            // Position on globe surface and orient outward
            let surfacePos = latLonToPosition(
                lat: city.latitude,
                lon: city.longitude + lonOffset,
                radius: globeRadius
            )
            pinRoot.position = surfacePos
            pinRoot.look(at: .zero, from: surfacePos, relativeTo: nil)
            let flipRotation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(1, 0, 0))
            pinRoot.orientation = pinRoot.orientation * flipRotation

            root.addChild(pinRoot)
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
