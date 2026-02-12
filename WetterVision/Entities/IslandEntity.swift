import RealityKit
import Foundation

class IslandEntity {
    static func create() -> Entity {
        let island = Entity()
        island.name = "Island"

        // Base: flattened sphere (terrain)
        let baseMesh = MeshResource.generateSphere(radius: 0.15)
        var baseMaterial = SimpleMaterial()
        baseMaterial.color = .init(tint: ColorPalette.grassGreen)
        let baseEntity = ModelEntity(mesh: baseMesh, materials: [baseMaterial])
        baseEntity.scale = SIMD3<Float>(1.0, 0.3, 1.0) // flatten
        baseEntity.position = SIMD3<Float>(0, -0.08, 0)
        island.addChild(baseEntity)

        // Bottom rock layer
        let rockMesh = MeshResource.generateSphere(radius: 0.12)
        var rockMaterial = SimpleMaterial()
        rockMaterial.color = .init(tint: ColorPalette.rockBrown)
        let rockEntity = ModelEntity(mesh: rockMesh, materials: [rockMaterial])
        rockEntity.scale = SIMD3<Float>(1.1, 0.5, 1.1)
        rockEntity.position = SIMD3<Float>(0, -0.14, 0)
        island.addChild(rockEntity)

        // Buildings
        addBuilding(to: island, position: SIMD3<Float>(0.05, 0.0, 0.02),
                     size: SIMD3<Float>(0.03, 0.06, 0.03), color: ColorPalette.buildingGray)
        addBuilding(to: island, position: SIMD3<Float>(-0.04, 0.0, -0.03),
                     size: SIMD3<Float>(0.025, 0.045, 0.025), color: ColorPalette.buildingLight)
        addBuilding(to: island, position: SIMD3<Float>(0.0, 0.0, 0.06),
                     size: SIMD3<Float>(0.02, 0.035, 0.02), color: ColorPalette.buildingDark)

        // Trees
        addTree(to: island, position: SIMD3<Float>(-0.08, 0.0, 0.04))
        addTree(to: island, position: SIMD3<Float>(0.07, 0.0, -0.05))

        return island
    }

    private static func addBuilding(to parent: Entity, position: SIMD3<Float>,
                                     size: SIMD3<Float>, color: UIColor) {
        let mesh = MeshResource.generateBox(size: size)
        var material = SimpleMaterial()
        material.color = .init(tint: color)
        let building = ModelEntity(mesh: mesh, materials: [material])
        building.position = SIMD3<Float>(position.x, position.y + size.y / 2, position.z)
        parent.addChild(building)
    }

    private static func addTree(to parent: Entity, position: SIMD3<Float>) {
        let tree = Entity()

        // Trunk
        let trunkMesh = MeshResource.generateCylinder(height: 0.025, radius: 0.003)
        var trunkMaterial = SimpleMaterial()
        trunkMaterial.color = .init(tint: ColorPalette.trunkBrown)
        let trunk = ModelEntity(mesh: trunkMesh, materials: [trunkMaterial])
        trunk.position = SIMD3<Float>(0, 0.0125, 0)
        tree.addChild(trunk)

        // Canopy
        let canopyMesh = MeshResource.generateSphere(radius: 0.015)
        var canopyMaterial = SimpleMaterial()
        canopyMaterial.color = .init(tint: ColorPalette.treeGreen)
        let canopy = ModelEntity(mesh: canopyMesh, materials: [canopyMaterial])
        canopy.position = SIMD3<Float>(0, 0.035, 0)
        tree.addChild(canopy)

        tree.position = position
        parent.addChild(tree)
    }
}
