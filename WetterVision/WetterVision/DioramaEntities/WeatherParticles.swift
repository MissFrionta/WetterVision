import RealityKit
import UIKit
import Foundation

class WeatherParticles {
    static func createRain() -> Entity {
        let rainRoot = Entity()
        rainRoot.name = "DioramaRain"

        var particles = ParticleEmitterComponent()
        particles.emitterShape = .plane
        particles.emitterShapeSize = SIMD3<Float>(0.3, 0.01, 0.3)
        particles.mainEmitter.birthRate = 350
        particles.mainEmitter.lifeSpan = 1.8
        particles.speed = 0.18
        particles.mainEmitter.birthDirection = .local
        particles.mainEmitter.size = 0.002
        particles.mainEmitter.color = .constant(.single(ColorPalette.rainBlue))
        particles.mainEmitter.acceleration = SIMD3<Float>(0, -0.35, 0)

        rainRoot.components.set(particles)
        return rainRoot
    }

    static func createSnow() -> Entity {
        let snowRoot = Entity()
        snowRoot.name = "DioramaSnow"

        var particles = ParticleEmitterComponent()
        particles.emitterShape = .plane
        particles.emitterShapeSize = SIMD3<Float>(0.3, 0.01, 0.3)
        particles.mainEmitter.birthRate = 120
        particles.mainEmitter.lifeSpan = 3.5
        particles.speed = 0.025
        particles.mainEmitter.birthDirection = .local
        particles.mainEmitter.size = 0.005
        particles.mainEmitter.color = .constant(.single(.white))
        particles.mainEmitter.acceleration = SIMD3<Float>(0.01, -0.04, 0.005)

        snowRoot.components.set(particles)
        return snowRoot
    }

    static func createHeavyRain() -> Entity {
        let rainRoot = Entity()
        rainRoot.name = "DioramaHeavyRain"

        var particles = ParticleEmitterComponent()
        particles.emitterShape = .plane
        particles.emitterShapeSize = SIMD3<Float>(0.3, 0.01, 0.3)
        particles.mainEmitter.birthRate = 500
        particles.mainEmitter.lifeSpan = 1.2
        particles.speed = 0.25
        particles.mainEmitter.birthDirection = .local
        particles.mainEmitter.size = 0.0025
        particles.mainEmitter.color = .constant(.single(ColorPalette.rainBlue))
        particles.mainEmitter.acceleration = SIMD3<Float>(0.02, -0.5, 0)

        rainRoot.components.set(particles)
        return rainRoot
    }
}
