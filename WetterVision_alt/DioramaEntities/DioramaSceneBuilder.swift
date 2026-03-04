import RealityKit
import Foundation

class DioramaSceneBuilder {
    static func build(for weather: WeatherData) async -> Entity {
        let root = Entity()
        root.name = "DioramaContent"

        // Always add terrain
        let terrain = await TerrainEntity.load()
        root.addChild(terrain)

        // Thermometer on the right side
        let thermometer = await AssetThermometerEntity.load(temperature: weather.temperature)
        thermometer.position = SIMD3<Float>(0.2, 0.0, 0)
        root.addChild(thermometer)

        // Wind streamers (reuse existing, always present)
        let wind = WindStreamerEntity.create(windSpeed: weather.windSpeed)
        root.addChild(wind)

        // Weather-specific elements
        switch weather.condition {
        case .sunny:
            let sun = await AssetSunEntity.load()
            sun.position = SIMD3<Float>(0.05, 0.22, 0)
            root.addChild(sun)

            let cloud = await AssetCloudEntity.load(isDark: false)
            cloud.position = SIMD3<Float>(-0.12, 0.17, 0.05)
            cloud.scale = SIMD3<Float>(repeating: 0.7)
            root.addChild(cloud)

        case .cloudy:
            let positions: [SIMD3<Float>] = [
                SIMD3<Float>(0, 0.18, 0),
                SIMD3<Float>(-0.1, 0.2, 0.04),
                SIMD3<Float>(0.12, 0.16, -0.03),
                SIMD3<Float>(-0.06, 0.15, -0.06),
                SIMD3<Float>(0.05, 0.21, 0.06)
            ]
            for (i, pos) in positions.enumerated() {
                let cloud = await AssetCloudEntity.load(isDark: i > 2)
                cloud.position = pos
                root.addChild(cloud)
            }

        case .rainy:
            let cloudPositions: [SIMD3<Float>] = [
                SIMD3<Float>(0, 0.18, 0),
                SIMD3<Float>(-0.08, 0.19, 0.04),
                SIMD3<Float>(0.09, 0.17, -0.03),
                SIMD3<Float>(-0.04, 0.16, -0.05)
            ]
            for pos in cloudPositions {
                let cloud = await AssetCloudEntity.load(isDark: true)
                cloud.position = pos
                root.addChild(cloud)
            }

            let rain = WeatherParticles.createRain()
            rain.position = SIMD3<Float>(0, 0.2, 0)
            root.addChild(rain)

        case .snowy:
            let cloudPositions: [SIMD3<Float>] = [
                SIMD3<Float>(0, 0.18, 0),
                SIMD3<Float>(-0.07, 0.2, 0.05),
                SIMD3<Float>(0.06, 0.17, -0.04)
            ]
            for pos in cloudPositions {
                let cloud = await AssetCloudEntity.load(isDark: true)
                cloud.position = pos
                root.addChild(cloud)
            }

            let snow = WeatherParticles.createSnow()
            snow.position = SIMD3<Float>(0, 0.2, 0)
            root.addChild(snow)

        case .stormy:
            let cloudPositions: [SIMD3<Float>] = [
                SIMD3<Float>(0, 0.17, 0),
                SIMD3<Float>(-0.09, 0.19, 0.04),
                SIMD3<Float>(0.1, 0.16, -0.03),
                SIMD3<Float>(-0.04, 0.15, -0.06),
                SIMD3<Float>(0.06, 0.2, 0.05),
                SIMD3<Float>(-0.02, 0.21, 0.02)
            ]
            for pos in cloudPositions {
                let cloud = await AssetCloudEntity.load(isDark: true)
                cloud.position = pos
                root.addChild(cloud)
            }

            let rain = WeatherParticles.createHeavyRain()
            rain.position = SIMD3<Float>(0, 0.2, 0)
            root.addChild(rain)

            // Lightning bolt
            let boltMesh = MeshResource.generateBox(size: SIMD3<Float>(0.006, 0.1, 0.006))
            var boltMaterial = UnlitMaterial()
            boltMaterial.color = .init(tint: ColorPalette.lightningYellow)
            let bolt = ModelEntity(mesh: boltMesh, materials: [boltMaterial])
            bolt.position = SIMD3<Float>(0.04, 0.12, 0.02)
            bolt.transform.rotation = simd_quatf(angle: 0.15, axis: SIMD3<Float>(0, 0, 1))
            bolt.name = "Lightning"
            root.addChild(bolt)

            // Second smaller lightning
            let bolt2Mesh = MeshResource.generateBox(size: SIMD3<Float>(0.004, 0.06, 0.004))
            let bolt2 = ModelEntity(mesh: bolt2Mesh, materials: [boltMaterial])
            bolt2.position = SIMD3<Float>(-0.05, 0.1, -0.02)
            bolt2.transform.rotation = simd_quatf(angle: -0.2, axis: SIMD3<Float>(0, 0, 1))
            bolt2.name = "Lightning2"
            root.addChild(bolt2)
        }

        return root
    }
}
