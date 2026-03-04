import RealityKit
import Foundation

class RainSystem {
    static func create() -> Entity {
        let rainRoot = Entity()
        rainRoot.name = "RainSystem"

        var particles = ParticleEmitterComponent()
        particles.emitterShape = .plane
        particles.emitterShapeSize = SIMD3<Float>(0.25, 0.01, 0.25)
        particles.mainEmitter.birthRate = 300
        particles.mainEmitter.lifeSpan = 1.5
        particles.speed = 0.15
        particles.mainEmitter.birthDirection = .local
        particles.mainEmitter.size = 0.002
        particles.mainEmitter.color = .constant(.single(ColorPalette.rainBlue))
        particles.mainEmitter.acceleration = SIMD3<Float>(0, -0.3, 0)

        rainRoot.components.set(particles)
        return rainRoot
    }
}
