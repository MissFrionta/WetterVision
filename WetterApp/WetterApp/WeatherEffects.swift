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
        let sunGlow = UIColor(red: 1.0, green: 0.92, blue: 0.40, alpha: 1)

        let sunRoot = Entity()
        sunRoot.name = "sun"
        sunRoot.position = SIMD3<Float>(0.04, 0.12, 0.0)

        let c = VoxelBuilder.VoxelCollector(blockSize: voxelSize)

        // Core (5x5 diamond) — bigger and brighter
        for dx in -2...2 {
            for dy in -2...2 {
                let dist = abs(dx) + abs(dy)
                guard dist <= 2 else { continue }
                let color = dist == 0 ? sunBright : (dist == 1 ? sunColor : sunGlow)
                c.addAt(color: color, position: SIMD3(Float(dx) * voxelSize, Float(dy) * voxelSize, 0))
            }
        }

        // Rays in 8 directions — long cardinal, medium diagonal
        let rayPositions: [(Int, Int, UIColor)] = [
            // Cardinal rays (long)
            (0, 3, sunColor), (0, 4, sunColor), (0, 5, sunGlow),
            (0, -3, sunColor), (0, -4, sunColor), (0, -5, sunGlow),
            (3, 0, sunColor), (4, 0, sunColor), (5, 0, sunGlow),
            (-3, 0, sunColor), (-4, 0, sunColor), (-5, 0, sunGlow),
            // Diagonal rays (medium)
            (3, 3, sunColor), (4, 4, sunGlow),
            (3, -3, sunColor), (4, -4, sunGlow),
            (-3, 3, sunColor), (-4, 4, sunGlow),
            (-3, -3, sunColor), (-4, -4, sunGlow),
        ]
        for (rx, ry, color) in rayPositions {
            c.addAt(color: color, position: SIMD3(Float(rx) * voxelSize, Float(ry) * voxelSize, 0))
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
        // Start at cloud level — no rotation, gravity does the work
        rainEntity.position = SIMD3<Float>(0, 0.10, 0)

        var emitter = ParticleEmitterComponent()
        emitter.emitterShape = .plane
        emitter.emitterShapeSize = SIMD3<Float>(0.10, 0.01, 0.10)
        emitter.mainEmitter.birthRate = 300
        // Tiny initial speed (plane emits upward by default, but gravity overwhelms immediately)
        emitter.speed = 0.01
        // Drops fall from y=0.10 to ground (~y=-0.07): takes ~0.85s at acceleration -0.5
        emitter.mainEmitter.lifeSpan = 0.95

        // Rain drops: visible streaks falling down
        emitter.mainEmitter.size = 0.004
        emitter.mainEmitter.stretchFactor = 8.0
        emitter.mainEmitter.color = .constant(.single(UIColor(red: 0.5, green: 0.7, blue: 0.95, alpha: 0.7)))
        // Strong downward pull — overwhelms tiny initial upward speed
        emitter.mainEmitter.acceleration = SIMD3<Float>(0, -0.5, 0)

        rainEntity.components.set(emitter)
        parent.addChild(rainEntity)
    }

    // MARK: - Snow (Particle System)

    private static func addSnow(to parent: Entity) {
        let snowEntity = Entity()
        snowEntity.name = "snow"
        // Start at cloud level (same as rain) so snow drifts down through entire globe
        snowEntity.position = SIMD3<Float>(0, 0.10, 0)

        var emitter = ParticleEmitterComponent()
        emitter.emitterShape = .plane
        emitter.emitterShapeSize = SIMD3<Float>(0.12, 0.01, 0.12)
        emitter.mainEmitter.birthRate = 60
        emitter.speed = 0.01
        emitter.mainEmitter.lifeSpan = 2.0

        // Snowflakes: small, white, drifting down slowly from cloud level
        emitter.mainEmitter.size = 0.003
        emitter.mainEmitter.color = .constant(.single(UIColor(white: 1.0, alpha: 0.9)))
        emitter.mainEmitter.acceleration = SIMD3<Float>(0, -0.08, 0)

        snowEntity.components.set(emitter)
        parent.addChild(snowEntity)
    }

    // MARK: - Lightning (merged voxels)

    private static func addLightning(to parent: Entity, voxelSize: Float = 0.010) {
        let boltColor = UIColor(red: 1.0, green: 0.95, blue: 0.55, alpha: 1)
        let boltBright = UIColor(red: 1.0, green: 1.0, blue: 0.80, alpha: 1)

        let bolt = Entity()
        bolt.name = "lightning"
        // Position near Statue of Liberty area, centered vertically
        bolt.position = SIMD3<Float>(0.06, 0.0, -0.06)

        let boltSize = max(voxelSize, 0.005)
        let c = VoxelBuilder.VoxelCollector(blockSize: boltSize)

        // Full bolt from clouds (y≈20) to ground (y≈-14), zigzag pattern
        let boltPath: [(Int, Int)] = [
            // Near clouds
            (0, 20), (0, 19), (1, 18), (1, 17), (2, 16),
            // Upper zigzag
            (1, 15), (0, 14), (0, 13), (-1, 12), (-1, 11),
            // Mid section
            (0, 10), (1, 9), (2, 8), (1, 7), (0, 6),
            // Lower zigzag
            (-1, 5), (-1, 4), (0, 3), (1, 2), (1, 1),
            (0, 0), (0, -1), (-1, -2), (-1, -3), (0, -4),
            // Near ground
            (0, -5), (1, -6), (1, -7), (0, -8), (0, -9),
            (-1, -10), (0, -11), (0, -12), (0, -13), (0, -14),
        ]
        for (bx, by) in boltPath {
            let color = abs(by) < 5 ? boltBright : boltColor
            c.addAt(color: color, position: SIMD3(Float(bx) * boltSize, Float(by) * boltSize, 0))
        }

        // Small branch splitting off mid-bolt
        let branchPath: [(Int, Int)] = [
            (3, 9), (4, 8), (5, 7), (5, 6),
        ]
        for (bx, by) in branchPath {
            c.addAt(color: boltColor, position: SIMD3(Float(bx) * boltSize, Float(by) * boltSize, 0))
        }

        c.flush(into: bolt)
        bolt.components.set(BillboardComponent())
        bolt.isEnabled = false // start hidden, flash periodically
        parent.addChild(bolt)

        // Double-flash pattern every 3–6 seconds
        Task { @MainActor in
            while !Task.isCancelled {
                let pause = Double.random(in: 3.0...6.0)
                try? await Task.sleep(for: .seconds(pause))
                guard bolt.parent != nil else { break }
                // Flash 1 (short)
                bolt.isEnabled = true
                try? await Task.sleep(for: .seconds(0.1))
                bolt.isEnabled = false
                try? await Task.sleep(for: .seconds(0.08))
                // Flash 2 (slightly longer)
                bolt.isEnabled = true
                try? await Task.sleep(for: .seconds(0.15))
                bolt.isEnabled = false
            }
        }
    }
}
