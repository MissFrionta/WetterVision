import RealityKit
import UIKit

/// Builds voxel snow globe scenes for each city — no external assets needed.
/// Uses mesh merging: all voxels of the same color become one ModelEntity.
struct VoxelBuilder {

    static let grid: Float = 0.010
    static let block: Float = 0.009

    // MARK: - Color Palette

    struct Palette {
        // Nature
        static let grassLight   = UIColor(red: 0.42, green: 0.75, blue: 0.33, alpha: 1)
        static let grassDark    = UIColor(red: 0.30, green: 0.62, blue: 0.25, alpha: 1)
        static let dirt         = UIColor(red: 0.55, green: 0.38, blue: 0.22, alpha: 1)
        static let dirtDark     = UIColor(red: 0.45, green: 0.30, blue: 0.18, alpha: 1)
        static let trunk        = UIColor(red: 0.50, green: 0.32, blue: 0.15, alpha: 1)
        static let trunkDark    = UIColor(red: 0.40, green: 0.25, blue: 0.12, alpha: 1)
        static let leaves       = UIColor(red: 0.22, green: 0.58, blue: 0.18, alpha: 1)
        static let leavesBright = UIColor(red: 0.35, green: 0.72, blue: 0.25, alpha: 1)
        static let leavesDark   = UIColor(red: 0.18, green: 0.48, blue: 0.15, alpha: 1)

        // Buildings
        static let wall         = UIColor(red: 0.92, green: 0.88, blue: 0.82, alpha: 1)
        static let wallShade    = UIColor(red: 0.85, green: 0.80, blue: 0.74, alpha: 1)
        static let roof         = UIColor(red: 0.78, green: 0.22, blue: 0.18, alpha: 1)
        static let roofDark     = UIColor(red: 0.65, green: 0.18, blue: 0.14, alpha: 1)
        static let windowBlue   = UIColor(red: 0.50, green: 0.75, blue: 0.95, alpha: 1)
        static let windowYellow = UIColor(red: 0.95, green: 0.85, blue: 0.50, alpha: 1)
        static let doorBrown    = UIColor(red: 0.60, green: 0.40, blue: 0.20, alpha: 1)

        // Concrete / Steel
        static let concrete      = UIColor(red: 0.65, green: 0.63, blue: 0.60, alpha: 1)
        static let concreteDark  = UIColor(red: 0.50, green: 0.48, blue: 0.45, alpha: 1)
        static let steel         = UIColor(red: 0.70, green: 0.72, blue: 0.75, alpha: 1)
        static let steelDark     = UIColor(red: 0.55, green: 0.57, blue: 0.60, alpha: 1)
        static let steelLight    = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1)

        // Berlin
        static let tvTowerSilver = UIColor(red: 0.78, green: 0.80, blue: 0.82, alpha: 1)
        static let tvTowerSphere = UIColor(red: 0.85, green: 0.85, blue: 0.88, alpha: 1)
        static let plattenbau    = UIColor(red: 0.75, green: 0.72, blue: 0.68, alpha: 1)
        static let plattenbauDark = UIColor(red: 0.65, green: 0.62, blue: 0.58, alpha: 1)

        // Tokyo
        static let pagodaRed     = UIColor(red: 0.75, green: 0.15, blue: 0.12, alpha: 1)
        static let pagodaRedDark = UIColor(red: 0.60, green: 0.10, blue: 0.08, alpha: 1)
        static let sakuraPink    = UIColor(red: 0.95, green: 0.70, blue: 0.78, alpha: 1)
        static let sakuraLight   = UIColor(red: 0.98, green: 0.82, blue: 0.87, alpha: 1)
        static let water         = UIColor(red: 0.35, green: 0.65, blue: 0.85, alpha: 1)
        static let waterDark     = UIColor(red: 0.25, green: 0.55, blue: 0.75, alpha: 1)

        // Paris
        static let parisStone    = UIColor(red: 0.88, green: 0.85, blue: 0.78, alpha: 1)
        static let parisStoneDk  = UIColor(red: 0.78, green: 0.74, blue: 0.68, alpha: 1)
        static let eiffelBrown   = UIColor(red: 0.50, green: 0.38, blue: 0.28, alpha: 1)
        static let eiffelDark    = UIColor(red: 0.40, green: 0.30, blue: 0.22, alpha: 1)
        static let parisRoof     = UIColor(red: 0.45, green: 0.50, blue: 0.55, alpha: 1)

        // London
        static let londonBrick   = UIColor(red: 0.65, green: 0.35, blue: 0.25, alpha: 1)
        static let londonBrickDk = UIColor(red: 0.55, green: 0.28, blue: 0.20, alpha: 1)
        static let clockGold     = UIColor(red: 0.90, green: 0.78, blue: 0.40, alpha: 1)
        static let londonRoof    = UIColor(red: 0.38, green: 0.42, blue: 0.45, alpha: 1)

        // Globe
        static let globeBase    = UIColor(red: 0.35, green: 0.25, blue: 0.15, alpha: 1)
        static let stone        = UIColor(red: 0.60, green: 0.58, blue: 0.55, alpha: 1)
        static let stoneDark    = UIColor(red: 0.48, green: 0.46, blue: 0.43, alpha: 1)
        static let flower       = UIColor(red: 0.90, green: 0.35, blue: 0.40, alpha: 1)
        static let flowerYellow = UIColor(red: 0.95, green: 0.85, blue: 0.30, alpha: 1)
    }

    // MARK: - Mesh Merging

    /// Groups voxels by color and creates one merged ModelEntity per color group.
    final class VoxelCollector {

        private struct ColorKey: Hashable {
            let r: UInt8, g: UInt8, b: UInt8, a: UInt8
            init(_ color: UIColor) {
                var rf: CGFloat = 0, gf: CGFloat = 0, bf: CGFloat = 0, af: CGFloat = 0
                color.getRed(&rf, green: &gf, blue: &bf, alpha: &af)
                r = UInt8(min(max(rf * 255, 0), 255))
                g = UInt8(min(max(gf * 255, 0), 255))
                b = UInt8(min(max(bf * 255, 0), 255))
                a = UInt8(min(max(af * 255, 0), 255))
            }
            var uiColor: UIColor {
                UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
            }
        }

        private var voxels: [ColorKey: [SIMD3<Float>]] = [:]
        private let halfSize: Float

        init(blockSize: Float = VoxelBuilder.block) {
            self.halfSize = blockSize / 2
        }

        /// Add a voxel at grid coordinates.
        func add(color: UIColor, x: Int, y: Int, z: Int) {
            let pos = SIMD3<Float>(Float(x) * VoxelBuilder.grid, Float(y) * VoxelBuilder.grid, Float(z) * VoxelBuilder.grid)
            addAt(color: color, position: pos)
        }

        /// Add a voxel at an absolute position.
        func addAt(color: UIColor, position: SIMD3<Float>) {
            let key = ColorKey(color)
            voxels[key, default: []].append(position)
        }

        /// Creates one ModelEntity per color group and adds them to parent.
        func flush(into parent: Entity) {
            let h = halfSize
            for (colorKey, positions) in voxels {
                guard let mesh = Self.buildMergedMesh(positions: positions, halfSize: h) else { continue }
                let mat = SimpleMaterial(color: colorKey.uiColor, isMetallic: false)
                parent.addChild(ModelEntity(mesh: mesh, materials: [mat]))
            }
        }

        private static func buildMergedMesh(positions: [SIMD3<Float>], halfSize h: Float) -> MeshResource? {
            var pos = [SIMD3<Float>]()
            var nrm = [SIMD3<Float>]()
            var idx = [UInt32]()
            pos.reserveCapacity(positions.count * 24)
            nrm.reserveCapacity(positions.count * 24)
            idx.reserveCapacity(positions.count * 36)

            for p in positions {
                let bi = UInt32(pos.count)

                // +Z face
                pos.append(contentsOf: [SIMD3(p.x-h, p.y-h, p.z+h), SIMD3(p.x+h, p.y-h, p.z+h),
                                        SIMD3(p.x+h, p.y+h, p.z+h), SIMD3(p.x-h, p.y+h, p.z+h)])
                nrm.append(contentsOf: repeatElement(SIMD3<Float>(0, 0, 1), count: 4))
                idx.append(contentsOf: [bi, bi+1, bi+2, bi, bi+2, bi+3])

                // -Z face
                let b1 = bi + 4
                pos.append(contentsOf: [SIMD3(p.x+h, p.y-h, p.z-h), SIMD3(p.x-h, p.y-h, p.z-h),
                                        SIMD3(p.x-h, p.y+h, p.z-h), SIMD3(p.x+h, p.y+h, p.z-h)])
                nrm.append(contentsOf: repeatElement(SIMD3<Float>(0, 0, -1), count: 4))
                idx.append(contentsOf: [b1, b1+1, b1+2, b1, b1+2, b1+3])

                // +X face
                let b2 = bi + 8
                pos.append(contentsOf: [SIMD3(p.x+h, p.y-h, p.z+h), SIMD3(p.x+h, p.y-h, p.z-h),
                                        SIMD3(p.x+h, p.y+h, p.z-h), SIMD3(p.x+h, p.y+h, p.z+h)])
                nrm.append(contentsOf: repeatElement(SIMD3<Float>(1, 0, 0), count: 4))
                idx.append(contentsOf: [b2, b2+1, b2+2, b2, b2+2, b2+3])

                // -X face
                let b3 = bi + 12
                pos.append(contentsOf: [SIMD3(p.x-h, p.y-h, p.z-h), SIMD3(p.x-h, p.y-h, p.z+h),
                                        SIMD3(p.x-h, p.y+h, p.z+h), SIMD3(p.x-h, p.y+h, p.z-h)])
                nrm.append(contentsOf: repeatElement(SIMD3<Float>(-1, 0, 0), count: 4))
                idx.append(contentsOf: [b3, b3+1, b3+2, b3, b3+2, b3+3])

                // +Y face
                let b4 = bi + 16
                pos.append(contentsOf: [SIMD3(p.x-h, p.y+h, p.z+h), SIMD3(p.x+h, p.y+h, p.z+h),
                                        SIMD3(p.x+h, p.y+h, p.z-h), SIMD3(p.x-h, p.y+h, p.z-h)])
                nrm.append(contentsOf: repeatElement(SIMD3<Float>(0, 1, 0), count: 4))
                idx.append(contentsOf: [b4, b4+1, b4+2, b4, b4+2, b4+3])

                // -Y face
                let b5 = bi + 20
                pos.append(contentsOf: [SIMD3(p.x-h, p.y-h, p.z-h), SIMD3(p.x+h, p.y-h, p.z-h),
                                        SIMD3(p.x+h, p.y-h, p.z+h), SIMD3(p.x-h, p.y-h, p.z+h)])
                nrm.append(contentsOf: repeatElement(SIMD3<Float>(0, -1, 0), count: 4))
                idx.append(contentsOf: [b5, b5+1, b5+2, b5, b5+2, b5+3])
            }

            var descriptor = MeshDescriptor(name: "merged-voxels")
            descriptor.positions = MeshBuffer(pos)
            descriptor.normals = MeshBuffer(nrm)
            descriptor.primitives = .triangles(idx)
            return try? MeshResource.generate(from: [descriptor])
        }
    }

    // MARK: - Public API

    /// Build a snow globe for a specific city.
    static func buildSnowGlobe(for cityName: String) -> Entity {
        let root = Entity()
        root.name = "snowglobe-\(cityName)"

        let scene = Entity()
        scene.name = "voxel-scene"
        let collector = VoxelCollector()

        switch cityName {
        case "Berlin":   buildBerlinScene(collector: collector)
        case "New York": buildNewYorkScene(collector: collector)
        case "Tokio":    buildTokioScene(collector: collector)
        case "London":   buildLondonScene(collector: collector)
        case "Paris":    buildParisScene(collector: collector)
        default:         buildGenericScene(collector: collector)
        }

        collector.flush(into: scene)
        scene.position.y = -0.07
        root.addChild(scene)

        // Weather effects based on dummy data
        if let weather = CityData.dummyWeather[cityName] {
            WeatherEffects.apply(condition: weather.condition, to: root)
        }

        // Glass sphere
        let globeMesh = MeshResource.generateSphere(radius: 0.17)
        var glassMat = SimpleMaterial()
        glassMat.color = .init(tint: UIColor(white: 1.0, alpha: 0.08))
        glassMat.metallic = .init(floatLiteral: 1.0)
        glassMat.roughness = .init(floatLiteral: 0.0)
        let globe = ModelEntity(mesh: globeMesh, materials: [glassMat])
        globe.name = "globe-glass"
        globe.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        globe.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.17)]))
        globe.components.set(HoverEffectComponent())
        root.addChild(globe)

        // Wooden base
        let baseMat = SimpleMaterial(color: Palette.globeBase, isMetallic: false)
        let base = ModelEntity(mesh: .generateCylinder(height: 0.04, radius: 0.12), materials: [baseMat])
        base.position.y = -0.19
        root.addChild(base)

        return root
    }

    // MARK: - Berlin: Fernsehturm + Plattenbauten

    private static func buildBerlinScene(collector c: VoxelCollector) {
        buildGrassGround(collector: c, radius: 8)

        // Fernsehturm — thin shaft, sphere near top, antenna
        let tx = 0, tz = 0
        for y in 1...18 {
            c.add(color: Palette.tvTowerSilver, x: tx, y: y, z: tz)
        }
        // Sphere bulge (3x3x3 sphere at y=14..16)
        for dy in -1...1 {
            for dx in -1...1 {
                for dz in -1...1 {
                    let dist = abs(dx) + abs(dy) + abs(dz)
                    if dist <= 2 {
                        c.add(color: Palette.tvTowerSphere, x: tx + dx, y: 15 + dy, z: tz + dz)
                    }
                }
            }
        }
        // Wider ring around sphere
        for dx in -2...2 {
            for dz in -2...2 {
                let dist = abs(dx) + abs(dz)
                if dist == 2 {
                    c.add(color: Palette.tvTowerSphere, x: tx + dx, y: 15, z: tz + dz)
                }
            }
        }
        // Antenna tip
        for y in 19...22 {
            c.add(color: Palette.tvTowerSilver, x: tx, y: y, z: tz)
        }

        // Plattenbauten
        buildPlattenbau(collector: c, gx: -8, gz: -3, w: 5, h: 8)
        buildPlattenbau(collector: c, gx: 4, gz: 2, w: 6, h: 6)
        buildPlattenbau(collector: c, gx: -4, gz: 5, w: 4, h: 5)

        // Trees
        buildRoundTree(collector: c, gx: -4, gz: -7, height: 4)
        buildRoundTree(collector: c, gx: 8, gz: -4, height: 3)
    }

    private static func buildPlattenbau(collector c: VoxelCollector, gx: Int, gz: Int, w: Int, h: Int) {
        let d = 3
        for y in 1...h {
            for dx in 0..<w {
                for dz in 0..<d {
                    let isExterior = dx == 0 || dx == w - 1 || dz == 0 || dz == d - 1
                    guard isExterior else { continue }

                    let isFrontBack = dz == 0 || dz == d - 1
                    if isFrontBack && y >= 2 && y % 2 == 0 && dx > 0 && dx < w - 1 && dx % 2 == 1 {
                        c.add(color: Palette.windowBlue, x: gx + dx, y: y, z: gz + dz)
                        continue
                    }

                    let color = (dx + y) % 3 == 0 ? Palette.plattenbauDark : Palette.plattenbau
                    c.add(color: color, x: gx + dx, y: y, z: gz + dz)
                }
            }
        }
        // Flat roof
        for dx in 0..<w {
            for dz in 0..<d {
                c.add(color: Palette.concreteDark, x: gx + dx, y: h + 1, z: gz + dz)
            }
        }
    }

    // MARK: - New York: Skyscrapers

    private static func buildNewYorkScene(collector c: VoxelCollector) {
        buildConcreteGround(collector: c, radius: 8)

        buildSkyscraper(collector: c, gx: -6, gz: -2, w: 4, d: 4, h: 16)
        buildSkyscraper(collector: c, gx: -1, gz: -3, w: 3, d: 3, h: 22)
        buildSkyscraper(collector: c, gx: 3, gz: -1, w: 4, d: 3, h: 13)
        buildSkyscraper(collector: c, gx: -5, gz: 3, w: 3, d: 4, h: 10)
        buildSkyscraper(collector: c, gx: 2, gz: 4, w: 5, d: 3, h: 8)

        // Antenna on tallest building
        for y in 23...26 {
            c.add(color: Palette.steel, x: 0, y: y, z: -2)
        }

        // Street-level yellow detail (taxi hint)
        c.add(color: Palette.flowerYellow, x: -3, y: 1, z: -6)
        c.add(color: Palette.flowerYellow, x: -2, y: 1, z: -6)
    }

    private static func buildSkyscraper(collector c: VoxelCollector, gx: Int, gz: Int, w: Int, d: Int, h: Int) {
        for y in 1...h {
            for dx in 0..<w {
                for dz in 0..<d {
                    let isExterior = dx == 0 || dx == w - 1 || dz == 0 || dz == d - 1
                    guard isExterior else { continue }

                    let isFace = (dz == 0 || dz == d - 1) && dx > 0 && dx < w - 1
                    let isSide = (dx == 0 || dx == w - 1) && dz > 0 && dz < d - 1
                    if (isFace || isSide) && y >= 2 && y % 2 == 0 {
                        let color = (dx + y + dz) % 5 == 0 ? Palette.windowYellow : Palette.windowBlue
                        c.add(color: color, x: gx + dx, y: y, z: gz + dz)
                        continue
                    }

                    let color: UIColor
                    if y == h { color = Palette.steelLight }
                    else if (dx + y) % 4 == 0 { color = Palette.steelDark }
                    else { color = Palette.steel }
                    c.add(color: color, x: gx + dx, y: y, z: gz + dz)
                }
            }
        }
    }

    // MARK: - Tokio: Pagode + Kirschbaum + Teich

    private static func buildTokioScene(collector c: VoxelCollector) {
        buildGrassGround(collector: c, radius: 8)

        // Pagoda (main landmark, left side)
        buildPagoda(collector: c, gx: -4, gz: -1)

        // Torii gate (iconic red shrine gate, front-right)
        buildTorii(collector: c, gx: 3, gz: -6)

        // Cherry trees — scattered around
        buildCherryTree(collector: c, gx: 6, gz: -3)
        buildCherryTree(collector: c, gx: -7, gz: -5)
        buildCherryTree(collector: c, gx: 7, gz: 5)

        // Fallen cherry blossom petals on ground
        let petalPositions: [(Int, Int)] = [
            (5, -4), (7, -2), (6, -1), (8, -3), (5, -2),
            (-6, -4), (-8, -5), (-7, -3), (-6, -6),
            (6, 4), (8, 6), (7, 3), (5, 5),
            (-2, -3), (0, -5), (1, -4), (-1, 3),
        ]
        for (px, pz) in petalPositions {
            let color = (px + pz) % 2 == 0 ? Palette.sakuraPink : Palette.sakuraLight
            c.add(color: color, x: px, y: 1, z: pz)
        }

        // Pond (right side, slightly larger)
        let pondCx = 5, pondCz = 5, pondR = 3
        for x in (pondCx - pondR)...(pondCx + pondR) {
            for z in (pondCz - pondR)...(pondCz + pondR) {
                let dist = sqrt(Float((x - pondCx) * (x - pondCx) + (z - pondCz) * (z - pondCz)))
                guard dist <= Float(pondR) + 0.3 else { continue }
                let color = (x + z) % 3 == 0 ? Palette.waterDark : Palette.water
                c.add(color: color, x: x, y: 1, z: z)
            }
        }

        // Stone edge around pond
        for x in (pondCx - pondR - 1)...(pondCx + pondR + 1) {
            for z in (pondCz - pondR - 1)...(pondCz + pondR + 1) {
                let dist = sqrt(Float((x - pondCx) * (x - pondCx) + (z - pondCz) * (z - pondCz)))
                if dist > Float(pondR) + 0.3 && dist <= Float(pondR) + 1.3 {
                    c.add(color: Palette.stone, x: x, y: 1, z: z)
                }
            }
        }

        // Small arched bridge over pond
        buildBridge(collector: c, gx: 3, gz: 5, length: 5)

        // Stone lanterns (pair flanking the path)
        buildStoneLantern(collector: c, gx: 1, gz: -4)
        buildStoneLantern(collector: c, gx: 5, gz: -4)

        // Stone stepping path from torii to pagoda
        let pathStones: [(Int, Int)] = [
            (3, -4), (2, -3), (1, -2), (0, -1), (-1, 0), (-2, 0),
        ]
        for (sx, sz) in pathStones {
            c.add(color: Palette.stone, x: sx, y: 1, z: sz)
            // Some stones are wider
            if (sx + sz) % 3 == 0 {
                c.add(color: Palette.stoneDark, x: sx + 1, y: 1, z: sz)
            }
        }
    }

    private static func buildTorii(collector c: VoxelCollector, gx: Int, gz: Int) {
        // Two pillars
        for y in 1...8 {
            c.add(color: Palette.pagodaRed, x: gx - 2, y: y, z: gz)
            c.add(color: Palette.pagodaRed, x: gx + 2, y: y, z: gz)
        }
        // Top crossbar (kasagi) — extends beyond pillars
        for dx in -3...3 {
            c.add(color: Palette.pagodaRedDark, x: gx + dx, y: 9, z: gz)
            c.add(color: Palette.pagodaRed, x: gx + dx, y: 8, z: gz)
        }
        // Second crossbar (nuki) slightly lower
        for dx in -2...2 {
            c.add(color: Palette.pagodaRedDark, x: gx + dx, y: 6, z: gz)
        }
    }

    private static func buildStoneLantern(collector c: VoxelCollector, gx: Int, gz: Int) {
        // Base
        c.add(color: Palette.stoneDark, x: gx, y: 1, z: gz)
        // Shaft
        c.add(color: Palette.stone, x: gx, y: 2, z: gz)
        c.add(color: Palette.stone, x: gx, y: 3, z: gz)
        // Light chamber
        c.add(color: Palette.windowYellow, x: gx, y: 4, z: gz)
        // Roof cap
        c.add(color: Palette.stoneDark, x: gx, y: 5, z: gz)
        c.add(color: Palette.stoneDark, x: gx - 1, y: 5, z: gz)
        c.add(color: Palette.stoneDark, x: gx + 1, y: 5, z: gz)
        c.add(color: Palette.stoneDark, x: gx, y: 5, z: gz - 1)
        c.add(color: Palette.stoneDark, x: gx, y: 5, z: gz + 1)
        // Finial
        c.add(color: Palette.stone, x: gx, y: 6, z: gz)
    }

    private static func buildBridge(collector c: VoxelCollector, gx: Int, gz: Int, length: Int) {
        // Arched bridge: slight curve up in the middle
        for i in 0..<length {
            let dx = i - length / 2
            // Arch height: higher in center
            let archY = i == length / 2 ? 3 : (i == 1 || i == length - 2 ? 2 : 1)
            c.add(color: Palette.pagodaRedDark, x: gx + dx, y: archY, z: gz)
            c.add(color: Palette.pagodaRedDark, x: gx + dx, y: archY, z: gz + 1)
            // Railings on sides
            if i == 0 || i == length / 2 || i == length - 1 {
                c.add(color: Palette.pagodaRed, x: gx + dx, y: archY + 1, z: gz)
                c.add(color: Palette.pagodaRed, x: gx + dx, y: archY + 1, z: gz + 1)
            }
        }
    }

    private static func buildPagoda(collector c: VoxelCollector, gx: Int, gz: Int) {
        let tiers: [(width: Int, height: Int)] = [(7, 4), (5, 3), (3, 3)]
        var currentY = 1

        for (tierIdx, tier) in tiers.enumerated() {
            let halfW = tier.width / 2

            for y in currentY..<(currentY + tier.height) {
                for dx in -halfW...halfW {
                    for dz in -halfW...halfW {
                        let isExterior = abs(dx) == halfW || abs(dz) == halfW
                        guard isExterior else { continue }
                        // Door opening on ground floor front
                        if tierIdx == 0 && dz == -halfW && abs(dx) <= 1 && y < currentY + 2 {
                            // Dark opening for door
                            if y == currentY {
                                c.add(color: Palette.doorBrown, x: gx + dx, y: y, z: gz + dz)
                            }
                            continue
                        }
                        // Window openings on upper floors
                        let isFace = abs(dz) == halfW && abs(dx) < halfW
                        if isFace && y == currentY + tier.height - 2 && abs(dx) % 2 == 1 {
                            c.add(color: Palette.windowYellow, x: gx + dx, y: y, z: gz + dz)
                            continue
                        }
                        let color = (dx + y + dz) % 3 == 0 ? Palette.wallShade : Palette.wall
                        c.add(color: color, x: gx + dx, y: y, z: gz + dz)
                    }
                }
            }

            // Roof with upturned corners
            let roofY = currentY + tier.height
            let roofExtend = halfW + 2
            for dx in -roofExtend...roofExtend {
                for dz in -roofExtend...roofExtend {
                    let isEdge = abs(dx) == roofExtend || abs(dz) == roofExtend
                    let isCorner = abs(dx) == roofExtend && abs(dz) == roofExtend
                    if isCorner {
                        // Upturned corner — one voxel higher
                        c.add(color: Palette.pagodaRedDark, x: gx + dx, y: roofY + 1, z: gz + dz)
                        continue
                    }
                    let color = isEdge ? Palette.pagodaRedDark : Palette.pagodaRed
                    c.add(color: color, x: gx + dx, y: roofY, z: gz + dz)
                }
            }
            // Inner roof layer
            let innerR = halfW + 1
            for dx in -innerR...innerR {
                for dz in -innerR...innerR {
                    if abs(dx) <= halfW && abs(dz) <= halfW {
                        c.add(color: Palette.pagodaRed, x: gx + dx, y: roofY + 1, z: gz + dz)
                    }
                }
            }

            currentY = roofY + 2
        }

        // Golden spire on top
        for y in currentY...(currentY + 2) {
            c.add(color: Palette.clockGold, x: gx, y: y, z: gz)
        }
        // Spire ornament
        c.add(color: Palette.clockGold, x: gx - 1, y: currentY, z: gz)
        c.add(color: Palette.clockGold, x: gx + 1, y: currentY, z: gz)
        c.add(color: Palette.clockGold, x: gx, y: currentY, z: gz - 1)
        c.add(color: Palette.clockGold, x: gx, y: currentY, z: gz + 1)
    }

    private static func buildCherryTree(collector c: VoxelCollector, gx: Int, gz: Int) {
        for y in 1...5 {
            c.add(color: Palette.trunk, x: gx, y: y, z: gz)
        }
        let r = 2, centerY = 7
        for dy in -r...r {
            for dx in -r...r {
                for dz in -r...r {
                    let dist = sqrt(Float(dx * dx + dy * dy + dz * dz))
                    guard dist <= Float(r) + 0.3 else { continue }
                    let color = abs(dx + dz + dy) % 2 == 0 ? Palette.sakuraPink : Palette.sakuraLight
                    c.add(color: color, x: gx + dx, y: centerY + dy, z: gz + dz)
                }
            }
        }
    }

    // MARK: - London: Big Ben + Parliament

    private static func buildLondonScene(collector c: VoxelCollector) {
        buildGrassGround(collector: c, radius: 8)

        let bx = 0, bz = 0

        // Tower shaft (3x3, 16 tall)
        for y in 1...16 {
            for dx in -1...1 {
                for dz in -1...1 {
                    let color = (dx + y + dz) % 3 == 0 ? Palette.londonBrickDk : Palette.londonBrick
                    c.add(color: color, x: bx + dx, y: y, z: bz + dz)
                }
            }
        }

        // Clock face (gold blocks on all 4 sides at y=13..14)
        for y in 13...14 {
            for d in -1...1 {
                c.add(color: Palette.clockGold, x: bx + d, y: y, z: bz - 2)
                c.add(color: Palette.clockGold, x: bx + d, y: y, z: bz + 2)
                c.add(color: Palette.clockGold, x: bx - 2, y: y, z: bz + d)
                c.add(color: Palette.clockGold, x: bx + 2, y: y, z: bz + d)
            }
        }

        // Pointed spire
        for dx in -1...1 {
            for dz in -1...1 {
                c.add(color: Palette.londonRoof, x: bx + dx, y: 17, z: bz + dz)
            }
        }
        c.add(color: Palette.londonRoof, x: bx, y: 18, z: bz)
        c.add(color: Palette.londonRoof, x: bx + 1, y: 18, z: bz)
        c.add(color: Palette.londonRoof, x: bx, y: 18, z: bz + 1)
        c.add(color: Palette.londonRoof, x: bx, y: 19, z: bz)
        c.add(color: Palette.londonRoof, x: bx, y: 20, z: bz)

        // Parliament building
        let px = 4, pz = -2
        let pw = 8, pd = 4, ph = 5
        for y in 1...ph {
            for dx in 0..<pw {
                for dz in 0..<pd {
                    let isExterior = dx == 0 || dx == pw - 1 || dz == 0 || dz == pd - 1
                    guard isExterior else { continue }
                    let isFace = dz == 0 || dz == pd - 1
                    if isFace && y >= 3 && dx > 0 && dx < pw - 1 && dx % 2 == 1 {
                        c.add(color: Palette.windowBlue, x: px + dx, y: y, z: pz + dz)
                        continue
                    }
                    let color = (dx + y) % 3 == 0 ? Palette.londonBrickDk : Palette.londonBrick
                    c.add(color: color, x: px + dx, y: y, z: pz + dz)
                }
            }
        }
        // Parliament flat roof
        for dx in 0..<pw {
            for dz in 0..<pd {
                c.add(color: Palette.londonRoof, x: px + dx, y: ph + 1, z: pz + dz)
            }
        }

        // Trees
        buildRoundTree(collector: c, gx: -6, gz: -5, height: 4)
        buildRoundTree(collector: c, gx: -7, gz: 4, height: 3)
        buildRoundTree(collector: c, gx: 8, gz: 5, height: 3)
    }

    // MARK: - Paris: Eiffelturm + Haeuser

    private static func buildParisScene(collector c: VoxelCollector) {
        buildGrassGround(collector: c, radius: 8)

        let ex = 0, ez = 0

        // Eiffel Tower — 4 legs merging into narrowing tower
        let legPositions = [(-3, -3), (-3, 2), (2, -3), (2, 2)]
        for y in 1...4 {
            for (lx, lz) in legPositions {
                let inward = y / 2
                let ax = lx + (lx < 0 ? inward : -inward)
                let az = lz + (lz < 0 ? inward : -inward)
                let color = (ax + y) % 2 == 0 ? Palette.eiffelBrown : Palette.eiffelDark
                c.add(color: color, x: ex + ax, y: y, z: ez + az)
            }
        }

        // Platform
        for dx in -2...2 {
            for dz in -2...2 {
                let color = (dx + dz) % 2 == 0 ? Palette.eiffelBrown : Palette.eiffelDark
                c.add(color: color, x: ex + dx, y: 5, z: ez + dz)
            }
        }

        // Narrowing shaft
        for y in 6...12 {
            let r = y < 9 ? 1 : 0
            for dx in -r...r {
                for dz in -r...r {
                    if r > 0 && abs(dx) == r && abs(dz) == r { continue }
                    let color = (dx + y) % 2 == 0 ? Palette.eiffelBrown : Palette.eiffelDark
                    c.add(color: color, x: ex + dx, y: y, z: ez + dz)
                }
            }
        }

        // Second platform at y=9
        for dx in -2...2 {
            for dz in -2...2 {
                if abs(dx) == 2 && abs(dz) == 2 { continue }
                c.add(color: Palette.eiffelBrown, x: ex + dx, y: 9, z: ez + dz)
            }
        }

        // Top antenna
        for y in 13...16 {
            c.add(color: Palette.eiffelBrown, x: ex, y: y, z: ez)
        }

        // Parisian buildings
        buildParisHouse(collector: c, gx: 5, gz: -3, w: 4, h: 5)
        buildParisHouse(collector: c, gx: 5, gz: 2, w: 3, h: 4)
        buildParisHouse(collector: c, gx: -7, gz: -2, w: 3, h: 5)

        // Trees
        buildRoundTree(collector: c, gx: -5, gz: 5, height: 4)
        buildRoundTree(collector: c, gx: 8, gz: 6, height: 3)
    }

    private static func buildParisHouse(collector c: VoxelCollector, gx: Int, gz: Int, w: Int, h: Int) {
        let d = 3
        for y in 1...h {
            for dx in 0..<w {
                for dz in 0..<d {
                    let isExterior = dx == 0 || dx == w - 1 || dz == 0 || dz == d - 1
                    guard isExterior else { continue }
                    let isFace = dz == 0 || dz == d - 1
                    if isFace && y >= 2 && dx > 0 && dx < w - 1 && y % 2 == 0 {
                        c.add(color: Palette.windowBlue, x: gx + dx, y: y, z: gz + dz)
                        continue
                    }
                    let color = (dx + y) % 3 == 0 ? Palette.parisStoneDk : Palette.parisStone
                    c.add(color: color, x: gx + dx, y: y, z: gz + dz)
                }
            }
        }
        // Mansard roof
        for dz in -1..<(d + 1) {
            for dx in 0..<w {
                c.add(color: Palette.parisRoof, x: gx + dx, y: h + 1, z: gz + dz)
            }
        }
    }

    // MARK: - Generic Scene (fallback)

    private static func buildGenericScene(collector c: VoxelCollector) {
        buildGrassGround(collector: c, radius: 8)
        buildRoundTree(collector: c, gx: -4, gz: -3, height: 5)
        buildRoundTree(collector: c, gx: 5, gz: 3, height: 4)
        buildRoundTree(collector: c, gx: 0, gz: 6, height: 3)
    }

    // MARK: - Shared Ground Types

    private static func buildGrassGround(collector c: VoxelCollector, radius: Int) {
        for x in -radius...radius {
            for z in -radius...radius {
                let dist = sqrt(Float(x * x + z * z))
                guard dist <= Float(radius) + 0.5 else { continue }
                let color = (x + z) % 2 == 0 ? Palette.grassLight : Palette.grassDark
                c.add(color: color, x: x, y: 0, z: z)
                c.add(color: Palette.dirt, x: x, y: -1, z: z)
            }
        }
    }

    private static func buildConcreteGround(collector c: VoxelCollector, radius: Int) {
        for x in -radius...radius {
            for z in -radius...radius {
                let dist = sqrt(Float(x * x + z * z))
                guard dist <= Float(radius) + 0.5 else { continue }
                let color = (x + z) % 2 == 0 ? Palette.concrete : Palette.concreteDark
                c.add(color: color, x: x, y: 0, z: z)
                c.add(color: Palette.concreteDark, x: x, y: -1, z: z)
            }
        }
    }

    // MARK: - Shared Building Blocks

    private static func buildRoundTree(collector c: VoxelCollector, gx: Int, gz: Int, height: Int,
                                       leafColor1: UIColor? = nil, leafColor2: UIColor? = nil) {
        let lc1 = leafColor1 ?? Palette.leaves
        let lc2 = leafColor2 ?? Palette.leavesBright

        for y in 1...height {
            c.add(color: Palette.trunk, x: gx, y: y, z: gz)
        }

        let r = 2
        let centerY = height + r
        for dy in -r...r {
            for dx in -r...r {
                for dz in -r...r {
                    let dist = sqrt(Float(dx * dx + dy * dy + dz * dz))
                    guard dist <= Float(r) + 0.3 else { continue }
                    let color = abs(dx + dz + dy) % 2 == 0 ? lc1 : lc2
                    c.add(color: color, x: gx + dx, y: centerY + dy, z: gz + dz)
                }
            }
        }
    }
}
