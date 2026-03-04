import RealityKit
import Foundation

class DioramaBuilder {
    static func build(for weather: WeatherData) -> Entity {
        let root = Entity()
        root.name = "DioramaContent"

        // Always add the island base
        let island = IslandEntity.create()
        root.addChild(island)

        // Thermometer on the right side
        let thermometer = ThermometerEntity.create(temperature: weather.temperature)
        thermometer.position = SIMD3<Float>(0.18, 0.0, 0)
        root.addChild(thermometer)

        // Wind streamers (always present, intensity varies)
        let wind = WindStreamerEntity.create(windSpeed: weather.windSpeed)
        root.addChild(wind)

        // Weather-specific elements
        switch weather.condition {
        case .sunny:
            let sun = SunEntity.create()
            sun.position = SIMD3<Float>(0.05, 0.2, 0)
            root.addChild(sun)

            // Light white cloud for variety
            let cloud = CloudEntity.create(isDark: false)
            cloud.position = SIMD3<Float>(-0.1, 0.15, 0.05)
            cloud.scale = SIMD3<Float>(repeating: 0.7)
            root.addChild(cloud)

        case .cloudy:
            // Multiple white/gray clouds
            let positions: [SIMD3<Float>] = [
                SIMD3<Float>(0, 0.16, 0),
                SIMD3<Float>(-0.08, 0.18, 0.04),
                SIMD3<Float>(0.1, 0.14, -0.03),
                SIMD3<Float>(-0.05, 0.13, -0.06)
            ]
            for (i, pos) in positions.enumerated() {
                let cloud = CloudEntity.create(isDark: i > 1)
                cloud.position = pos
                root.addChild(cloud)
            }

        case .rainy:
            // Dark clouds
            let cloudPositions: [SIMD3<Float>] = [
                SIMD3<Float>(0, 0.16, 0),
                SIMD3<Float>(-0.07, 0.17, 0.04),
                SIMD3<Float>(0.08, 0.15, -0.03)
            ]
            for pos in cloudPositions {
                let cloud = CloudEntity.create(isDark: true)
                cloud.position = pos
                root.addChild(cloud)
            }

            // Rain particles
            let rain = RainSystem.create()
            rain.position = SIMD3<Float>(0, 0.18, 0)
            root.addChild(rain)

        case .snowy:
            // Gray clouds
            let cloudPositions: [SIMD3<Float>] = [
                SIMD3<Float>(0, 0.16, 0),
                SIMD3<Float>(-0.06, 0.18, 0.05)
            ]
            for pos in cloudPositions {
                let cloud = CloudEntity.create(isDark: true)
                cloud.position = pos
                root.addChild(cloud)
            }

            // Snow particles
            let snow = SnowSystem.create()
            snow.position = SIMD3<Float>(0, 0.18, 0)
            root.addChild(snow)

        case .stormy:
            // Dense dark clouds
            let cloudPositions: [SIMD3<Float>] = [
                SIMD3<Float>(0, 0.15, 0),
                SIMD3<Float>(-0.08, 0.17, 0.04),
                SIMD3<Float>(0.09, 0.14, -0.03),
                SIMD3<Float>(-0.03, 0.13, -0.06),
                SIMD3<Float>(0.05, 0.18, 0.05)
            ]
            for pos in cloudPositions {
                let cloud = CloudEntity.create(isDark: true)
                cloud.position = pos
                root.addChild(cloud)
            }

            // Heavy rain
            let rain = RainSystem.create()
            rain.position = SIMD3<Float>(0, 0.18, 0)
            root.addChild(rain)

            // Lightning bolt (simple yellow box flash)
            let boltMesh = MeshResource.generateBox(size: SIMD3<Float>(0.005, 0.08, 0.005))
            var boltMaterial = UnlitMaterial()
            boltMaterial.color = .init(tint: ColorPalette.lightningYellow)
            let bolt = ModelEntity(mesh: boltMesh, materials: [boltMaterial])
            bolt.position = SIMD3<Float>(0.03, 0.1, 0.02)
            // Slight rotation for natural look
            bolt.transform.rotation = simd_quatf(angle: 0.2, axis: SIMD3<Float>(0, 0, 1))
            bolt.name = "Lightning"
            root.addChild(bolt)
        }

        return root
    }
}
