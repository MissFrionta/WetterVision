import RealityKit
import UIKit
import Foundation

class AssetSunEntity {
    static func load() async -> Entity {
        if let asset = try? await Entity(named: "sun") {
            asset.name = "Sun"
            return asset
        }
        return createFallback()
    }

    private static func createFallback() -> Entity {
        let sun = Entity()
        sun.name = "Sun"

        // Main sun sphere — larger, glowing
        let sunMesh = MeshResource.generateSphere(radius: 0.04)
        var sunMaterial = UnlitMaterial()
        sunMaterial.color = .init(tint: ColorPalette.sunYellow)
        let sunSphere = ModelEntity(mesh: sunMesh, materials: [sunMaterial])
        sun.addChild(sunSphere)

        // Outer glow ring
        let glowMesh = MeshResource.generateSphere(radius: 0.055)
        var glowMat = UnlitMaterial()
        glowMat.color = .init(tint: ColorPalette.sunYellow.withAlphaComponent(0.25))
        let glow = ModelEntity(mesh: glowMesh, materials: [glowMat])
        sun.addChild(glow)

        // 12 rays for smoother appearance
        let rayCount = 12
        for i in 0..<rayCount {
            let angle = Float(i) * (2 * .pi / Float(rayCount))
            let rayLength: Float = (i % 2 == 0) ? 0.03 : 0.02
            let rayMesh = MeshResource.generateBox(size: SIMD3<Float>(0.004, rayLength, 0.004))
            var rayMaterial = UnlitMaterial()
            rayMaterial.color = .init(tint: ColorPalette.sunRayOrange)
            let ray = ModelEntity(mesh: rayMesh, materials: [rayMaterial])

            let distance: Float = 0.055
            ray.position = SIMD3<Float>(cos(angle) * distance, sin(angle) * distance, 0)
            ray.transform.rotation = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 0, 1))
            sun.addChild(ray)
        }

        return sun
    }
}
