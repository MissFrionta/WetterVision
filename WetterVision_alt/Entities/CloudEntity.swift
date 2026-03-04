import RealityKit
import Foundation

class CloudEntity {
    static func create(isDark: Bool = false) -> Entity {
        let cloud = Entity()
        cloud.name = isDark ? "DarkCloud" : "Cloud"

        let color: UIColor = isDark ? ColorPalette.darkCloudGray : ColorPalette.cloudWhite

        // Cluster of 5 overlapping spheres
        let positions: [SIMD3<Float>] = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(0.02, 0.005, 0.005),
            SIMD3<Float>(-0.02, 0.003, -0.003),
            SIMD3<Float>(0.01, -0.005, 0.01),
            SIMD3<Float>(-0.01, 0.008, -0.008)
        ]

        let radii: [Float] = [0.018, 0.015, 0.014, 0.012, 0.013]

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
