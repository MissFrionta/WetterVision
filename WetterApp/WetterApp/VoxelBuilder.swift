import RealityKit
import UIKit

/// Builds voxel snow globe scenes for each city — no external assets needed.
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

    // MARK: - Public API

    /// Build a snow globe for a specific city.
    static func buildSnowGlobe(for cityName: String) -> Entity {
        let root = Entity()
        root.name = "snowglobe-\(cityName)"
        let mesh = MeshResource.generateBox(size: block)

        let scene = Entity()
        scene.name = "voxel-scene"
        switch cityName {
        case "Berlin":   buildBerlinScene(in: scene, mesh: mesh)
        case "New York": buildNewYorkScene(in: scene, mesh: mesh)
        case "Tokio":    buildTokioScene(in: scene, mesh: mesh)
        case "London":   buildLondonScene(in: scene, mesh: mesh)
        case "Paris":    buildParisScene(in: scene, mesh: mesh)
        default:         buildGenericScene(in: scene, mesh: mesh)
        }
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
        globe.components.set(InputTargetComponent())
        globe.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.17)]))
        root.addChild(globe)

        // Wooden base
        let baseMat = SimpleMaterial(color: Palette.globeBase, isMetallic: false)
        let base = ModelEntity(mesh: .generateCylinder(height: 0.04, radius: 0.12), materials: [baseMat])
        base.position.y = -0.19
        root.addChild(base)

        return root
    }

    // MARK: - Berlin: Fernsehturm + Plattenbauten

    private static func buildBerlinScene(in parent: Entity, mesh: MeshResource) {
        buildGrassGround(in: parent, mesh: mesh, radius: 11)

        let towerMat = SimpleMaterial(color: Palette.tvTowerSilver, isMetallic: false)
        let sphereMat = SimpleMaterial(color: Palette.tvTowerSphere, isMetallic: false)

        // Fernsehturm — thin shaft, sphere near top, antenna
        let tx = 0, tz = 0
        // Shaft (1 wide, 18 tall)
        for y in 1...18 {
            parent.addChild(voxel(mesh: mesh, mat: towerMat, x: tx, y: y, z: tz))
        }
        // Sphere bulge (3x3x3 sphere at y=14..16)
        for dy in -1...1 {
            for dx in -1...1 {
                for dz in -1...1 {
                    let dist = abs(dx) + abs(dy) + abs(dz)
                    if dist <= 2 {
                        parent.addChild(voxel(mesh: mesh, mat: sphereMat, x: tx + dx, y: 15 + dy, z: tz + dz))
                    }
                }
            }
        }
        // Wider ring around sphere
        for dx in -2...2 {
            for dz in -2...2 {
                let dist = abs(dx) + abs(dz)
                if dist == 2 {
                    parent.addChild(voxel(mesh: mesh, mat: sphereMat, x: tx + dx, y: 15, z: tz + dz))
                }
            }
        }
        // Antenna tip
        for y in 19...22 {
            parent.addChild(voxel(mesh: mesh, mat: towerMat, x: tx, y: y, z: tz))
        }

        // Plattenbau left
        buildPlattenbau(in: parent, gx: -8, gz: -3, w: 5, h: 8, mesh: mesh)
        // Plattenbau right
        buildPlattenbau(in: parent, gx: 4, gz: 2, w: 6, h: 6, mesh: mesh)
        // Small one behind
        buildPlattenbau(in: parent, gx: -4, gz: 5, w: 4, h: 5, mesh: mesh)

        // A couple of trees
        buildRoundTree(in: parent, gx: -4, gz: -7, height: 4, mesh: mesh)
        buildRoundTree(in: parent, gx: 8, gz: -4, height: 3, mesh: mesh)
    }

    private static func buildPlattenbau(in parent: Entity, gx: Int, gz: Int, w: Int, h: Int, mesh: MeshResource) {
        let wallMat = SimpleMaterial(color: Palette.plattenbau, isMetallic: false)
        let wallDkMat = SimpleMaterial(color: Palette.plattenbauDark, isMetallic: false)
        let winMat = SimpleMaterial(color: Palette.windowBlue, isMetallic: false)

        let d = 3 // depth
        for y in 1...h {
            for dx in 0..<w {
                for dz in 0..<d {
                    let isExterior = dx == 0 || dx == w - 1 || dz == 0 || dz == d - 1
                    guard isExterior else { continue }

                    // Windows every other block on front/back, starting at y=2
                    let isFrontBack = dz == 0 || dz == d - 1
                    if isFrontBack && y >= 2 && y % 2 == 0 && dx > 0 && dx < w - 1 && dx % 2 == 1 {
                        parent.addChild(voxel(mesh: mesh, mat: winMat, x: gx + dx, y: y, z: gz + dz))
                        continue
                    }

                    let mat = (dx + y) % 3 == 0 ? wallDkMat : wallMat
                    parent.addChild(voxel(mesh: mesh, mat: mat, x: gx + dx, y: y, z: gz + dz))
                }
            }
        }
        // Flat roof
        let roofMat = SimpleMaterial(color: Palette.concreteDark, isMetallic: false)
        for dx in 0..<w {
            for dz in 0..<d {
                parent.addChild(voxel(mesh: mesh, mat: roofMat, x: gx + dx, y: h + 1, z: gz + dz))
            }
        }
    }

    // MARK: - New York: Skyscrapers

    private static func buildNewYorkScene(in parent: Entity, mesh: MeshResource) {
        buildConcreteGround(in: parent, mesh: mesh, radius: 11)

        // Skyline — several buildings of different heights
        buildSkyscraper(in: parent, gx: -6, gz: -2, w: 4, d: 4, h: 16, mesh: mesh)
        buildSkyscraper(in: parent, gx: -1, gz: -3, w: 3, d: 3, h: 22, mesh: mesh) // Empire State
        buildSkyscraper(in: parent, gx: 3, gz: -1, w: 4, d: 3, h: 13, mesh: mesh)
        buildSkyscraper(in: parent, gx: -5, gz: 3, w: 3, d: 4, h: 10, mesh: mesh)
        buildSkyscraper(in: parent, gx: 2, gz: 4, w: 5, d: 3, h: 8, mesh: mesh)

        // Antenna on tallest building
        let antMat = SimpleMaterial(color: Palette.steel, isMetallic: false)
        for y in 23...26 {
            parent.addChild(voxel(mesh: mesh, mat: antMat, x: 0, y: y, z: -2))
        }

        // Street-level yellow detail (taxi hint)
        let yellowMat = SimpleMaterial(color: Palette.flowerYellow, isMetallic: false)
        parent.addChild(voxel(mesh: mesh, mat: yellowMat, x: -3, y: 1, z: -6))
        parent.addChild(voxel(mesh: mesh, mat: yellowMat, x: -2, y: 1, z: -6))
    }

    private static func buildSkyscraper(in parent: Entity, gx: Int, gz: Int, w: Int, d: Int, h: Int, mesh: MeshResource) {
        let steelMat = SimpleMaterial(color: Palette.steel, isMetallic: false)
        let steelDkMat = SimpleMaterial(color: Palette.steelDark, isMetallic: false)
        let steelLtMat = SimpleMaterial(color: Palette.steelLight, isMetallic: false)
        let winMat = SimpleMaterial(color: Palette.windowBlue, isMetallic: false)
        let winLitMat = SimpleMaterial(color: Palette.windowYellow, isMetallic: false)

        for y in 1...h {
            for dx in 0..<w {
                for dz in 0..<d {
                    let isExterior = dx == 0 || dx == w - 1 || dz == 0 || dz == d - 1
                    guard isExterior else { continue }

                    // Window grid
                    let isFace = (dz == 0 || dz == d - 1) && dx > 0 && dx < w - 1
                    let isSide = (dx == 0 || dx == w - 1) && dz > 0 && dz < d - 1
                    if (isFace || isSide) && y >= 2 && y % 2 == 0 {
                        let wm = (dx + y + dz) % 5 == 0 ? winLitMat : winMat
                        parent.addChild(voxel(mesh: mesh, mat: wm, x: gx + dx, y: y, z: gz + dz))
                        continue
                    }

                    let mat: SimpleMaterial
                    if y == h { mat = steelLtMat }
                    else if (dx + y) % 4 == 0 { mat = steelDkMat }
                    else { mat = steelMat }
                    parent.addChild(voxel(mesh: mesh, mat: mat, x: gx + dx, y: y, z: gz + dz))
                }
            }
        }
    }

    // MARK: - Tokio: Pagode + Kirschbaum + Teich

    private static func buildTokioScene(in parent: Entity, mesh: MeshResource) {
        buildGrassGround(in: parent, mesh: mesh, radius: 11)

        // Pagoda (center-left)
        buildPagoda(in: parent, gx: -3, gz: 0, mesh: mesh)

        // Cherry blossom tree (right side)
        buildCherryTree(in: parent, gx: 5, gz: -3, mesh: mesh)
        buildCherryTree(in: parent, gx: 7, gz: 4, mesh: mesh)

        // Pond (front-right area, flat blue voxels at ground level)
        let waterMat = SimpleMaterial(color: Palette.water, isMetallic: false)
        let waterDkMat = SimpleMaterial(color: Palette.waterDark, isMetallic: false)
        let pondCx = 4, pondCz = 6
        let pondR = 3
        for x in (pondCx - pondR)...(pondCx + pondR) {
            for z in (pondCz - pondR)...(pondCz + pondR) {
                let dist = sqrt(Float((x - pondCx) * (x - pondCx) + (z - pondCz) * (z - pondCz)))
                guard dist <= Float(pondR) + 0.3 else { continue }
                let mat = (x + z) % 3 == 0 ? waterDkMat : waterMat
                parent.addChild(voxel(mesh: mesh, mat: mat, x: x, y: 1, z: z))
            }
        }

        // Stone lantern near pond
        let stoneMat = SimpleMaterial(color: Palette.stone, isMetallic: false)
        for y in 1...3 {
            parent.addChild(voxel(mesh: mesh, mat: stoneMat, x: 1, y: y, z: 5))
        }
        let lanternMat = SimpleMaterial(color: Palette.windowYellow, isMetallic: false)
        parent.addChild(voxel(mesh: mesh, mat: lanternMat, x: 1, y: 4, z: 5))
        parent.addChild(voxel(mesh: mesh, mat: stoneMat, x: 1, y: 5, z: 5))
    }

    private static func buildPagoda(in parent: Entity, gx: Int, gz: Int, mesh: MeshResource) {
        let wallMat = SimpleMaterial(color: Palette.wall, isMetallic: false)
        let roofMat = SimpleMaterial(color: Palette.pagodaRed, isMetallic: false)
        let roofDkMat = SimpleMaterial(color: Palette.pagodaRedDark, isMetallic: false)

        // 3 tiers, each smaller and with overhanging roof
        let tiers: [(width: Int, height: Int)] = [(7, 4), (5, 3), (3, 3)]
        var currentY = 1

        for (tierIdx, tier) in tiers.enumerated() {
            let halfW = tier.width / 2

            // Walls for this tier
            for y in currentY..<(currentY + tier.height) {
                for dx in -halfW...halfW {
                    for dz in -halfW...halfW {
                        let isExterior = abs(dx) == halfW || abs(dz) == halfW
                        guard isExterior else { continue }
                        // Door on ground floor front
                        if tierIdx == 0 && dz == -halfW && abs(dx) <= 1 && y < currentY + 2 { continue }
                        parent.addChild(voxel(mesh: mesh, mat: wallMat, x: gx + dx, y: y, z: gz + dz))
                    }
                }
            }

            // Overhanging roof
            let roofY = currentY + tier.height
            let roofExtend = halfW + 2
            for dx in -roofExtend...roofExtend {
                for dz in -roofExtend...roofExtend {
                    let isEdge = abs(dx) == roofExtend || abs(dz) == roofExtend
                    let mat = isEdge ? roofDkMat : roofMat
                    parent.addChild(voxel(mesh: mesh, mat: mat, x: gx + dx, y: roofY, z: gz + dz))
                }
            }
            // Slight upward curve at roof edges (second layer, inner part only)
            let innerR = halfW + 1
            for dx in -innerR...innerR {
                for dz in -innerR...innerR {
                    if abs(dx) <= halfW && abs(dz) <= halfW {
                        parent.addChild(voxel(mesh: mesh, mat: roofMat, x: gx + dx, y: roofY + 1, z: gz + dz))
                    }
                }
            }

            currentY = roofY + 2
        }

        // Spire on top
        let spireMat = SimpleMaterial(color: Palette.clockGold, isMetallic: false)
        for y in currentY...(currentY + 3) {
            parent.addChild(voxel(mesh: mesh, mat: spireMat, x: gx, y: y, z: gz))
        }
    }

    private static func buildCherryTree(in parent: Entity, gx: Int, gz: Int, mesh: MeshResource) {
        let trunkMat = SimpleMaterial(color: Palette.trunk, isMetallic: false)
        let sakuraMats = [
            SimpleMaterial(color: Palette.sakuraPink, isMetallic: false),
            SimpleMaterial(color: Palette.sakuraLight, isMetallic: false)
        ]

        // Trunk
        for y in 1...5 {
            parent.addChild(voxel(mesh: mesh, mat: trunkMat, x: gx, y: y, z: gz))
        }

        // Pink crown (spherical)
        let r = 3
        let centerY = 8
        for dy in -r...r {
            for dx in -r...r {
                for dz in -r...r {
                    let dist = sqrt(Float(dx * dx + dy * dy + dz * dz))
                    guard dist <= Float(r) + 0.3 else { continue }
                    if dy < -1 && abs(dx) <= 1 && abs(dz) <= 1 { continue }
                    let mat = sakuraMats[abs(dx + dz + dy) % 2]
                    parent.addChild(voxel(mesh: mesh, mat: mat, x: gx + dx, y: centerY + dy, z: gz + dz))
                }
            }
        }
    }

    // MARK: - London: Big Ben + Parliament

    private static func buildLondonScene(in parent: Entity, mesh: MeshResource) {
        buildGrassGround(in: parent, mesh: mesh, radius: 11)

        // Big Ben tower
        let brickMat = SimpleMaterial(color: Palette.londonBrick, isMetallic: false)
        let brickDkMat = SimpleMaterial(color: Palette.londonBrickDk, isMetallic: false)
        let clockMat = SimpleMaterial(color: Palette.clockGold, isMetallic: false)
        let roofMat = SimpleMaterial(color: Palette.londonRoof, isMetallic: false)

        let bx = 0, bz = 0

        // Tower shaft (3x3, 16 tall)
        for y in 1...16 {
            for dx in -1...1 {
                for dz in -1...1 {
                    let mat = (dx + y + dz) % 3 == 0 ? brickDkMat : brickMat
                    parent.addChild(voxel(mesh: mesh, mat: mat, x: bx + dx, y: y, z: bz + dz))
                }
            }
        }

        // Clock face (gold blocks on all 4 sides at y=13..14)
        for y in 13...14 {
            for d in -1...1 {
                parent.addChild(voxel(mesh: mesh, mat: clockMat, x: bx + d, y: y, z: bz - 2))  // front
                parent.addChild(voxel(mesh: mesh, mat: clockMat, x: bx + d, y: y, z: bz + 2))  // back
                parent.addChild(voxel(mesh: mesh, mat: clockMat, x: bx - 2, y: y, z: bz + d))  // left
                parent.addChild(voxel(mesh: mesh, mat: clockMat, x: bx + 2, y: y, z: bz + d))  // right
            }
        }

        // Pointed spire
        for dx in -1...1 {
            for dz in -1...1 {
                parent.addChild(voxel(mesh: mesh, mat: roofMat, x: bx + dx, y: 17, z: bz + dz))
            }
        }
        parent.addChild(voxel(mesh: mesh, mat: roofMat, x: bx, y: 18, z: bz))
        parent.addChild(voxel(mesh: mesh, mat: roofMat, x: bx + 1, y: 18, z: bz))
        parent.addChild(voxel(mesh: mesh, mat: roofMat, x: bx, y: 18, z: bz + 1))
        parent.addChild(voxel(mesh: mesh, mat: roofMat, x: bx, y: 19, z: bz))
        parent.addChild(voxel(mesh: mesh, mat: roofMat, x: bx, y: 20, z: bz))

        // Parliament building (long, low, to the right)
        let px = 4, pz = -2
        let pw = 8, pd = 4, ph = 5
        for y in 1...ph {
            for dx in 0..<pw {
                for dz in 0..<pd {
                    let isExterior = dx == 0 || dx == pw - 1 || dz == 0 || dz == pd - 1
                    guard isExterior else { continue }
                    let isFace = dz == 0 || dz == pd - 1
                    if isFace && y >= 3 && dx > 0 && dx < pw - 1 && dx % 2 == 1 {
                        parent.addChild(voxel(mesh: mesh, mat: SimpleMaterial(color: Palette.windowBlue, isMetallic: false),
                                              x: px + dx, y: y, z: pz + dz))
                        continue
                    }
                    let mat = (dx + y) % 3 == 0 ? brickDkMat : brickMat
                    parent.addChild(voxel(mesh: mesh, mat: mat, x: px + dx, y: y, z: pz + dz))
                }
            }
        }
        // Parliament flat roof
        for dx in 0..<pw {
            for dz in 0..<pd {
                parent.addChild(voxel(mesh: mesh, mat: roofMat, x: px + dx, y: ph + 1, z: pz + dz))
            }
        }

        // A few trees
        buildRoundTree(in: parent, gx: -6, gz: -5, height: 4, mesh: mesh)
        buildRoundTree(in: parent, gx: -7, gz: 4, height: 3, mesh: mesh)
        buildRoundTree(in: parent, gx: 8, gz: 5, height: 3, mesh: mesh)
    }

    // MARK: - Paris: Eiffelturm + Häuser

    private static func buildParisScene(in parent: Entity, mesh: MeshResource) {
        buildGrassGround(in: parent, mesh: mesh, radius: 11)

        let eMat = SimpleMaterial(color: Palette.eiffelBrown, isMetallic: false)
        let eDkMat = SimpleMaterial(color: Palette.eiffelDark, isMetallic: false)
        let ex = 0, ez = 0

        // Eiffel Tower — 4 legs merging into narrowing tower
        // Layer 0-3: Four separate legs (2x2 each, spread apart)
        let legPositions = [(-3, -3), (-3, 2), (2, -3), (2, 2)]
        for y in 1...4 {
            for (lx, lz) in legPositions {
                // Each leg moves inward as it goes up
                let inward = y / 2
                let ax = lx + (lx < 0 ? inward : -inward)
                let az = lz + (lz < 0 ? inward : -inward)
                let mat = (ax + y) % 2 == 0 ? eMat : eDkMat
                parent.addChild(voxel(mesh: mesh, mat: mat, x: ex + ax, y: y, z: ez + az))
            }
        }

        // Layer 5-6: Platform (wider section where legs meet)
        for dx in -2...2 {
            for dz in -2...2 {
                let mat = (dx + dz) % 2 == 0 ? eMat : eDkMat
                parent.addChild(voxel(mesh: mesh, mat: mat, x: ex + dx, y: 5, z: ez + dz))
            }
        }

        // Layer 6-12: Narrowing shaft
        for y in 6...12 {
            let r = y < 9 ? 1 : 0
            for dx in -r...r {
                for dz in -r...r {
                    if r > 0 && abs(dx) == r && abs(dz) == r { continue }
                    let mat = (dx + y) % 2 == 0 ? eMat : eDkMat
                    parent.addChild(voxel(mesh: mesh, mat: mat, x: ex + dx, y: y, z: ez + dz))
                }
            }
        }

        // Second platform at y=9
        for dx in -2...2 {
            for dz in -2...2 {
                if abs(dx) == 2 && abs(dz) == 2 { continue }
                parent.addChild(voxel(mesh: mesh, mat: eMat, x: ex + dx, y: 9, z: ez + dz))
            }
        }

        // Top antenna
        for y in 13...16 {
            parent.addChild(voxel(mesh: mesh, mat: eMat, x: ex, y: y, z: ez))
        }

        // Parisian buildings (right side)
        buildParisHouse(in: parent, gx: 5, gz: -3, w: 4, h: 5, mesh: mesh)
        buildParisHouse(in: parent, gx: 5, gz: 2, w: 3, h: 4, mesh: mesh)
        buildParisHouse(in: parent, gx: -7, gz: -2, w: 3, h: 5, mesh: mesh)

        // Trees
        buildRoundTree(in: parent, gx: -5, gz: 5, height: 4, mesh: mesh)
        buildRoundTree(in: parent, gx: 8, gz: 6, height: 3, mesh: mesh)
    }

    private static func buildParisHouse(in parent: Entity, gx: Int, gz: Int, w: Int, h: Int, mesh: MeshResource) {
        let wallMat = SimpleMaterial(color: Palette.parisStone, isMetallic: false)
        let wallDkMat = SimpleMaterial(color: Palette.parisStoneDk, isMetallic: false)
        let roofMat = SimpleMaterial(color: Palette.parisRoof, isMetallic: false)
        let winMat = SimpleMaterial(color: Palette.windowBlue, isMetallic: false)

        let d = 3
        for y in 1...h {
            for dx in 0..<w {
                for dz in 0..<d {
                    let isExterior = dx == 0 || dx == w - 1 || dz == 0 || dz == d - 1
                    guard isExterior else { continue }
                    let isFace = dz == 0 || dz == d - 1
                    if isFace && y >= 2 && dx > 0 && dx < w - 1 && y % 2 == 0 {
                        parent.addChild(voxel(mesh: mesh, mat: winMat, x: gx + dx, y: y, z: gz + dz))
                        continue
                    }
                    let mat = (dx + y) % 3 == 0 ? wallDkMat : wallMat
                    parent.addChild(voxel(mesh: mesh, mat: mat, x: gx + dx, y: y, z: gz + dz))
                }
            }
        }
        // Mansard roof (angled, typical Paris)
        for dz in -1..<(d + 1) {
            for dx in 0..<w {
                parent.addChild(voxel(mesh: mesh, mat: roofMat, x: gx + dx, y: h + 1, z: gz + dz))
            }
        }
    }

    // MARK: - Generic Scene (fallback for unknown cities)

    private static func buildGenericScene(in parent: Entity, mesh: MeshResource) {
        buildGrassGround(in: parent, mesh: mesh, radius: 11)
        buildRoundTree(in: parent, gx: -4, gz: -3, height: 5, mesh: mesh)
        buildRoundTree(in: parent, gx: 5, gz: 3, height: 4, mesh: mesh)
        buildRoundTree(in: parent, gx: 0, gz: 6, height: 3, mesh: mesh)
    }

    // MARK: - Shared Ground Types

    private static func buildGrassGround(in parent: Entity, mesh: MeshResource, radius: Int) {
        let lightMat = SimpleMaterial(color: Palette.grassLight, isMetallic: false)
        let darkMat = SimpleMaterial(color: Palette.grassDark, isMetallic: false)
        let dirtMat = SimpleMaterial(color: Palette.dirt, isMetallic: false)
        let dirtDkMat = SimpleMaterial(color: Palette.dirtDark, isMetallic: false)

        for x in -radius...radius {
            for z in -radius...radius {
                let dist = sqrt(Float(x * x + z * z))
                guard dist <= Float(radius) + 0.5 else { continue }
                let grassMat = (x + z) % 2 == 0 ? lightMat : darkMat
                parent.addChild(voxel(mesh: mesh, mat: grassMat, x: x, y: 0, z: z))
                let dm = (x + z) % 3 == 0 ? dirtDkMat : dirtMat
                parent.addChild(voxel(mesh: mesh, mat: dm, x: x, y: -1, z: z))
                parent.addChild(voxel(mesh: mesh, mat: dirtDkMat, x: x, y: -2, z: z))
            }
        }
    }

    private static func buildConcreteGround(in parent: Entity, mesh: MeshResource, radius: Int) {
        let concMat = SimpleMaterial(color: Palette.concrete, isMetallic: false)
        let concDkMat = SimpleMaterial(color: Palette.concreteDark, isMetallic: false)

        for x in -radius...radius {
            for z in -radius...radius {
                let dist = sqrt(Float(x * x + z * z))
                guard dist <= Float(radius) + 0.5 else { continue }
                let mat = (x + z) % 2 == 0 ? concMat : concDkMat
                parent.addChild(voxel(mesh: mesh, mat: mat, x: x, y: 0, z: z))
                parent.addChild(voxel(mesh: mesh, mat: concDkMat, x: x, y: -1, z: z))
                parent.addChild(voxel(mesh: mesh, mat: concDkMat, x: x, y: -2, z: z))
            }
        }
    }

    // MARK: - Shared Building Blocks

    private static func buildRoundTree(in parent: Entity, gx: Int, gz: Int, height: Int, mesh: MeshResource,
                                       leafColor1: UIColor? = nil, leafColor2: UIColor? = nil) {
        let trunkMat = SimpleMaterial(color: Palette.trunk, isMetallic: false)
        let leafMats = [
            SimpleMaterial(color: leafColor1 ?? Palette.leaves, isMetallic: false),
            SimpleMaterial(color: leafColor2 ?? Palette.leavesBright, isMetallic: false)
        ]

        for y in 1...height {
            parent.addChild(voxel(mesh: mesh, mat: trunkMat, x: gx, y: y, z: gz))
        }

        let r = 3
        let centerY = height + r
        for dy in -r...r {
            for dx in -r...r {
                for dz in -r...r {
                    let dist = sqrt(Float(dx * dx + dy * dy + dz * dz))
                    guard dist <= Float(r) + 0.3 else { continue }
                    if dy < -1 && abs(dx) <= 1 && abs(dz) <= 1 { continue }
                    let mat = leafMats[abs(dx + dz + dy) % 2]
                    parent.addChild(voxel(mesh: mesh, mat: mat, x: gx + dx, y: centerY + dy, z: gz + dz))
                }
            }
        }
    }

    // MARK: - Core Helper

    private static func voxel(mesh: MeshResource, mat: SimpleMaterial, x: Int, y: Int, z: Int) -> ModelEntity {
        let entity = ModelEntity(mesh: mesh, materials: [mat])
        entity.position = SIMD3<Float>(Float(x) * grid, Float(y) * grid, Float(z) * grid)
        return entity
    }
}
