import RealityKit
import UIKit

class VoxelBuilder {
    static let voxelSize: Float = 0.015

    // MARK: - Helper

    static func addVoxel(to parent: Entity, position: SIMD3<Int>, color: UIColor, size: Float = voxelSize) {
        let mesh = MeshResource.generateBox(size: size)
        var material = SimpleMaterial()
        material.color = .init(tint: color)
        material.roughness = .float(0.8)
        let voxel = ModelEntity(mesh: mesh, materials: [material])
        voxel.position = SIMD3<Float>(
            Float(position.x) * size,
            Float(position.y) * size,
            Float(position.z) * size
        )
        parent.addChild(voxel)
    }

    // MARK: - Tree

    static func buildTree() -> Entity {
        let tree = Entity()
        tree.name = "VoxelTree"

        let brown = UIColor(red: 0.45, green: 0.25, blue: 0.1, alpha: 1)
        let darkGreen = UIColor(red: 0.1, green: 0.55, blue: 0.15, alpha: 1)
        let lightGreen = UIColor(red: 0.2, green: 0.7, blue: 0.25, alpha: 1)

        // Trunk: 2x2 column, 5 voxels tall
        for y in 0..<5 {
            for x in 0..<2 {
                for z in 0..<2 {
                    addVoxel(to: tree, position: SIMD3<Int>(x, y, z), color: brown)
                }
            }
        }

        // Crown: layered cube of leaves
        // Bottom layer (5x5) at y=5
        for y in 5..<9 {
            let layerIndex = y - 5
            // Taper: radius shrinks as we go up
            let r: Int
            switch layerIndex {
            case 0: r = 3
            case 1: r = 3
            case 2: r = 2
            case 3: r = 1
            default: r = 1
            }
            let offset = -r / 2
            for x in 0..<r {
                for z in 0..<r {
                    let green = ((x + z + y) % 3 == 0) ? lightGreen : darkGreen
                    addVoxel(to: tree, position: SIMD3<Int>(x + offset, y, z + offset), color: green)
                }
            }
        }

        // Bigger crown: place a 5x4x5 block centered on trunk
        // Clear what we did above and redo more carefully
        // Actually let's remove the loop above and do it properly
        // The loop above already ran — let's just add more leaves to fill it out

        // Add a fuller crown: 5 wide, 4 tall, 5 deep, centered on trunk
        let crownOffsetX = -2
        let crownOffsetZ = -1
        for y in 5..<9 {
            let layer = y - 5
            let inset: Int
            switch layer {
            case 0: inset = 0
            case 1: inset = 0
            case 2: inset = 1
            case 3: inset = 2
            default: inset = 0
            }
            let w = 5 - inset * 2
            let d = 5 - inset * 2
            for x in 0..<w {
                for z in 0..<d {
                    let green = ((x + z + y) % 2 == 0) ? lightGreen : darkGreen
                    addVoxel(to: tree, position: SIMD3<Int>(
                        x + crownOffsetX + inset,
                        y,
                        z + crownOffsetZ + inset
                    ), color: green)
                }
            }
        }

        return tree
    }

    // MARK: - Cloud

    static func buildCloud() -> Entity {
        let cloud = Entity()
        cloud.name = "VoxelCloud"

        let white = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1)
        let lightGray = UIColor(red: 0.85, green: 0.85, blue: 0.9, alpha: 1)

        // Cloud shape: a flat blob, ~7 wide, 2 tall, 4 deep
        // Bottom layer (wider)
        let bottomShape: [(Int, Int)] = [
            (1,0), (2,0), (3,0), (4,0), (5,0),
            (0,1), (1,1), (2,1), (3,1), (4,1), (5,1), (6,1),
            (1,2), (2,2), (3,2), (4,2), (5,2),
            (2,3), (3,3), (4,3),
        ]
        for (x, z) in bottomShape {
            let c = ((x + z) % 2 == 0) ? white : lightGray
            addVoxel(to: cloud, position: SIMD3<Int>(x, 0, z), color: c)
        }

        // Top layer (smaller, centered)
        let topShape: [(Int, Int)] = [
            (2,0), (3,0), (4,0),
            (1,1), (2,1), (3,1), (4,1), (5,1),
            (2,2), (3,2), (4,2),
        ]
        for (x, z) in topShape {
            let c = ((x + z) % 2 == 0) ? lightGray : white
            addVoxel(to: cloud, position: SIMD3<Int>(x, 1, z), color: c)
        }

        // Peak
        addVoxel(to: cloud, position: SIMD3<Int>(3, 2, 1), color: white)

        return cloud
    }

    // MARK: - Ground

    static func buildGround() -> Entity {
        let ground = Entity()
        ground.name = "VoxelGround"

        let grass = UIColor(red: 0.3, green: 0.65, blue: 0.2, alpha: 1)
        let dirt = UIColor(red: 0.5, green: 0.35, blue: 0.15, alpha: 1)

        // Grass layer: 10x10
        for x in -5..<5 {
            for z in -5..<5 {
                let c = ((x + z) % 3 == 0) ? UIColor(red: 0.25, green: 0.6, blue: 0.18, alpha: 1) : grass
                addVoxel(to: ground, position: SIMD3<Int>(x, 0, z), color: c)
            }
        }

        // Dirt layer below
        for x in -5..<5 {
            for z in -5..<5 {
                addVoxel(to: ground, position: SIMD3<Int>(x, -1, z), color: dirt)
            }
        }

        return ground
    }

    // MARK: - Demo Scene

    static func buildDemo() -> Entity {
        let root = Entity()
        root.name = "VoxelDemo"

        // Ground
        let ground = buildGround()
        ground.position = SIMD3<Float>(0, 0, 0)
        root.addChild(ground)

        // Tree on the ground
        let tree = buildTree()
        tree.position = SIMD3<Float>(0.01, voxelSize, 0)
        root.addChild(tree)

        // Cloud floating above
        let cloud = buildCloud()
        cloud.position = SIMD3<Float>(-0.03, voxelSize * 13, 0.02)
        root.addChild(cloud)

        // Second smaller cloud
        let cloud2 = buildCloud()
        cloud2.position = SIMD3<Float>(0.06, voxelSize * 15, -0.02)
        cloud2.scale = SIMD3<Float>(repeating: 0.7)
        root.addChild(cloud2)

        // Center the scene vertically so it sits nicely in the volume
        root.position = SIMD3<Float>(0, -0.05, 0)

        return root
    }
}
