import RealityKit
import UIKit
import Foundation

class SunEntity {
    static func create() -> Entity {
        let sun = Entity()
        sun.name = "Sun"

        // Main sun sphere (unlit bright yellow)
        let sunMesh = MeshResource.generateSphere(radius: 0.035)
        var sunMaterial = UnlitMaterial()
        sunMaterial.color = .init(tint: ColorPalette.sunYellow)
        let sunSphere = ModelEntity(mesh: sunMesh, materials: [sunMaterial])
        sun.addChild(sunSphere)

        // Rays: 8 thin elongated boxes around the sun
        let rayCount = 8
        for i in 0..<rayCount {
            let angle = Float(i) * (2 * .pi / Float(rayCount))
            let rayMesh = MeshResource.generateBox(size: SIMD3<Float>(0.005, 0.025, 0.005))
            var rayMaterial = UnlitMaterial()
            rayMaterial.color = .init(tint: ColorPalette.sunRayOrange)
            let ray = ModelEntity(mesh: rayMesh, materials: [rayMaterial])

            let distance: Float = 0.05
            ray.position = SIMD3<Float>(cos(angle) * distance, sin(angle) * distance, 0)

            // Rotate ray to point outward
            ray.transform.rotation = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 0, 1))
            sun.addChild(ray)
        }

        return sun
    }
}
