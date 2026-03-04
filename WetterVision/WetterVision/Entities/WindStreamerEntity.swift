import RealityKit
import Foundation

class WindStreamerEntity {
    static func create(windSpeed: Double) -> Entity {
        let windRoot = Entity()
        windRoot.name = "WindStreamers"

        // Number of streamers scales with wind speed
        let streamerCount = min(max(Int(windSpeed / 10.0), 2), 6)
        let length: Float = Float(min(windSpeed / 50.0, 1.0)) * 0.12 + 0.03

        for i in 0..<streamerCount {
            let streamer = Entity()

            let mesh = MeshResource.generateBox(size: SIMD3<Float>(length, 0.002, 0.002))
            var material = SimpleMaterial()
            material.color = .init(tint: ColorPalette.windTeal.withAlphaComponent(0.6))
            let model = ModelEntity(mesh: mesh, materials: [material])
            streamer.addChild(model)

            // Distribute vertically
            let yOffset = Float(i) * 0.025 - Float(streamerCount) * 0.0125
            streamer.position = SIMD3<Float>(-0.15, 0.08 + yOffset, Float(i % 3) * 0.03 - 0.03)

            windRoot.addChild(streamer)
        }

        return windRoot
    }
}
