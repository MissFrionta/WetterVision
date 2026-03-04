import RealityKit
import UIKit
import Foundation

class ThermometerEntity {
    static func create(temperature: Double) -> Entity {
        let thermometer = Entity()
        thermometer.name = "Thermometer"

        // Glass tube (outer)
        let tubeMesh = MeshResource.generateCylinder(height: 0.1, radius: 0.008)
        var tubeMaterial = SimpleMaterial()
        tubeMaterial.color = .init(tint: UIColor.white.withAlphaComponent(0.3))
        tubeMaterial.roughness = 0.1
        let tube = ModelEntity(mesh: tubeMesh, materials: [tubeMaterial])
        tube.position = SIMD3<Float>(0, 0.05, 0)
        thermometer.addChild(tube)

        // Bulb at bottom
        let bulbMesh = MeshResource.generateSphere(radius: 0.012)
        var bulbMaterial = SimpleMaterial()
        bulbMaterial.color = .init(tint: temperatureColor(for: temperature))
        let bulb = ModelEntity(mesh: bulbMesh, materials: [bulbMaterial])
        bulb.position = SIMD3<Float>(0, 0, 0)
        thermometer.addChild(bulb)

        // Fill level (colored cylinder inside)
        let normalizedTemp = Float(min(max((temperature + 10) / 50.0, 0.05), 1.0))
        let fillHeight: Float = normalizedTemp * 0.09
        let fillMesh = MeshResource.generateCylinder(height: fillHeight, radius: 0.005)
        var fillMaterial = SimpleMaterial()
        fillMaterial.color = .init(tint: temperatureColor(for: temperature))
        let fill = ModelEntity(mesh: fillMesh, materials: [fillMaterial])
        fill.position = SIMD3<Float>(0, fillHeight / 2 + 0.005, 0)
        thermometer.addChild(fill)

        return thermometer
    }

    private static func temperatureColor(for temperature: Double) -> UIColor {
        if temperature < 0 { return ColorPalette.coldBlue }
        if temperature < 15 { return ColorPalette.coolCyan }
        if temperature < 25 { return ColorPalette.warmOrange }
        return ColorPalette.hotRed
    }
}
