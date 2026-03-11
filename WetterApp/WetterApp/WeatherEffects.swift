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

    // MARK: - Sun (merged voxels)

    private static func addSun(to parent: Entity) {
        let sunColor = UIColor(red: 0.98, green: 0.85, blue: 0.25, alpha: 1)
        let sunBright = UIColor(red: 1.0, green: 0.95, blue: 0.50, alpha: 1)

        let sunRoot = Entity()
        sunRoot.name = "sun"
        sunRoot.position = SIMD3<Float>(0.03, 0.07, 0.0)

        let c = VoxelBuilder.VoxelCollector()

        // Core (3x3)
        for dx in -1...1 {
            for dy in -1...1 {
                let color = (abs(dx) + abs(dy)) == 0 ? sunBright : sunColor
                c.addAt(color: color, position: SIMD3(Float(dx) * 0.010, Float(dy) * 0.010, 0))
            }
        }

        // Rays (extending voxels in 4 directions + diagonals)
        let rayPositions: [(Int, Int)] = [
            (0, 2), (0, -2), (2, 0), (-2, 0),
            (2, 2), (2, -2), (-2, 2), (-2, -2),
            (0, 3), (0, -3), (3, 0), (-3, 0),
        ]
        for (rx, ry) in rayPositions {
            c.addAt(color: sunColor, position: SIMD3(Float(rx) * 0.010, Float(ry) * 0.010, 0))
        }

        c.flush(into: sunRoot)
        sunRoot.components.set(BillboardComponent())
        parent.addChild(sunRoot)
    }

    // MARK: - Clouds (merged voxels)

    private static func addClouds(to parent: Entity, dark: Bool) {
        let lightColor = dark
            ? UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1)
            : UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)
        let darkColor = dark
            ? UIColor(red: 0.42, green: 0.42, blue: 0.45, alpha: 1)
            : UIColor(red: 0.82, green: 0.84, blue: 0.88, alpha: 1)

        // Merge all cloud voxels into one entity using absolute positions
        let cloudPositions: [SIMD3<Float>] = [
            SIMD3<Float>(-0.04, 0.06, 0.02),
            SIMD3<Float>(0.03, 0.07, -0.02),
            SIMD3<Float>(-0.01, 0.05, 0.04),
        ]

        let c = VoxelBuilder.VoxelCollector()

        for (i, pos) in cloudPositions.enumerated() {
            let w = i == 1 ? 4 : 3
            for dx in -w...w {
                for dz in -1...1 {
                    for dy in 0...1 {
                        if abs(dx) == w && (abs(dz) > 0 || dy > 0) { continue }
                        if dy == 1 && abs(dx) > w - 1 { continue }
                        let color = (dx + dz + dy) % 2 == 0 ? lightColor : darkColor
                        let absolutePos = pos + SIMD3<Float>(Float(dx) * 0.010, Float(dy) * 0.010, Float(dz) * 0.010)
                        c.addAt(color: color, position: absolutePos)
                    }
                }
            }
        }

        c.flush(into: parent)
    }

    // MARK: - Rain (Particle System)

    private static func addRain(to parent: Entity) {
        let rainEntity = Entity()
        rainEntity.name = "rain"
        rainEntity.position = SIMD3<Float>(0, 0.04, 0)

        var emitter = ParticleEmitterComponent()
        emitter.emitterShape = .plane
        emitter.emitterShapeSize = SIMD3<Float>(0.12, 0.01, 0.12)
        emitter.mainEmitter.birthRate = 150
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
        emitter.mainEmitter.birthRate = 50
        emitter.speed = 0.03
        emitter.mainEmitter.lifeSpan = 2.0

        // Snowflakes: small, white, drifting down slowly
        emitter.mainEmitter.size = 0.003
        emitter.mainEmitter.color = .constant(.single(UIColor(white: 1.0, alpha: 0.9)))
        emitter.mainEmitter.acceleration = SIMD3<Float>(0, -0.05, 0)

        snowEntity.components.set(emitter)
        parent.addChild(snowEntity)
    }

    // MARK: - Lightning (merged voxels)

    private static func addLightning(to parent: Entity) {
        let boltColor = UIColor(red: 1.0, green: 0.95, blue: 0.55, alpha: 1)

        let bolt = Entity()
        bolt.name = "lightning"
        bolt.position = SIMD3<Float>(0.02, 0.04, 0.01)

        let c = VoxelBuilder.VoxelCollector(blockSize: 0.008)

        let boltPath: [(Int, Int)] = [
            (0, 4), (0, 3), (1, 2), (0, 1), (1, 0), (0, -1), (1, -2), (0, -3)
        ]
        for (bx, by) in boltPath {
            c.addAt(color: boltColor, position: SIMD3(Float(bx) * 0.010, Float(by) * 0.010, 0))
        }

        c.flush(into: bolt)
        bolt.components.set(BillboardComponent())
        parent.addChild(bolt)
    }
}
