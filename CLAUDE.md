# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is a **visionOS 2.0+** app (Apple Vision Pro). It requires **Xcode 16+** on macOS and uses **XcodeGen** to generate the `.xcodeproj`.

```bash
# Generate Xcode project (requires: brew install xcodegen)
xcodegen generate

# Open in Xcode
open WetterVision.xcodeproj

# Build & run: select "Apple Vision Pro" simulator in Xcode, then ⌘+R
```

There are no automated tests. Testing is manual in the visionOS Simulator.

If Swift 6.0 strict concurrency causes errors, switch to Swift 5.9 in `project.yml` (`SWIFT_VERSION: "5.9"`).

## Architecture

**MVVM** with SwiftUI + RealityKit. No external dependencies — only Apple frameworks (SwiftUI, RealityKit, Spatial, Foundation).

### Data flow

`WeatherViewModel` is the single source of truth, injected via `@EnvironmentObject` from `WetterVisionApp` through the entire view hierarchy.

- **City selection:** `CityPickerView` → `WeatherViewModel.selectCity(at:)` → `DioramaRealityView.rebuildScene()` tears down old entities and calls `DioramaBuilder.build(for:)` to construct new ones.
- **Gestures:** `DioramaGestures` (ViewModifier) captures `RotateGesture3D` / `MagnifyGesture` → updates ViewModel's `dioramaRotation` / `dioramaScale` → `RealityView` update closure applies transforms to root entity. Base values are committed on gesture end.

### Scene construction

All 3D content is **programmatic** — no USDZ assets. `DioramaBuilder.build(for:)` is the orchestrator that always adds island + thermometer + wind, then switches on `WeatherCondition` to add sun, clouds, rain/snow particles, or lightning. Each entity class (`IslandEntity`, `CloudEntity`, `SunEntity`, etc.) has a static `create()` factory method returning an `Entity`.

The root entity has `InputTargetComponent` + `CollisionComponent` for gesture targeting. The volumetric window is 0.8×0.6×0.8 meters.

### UI composition

`ContentView` layers `DioramaRealityView` (3D scene) with a `.ornament(bottom)` containing `CityPickerView` + `WeatherInfoPanel` in a glass-effect panel. `TemperatureGaugeView` is attached as a RealityKit `Attachment` positioned in 3D space next to the thermometer.

## Key conventions

- **Colors:** All defined centrally in `ColorPalette.swift` as static `UIColor` properties. Use these instead of inline colors.
- **Entity pattern:** Each entity type is a class with `static func create(...) -> Entity`. Meshes use `MeshResource.generateSphere/Box/Cylinder` + `SimpleMaterial` or `UnlitMaterial`.
- **Particles:** Rain and snow use `ParticleEmitterComponent` directly on entities (no `.particleEmitter` preset files).
- **Scale clamping:** Pinch gesture is clamped to 0.5×–2.0× in the ViewModel.
- **Language:** UI text is in German (city names, weather condition labels). Code (variable names, comments) is in English.
