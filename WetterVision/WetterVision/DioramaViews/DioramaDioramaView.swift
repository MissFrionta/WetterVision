import SwiftUI
import RealityKit
import Spatial

struct DioramaDioramaView: View {
    @Environment(WeatherViewModel.self) var viewModel

    @State private var rootEntity = Entity()
    @State private var contentEntity: Entity?
    @State private var isLoading = true

    var body: some View {
        RealityView { content, attachments in
            rootEntity.name = "DioramaRoot"
            rootEntity.components.set(InputTargetComponent())

            let bounds = BoundingBox(min: SIMD3<Float>(-0.3, -0.2, -0.3),
                                     max: SIMD3<Float>(0.3, 0.3, 0.3))
            let collisionShape = ShapeResource.generateBox(
                width: bounds.max.x - bounds.min.x,
                height: bounds.max.y - bounds.min.y,
                depth: bounds.max.z - bounds.min.z
            )
            rootEntity.components.set(CollisionComponent(shapes: [collisionShape]))

            content.add(rootEntity)

            // Attach temperature gauge
            if let gaugeAttachment = attachments.entity(for: "temperatureGauge") {
                gaugeAttachment.position = SIMD3<Float>(0.25, 0.14, 0)
                rootEntity.addChild(gaugeAttachment)
            }

            // Load scene asynchronously
            Task {
                let weatherContent = await DioramaSceneBuilder.build(for: viewModel.currentWeather)
                await MainActor.run {
                    rootEntity.addChild(weatherContent)
                    contentEntity = weatherContent
                    AnimationUtilities.fadeIn(entity: weatherContent, duration: 0.5)
                    isLoading = false
                }
            }

        } update: { content, attachments in
            let rotation = viewModel.dioramaRotation
            rootEntity.transform.rotation = simd_quatf(
                ix: Float(rotation.vector.x),
                iy: Float(rotation.vector.y),
                iz: Float(rotation.vector.z),
                r: Float(rotation.vector.w)
            )
            rootEntity.scale = SIMD3<Float>(repeating: Float(viewModel.dioramaScale))

            if let gaugeAttachment = attachments.entity(for: "temperatureGauge") {
                gaugeAttachment.position = SIMD3<Float>(0.25, 0.14, 0)
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
        if let old = contentEntity {
            old.removeFromParent()
        }

        isLoading = true

        Task {
            let newContent = await DioramaSceneBuilder.build(for: viewModel.currentWeather)
            await MainActor.run {
                rootEntity.addChild(newContent)
                contentEntity = newContent
                AnimationUtilities.fadeIn(entity: newContent, duration: 0.4)
                isLoading = false
            }
        }
    }
}
