import RealityKit
import Foundation

class AssetThermometerEntity {
    static func load(temperature: Double) async -> Entity {
        if let asset = try? await Entity(named: "thermometer") {
            asset.name = "Thermometer"
            // Even with an asset, add the fill indicator programmatically
            addFillIndicator(to: asset, temperature: temperature)
            return asset
        }
        return createFallback(temperature: temperature)
    }

    private static func addFillIndicator(to entity: Entity, temperature: Double) {
        let normalizedTemp = Float(min(max((temperature + 10) / 50.0, 0.05), 1.0))
        let fillHeight: Float = normalizedTemp * 0.09
        let fillMesh = MeshResource.generateCylinder(height: fillHeight, radius: 0.005)
        var fillMaterial = SimpleMaterial()
        fillMaterial.color = .init(tint: temperatureColor(for: temperature))
        let fill = ModelEntity(mesh: fillMesh, materials: [fillMaterial])
        fill.position = SIMD3<Float>(0, fillHeight / 2 + 0.005, 0)
        fill.name = "ThermometerFill"
        entity.addChild(fill)
    }

    private static func createFallback(temperature: Double) -> Entity {
        let thermometer = Entity()
        thermometer.name = "Thermometer"

        // Glass tube — taller, more refined
        let tubeMesh = MeshResource.generateCylinder(height: 0.12, radius: 0.009)
        var tubeMaterial = SimpleMaterial()
        tubeMaterial.color = .init(tint: UIColor.white.withAlphaComponent(0.25))
        tubeMaterial.roughness = 0.05
        tubeMaterial.metallic = 0.1
        let tube = ModelEntity(mesh: tubeMesh, materials: [tubeMaterial])
        tube.position = SIMD3<Float>(0, 0.06, 0)
        thermometer.addChild(tube)

        // Bulb at bottom — slightly larger
        let bulbMesh = MeshResource.generateSphere(radius: 0.014)
        var bulbMaterial = SimpleMaterial()
        bulbMaterial.color = .init(tint: temperatureColor(for: temperature))
        let bulb = ModelEntity(mesh: bulbMesh, materials: [bulbMaterial])
        bulb.position = SIMD3<Float>(0, 0, 0)
        thermometer.addChild(bulb)

        // Fill level
        let normalizedTemp = Float(min(max((temperature + 10) / 50.0, 0.05), 1.0))
        let fillHeight: Float = normalizedTemp * 0.1
        let fillMesh = MeshResource.generateCylinder(height: fillHeight, radius: 0.006)
        var fillMaterial = SimpleMaterial()
        fillMaterial.color = .init(tint: temperatureColor(for: temperature))
        let fill = ModelEntity(mesh: fillMesh, materials: [fillMaterial])
        fill.position = SIMD3<Float>(0, fillHeight / 2 + 0.005, 0)
        thermometer.addChild(fill)

        // Scale markings — small white notches
        for i in 0..<5 {
            let y = Float(i) * 0.022 + 0.015
            let markMesh = MeshResource.generateBox(size: SIMD3<Float>(0.012, 0.001, 0.001))
            var markMat = SimpleMaterial()
            markMat.color = .init(tint: UIColor.white.withAlphaComponent(0.5))
            let mark = ModelEntity(mesh: markMesh, materials: [markMat])
            mark.position = SIMD3<Float>(0, y, 0.009)
            thermometer.addChild(mark)
        }

        // Metal cap on top
        let capMesh = MeshResource.generateSphere(radius: 0.01)
        var capMat = SimpleMaterial()
        capMat.color = .init(tint: UIColor(red: 0.7, green: 0.7, blue: 0.75, alpha: 1.0))
        capMat.metallic = 0.8
        capMat.roughness = 0.2
        let cap = ModelEntity(mesh: capMesh, materials: [capMat])
        cap.scale = SIMD3<Float>(1.0, 0.4, 1.0)
        cap.position = SIMD3<Float>(0, 0.12, 0)
        thermometer.addChild(cap)

        return thermometer
    }

    private static func temperatureColor(for temperature: Double) -> UIColor {
        if temperature < 0 { return ColorPalette.coldBlue }
        if temperature < 15 { return ColorPalette.coolCyan }
        if temperature < 25 { return ColorPalette.warmOrange }
        return ColorPalette.hotRed
    }
}
