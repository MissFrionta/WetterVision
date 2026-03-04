import RealityKit
import UIKit

/// Builds a voxel snow globe scene entirely from code — no external assets needed.
struct VoxelBuilder {

    // Finer voxels: ~1cm blocks with tiny gaps
    static let grid: Float = 0.010
    static let block: Float = 0.009

    // MARK: - Color Palette

    struct Palette {
        static let grassLight   = UIColor(red: 0.42, green: 0.75, blue: 0.33, alpha: 1)
        static let grassDark    = UIColor(red: 0.30, green: 0.62, blue: 0.25, alpha: 1)
        static let dirt         = UIColor(red: 0.55, green: 0.38, blue: 0.22, alpha: 1)
        static let dirtDark     = UIColor(red: 0.45, green: 0.30, blue: 0.18, alpha: 1)
        static let trunk        = UIColor(red: 0.50, green: 0.32, blue: 0.15, alpha: 1)
        static let trunkDark    = UIColor(red: 0.40, green: 0.25, blue: 0.12, alpha: 1)
        static let leaves       = UIColor(red: 0.22, green: 0.58, blue: 0.18, alpha: 1)
        static let leavesBright = UIColor(red: 0.35, green: 0.72, blue: 0.25, alpha: 1)
        static let leavesDark   = UIColor(red: 0.18, green: 0.48, blue: 0.15, alpha: 1)
        static let wall         = UIColor(red: 0.92, green: 0.88, blue: 0.82, alpha: 1)
        static let wallShade    = UIColor(red: 0.85, green: 0.80, blue: 0.74, alpha: 1)
        static let roof         = UIColor(red: 0.78, green: 0.22, blue: 0.18, alpha: 1)
        static let roofDark     = UIColor(red: 0.65, green: 0.18, blue: 0.14, alpha: 1)
        static let windowBlue   = UIColor(red: 0.50, green: 0.75, blue: 0.95, alpha: 1)
        static let doorBrown    = UIColor(red: 0.60, green: 0.40, blue: 0.20, alpha: 1)
        static let flower       = UIColor(red: 0.90, green: 0.35, blue: 0.40, alpha: 1)
        static let flowerYellow = UIColor(red: 0.95, green: 0.85, blue: 0.30, alpha: 1)
        static let stone        = UIColor(red: 0.60, green: 0.58, blue: 0.55, alpha: 1)
        static let stoneDark    = UIColor(red: 0.48, green: 0.46, blue: 0.43, alpha: 1)
        static let globeBase    = UIColor(red: 0.35, green: 0.25, blue: 0.15, alpha: 1)
    }

    // MARK: - Public API

    static func buildSnowGlobe() -> Entity {
        let root = Entity()
        let mesh = MeshResource.generateBox(size: block)

        // -- Voxel landscape --
        let scene = Entity()
        buildGround(in: scene, mesh: mesh)
        buildHill(in: scene, mesh: mesh)
        buildTree(in: scene, gx: -8, gz: -5, height: 6, mesh: mesh)
        buildTree(in: scene, gx: 7, gz: 4, height: 8, mesh: mesh)
        buildTree(in: scene, gx: -5, gz: 7, height: 5, mesh: mesh)
        buildSmallTree(in: scene, gx: 9, gz: -3, mesh: mesh)
        buildSmallTree(in: scene, gx: -3, gz: -8, mesh: mesh)
        buildHouse(in: scene, gx: -1, gz: -2, mesh: mesh)
        buildPath(in: scene, mesh: mesh)
        buildFlowers(in: scene, mesh: mesh)
        scene.position.y = -0.07
        root.addChild(scene)

        // -- Glass sphere --
        let globeMesh = MeshResource.generateSphere(radius: 0.17)
        var glassMat = SimpleMaterial()
        glassMat.color = .init(tint: UIColor(white: 1.0, alpha: 0.08))
        glassMat.metallic = .init(floatLiteral: 1.0)
        glassMat.roughness = .init(floatLiteral: 0.0)
        let globe = ModelEntity(mesh: globeMesh, materials: [glassMat])
        root.addChild(globe)

        // -- Wooden base --
        let baseMesh = MeshResource.generateCylinder(height: 0.04, radius: 0.12)
        let baseMat = SimpleMaterial(color: Palette.globeBase, isMetallic: false)
        let base = ModelEntity(mesh: baseMesh, materials: [baseMat])
        base.position.y = -0.19
        root.addChild(base)

        return root
    }

    // MARK: - Ground

    private static func buildGround(in parent: Entity, mesh: MeshResource) {
        let lightMat = SimpleMaterial(color: Palette.grassLight, isMetallic: false)
        let darkMat = SimpleMaterial(color: Palette.grassDark, isMetallic: false)
        let dirtMat = SimpleMaterial(color: Palette.dirt, isMetallic: false)
        let dirtDarkMat = SimpleMaterial(color: Palette.dirtDark, isMetallic: false)

        let radius = 11
        for x in -radius...radius {
            for z in -radius...radius {
                let dist = sqrt(Float(x * x + z * z))
                guard dist <= Float(radius) + 0.5 else { continue }

                // Grass top layer
                let grassMat = (x + z) % 2 == 0 ? lightMat : darkMat
                parent.addChild(voxel(mesh: mesh, mat: grassMat, x: x, y: 0, z: z))

                // Two dirt layers for depth
                let dm = (x + z) % 3 == 0 ? dirtDarkMat : dirtMat
                parent.addChild(voxel(mesh: mesh, mat: dm, x: x, y: -1, z: z))
                parent.addChild(voxel(mesh: mesh, mat: dirtDarkMat, x: x, y: -2, z: z))
            }
        }
    }

    // MARK: - Hill (small elevation near back)

    private static func buildHill(in parent: Entity, mesh: MeshResource) {
        let lightMat = SimpleMaterial(color: Palette.grassLight, isMetallic: false)
        let darkMat = SimpleMaterial(color: Palette.grassDark, isMetallic: false)
        let dirtMat = SimpleMaterial(color: Palette.dirt, isMetallic: false)

        // Gentle hill at back-right
        let cx = 5
        let cz = 5
        let hillRadius = 4
        for x in (cx - hillRadius)...(cx + hillRadius) {
            for z in (cz - hillRadius)...(cz + hillRadius) {
                let dx = x - cx
                let dz = z - cz
                let dist = sqrt(Float(dx * dx + dz * dz))
                guard dist <= Float(hillRadius) else { continue }
                let height = Int(round(2.0 * (1.0 - dist / Float(hillRadius))))
                guard height > 0 else { continue }
                for y in 1...height {
                    let mat = y == height
                        ? ((x + z) % 2 == 0 ? lightMat : darkMat)
                        : dirtMat
                    parent.addChild(voxel(mesh: mesh, mat: mat, x: x, y: y, z: z))
                }
            }
        }
    }

    // MARK: - Tree (detailed)

    private static func buildTree(in parent: Entity, gx: Int, gz: Int, height: Int, mesh: MeshResource) {
        let trunkMat = SimpleMaterial(color: Palette.trunk, isMetallic: false)
        let trunkDarkMat = SimpleMaterial(color: Palette.trunkDark, isMetallic: false)
        let leafMats = [
            SimpleMaterial(color: Palette.leaves, isMetallic: false),
            SimpleMaterial(color: Palette.leavesBright, isMetallic: false),
            SimpleMaterial(color: Palette.leavesDark, isMetallic: false)
        ]

        // Trunk (2×2 base for taller trees, 1×1 for short)
        let thick = height >= 6
        for y in 1...height {
            if thick {
                for dx in 0...1 {
                    for dz in 0...1 {
                        let mat = (dx + dz + y) % 2 == 0 ? trunkMat : trunkDarkMat
                        parent.addChild(voxel(mesh: mesh, mat: mat, x: gx + dx, y: y, z: gz + dz))
                    }
                }
            } else {
                parent.addChild(voxel(mesh: mesh, mat: trunkMat, x: gx, y: y, z: gz))
            }
        }

        // Spherical crown
        let crownRadius = thick ? 4 : 3
        let crownCenter = height + crownRadius - 1
        let offset = thick ? 0 : 0

        for dy in -crownRadius...crownRadius {
            for dx in -crownRadius...crownRadius {
                for dz in -crownRadius...crownRadius {
                    let dist = sqrt(Float(dx * dx + dy * dy + dz * dz))
                    // Sphere shape with some randomness via modulo
                    let threshold = Float(crownRadius) + ((dx + dz + dy) % 3 == 0 ? 0.5 : 0.0)
                    guard dist <= threshold else { continue }
                    // Skip bottom-center to leave space for trunk
                    if dy < -crownRadius / 2 && abs(dx) <= 1 && abs(dz) <= 1 { continue }

                    let matIndex = abs(dx + dz + dy) % leafMats.count
                    parent.addChild(voxel(mesh: mesh, mat: leafMats[matIndex],
                                          x: gx + offset + dx, y: crownCenter + dy, z: gz + offset + dz))
                }
            }
        }
    }

    // MARK: - Small Tree / Bush

    private static func buildSmallTree(in parent: Entity, gx: Int, gz: Int, mesh: MeshResource) {
        let trunkMat = SimpleMaterial(color: Palette.trunk, isMetallic: false)
        let leafMat = SimpleMaterial(color: Palette.leaves, isMetallic: false)
        let leafBrightMat = SimpleMaterial(color: Palette.leavesBright, isMetallic: false)

        // Short trunk
        for y in 1...3 {
            parent.addChild(voxel(mesh: mesh, mat: trunkMat, x: gx, y: y, z: gz))
        }

        // Small round crown
        for dy in 0...3 {
            let r = dy == 1 || dy == 2 ? 2 : 1
            for dx in -r...r {
                for dz in -r...r {
                    let dist = abs(dx) + abs(dz)
                    if dist > r + 1 { continue }
                    if abs(dx) == r && abs(dz) == r { continue }
                    let mat = (dx + dz + dy) % 2 == 0 ? leafMat : leafBrightMat
                    parent.addChild(voxel(mesh: mesh, mat: mat, x: gx + dx, y: 4 + dy, z: gz + dz))
                }
            }
        }
    }

    // MARK: - House (detailed)

    private static func buildHouse(in parent: Entity, gx: Int, gz: Int, mesh: MeshResource) {
        let wallMat = SimpleMaterial(color: Palette.wall, isMetallic: false)
        let wallShadeMat = SimpleMaterial(color: Palette.wallShade, isMetallic: false)
        let roofMat = SimpleMaterial(color: Palette.roof, isMetallic: false)
        let roofDarkMat = SimpleMaterial(color: Palette.roofDark, isMetallic: false)
        let windowMat = SimpleMaterial(color: Palette.windowBlue, isMetallic: false)
        let doorMat = SimpleMaterial(color: Palette.doorBrown, isMetallic: false)

        let w = 5  // width (x)
        let d = 5  // depth (z)
        let h = 5  // wall height

        // Walls
        for y in 1...h {
            for dx in 0..<w {
                for dz in 0..<d {
                    let isFront = dz == 0
                    let isBack = dz == d - 1
                    let isLeft = dx == 0
                    let isRight = dx == w - 1
                    let isExterior = isFront || isBack || isLeft || isRight
                    guard isExterior else { continue }

                    // Door (front center, 3 tall)
                    if isFront && dx == w / 2 && y <= 3 {
                        if y == 3 {
                            parent.addChild(voxel(mesh: mesh, mat: doorMat, x: gx + dx, y: y, z: gz + dz))
                        }
                        continue
                    }

                    // Windows (front side, two windows)
                    if isFront && y >= 3 && y <= 4 && (dx == 1 || dx == w - 2) {
                        parent.addChild(voxel(mesh: mesh, mat: windowMat, x: gx + dx, y: y, z: gz + dz))
                        continue
                    }

                    // Side windows
                    if (isLeft || isRight) && y >= 3 && y <= 4 && dz == d / 2 {
                        parent.addChild(voxel(mesh: mesh, mat: windowMat, x: gx + dx, y: y, z: gz + dz))
                        continue
                    }

                    let wm = (dx + y) % 3 == 0 ? wallShadeMat : wallMat
                    parent.addChild(voxel(mesh: mesh, mat: wm, x: gx + dx, y: y, z: gz + dz))
                }
            }
        }

        // Floor inside
        let floorMat = SimpleMaterial(color: Palette.doorBrown, isMetallic: false)
        for dx in 1..<(w - 1) {
            for dz in 1..<(d - 1) {
                parent.addChild(voxel(mesh: mesh, mat: floorMat, x: gx + dx, y: 1, z: gz + dz))
            }
        }

        // Roof (A-frame)
        let roofOverhang = 1
        for layer in 0...((w / 2) + 1) {
            let roofY = h + 1 + layer
            for dz in -roofOverhang..<(d + roofOverhang) {
                let rm = (layer + dz) % 2 == 0 ? roofMat : roofDarkMat
                // Left slope
                if layer < (w + 1) / 2 {
                    parent.addChild(voxel(mesh: mesh, mat: rm, x: gx + layer, y: roofY, z: gz + dz))
                    parent.addChild(voxel(mesh: mesh, mat: rm, x: gx + (w - 1 - layer), y: roofY, z: gz + dz))
                }
                // Peak
                if layer == (w + 1) / 2 {
                    parent.addChild(voxel(mesh: mesh, mat: rm, x: gx + w / 2, y: roofY, z: gz + dz))
                }
            }
        }
    }

    // MARK: - Stone Path

    private static func buildPath(in parent: Entity, mesh: MeshResource) {
        let stoneMat = SimpleMaterial(color: Palette.stone, isMetallic: false)
        let stoneDarkMat = SimpleMaterial(color: Palette.stoneDark, isMetallic: false)

        // Path from house door toward front
        let pathPoints: [(Int, Int)] = [
            (0, -3), (1, -3),
            (0, -4), (1, -4),
            (1, -5), (0, -5),
            (1, -6), (0, -6), (-1, -6),
            (0, -7), (1, -7),
            (0, -8), (-1, -8),
            (0, -9), (1, -9),
        ]
        for (x, z) in pathPoints {
            let mat = (x + z) % 2 == 0 ? stoneMat : stoneDarkMat
            parent.addChild(voxel(mesh: mesh, mat: mat, x: x, y: 1, z: z))
        }
    }

    // MARK: - Flowers

    private static func buildFlowers(in parent: Entity, mesh: MeshResource) {
        let flowerMat = SimpleMaterial(color: Palette.flower, isMetallic: false)
        let flowerYellowMat = SimpleMaterial(color: Palette.flowerYellow, isMetallic: false)
        let leafMat = SimpleMaterial(color: Palette.leaves, isMetallic: false)

        let flowerSpots: [(Int, Int, SimpleMaterial)] = [
            (4, -4, flowerMat),
            (5, -6, flowerYellowMat),
            (-6, -3, flowerMat),
            (-7, 2, flowerYellowMat),
            (3, -7, flowerMat),
            (-4, 6, flowerYellowMat),
        ]

        for (fx, fz, mat) in flowerSpots {
            // Stem
            parent.addChild(voxel(mesh: mesh, mat: leafMat, x: fx, y: 1, z: fz))
            // Bloom
            parent.addChild(voxel(mesh: mesh, mat: mat, x: fx, y: 2, z: fz))
        }
    }

    // MARK: - Helpers

    private static func voxel(mesh: MeshResource, mat: SimpleMaterial, x: Int, y: Int, z: Int) -> ModelEntity {
        let entity = ModelEntity(mesh: mesh, materials: [mat])
        entity.position = SIMD3<Float>(Float(x) * grid, Float(y) * grid, Float(z) * grid)
        return entity
    }
}
