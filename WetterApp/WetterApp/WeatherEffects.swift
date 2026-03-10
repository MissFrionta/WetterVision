import RealityKit
import UIKit

/// Adds weather visualizations (sun, clouds, rain, snow, storm) inside the snow globe.
struct WeatherEffects {

    // MARK: - Public API

    /// Adds the appropriate weather effects to a snow globe scene entity.
    static func apply(condition: WeatherCondition, to parent: Entity) {
        let effectsRoot = Entity()
        effectsRoot.name = "weather-effects"

        switch condition {
        case .sunny:
            addSun(to: effectsRoot)
        case .cloudy:
            addClouds(to: effectsRoot, dark: false)
        case .rainy:
            addClouds(to: effectsRoot, dark: true)
            addRain(to: effectsRoot)
        case .snowy:
            addClouds(to: effectsRoot, dark: false)
            addSnow(to: effectsRoot)
        case .stormy:
            addClouds(to: effectsRoot, dark: true)
            addRain(to: effectsRoot)
            addLightning(to: effectsRoot)
        }

        parent.addChild(effectsRoot)
    }

    // MARK: - Sun

    private static func addSun(to parent: Entity) {
        let mesh = MeshResource.generateBox(size: 0.009)

        // Build a voxel sun (5x5 cross pattern)
        let sunColor = UIColor(red: 0.98, green: 0.85, blue: 0.25, alpha: 1)
        let sunBright = UIColor(red: 1.0, green: 0.95, blue: 0.50, alpha: 1)
        let sunMat = SimpleMaterial(color: sunColor, isMetallic: false)
        let sunBrightMat = SimpleMaterial(color: sunBright, isMetallic: false)

        let sunRoot = Entity()
        sunRoot.name = "sun"
        sunRoot.position = SIMD3<Float>(0.03, 0.07, 0.0)

        // Core (3x3)
        for dx in -1...1 {
            for dy in -1...1 {
                let mat = (abs(dx) + abs(dy)) == 0 ? sunBrightMat : sunMat
                let v = ModelEntity(mesh: mesh, materials: [mat])
                v.position = SIMD3<Float>(Float(dx) * 0.010, Float(dy) * 0.010, 0)
                sunRoot.addChild(v)
            }
        }

        // Rays (extending voxels in 4 directions + diagonals)
        let rayPositions: [(Int, Int)] = [
            (0, 2), (0, -2), (2, 0), (-2, 0),  // cardinal
            (2, 2), (2, -2), (-2, 2), (-2, -2), // diagonal
            (0, 3), (0, -3), (3, 0), (-3, 0),   // longer cardinal
        ]
        for (rx, ry) in rayPositions {
            let v = ModelEntity(mesh: mesh, materials: [sunMat])
            v.position = SIMD3<Float>(Float(rx) * 0.010, Float(ry) * 0.010, 0)
            sunRoot.addChild(v)
        }

        // Make sun always face user
        sunRoot.components.set(BillboardComponent())

        parent.addChild(sunRoot)
    }

    // MARK: - Clouds

    private static func addClouds(to parent: Entity, dark: Bool) {
        let mesh = MeshResource.generateBox(size: 0.009)

        let lightColor = dark
            ? UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1)
            : UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)
        let darkColor = dark
            ? UIColor(red: 0.42, green: 0.42, blue: 0.45, alpha: 1)
            : UIColor(red: 0.82, green: 0.84, blue: 0.88, alpha: 1)

        let lightMat = SimpleMaterial(color: lightColor, isMetallic: false)
        let darkMat = SimpleMaterial(color: darkColor, isMetallic: false)

        // Place 2-3 cloud clusters at different positions
        let cloudPositions: [SIMD3<Float>] = [
            SIMD3<Float>(-0.04, 0.06, 0.02),
            SIMD3<Float>(0.03, 0.07, -0.02),
            SIMD3<Float>(-0.01, 0.05, 0.04),
        ]

        for (i, pos) in cloudPositions.enumerated() {
            let cloud = Entity()
            cloud.name = "cloud-\(i)"
            cloud.position = pos

            // Each cloud: elongated blob (wider than tall)
            let w = i == 1 ? 4 : 3 // vary size
            for dx in -w...w {
                for dz in -1...1 {
                    for dy in 0...1 {
                        // Rounded shape
                        if abs(dx) == w && (abs(dz) > 0 || dy > 0) { continue }
                        if dy == 1 && abs(dx) > w - 1 { continue }
                        let mat = (dx + dz + dy) % 2 == 0 ? lightMat : darkMat
                        let v = ModelEntity(mesh: mesh, materials: [mat])
                        v.position = SIMD3<Float>(Float(dx) * 0.010, Float(dy) * 0.010, Float(dz) * 0.010)
                        cloud.addChild(v)
                    }
                }
            }

            parent.addChild(cloud)
        }
    }

    // MARK: - Rain (Particle System)

    private static func addRain(to parent: Entity) {
        let rainEntity = Entity()
        rainEntity.name = "rain"
        rainEntity.position = SIMD3<Float>(0, 0.04, 0)

        var emitter = ParticleEmitterComponent()
        emitter.emitterShape = .plane
        emitter.emitterShapeSize = SIMD3<Float>(0.12, 0.01, 0.12)
        emitter.mainEmitter.birthRate = 200
        emitter.speed = 0.15
        emitter.mainEmitter.lifeSpan = 0.6

        // Rain drops: small, blue, falling down
        emitter.mainEmitter.size = 0.002
        emitter.mainEmitter.color = .constant(.single(UIColor(red: 0.4, green: 0.65, blue: 0.9, alpha: 0.8)))
        emitter.mainEmitter.acceleration = SIMD3<Float>(0, -0.3, 0)

        rainEntity.components.set(emitter)
        parent.addChild(rainEntity)
    }

    // MARK: - Snow (Particle System)

    private static func addSnow(to parent: Entity) {
        let snowEntity = Entity()
        snowEntity.name = "snow"
        snowEntity.position = SIMD3<Float>(0, 0.04, 0)

        var emitter = ParticleEmitterComponent()
        emitter.emitterShape = .plane
        emitter.emitterShapeSize = SIMD3<Float>(0.12, 0.01, 0.12)
        emitter.mainEmitter.birthRate = 80
        emitter.speed = 0.03
        emitter.mainEmitter.lifeSpan = 2.0

        // Snowflakes: small, white, drifting down slowly
        emitter.mainEmitter.size = 0.003
        emitter.mainEmitter.color = .constant(.single(UIColor(white: 1.0, alpha: 0.9)))
        emitter.mainEmitter.acceleration = SIMD3<Float>(0, -0.05, 0)

        snowEntity.components.set(emitter)
        parent.addChild(snowEntity)
    }

    // MARK: - Lightning

    private static func addLightning(to parent: Entity) {
        let mesh = MeshResource.generateBox(size: 0.008)
        let boltMat = SimpleMaterial(color: UIColor(red: 1.0, green: 0.95, blue: 0.55, alpha: 1), isMetallic: false)

        let bolt = Entity()
        bolt.name = "lightning"
        bolt.position = SIMD3<Float>(0.02, 0.04, 0.01)

        // Zigzag bolt shape
        let boltPath: [(Int, Int)] = [
            (0, 4), (0, 3), (1, 2), (0, 1), (1, 0), (0, -1), (1, -2), (0, -3)
        ]
        for (bx, by) in boltPath {
            let v = ModelEntity(mesh: mesh, materials: [boltMat])
            v.position = SIMD3<Float>(Float(bx) * 0.010, Float(by) * 0.010, 0)
            bolt.addChild(v)
        }

        bolt.components.set(BillboardComponent())
        parent.addChild(bolt)
    }
}
