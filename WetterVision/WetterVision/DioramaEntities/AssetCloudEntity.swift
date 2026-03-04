import RealityKit
import UIKit
import Foundation

class AssetCloudEntity {
    static func load(isDark: Bool = false) async -> Entity {
        let assetName = isDark ? "cloud_dark" : "cloud"
        if let asset = try? await Entity(named: assetName) {
            asset.name = isDark ? "DarkCloud" : "Cloud"
            return asset
        }
        return createFallback(isDark: isDark)
    }

    private static func createFallback(isDark: Bool) -> Entity {
        let cloud = Entity()
        cloud.name = isDark ? "DarkCloud" : "Cloud"

        let color: UIColor = isDark ? ColorPalette.darkCloudGray : ColorPalette.cloudWhite

        // Richer cloud cluster with 7 overlapping spheres
        let positions: [SIMD3<Float>] = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(0.022, 0.004, 0.004),
            SIMD3<Float>(-0.022, 0.003, -0.003),
            SIMD3<Float>(0.012, -0.004, 0.012),
            SIMD3<Float>(-0.012, 0.007, -0.008),
            SIMD3<Float>(0.008, 0.006, -0.01),
            SIMD3<Float>(-0.005, -0.003, 0.015)
        ]

        let radii: [Float] = [0.02, 0.017, 0.016, 0.014, 0.015, 0.012, 0.011]

        for (i, pos) in positions.enumerated() {
            let mesh = MeshResource.generateSphere(radius: radii[i])
            var material = SimpleMaterial()
            material.color = .init(tint: color)
            material.roughness = 1.0
            let sphere = ModelEntity(mesh: mesh, materials: [material])
            sphere.position = pos
            cloud.addChild(sphere)
        }

        return cloud
    }
}
