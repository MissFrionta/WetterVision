import RealityKit
import UIKit

/// Adds weather visualizations (sun, clouds, rain, snow, storm) inside the snow globe.
struct WeatherEffects {

    // MARK: - Public API

    /// Adds the appropriate weather effects to a snow globe scene entity.
    static func apply(condition: WeatherCondition, to parent: Entity, voxelSize: Float = 0.010) {
        let effectsRoot = Entity()
        effectsRoot.name = "weather-effects"

        switch condition {
        case .sunny:
            addSun(to: effectsRoot, voxelSize: voxelSize)
        case .cloudy:
            addClouds(to: effectsRoot, dark: false, voxelSize: voxelSize)
        case .rainy:
            addClouds(to: effectsRoot, dark: true, voxelSize: voxelSize)
            addRain(to: effectsRoot)
        case .snowy:
            addClouds(to: effectsRoot, dark: false, voxelSize: voxelSize)
            addSnow(to: effectsRoot)
        case .stormy:
            addClouds(to: effectsRoot, dark: true, voxelSize: voxelSize)
            addRain(to: effectsRoot)
            addLightning(to: effectsRoot, voxelSize: voxelSize)
        }

        parent.addChild(effectsRoot)
    }

    // MARK: - Sun (merged voxels)

    private static func addSun(to parent: Entity, voxelSize: Float = 0.010) {
        let sunColor = UIColor(red: 0.98, green: 0.85, blue: 0.25, alpha: 1)
        let sunBright = UIColor(red: 1.0, green: 0.95, blue: 0.50, alpha: 1)

        let sunRoot = Entity()
        sunRoot.name = "sun"
        sunRoot.position = SIMD3<Float>(0.04, 0.12, 0.0)

        let c = VoxelBuilder.VoxelCollector(blockSize: voxelSize)

        // Core (3x3)
        for dx in -1...1 {
            for dy in -1...1 {
                let color = (abs(dx) + abs(dy)) == 0 ? sunBright : sunColor
                c.addAt(color: color, position: SIMD3(Float(dx) * voxelSize, Float(dy) * voxelSize, 0))
            }
        }

        // Rays (extending voxels in 4 directions + diagonals)
        let rayPositions: [(Int, Int)] = [
            (0, 2), (0, -2), (2, 0), (-2, 0),
            (2, 2), (2, -2), (-2, 2), (-2, -2),
            (0, 3), (0, -3), (3, 0), (-3, 0),
        ]
        for (rx, ry) in rayPositions {
            c.addAt(color: sunColor, position: SIMD3(Float(rx) * voxelSize, Float(ry) * voxelSize, 0))
        }

        c.flush(into: sunRoot)
        sunRoot.components.set(BillboardComponent())
        parent.addChild(sunRoot)
    }

    // MARK: - Clouds (merged voxels)

    private static func addClouds(to parent: Entity, dark: Bool, voxelSize: Float = 0.010) {
        let lightColor = dark
            ? UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1)
            : UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)
        let darkColor = dark
            ? UIColor(red: 0.42, green: 0.42, blue: 0.45, alpha: 1)
            : UIColor(red: 0.82, green: 0.84, blue: 0.88, alpha: 1)

        // Each cloud: (position, radiusX, radiusZ, height) — elliptical shapes
        let clouds: [(pos: SIMD3<Float>, rx: Int, rz: Int, h: Int)] = [
            (SIMD3<Float>(-0.05, 0.11, 0.01),  8, 4, 2),  // large flat
            (SIMD3<Float>( 0.04, 0.12, -0.02), 6, 5, 3),  // round tall
            (SIMD3<Float>( 0.00, 0.10, 0.05),  7, 4, 2),  // wide
            (SIMD3<Float>(-0.02, 0.12, -0.04), 5, 3, 2),  // small
            (SIMD3<Float>( 0.06, 0.11, 0.03),  9, 3, 2),  // long
            (SIMD3<Float>(-0.06, 0.10, -0.02), 6, 5, 3),  // chunky
        ]

        let c = VoxelBuilder.VoxelCollector(blockSize: voxelSize)

        for cloud in clouds {
            let rx = cloud.rx, rz = cloud.rz, h = cloud.h
            for dx in -rx...rx {
                for dz in -rz...rz {
                    // Elliptical shape: distance check
                    let ex = Float(dx) / Float(rx)
                    let ez = Float(dz) / Float(rz)
                    let dist = ex * ex + ez * ez
                    guard dist <= 1.0 else { continue }
                    for dy in 0..<h {
                        // Upper layers shrink inward
                        let shrink = Float(dy) * 0.3
                        let layerDist = ex * ex / max(1.0 - shrink, 0.3) + ez * ez / max(1.0 - shrink, 0.3)
                        guard layerDist <= 1.0 else { continue }
                        let color = (dx + dz + dy) % 2 == 0 ? lightColor : darkColor
                        let absolutePos = cloud.pos + SIMD3<Float>(Float(dx) * voxelSize, Float(dy) * voxelSize, Float(dz) * voxelSize)
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
        // Start at cloud level
        rainEntity.position = SIMD3<Float>(0, 0.11, 0)
        // Rotate 180° around X so the plane emits downward
        rainEntity.orientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(1, 0, 0))

        var emitter = ParticleEmitterComponent()
        emitter.emitterShape = .plane
        emitter.emitterShapeSize = SIMD3<Float>(0.12, 0.01, 0.12)
        emitter.mainEmitter.birthRate = 300
        emitter.speed = 0.12
        // lifeSpan tuned so drops reach ground level (~y=-0.07) then disappear
        emitter.mainEmitter.lifeSpan = 0.7

        // Rain drops: visible streaks falling down
        emitter.mainEmitter.size = 0.004
        emitter.mainEmitter.stretchFactor = 8.0
        emitter.mainEmitter.color = .constant(.single(UIColor(red: 0.5, green: 0.7, blue: 0.95, alpha: 0.7)))
        // Acceleration in world space — pulls drops downward
        emitter.mainEmitter.acceleration = SIMD3<Float>(0, -0.4, 0)

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

    private static func addLightning(to parent: Entity, voxelSize: Float = 0.010) {
        let boltColor = UIColor(red: 1.0, green: 0.95, blue: 0.55, alpha: 1)

        let bolt = Entity()
        bolt.name = "lightning"
        bolt.position = SIMD3<Float>(0.02, 0.08, 0.01)

        let boltSize = max(voxelSize, 0.006)
        let c = VoxelBuilder.VoxelCollector(blockSize: boltSize)

        let boltPath: [(Int, Int)] = [
            (0, 4), (0, 3), (1, 2), (0, 1), (1, 0), (0, -1), (1, -2), (0, -3)
        ]
        for (bx, by) in boltPath {
            c.addAt(color: boltColor, position: SIMD3(Float(bx) * voxelSize, Float(by) * voxelSize, 0))
        }

        c.flush(into: bolt)
        bolt.components.set(BillboardComponent())
        parent.addChild(bolt)
    }
}
