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

        // Each cloud is built from overlapping spheres (blobs) for organic 3D shape
        // Blob: (dx, dy, dz) offset from cloud center, r = radius in grid units
        let clouds: [(pos: SIMD3<Float>, blobs: [(dx: Int, dy: Int, dz: Int, r: Int)])] = [
            // Large puffy cloud
            (SIMD3<Float>(-0.05, 0.11, 0.01), [
                (0, 0, 0, 5), (4, 1, 0, 4), (-3, 0, 1, 4), (1, 2, 0, 3)]),
            // Round tall cloud
            (SIMD3<Float>( 0.04, 0.12, -0.02), [
                (0, 0, 0, 4), (2, 2, -1, 3), (-1, 1, 1, 3)]),
            // Wide cloud
            (SIMD3<Float>( 0.00, 0.10, 0.05), [
                (0, 0, 0, 4), (-4, 0, 0, 3), (4, 0, 1, 3), (0, 1, 0, 3)]),
            // Small cloud
            (SIMD3<Float>(-0.02, 0.12, -0.04), [
                (0, 0, 0, 3), (2, 1, 0, 2)]),
            // Long cloud
            (SIMD3<Float>( 0.06, 0.11, 0.03), [
                (0, 0, 0, 4), (5, 0, 0, 3), (-4, 0, 1, 3), (2, 1, 0, 3)]),
            // Chunky cloud
            (SIMD3<Float>(-0.06, 0.10, -0.02), [
                (0, 0, 0, 5), (0, 2, 0, 3), (3, 0, 2, 3), (-2, 1, -1, 3)]),
        ]

        let c = VoxelBuilder.VoxelCollector(blockSize: voxelSize)

        for cloud in clouds {
            // Find bounding box from all blobs
            var minX = Int.max, maxX = Int.min
            var minY = Int.max, maxY = Int.min
            var minZ = Int.max, maxZ = Int.min
            for b in cloud.blobs {
                minX = min(minX, b.dx - b.r); maxX = max(maxX, b.dx + b.r)
                minY = min(minY, b.dy - b.r); maxY = max(maxY, b.dy + b.r)
                minZ = min(minZ, b.dz - b.r); maxZ = max(maxZ, b.dz + b.r)
            }
            for dx in minX...maxX {
                for dy in minY...maxY {
                    for dz in minZ...maxZ {
                        // Include voxel if inside ANY blob sphere
                        var inside = false
                        for b in cloud.blobs {
                            let bx = dx - b.dx, by = dy - b.dy, bz = dz - b.dz
                            if bx * bx + by * by + bz * bz <= b.r * b.r {
                                inside = true
                                break
                            }
                        }
                        guard inside else { continue }
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
        emitter.emitterShapeSize = SIMD3<Float>(0.08, 0.01, 0.08)
        emitter.mainEmitter.birthRate = 300
        emitter.speed = 0.12
        // lifeSpan tuned: drops fall from clouds (y=0.11) to just above ground (~y=-0.05)
        emitter.mainEmitter.lifeSpan = 0.55

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
