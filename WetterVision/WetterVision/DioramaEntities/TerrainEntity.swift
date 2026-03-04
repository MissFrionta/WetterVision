import RealityKit
import UIKit
import Foundation

class TerrainEntity {
    static func load() async -> Entity {
        if let asset = try? await Entity(named: "terrain") {
            asset.name = "Terrain"
            return asset
        }
        return createFallback()
    }

    private static func createFallback() -> Entity {
        let terrain = Entity()
        terrain.name = "Terrain"

        // Main terrain: larger, more detailed island base
        let baseMesh = MeshResource.generateSphere(radius: 0.18)
        var baseMaterial = SimpleMaterial()
        baseMaterial.color = .init(tint: ColorPalette.grassGreen)
        baseMaterial.roughness = 0.9
        let baseEntity = ModelEntity(mesh: baseMesh, materials: [baseMaterial])
        baseEntity.scale = SIMD3<Float>(1.2, 0.25, 1.2)
        baseEntity.position = SIMD3<Float>(0, -0.08, 0)
        terrain.addChild(baseEntity)

        // Rock layer underneath
        let rockMesh = MeshResource.generateSphere(radius: 0.16)
        var rockMaterial = SimpleMaterial()
        rockMaterial.color = .init(tint: ColorPalette.rockBrown)
        rockMaterial.roughness = 1.0
        let rockEntity = ModelEntity(mesh: rockMesh, materials: [rockMaterial])
        rockEntity.scale = SIMD3<Float>(1.15, 0.5, 1.15)
        rockEntity.position = SIMD3<Float>(0, -0.15, 0)
        terrain.addChild(rockEntity)

        // Secondary rock detail
        let detailRockMesh = MeshResource.generateSphere(radius: 0.06)
        var detailRockMat = SimpleMaterial()
        detailRockMat.color = .init(tint: UIColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0))
        detailRockMat.roughness = 1.0
        let detailRock = ModelEntity(mesh: detailRockMesh, materials: [detailRockMat])
        detailRock.scale = SIMD3<Float>(1.0, 0.6, 1.0)
        detailRock.position = SIMD3<Float>(-0.12, -0.12, 0.05)
        terrain.addChild(detailRock)

        // Buildings — more variety
        addBuilding(to: terrain, position: SIMD3<Float>(0.06, 0.0, 0.02),
                     size: SIMD3<Float>(0.035, 0.07, 0.035), color: ColorPalette.buildingGray)
        addBuilding(to: terrain, position: SIMD3<Float>(0.03, 0.0, 0.05),
                     size: SIMD3<Float>(0.025, 0.05, 0.025), color: ColorPalette.buildingLight)
        addBuilding(to: terrain, position: SIMD3<Float>(-0.05, 0.0, -0.03),
                     size: SIMD3<Float>(0.03, 0.055, 0.03), color: ColorPalette.buildingLight)
        addBuilding(to: terrain, position: SIMD3<Float>(-0.02, 0.0, 0.07),
                     size: SIMD3<Float>(0.022, 0.04, 0.022), color: ColorPalette.buildingDark)
        addBuilding(to: terrain, position: SIMD3<Float>(0.08, 0.0, -0.04),
                     size: SIMD3<Float>(0.02, 0.035, 0.02), color: ColorPalette.buildingDark)

        // Trees — more spread out
        addTree(to: terrain, position: SIMD3<Float>(-0.09, 0.0, 0.05), scale: 1.2)
        addTree(to: terrain, position: SIMD3<Float>(0.08, 0.0, -0.06), scale: 1.0)
        addTree(to: terrain, position: SIMD3<Float>(-0.06, 0.0, -0.07), scale: 0.8)
        addTree(to: terrain, position: SIMD3<Float>(0.1, 0.0, 0.04), scale: 0.9)
        addTree(to: terrain, position: SIMD3<Float>(-0.02, 0.0, -0.09), scale: 0.7)

        // Small grass patches
        addGrassPatch(to: terrain, position: SIMD3<Float>(0.0, -0.01, 0.1))
        addGrassPatch(to: terrain, position: SIMD3<Float>(-0.1, -0.01, -0.02))

        return terrain
    }

    private static func addBuilding(to parent: Entity, position: SIMD3<Float>,
                                     size: SIMD3<Float>, color: UIColor) {
        let building = Entity()

        // Main body
        let mesh = MeshResource.generateBox(size: size)
        var material = SimpleMaterial()
        material.color = .init(tint: color)
        material.roughness = 0.6
        let body = ModelEntity(mesh: mesh, materials: [material])
        body.position = SIMD3<Float>(0, size.y / 2, 0)
        building.addChild(body)

        // Roof (flat darker piece on top)
        let roofMesh = MeshResource.generateBox(size: SIMD3<Float>(size.x + 0.004, 0.004, size.z + 0.004))
        var roofMat = SimpleMaterial()
        roofMat.color = .init(tint: UIColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 1.0))
        let roof = ModelEntity(mesh: roofMesh, materials: [roofMat])
        roof.position = SIMD3<Float>(0, size.y + 0.002, 0)
        building.addChild(roof)

        building.position = position
        parent.addChild(building)
    }

    private static func addTree(to parent: Entity, position: SIMD3<Float>, scale: Float = 1.0) {
        let tree = Entity()

        // Trunk
        let trunkMesh = MeshResource.generateCylinder(height: 0.03 * scale, radius: 0.004 * scale)
        var trunkMaterial = SimpleMaterial()
        trunkMaterial.color = .init(tint: ColorPalette.trunkBrown)
        trunkMaterial.roughness = 0.9
        let trunk = ModelEntity(mesh: trunkMesh, materials: [trunkMaterial])
        trunk.position = SIMD3<Float>(0, 0.015 * scale, 0)
        tree.addChild(trunk)

        // Canopy — two overlapping spheres for fuller look
        let canopyMesh1 = MeshResource.generateSphere(radius: 0.018 * scale)
        var canopyMat = SimpleMaterial()
        canopyMat.color = .init(tint: ColorPalette.treeGreen)
        canopyMat.roughness = 0.8
        let canopy1 = ModelEntity(mesh: canopyMesh1, materials: [canopyMat])
        canopy1.position = SIMD3<Float>(0, 0.04 * scale, 0)
        tree.addChild(canopy1)

        let canopyMesh2 = MeshResource.generateSphere(radius: 0.013 * scale)
        let canopy2 = ModelEntity(mesh: canopyMesh2, materials: [canopyMat])
        canopy2.position = SIMD3<Float>(0.008 * scale, 0.035 * scale, 0.005 * scale)
        tree.addChild(canopy2)

        tree.position = position
        parent.addChild(tree)
    }

    private static func addGrassPatch(to parent: Entity, position: SIMD3<Float>) {
        let mesh = MeshResource.generateSphere(radius: 0.025)
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor(red: 0.3, green: 0.6, blue: 0.2, alpha: 1.0))
        material.roughness = 1.0
        let patch = ModelEntity(mesh: mesh, materials: [material])
        patch.scale = SIMD3<Float>(1.0, 0.1, 1.0)
        patch.position = position
        parent.addChild(patch)
    }
}
