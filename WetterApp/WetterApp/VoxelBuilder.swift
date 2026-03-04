import RealityKit
import UIKit

/// Builds a voxel snow globe scene entirely from code — no external assets needed.
struct VoxelBuilder {

    // Grid spacing (distance between voxel centers) vs block size (actual cube size).
    // The difference creates visible gaps — the key to the voxel look.
    static let grid: Float = 0.018
    static let block: Float = 0.016

    // MARK: - Color Palette (warm, Minecraft-inspired)

    struct Palette {
        static let grassLight   = UIColor(red: 0.42, green: 0.75, blue: 0.33, alpha: 1)
        static let grassDark    = UIColor(red: 0.30, green: 0.62, blue: 0.25, alpha: 1)
        static let dirt         = UIColor(red: 0.55, green: 0.38, blue: 0.22, alpha: 1)
        static let trunk        = UIColor(red: 0.50, green: 0.32, blue: 0.15, alpha: 1)
        static let leaves       = UIColor(red: 0.22, green: 0.58, blue: 0.18, alpha: 1)
        static let leavesBright = UIColor(red: 0.35, green: 0.72, blue: 0.25, alpha: 1)
        static let wall         = UIColor(red: 0.92, green: 0.88, blue: 0.82, alpha: 1)
        static let roof         = UIColor(red: 0.78, green: 0.22, blue: 0.18, alpha: 1)
        static let windowBlue   = UIColor(red: 0.50, green: 0.75, blue: 0.95, alpha: 1)
        static let globeBase    = UIColor(red: 0.35, green: 0.25, blue: 0.15, alpha: 1)
    }

    // MARK: - Public API

    /// Builds the complete snow globe: glass sphere + voxel landscape + base.
    static func buildSnowGlobe() -> Entity {
        let root = Entity()
        let mesh = MeshResource.generateBox(size: block)

        // -- Voxel landscape --
        let scene = Entity()
        buildGround(in: scene, mesh: mesh)
        buildTree(in: scene, gx: -4, gz: -3, height: 3, mesh: mesh)
        buildTree(in: scene, gx: 3, gz: 2, height: 4, mesh: mesh)
        buildTree(in: scene, gx: -2, gz: 4, height: 3, mesh: mesh)
        buildHouse(in: scene, gx: 0, gz: -1, mesh: mesh)
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

        let radius = 6
        for x in -radius...radius {
            for z in -radius...radius {
                let dist = sqrt(Float(x * x + z * z))
                guard dist <= Float(radius) + 0.5 else { continue }

                // Grass top layer (checkerboard pattern)
                let grassMat = (x + z) % 2 == 0 ? lightMat : darkMat
                parent.addChild(voxel(mesh: mesh, mat: grassMat, x: x, y: 0, z: z))

                // Dirt layer underneath
                parent.addChild(voxel(mesh: mesh, mat: dirtMat, x: x, y: -1, z: z))
            }
        }
    }

    // MARK: - Tree

    private static func buildTree(in parent: Entity, gx: Int, gz: Int, height: Int, mesh: MeshResource) {
        let trunkMat = SimpleMaterial(color: Palette.trunk, isMetallic: false)
        let leafMat = SimpleMaterial(color: Palette.leaves, isMetallic: false)
        let leafBrightMat = SimpleMaterial(color: Palette.leavesBright, isMetallic: false)

        // Trunk
        for y in 1...height {
            parent.addChild(voxel(mesh: mesh, mat: trunkMat, x: gx, y: y, z: gz))
        }

        // Crown (3 layers, middle layer wider)
        let crownY = height + 1
        for dy in 0...2 {
            let r = dy == 1 ? 2 : 1
            for dx in -r...r {
                for dz in -r...r {
                    if abs(dx) == r && abs(dz) == r && r > 1 { continue }
                    let mat = (dx + dz + dy) % 2 == 0 ? leafMat : leafBrightMat
                    parent.addChild(voxel(mesh: mesh, mat: mat, x: gx + dx, y: crownY + dy, z: gz + dz))
                }
            }
        }
    }

    // MARK: - House

    private static func buildHouse(in parent: Entity, gx: Int, gz: Int, mesh: MeshResource) {
        let wallMat = SimpleMaterial(color: Palette.wall, isMetallic: false)
        let roofMat = SimpleMaterial(color: Palette.roof, isMetallic: false)
        let windowMat = SimpleMaterial(color: Palette.windowBlue, isMetallic: false)

        // Walls: 3 wide (x) × 3 deep (z) × 3 tall (y), hollow
        for y in 1...3 {
            for dx in 0...2 {
                for dz in 0...2 {
                    let isExterior = dx == 0 || dx == 2 || dz == 0 || dz == 2
                    guard isExterior else { continue }

                    // Door opening (front center, lower 2 blocks)
                    if dx == 1 && dz == 0 && y <= 2 { continue }

                    // Windows (side walls, middle height)
                    if y == 2 && dz == 1 && (dx == 0 || dx == 2) {
                        parent.addChild(voxel(mesh: mesh, mat: windowMat, x: gx + dx, y: y, z: gz + dz))
                        continue
                    }

                    parent.addChild(voxel(mesh: mesh, mat: wallMat, x: gx + dx, y: y, z: gz + dz))
                }
            }
        }

        // Roof (A-frame, extends 1 block on each side)
        for dz in -1...3 {
            parent.addChild(voxel(mesh: mesh, mat: roofMat, x: gx, y: 4, z: gz + dz))
            parent.addChild(voxel(mesh: mesh, mat: roofMat, x: gx + 1, y: 5, z: gz + dz))
            parent.addChild(voxel(mesh: mesh, mat: roofMat, x: gx + 2, y: 4, z: gz + dz))
        }
    }

    // MARK: - Helpers

    private static func voxel(mesh: MeshResource, mat: SimpleMaterial, x: Int, y: Int, z: Int) -> ModelEntity {
        let entity = ModelEntity(mesh: mesh, materials: [mat])
        entity.position = SIMD3<Float>(Float(x) * grid, Float(y) * grid, Float(z) * grid)
        return entity
    }
}
