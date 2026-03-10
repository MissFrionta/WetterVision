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
| `VoxelBuilder.swift` | Builds city-specific voxel snow globe scenes (Berlin, New York, Tokyo, Paris) |
| `WeatherEffects.swift` | Weather visualizations: sun, clouds, rain/snow particles, lightning |
| `CityData.swift` | Data model: City struct, WeatherInfo, dummy weather data for 4 cities |
| `AppModel.swift` | App-wide state (Xcode template) |

### Data flow

- `ContentView` owns all state as `@State` variables (no ViewModel)
- City selection: Tap on label/marker → `selectCity(named:)` → `selectedCity` changes → `update` closure runs → `updateSnowGlobe()` builds/swaps snow globe
- Gestures: `.simultaneousGesture()` on RealityView → updates `@State` rotation/scale → `update` closure applies transforms
- Entity identification: `isDragOnSnowGlobe()` traverses entity hierarchy by name

### Scene construction

- **Globe:** Earth.usdz loaded via `Entity(named: "Earth", in: realityKitContentBundle)` at scale 1.1
- **Pins:** Stecknadel-style — white cylinder stick + colored sphere head, positioned via lat/lon → spherical coordinates
- **Labels:** SwiftUI Attachments with BillboardComponent, named `"label-CityName"` for tap detection
- **Snow globes:** `VoxelBuilder.buildSnowGlobe(for:)` — procedural voxel scenes with glass sphere, city landmarks, and weather effects
- **Weather:** `WeatherEffects.apply(condition:to:)` adds sun/clouds/rain/snow/lightning

### Important constants (GlobeBuilder)

- `globeCollisionRadius = 0.155` — collision shape matching visual Earth
- `globeRadius = 0.108` — pin placement radius (closer to surface)
- `lonOffset = -80.0` — longitude correction for Earth texture alignment

## Key conventions

- **Colors:** Defined in `VoxelBuilder.Palette` as static `UIColor` properties
- **Collision:** Explicit `CollisionComponent` on all interactive entities (no `generateCollisionShapes`)
- **Hover:** `HoverEffectComponent` on entities that should highlight on gaze
- **Input:** `InputTargetComponent(allowedInputTypes: .indirect)` for eye+hand interaction
- **Gestures:** All registered as `.simultaneousGesture()` on RealityView
- **Particles:** Rain and snow use `ParticleEmitterComponent` directly; `mainEmitter.birthRate` for rate, `speed` (top-level) for velocity
- **Language:** UI text is in German. Code (variable names, comments) is in English.

## Workflow

- Code is written on Windows via Claude Code and pushed via Git
- On Mac: git pull, open in Xcode, build, test on device or simulator
- **No XcodeGen** — user works directly in Xcode
