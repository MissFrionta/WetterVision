import RealityKit
import RealityKitContent
import UIKit

/// Builds a 3D globe with voxel-style city pins.
struct GlobeBuilder {

    static let globeRadius: Float = 0.15
    static let pinVoxelSize: Float = 0.008
    static let pinVoxelGrid: Float = 0.009

    // MARK: - Public API

    /// Builds the full globe entity with all city pins attached.
    /// Each pin entity is named "pin-{cityName}" for tap detection.
    static func buildGlobe(cities: [City]) async -> Entity {
        let root = Entity()
        root.name = "globe-root"

        // -- Earth globe from USDZ model --
        if let earthEntity = try? await Entity(named: "Earth", in: realityKitContentBundle) {
            // Scale the model to match our globe radius
            // Adjust this value if the globe appears too big or small
            earthEntity.scale = SIMD3<Float>(repeating: 1.1)
            earthEntity.name = "globe-sphere"

            // Enable input on globe for drag rotation
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

        // -- City pins --
        for city in cities {
            let pin = buildPin(for: city)
            root.addChild(pin)
        }

        return root
    }

    // MARK: - Pin Builder

    /// Creates a voxel pin at the correct position on the globe surface.
    /// The pin sticks outward from the globe, oriented away from center.
    private static func buildPin(for city: City) -> Entity {
        let pinRoot = Entity()
        pinRoot.name = "pin-\(city.name)"

        let mesh = MeshResource.generateBox(size: pinVoxelSize)
        let stickMat = SimpleMaterial(color: UIColor(white: 0.9, alpha: 1), isMetallic: false)
        let headMat = SimpleMaterial(color: city.pinColor, isMetallic: false)

        // Stick: 3 voxels outward from surface
        for i in 0...2 {
            let v = ModelEntity(mesh: mesh, materials: [stickMat])
            v.position = SIMD3<Float>(0, Float(i) * pinVoxelGrid, 0)
            pinRoot.addChild(v)
        }

        // Head: colored voxel on top (larger for visibility)
        let headMesh = MeshResource.generateBox(size: pinVoxelSize * 2.5)
        let head = ModelEntity(mesh: headMesh, materials: [headMat])
        head.position = SIMD3<Float>(0, 3 * pinVoxelGrid, 0)
        head.name = "pin-head-\(city.name)"
        pinRoot.addChild(head)

        // Enable tap on the pin — large collision sphere for easy eye targeting
        let pinCollisionRadius: Float = 0.04
        pinRoot.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        pinRoot.components.set(CollisionComponent(shapes: [.generateSphere(radius: pinCollisionRadius)]))
        pinRoot.components.set(HoverEffectComponent())

        // Position on globe surface and orient outward
        let surfacePos = latLonToPosition(lat: city.latitude, lon: city.longitude, radius: globeRadius)
        pinRoot.position = surfacePos
        pinRoot.look(at: .zero, from: surfacePos, relativeTo: nil)
        // look(at: .zero) makes pin point toward center — we need the opposite.
        // The pin is built along +Y, and look(at:) aligns -Z toward target.
        // So we rotate 90° around X to flip from -Z-forward to +Y-up-is-outward.
        let flipRotation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        pinRoot.orientation = pinRoot.orientation * flipRotation

        return pinRoot
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
