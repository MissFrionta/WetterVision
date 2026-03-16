# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is a **visionOS 2.0+** app (Apple Vision Pro). It requires **Xcode 16+** on macOS.

```bash
# Open in Xcode
open WetterApp/WetterApp.xcodeproj

# Build & run: select "Apple Vision Pro" device or simulator in Xcode, then ⌘+R
```

There are no automated tests. Testing is manual on device (Apple Vision Pro) or in the visionOS Simulator.

## Architecture

SwiftUI + RealityKit. No external dependencies — only Apple frameworks (SwiftUI, RealityKit, RealityKitContent).

### Key files

| File | Purpose |
|---|---|
| `WetterAppApp.swift` | App entry point, `.windowStyle(.volumetric)`, `.defaultSize(0.9, 0.6, 0.6m)` |
| `ContentView.swift` | Main view: RealityView (make/update/attachments), all gestures, snow globe management, WeatherPanelView |
| `GlobeBuilder.swift` | Builds Earth globe (USDZ model) with stecknadel-style city pins |
| `VoxelBuilder.swift` | Builds city-specific voxel snow globe scenes (Berlin, New York, Tokio). Contains `VoxelCollector` for mesh merging |
| `WeatherEffects.swift` | Weather visualizations: sun, clouds, rain/snow particles, lightning. Uses VoxelCollector for merged meshes |
| `CityData.swift` | Data model: City struct, WeatherInfo, dummy weather data for 3 cities |
| `AppModel.swift` | App-wide state (Xcode template) |

### Data flow

- `ContentView` owns all state as `@State` variables (no ViewModel)
- City selection: Tap on label/marker → `selectCity(named:)` → `selectedCity` changes → `update` closure runs → `updateSnowGlobe()` builds/swaps snow globe
- Gestures: `.simultaneousGesture()` on RealityView → updates `@State` rotation/scale → `update` closure applies transforms
- Entity identification: `isDragOnSnowGlobe()` traverses entity hierarchy by name
- Tap on globe surface deselects the current city

### Scene construction

- **Globe:** Earth.usdz loaded via `Entity(named: "Earth", in: realityKitContentBundle)` at scale 1.1
- **Pins:** Stecknadel-style — white cylinder stick + colored sphere head, positioned via lat/lon → spherical coordinates
- **Labels:** SwiftUI Attachments with BillboardComponent + HoverEffectComponent (on Entity), plain HStack views (no .hoverEffect modifier on SwiftUI side!)
- **Snow globes:** `VoxelBuilder.buildSnowGlobe(for:)` — procedural voxel scenes with glass sphere, city landmarks, and weather effects. Uses mesh merging (~12 entities instead of ~700)
- **Weather:** `WeatherEffects.apply(condition:to:)` adds sun/clouds/rain/snow/lightning

### Important constants (GlobeBuilder)

- `globeRadius = 0.108` — used for BOTH pin placement AND collision shape
- `lonOffset = -80.0` — longitude correction for Earth texture alignment

### Performance: VoxelCollector (mesh merging)

`VoxelBuilder.VoxelCollector` groups voxels by color and generates one merged `MeshResource` per color group via `MeshDescriptor`. Each box contributes 24 vertices (4 per face, for flat-shading normals) and 36 indices (6 per face, CCW winding). This reduces entity count from ~700 to ~12 per snow globe.

## Key conventions

- **Colors:** Defined in `VoxelBuilder.Palette` as static `UIColor` properties
- **Collision:** Explicit `CollisionComponent` on all interactive entities (no `generateCollisionShapes`)
- **Hover:** `HoverEffectComponent` on RealityKit entities for gaze highlight. Do NOT use `.hoverEffect(.highlight)` on the SwiftUI attachment views (see gesture rules below)
- **Input:** `InputTargetComponent(allowedInputTypes: .indirect)` for eye+hand interaction
- **Gestures:** All registered as `.simultaneousGesture()` on RealityView
- **Particles:** Rain and snow use `ParticleEmitterComponent` directly; `mainEmitter.birthRate` for rate, `speed` (top-level) for velocity
- **Language:** UI text is in German. Code (variable names, comments) is in English.

## CRITICAL: visionOS gesture rules — DO NOT CHANGE without device testing

These rules were learned through extensive debugging on the real Apple Vision Pro.
Violating any of them WILL break DragGesture and MagnifyGesture on the globe.

### 1. Keep label collision spheres SMALL (max 0.025 radius)

The labels (SwiftUI Attachments) have CollisionComponent for tap detection. Their collision
spheres MUST NOT overlap significantly with the globe's collision sphere. When they overlap,
continuous gestures (Drag/Magnify) that hit a label attachment get consumed by SwiftUI's
internal gesture handling and never reach the RealityView's gesture handlers.

Working values (commit f4937e1, confirmed on device):
- Globe collision: `globeRadius` = 0.108 (effective ~0.119 with Earth scale 1.1)
- Label collision: 0.025
- Label position radius: globeRadius + stickHeight + 0.015 = ~0.138

The overlap between these is ~0.006 — small enough that most globe drags hit the Earth entity.

### 2. Do NOT use SwiftUI interactive modifiers on Attachment views

These modifiers on the SwiftUI content inside Attachments break continuous gestures:
- `.hoverEffect(.highlight)` — makes SwiftUI treat the view as interactive, intercepts drags
- `Button` / `.onTapGesture` — actively consumes all gesture events
- `.clipShape()` with complex shapes — can interfere with gesture passthrough

Safe modifiers: `.background(.ultraThinMaterial)`, `.cornerRadius()`, `.font()`, `.padding()`

Use `HoverEffectComponent()` on the Entity instead (set in the make closure, not on the SwiftUI view).

### 3. Do NOT increase globeCollisionRadius beyond globeRadius

The globe collision was originally 0.108 (= globeRadius). A previous attempt increased it to
0.155 to "match the visual Earth", but this massively increased overlap with label collision
spheres and broke gestures. Keep globe collision = globeRadius = 0.108.

### 4. Keep labels visually small

Larger labels (font 14, padding 12/8, .regularMaterial) were tested and broke gestures even
with small collision spheres. The working label style is:
- Font: `.system(size: 11, weight: .semibold)`
- Padding: `.horizontal(8)`, `.vertical(5)`
- Background: `.ultraThinMaterial`
- Corner radius: 8

### Summary of gesture-safe values

```
Globe collision radius:  0.108 (= globeRadius, NOT larger)
Label collision radius:  0.025
Label position offset:   0.015 above stick top
Label font size:         11
Label padding:           8 horizontal, 5 vertical
Label background:        .ultraThinMaterial
SwiftUI .hoverEffect:    NO (use HoverEffectComponent on Entity instead)
SwiftUI Button:          NO (use SpatialTapGesture handler)
```

## Workflow

- Code is written on Windows via Claude Code and pushed via Git
- On Mac: git pull, open in Xcode, build, test on device (Apple Vision Pro)
- **No XcodeGen** — user works directly in Xcode
- When testing on real device: must trust developer certificate in Settings → General → VPN & Device Management
- **ALWAYS test gesture changes on the real Apple Vision Pro** — the Simulator does not reliably reproduce gesture issues
