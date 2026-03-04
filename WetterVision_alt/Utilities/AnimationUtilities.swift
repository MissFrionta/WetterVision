import RealityKit
import Foundation

enum AnimationUtilities {
    /// Applies a smooth fade-in by scaling from 0 to target scale
    static func fadeIn(entity: Entity, duration: TimeInterval = 0.5, targetScale: SIMD3<Float> = .one) {
        entity.scale = SIMD3<Float>(repeating: 0.01)
        entity.move(
            to: Transform(
                scale: targetScale,
                rotation: entity.transform.rotation,
                translation: entity.transform.translation
            ),
            relativeTo: entity.parent,
            duration: duration
        )
    }

    /// Applies a gentle hovering animation (up and down)
    static func hover(entity: Entity, height: Float = 0.008, duration: TimeInterval = 2.0) {
        let basePosition = entity.position
        let upTransform = Transform(
            scale: entity.scale,
            rotation: entity.transform.rotation,
            translation: basePosition + SIMD3<Float>(0, height, 0)
        )
        entity.move(to: upTransform, relativeTo: entity.parent, duration: duration)
    }
}
