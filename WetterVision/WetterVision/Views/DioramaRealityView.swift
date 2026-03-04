import SwiftUI
import RealityKit
import Spatial

struct DioramaRealityView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    @State private var rootEntity = Entity()
    @State private var contentEntity: Entity?

    var body: some View {
        RealityView { content, attachments in
            // Setup root entity with interaction components
            rootEntity.name = "DioramaRoot"
            rootEntity.components.set(InputTargetComponent())

            // Add collision for the entire diorama volume
            let bounds = BoundingBox(min: SIMD3<Float>(-0.3, -0.2, -0.3),
                                     max: SIMD3<Float>(0.3, 0.3, 0.3))
            let collisionShape = ShapeResource.generateBox(
                width: bounds.max.x - bounds.min.x,
                height: bounds.max.y - bounds.min.y,
                depth: bounds.max.z - bounds.min.z
            )
            rootEntity.components.set(CollisionComponent(shapes: [collisionShape]))

            // Build initial weather scene
            let weatherContent = DioramaBuilder.build(for: viewModel.currentWeather)
            rootEntity.addChild(weatherContent)
            contentEntity = weatherContent

            // Attach temperature gauge
            if let gaugeAttachment = attachments.entity(for: "temperatureGauge") {
                gaugeAttachment.position = SIMD3<Float>(0.22, 0.12, 0)
                rootEntity.addChild(gaugeAttachment)
            }

            content.add(rootEntity)

        } update: { content, attachments in
            // Apply rotation and scale from ViewModel
            let rotation = viewModel.dioramaRotation
            rootEntity.transform.rotation = simd_quatf(
                ix: Float(rotation.vector.x),
                iy: Float(rotation.vector.y),
                iz: Float(rotation.vector.z),
                r: Float(rotation.vector.w)
            )
            rootEntity.scale = SIMD3<Float>(repeating: Float(viewModel.dioramaScale))

            // Update temperature gauge attachment position
            if let gaugeAttachment = attachments.entity(for: "temperatureGauge") {
                gaugeAttachment.position = SIMD3<Float>(0.22, 0.12, 0)
            }

        } attachments: {
            Attachment(id: "temperatureGauge") {
                TemperatureGaugeView(temperature: viewModel.currentWeather.temperature)
            }
        }
        .dioramaGestures()
        .onChange(of: viewModel.selectedCityIndex) { _, _ in
            rebuildScene()
        }
    }

    private func rebuildScene() {
        // Remove old content
        if let old = contentEntity {
            old.removeFromParent()
        }

        // Build new content for selected city
        let newContent = DioramaBuilder.build(for: viewModel.currentWeather)
        rootEntity.addChild(newContent)
        contentEntity = newContent

        // Fade in animation
        AnimationUtilities.fadeIn(entity: newContent, duration: 0.4)
    }
}
