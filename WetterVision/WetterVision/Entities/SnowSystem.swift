import RealityKit
import UIKit
import Foundation

class SnowSystem {
    static func create() -> Entity {
        let snowRoot = Entity()
        snowRoot.name = "SnowSystem"

        var particles = ParticleEmitterComponent()
        particles.emitterShape = .plane
        particles.emitterShapeSize = SIMD3<Float>(0.25, 0.01, 0.25)
        particles.mainEmitter.birthRate = 100
        particles.mainEmitter.lifeSpan = 3.0
        particles.speed = 0.03
        particles.mainEmitter.birthDirection = .local
        particles.mainEmitter.size = 0.004
        particles.mainEmitter.color = .constant(.single(.white))
        particles.mainEmitter.acceleration = SIMD3<Float>(0.01, -0.05, 0.005)

        snowRoot.components.set(particles)
        return snowRoot
    }
}
