# WetterVision - App-Dokumentation

## Inhaltsverzeichnis
1. [Konzept & Vision](#1-konzept--vision)
2. [Visuelle Darstellung der App](#2-visuelle-darstellung-der-app)
3. [Die 5 Wetter-Dioramen im Detail](#3-die-5-wetter-dioramen-im-detail)
4. [Benutzeroberfläche & Layout](#4-benutzeroberfläche--layout)
5. [Interaktionsmodell](#5-interaktionsmodell)
6. [Architektur & Datenfluss](#6-architektur--datenfluss)
7. [3D-Szenenaufbau (technisch)](#7-3d-szenenaufbau-technisch)
8. [Farbpalette](#8-farbpalette)
9. [Dateistruktur & Code-Übersicht](#9-dateistruktur--code-übersicht)

---

## 1. Konzept & Vision

**WetterVision** ist eine visionOS-App für die Apple Vision Pro, die Wetterdaten als interaktives 3D-Miniatur-Diorama im Raum des Nutzers darstellt. Statt Wetter als abstrakte Zahlen auf einem Bildschirm zu zeigen, wird es als greifbare Miniaturwelt erlebbar gemacht.

### Designprinzipien
- **Metapher**: Wetter als Miniaturwelt (Diorama) - eine schwebende Insel mit Gebäuden, Bäumen und dynamischen Wettereffekten
- **Spatial Computing**: Das Diorama schwebt als volumetrisches Fenster (80cm x 60cm x 80cm) im physischen Raum des Nutzers
- **Direkte Manipulation**: Der Nutzer kann das Diorama mit natürlichen Handgesten drehen und skalieren
- **Programmatische 3D-Grafik**: Alle 3D-Objekte werden zur Laufzeit aus geometrischen Grundformen erzeugt - keine vormodellierten 3D-Assets

### Zielplattform
- Apple Vision Pro mit visionOS 2.0+
- Volumetrisches Fenster (kein Immersive Space)

---

## 2. Visuelle Darstellung der App

### Gesamtansicht der App
```
    ╔══════════════════════════════════════════════════════════════╗
    ║                  VOLUMETRISCHES FENSTER                     ║
    ║                  (0.8m x 0.6m x 0.8m)                      ║
    ║                                                             ║
    ║                                                             ║
    ║              ☀  Sonne / Wolken / Effekte                    ║
    ║               \                                             ║
    ║                \        ╭──────╮                            ║
    ║                 \       │ 24°  │ ← Temperatur-Gauge         ║
    ║                  ╲      │ ━━━━ │    (SwiftUI Attachment)    ║
    ║     ═══ ═══       ╲    ╰──────╯                            ║
    ║     Wind-          ╲       |   ← Thermometer (3D)          ║
    ║     Bänder    ┌────┐ ╲     |                               ║
    ║     ═══ ═══   │    │  ╲  ┌─┐                               ║
    ║               │Geb.│ 🌳 │T│                                ║
    ║            🌳 │    │    └─┘                                 ║
    ║          ╔════╧════╧═══════╧════╗                           ║
    ║          ║   GRÜNE INSEL        ║  ← Abgeflachte Kugel     ║
    ║          ║  (Gras-Oberfläche)   ║     mit Gras-Textur      ║
    ║          ╠══════════════════════╣                            ║
    ║          ║  BRAUNE FELSSCHICHT  ║  ← Felsen unter der Insel ║
    ║          ╚══════════════════════╝                            ║
    ║                                                             ║
    ╠═════════════════════════════════════════════════════════════╣
    ║  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐             ║
    ║  │ ☀️   │ │ 🌧   │ │ ❄️   │ │ ☁️   │ │ ⛈   │             ║
    ║  │Berlin│ │Hambg.│ │Münch.│ │ Köln │ │Frankf│             ║
    ║  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘             ║
    ║                                                             ║
    ║  🌡 24°C    ☀️ Sonnig    💧 40%    🌬 12 km/h               ║
    ║  ↑ Temperatur  Zustand  Feuchtigk.  Wind                  ║
    ╚═════════════════════════════════════════════════════════════╝
       ↑                                        ↑
       Ornament-Leiste (SwiftUI, Glass-Effekt)  City Picker + Info Panel
```

### Schichtaufbau der 3D-Szene (Seitenansicht)
```
    Höhe (Y)
      ↑
  0.20│   ☀ Sonne / ☁ Wolken / Partikel
      │
  0.18│   ~~~ Regen-/Schnee-Emitter ~~~
      │
  0.15│   ☁ ☁ Wolkencluster (je 5 Kugeln)
      │
  0.12│              ┌──────┐ Temperatur-Gauge (SwiftUI)
  0.10│      ═══     │      │ Thermometer-Glasrohr
  0.08│  Wind ═══    │  °C  │
      │  Bänder      │      │
  0.06│      ┌──┐    └──┬───┘
  0.04│  🌳  │  │  🌳   │ Thermometer-Kugel
  0.02│      │G │       │
  0.00│══════╧══╧═══════╧═══════ Gras-Oberfläche
 -0.08│     ╔═══════════════╗    Abgeflachte grüne Kugel
      │     ╚═══════════════╝
 -0.14│      ╔═════════════╗     Braune Felsschicht
      │      ╚═════════════╝
      └──────────────────────────→ X-Achse
         -0.15    0     0.15  0.18
```

---

## 3. Die 5 Wetter-Dioramen im Detail

### Berlin - Sonnig (24°C)
```
    Wetterdaten: 24°C | Sonnig | 40% Feuchtigkeit | 12 km/h Wind

                  *  *
               *  ☀️  *         ← Sonne: Leuchtende gelbe Kugel (r=0.035)
                *  *               mit 8 orangenen Strahlen drum herum
               *  *
                                ╭──────╮
        ☁                       │ 24°  │ ← Orange (warm)
     (kleine helle              │ ████ │
      Wolke, 70%)               ╰──────╯
                                   |
     ═══                     ┌────┐|
     ═══ (2 Bänder,         │    │|
      kurz, 12km/h)    🌳   │    │🌳 ┌─┐
                             │    │   │T│
    ═════════════════════════╧════╧═══╧═╧════
    ████████  GRÜNE INSEL  ████████████████
    ▓▓▓▓▓▓▓▓  FELSEN  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

    Besonderheiten:
    - Sonne: UnlitMaterial (selbstleuchtend, kein Schatten)
    - 8 Sonnenstrahlen: Dünne Boxen (0.005 x 0.025 x 0.005), kreisförmig
    - 1 helle kleine Wolke (auf 70% skaliert) für visuelle Abwechslung
    - Thermometer-Füllung: Orange (warm, 24°C → ~68% gefüllt)
    - Nur 2 kurze Wind-Bänder (schwacher Wind)
```

### Hamburg - Regen (14°C)
```
    Wetterdaten: 14°C | Regen | 85% Feuchtigkeit | 25 km/h Wind

        ████  ████  ████
       ██████████████████       ← 3 dunkle Wolkencluster
        ████  ████  ████          (je 5 überlappende graue Kugeln)

        | | | | | | | | |      ← Regen-Partikelsystem
        | | | | | | | | |        300 Partikel/Sek, blaue Tropfen
        | | | | | | | | |        Beschleunigung nach unten (-0.3)
                                ╭──────╮
     ════                       │ 14°  │ ← Cyan (kühl)
     ════                       │ ██░░ │
     ════ (3 Bänder,            ╰──────╯
      mittel, 25km/h)             |
                           🌳 ┌──┐|
                              │  │| 🌳 ┌─┐
                              │  │|    │T│
    ══════════════════════════╧══╧═════╧═╧════
    ████████  GRÜNE INSEL  ████████████████
    ▓▓▓▓▓▓▓▓  FELSEN  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

    Besonderheiten:
    - 3 dunkle Wolkencluster (isDark=true, dunkelgrau #73737F)
    - Regen: ParticleEmitterComponent, Ebenen-Emitter (0.25 x 0.25m)
    - Tropfen: Kleine blaue Partikel (Größe 0.002), Lebensdauer 1.5s
    - Fallgeschwindigkeit: 0.15 + Gravitation (-0.3)
    - Thermometer: Cyan-Füllung (~48% gefüllt)
    - 3 Wind-Bänder mittlerer Länge
```

### München - Schnee (-2°C)
```
    Wetterdaten: -2°C | Schnee | 70% Feuchtigkeit | 8 km/h Wind

          ████  ████
         ████████████           ← 2 dunkle Wolkencluster
          ████  ████

          *  .  *  .  *        ← Schnee-Partikelsystem
        .  *  .  *  .  *         100 Partikel/Sek, weiße Flocken
          *  .  *  .  *          Langsam (0.03), leichter Seitenwind
        .  *  .  *  .  *         Lebensdauer 3.0s
                                ╭──────╮
     ══                         │ -2°  │ ← Blau (kalt)
     ══ (2 Bänder,              │ █░░░ │
      kurz, 8km/h)              ╰──────╯
                                   |
                           🌳 ┌──┐|
                              │  │| 🌳 ┌─┐
                              │  │|    │T│
    ══════════════════════════╧══╧═════╧═╧════
    ████████  GRÜNE INSEL  ████████████████
    ▓▓▓▓▓▓▓▓  FELSEN  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

    Besonderheiten:
    - 2 dunkle Wolkencluster
    - Schnee: ParticleEmitterComponent, weiße Partikel (Größe 0.004)
    - Langsamere Fallgeschwindigkeit als Regen (0.03 vs 0.15)
    - Leichter diagonaler Drift (X: +0.01, Z: +0.005)
    - Thermometer: Blau-Füllung (kalt, ~16% gefüllt)
    - Nur 2 sehr kurze Wind-Bänder (schwacher Wind)
```

### Köln - Bewölkt (18°C)
```
    Wetterdaten: 18°C | Bewölkt | 60% Feuchtigkeit | 15 km/h Wind

       ☁☁   ☁☁   ☁☁   ☁☁
      ☁☁☁☁ ☁☁☁☁ ☁☁☁☁ ☁☁☁☁    ← 4 Wolkencluster
       ☁☁   ☁☁   ☁☁   ☁☁       (2 helle + 2 dunkle, gemischt)

                                ╭──────╮
     ═══                        │ 18°  │ ← Orange (warm)
     ═══ (2 Bänder,             │ ███░ │
      mittel, 15km/h)           ╰──────╯
                                   |
                           🌳 ┌──┐|
                              │  │|   ┌─┐
                         🌳   │  │| 🌳│T│
                              │  │|   │ │
    ══════════════════════════╧══╧════╧═╧════
    ████████  GRÜNE INSEL  ████████████████
    ▓▓▓▓▓▓▓▓  FELSEN  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

    Besonderheiten:
    - 4 Wolkencluster auf verschiedenen Höhen (0.13-0.18)
    - Die ersten 2 Wolken sind hell (isDark=false, weiß #F2F2F7)
    - Die letzten 2 sind dunkler (isDark=true, grau #73737F)
    - Keine Niederschlagseffekte
    - Thermometer: Orange-Füllung (~56% gefüllt)
    - 2 Wind-Bänder mittlerer Länge
```

### Frankfurt - Gewitter (20°C)
```
    Wetterdaten: 20°C | Gewitter | 75% Feuchtigkeit | 45 km/h Wind

       ████ ████ ████ ████ ████
      ██████████████████████████    ← 5 dichte dunkle Wolkencluster
       ████ ████ ████ ████ ████       (alle isDark=true)

        | | |⚡| | | | | | |       ← Regen + Blitz!
        | | | | | | | | | | |        Blitz: Gelber leuchtender Balken
        | | | | | | | | | | |        Regen: 300 Partikel/Sek
                                ╭──────╮
     ══════                     │ 20°  │ ← Orange (warm)
     ══════                     │ ███░ │
     ══════                     ╰──────╯
     ══════ (5 Bänder,            |
     ══════  lang, 45km/h)        |
     ══════              🌳 ┌──┐|
                            │  │|   ┌─┐
                       🌳   │  │| 🌳│T│
    ════════════════════════╧══╧════╧═╧════
    ████████  GRÜNE INSEL  ████████████████
    ▓▓▓▓▓▓▓▓  FELSEN  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

    Besonderheiten:
    - 5 dichte, dunkle Wolkencluster (dramatischste Szene)
    - Starker Regen wie bei Hamburg (300 Partikel/Sek)
    - Blitz: Leuchtend gelber Balken (0.005 x 0.08 x 0.005)
      - UnlitMaterial (selbstleuchtend, Farbe #FFFF99)
      - Leicht schräg (0.2 rad Rotation um Z-Achse)
    - 6 lange Wind-Bänder (max. Anzahl bei 45 km/h)
    - Bänder sind deutlich länger als bei anderen Städten
    - Thermometer: Orange-Füllung (~60% gefüllt)
```

---

## 4. Benutzeroberfläche & Layout

### Ornament-Leiste (am unteren Rand des volumetrischen Fensters)

Die Ornament-Leiste ist ein SwiftUI-Panel mit Glass-Effekt, das als `.ornament` am unteren Rand des 3D-Fensters angebracht ist. Sie besteht aus zwei Bereichen:

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐ ┌────────┐ ║
║  │  ☀️    │  │  🌧️   │  │  ❄️    │  │  ☁️    │ │  ⛈️    │ ║
║  │ Berlin │  │Hamburg │  │München │  │  Köln  │ │Frankfrt│ ║
║  └────────┘  └────────┘  └────────┘  └────────┘ └────────┘ ║
║  [aktiv]                                                     ║
║                      STADTAUSWAHL                            ║
║──────────────────────────────────────────────────────────────║
║                                                              ║
║  🌡 24°C       ☀️ Sonnig       💧 40%       🌬 12 km/h      ║
║  Temperatur    Zustand        Feuchte      Wind              ║
║                                                              ║
║                    WETTER-INFO-PANEL                         ║
╚══════════════════════════════════════════════════════════════╝
```

**Stadtauswahl (CityPickerView)**:
- 5 Buttons nebeneinander in einer HStack
- Jeder Button zeigt ein SF-Symbol (Wetter-Icon) und den Stadtnamen
- Die aktuell ausgewählte Stadt hat einen blauen Hintergrund (accentColor, 30% Opacity)
- Tap auf einen Button wechselt die Stadt mit einer 0.3s ease-in-out Animation

**Wetter-Info-Panel (WeatherInfoPanel)**:
- Zeigt die 4 wichtigsten Wetterdaten in einer HStack:
  - Temperatur (°C, fett, mit Thermometer-Icon in Rot)
  - Wetterzustand (deutscher Text + SF-Symbol, Multicolor)
  - Luftfeuchtigkeit (%, mit Tropfen-Icon in Cyan)
  - Windgeschwindigkeit (km/h, mit Wind-Icon in Teal)

### Temperatur-Gauge (als 3D-Attachment)

Direkt im 3D-Raum neben dem Thermometer schwebt ein kleines SwiftUI-Widget:

```
    ╭──────────╮
    │   24°    │  ← Temperatur in farbiger Schrift
    │  ████░░  │  ← Linearer Gauge (SwiftUI)
    ╰──────────╯
     Glass-Hintergrund (ultraThinMaterial)
```

Position im 3D-Raum: X=0.22, Y=0.12, Z=0 (rechts neben dem Thermometer)

---

## 5. Interaktionsmodell

### Gesten-Übersicht

```
    ┌─────────────────────────────────────────────────────────────┐
    │                    INTERAKTIONSMODELL                        │
    │                                                             │
    │  ┌──────────────────┐    ┌───────────────────────────────┐ │
    │  │  BLICK + TAP     │    │  ROTATION                     │ │
    │  │                  │    │                               │ │
    │  │  👁 → Stadt-Button│    │  🤏🤏 Zwei-Finger-Drehen     │ │
    │  │  👆 Tap/Pinch    │    │                               │ │
    │  │                  │    │  → Dreht das gesamte Diorama  │ │
    │  │  Wechselt die    │    │    um seine Achse             │ │
    │  │  angezeigte Stadt│    │  → RotateGesture3D            │ │
    │  │  und baut die    │    │  → Unbegrenzt drehbar         │ │
    │  │  Szene neu auf   │    │                               │ │
    │  └──────────────────┘    └───────────────────────────────┘ │
    │                                                             │
    │  ┌──────────────────┐    ┌───────────────────────────────┐ │
    │  │  SKALIERUNG      │    │  IM SIMULATOR (Mac)           │ │
    │  │                  │    │                               │ │
    │  │  🤏 Pinch-Zoom   │    │  Rotation:                   │ │
    │  │                  │    │    Option + Maus ziehen       │ │
    │  │  → Vergrößert/   │    │                               │ │
    │  │    verkleinert   │    │  Skalierung:                  │ │
    │  │    das Diorama   │    │    Option+Shift + Maus        │ │
    │  │  → MagnifyGesture│    │                               │ │
    │  │  → Begrenzt:     │    │  Tap:                         │ │
    │  │    0.5x bis 2.0x │    │    Mausklick                  │ │
    │  └──────────────────┘    └───────────────────────────────┘ │
    └─────────────────────────────────────────────────────────────┘
```

### Gesten-Datenfluss

```
    Nutzer-Geste
        │
        ├─ RotateGesture3D ──→ viewModel.updateRotation(by: delta)
        │     .onChanged        → dioramaRotation = baseRotation.rotated(by: delta)
        │     .onEnded    ──→ viewModel.commitRotation()
        │                       → baseRotation = dioramaRotation
        │
        ├─ MagnifyGesture ───→ viewModel.updateScale(by: magnification)
        │     .onChanged        → dioramaScale = clamp(baseScale * mag, 0.5, 2.0)
        │     .onEnded    ──→ viewModel.commitScale()
        │                       → baseScale = dioramaScale
        │
        └─ Tap auf Button ──→ viewModel.selectCity(at: index)
              CityPickerView    → selectedCityIndex = index
                                → DioramaRealityView.rebuildScene()
                                  → alte Entities entfernen
                                  → DioramaBuilder.build(for: neuStadt)
                                  → Fade-In Animation (0.4s)
```

---

## 6. Architektur & Datenfluss

### MVVM-Architektur

```
    ┌─────────────────────────────────────────────────────────────────┐
    │                        WetterVisionApp                          │
    │                    @StateObject viewModel                       │
    │                    .windowStyle(.volumetric)                     │
    │                    .defaultSize(0.8, 0.6, 0.8m)                 │
    └──────────────────────────┬──────────────────────────────────────┘
                               │ .environmentObject(viewModel)
                               ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                        ContentView                              │
    │                                                                 │
    │  ┌──────────────────────────────────────────────────────┐      │
    │  │  DioramaRealityView                                   │      │
    │  │  ┌──────────────────┐  ┌──────────────────────────┐  │      │
    │  │  │  RealityView     │  │  TemperatureGaugeView    │  │      │
    │  │  │  (3D Scene)      │  │  (SwiftUI Attachment)    │  │      │
    │  │  └──────────────────┘  └──────────────────────────┘  │      │
    │  │  + DioramaGestures (ViewModifier)                     │      │
    │  └──────────────────────────────────────────────────────┘      │
    │                                                                 │
    │  .ornament(bottom) ─────────────────────────────────────┐      │
    │  │  ┌────────────────────┐  ┌─────────────────────┐    │      │
    │  │  │  CityPickerView    │  │  WeatherInfoPanel   │    │      │
    │  │  │  (Stadt-Buttons)   │  │  (Wetterdaten)      │    │      │
    │  │  └────────────────────┘  └─────────────────────┘    │      │
    │  └──────────────────────────────────────────────────────┘      │
    └─────────────────────────────────────────────────────────────────┘
                               │
                    Alle Views beobachten:
                               ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                   WeatherViewModel                              │
    │                   (ObservableObject)                             │
    │                                                                 │
    │   @Published selectedCityIndex: Int = 0                         │
    │   @Published dioramaRotation: Rotation3D = .identity            │
    │   @Published dioramaScale: Double = 1.0                         │
    │                                                                 │
    │   var currentWeather: WeatherData  ← (computed aus Index)       │
    │   let cities: [WeatherData]        ← DummyWeatherProvider       │
    │                                                                 │
    │   func selectCity(at:)             → ändert Index               │
    │   func updateRotation(by:)         → Rotation während Geste     │
    │   func commitRotation()            → Speichert Endwert          │
    │   func updateScale(by:)            → Scale mit Clamp 0.5-2.0   │
    │   func commitScale()               → Speichert Endwert          │
    └─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                  DummyWeatherProvider                            │
    │                                                                 │
    │   Berlin    │ 24°C │ Sonnig   │ 40% │ 12 km/h                  │
    │   Hamburg   │ 14°C │ Regen    │ 85% │ 25 km/h                  │
    │   München   │ -2°C │ Schnee   │ 70% │  8 km/h                  │
    │   Köln      │ 18°C │ Bewölkt  │ 60% │ 15 km/h                  │
    │   Frankfurt │ 20°C │ Gewitter │ 75% │ 45 km/h                  │
    └─────────────────────────────────────────────────────────────────┘
```

### Szenen-Rebuild-Zyklus

```
    Stadt-Wechsel
         │
         ▼
    ┌─────────────────┐
    │ selectCity(at:)  │
    │ → Index ändert   │
    └────────┬────────┘
             │ @Published → .onChange(of:)
             ▼
    ┌─────────────────┐
    │ rebuildScene()   │
    │ 1. Alte Entity   │
    │    entfernen     │
    │ 2. Neue Entity   │
    │    bauen         │
    │ 3. Fade-In       │
    │    (0.4s Scale)  │
    └────────┬────────┘
             │
             ▼
    ┌──────────────────────────────────────────────────────────┐
    │ DioramaBuilder.build(for: weather)                       │
    │                                                          │
    │  IMMER:                     JE NACH WETTER:              │
    │  ├─ IslandEntity.create()   ├─ sunny:  Sun + 1 Wolke    │
    │  ├─ ThermometerEntity       ├─ cloudy: 4 Wolken          │
    │  │   .create(temp)          ├─ rainy:  3 Wolken + Regen  │
    │  └─ WindStreamerEntity      ├─ snowy:  2 Wolken + Schnee │
    │      .create(windSpeed)     └─ stormy: 5 Wolken + Regen  │
    │                                        + Blitz           │
    └──────────────────────────────────────────────────────────┘
```

---

## 7. 3D-Szenenaufbau (technisch)

### Entity-Hierarchie

```
    rootEntity ("DioramaRoot")
    │   InputTargetComponent ← Ermöglicht Gesten-Erkennung
    │   CollisionComponent   ← Bounding Box 0.6 x 0.5 x 0.6m
    │
    ├── contentEntity ("DioramaContent")
    │   │
    │   ├── Island ("Island")
    │   │   ├── Base (abgeflachte Kugel, r=0.15, Y-Scale 0.3)
    │   │   │     Farbe: grassGreen (#59A640)
    │   │   ├── Rock (abgeflachte Kugel, r=0.12, Y-Scale 0.5)
    │   │   │     Farbe: rockBrown (#735940)
    │   │   ├── Building 1 (Box 0.03x0.06x0.03, Position: 0.05, 0, 0.02)
    │   │   │     Farbe: buildingGray (#A6A6B3)
    │   │   ├── Building 2 (Box 0.025x0.045x0.025, Position: -0.04, 0, -0.03)
    │   │   │     Farbe: buildingLight (#CCC7BF)
    │   │   ├── Building 3 (Box 0.02x0.035x0.02, Position: 0, 0, 0.06)
    │   │   │     Farbe: buildingDark (#80808C)
    │   │   ├── Tree 1 (Position: -0.08, 0, 0.04)
    │   │   │   ├── Trunk (Zylinder h=0.025, r=0.003, braun)
    │   │   │   └── Canopy (Kugel r=0.015, dunkelgrün)
    │   │   └── Tree 2 (Position: 0.07, 0, -0.05)
    │   │       ├── Trunk
    │   │       └── Canopy
    │   │
    │   ├── Thermometer ("Thermometer", Position: 0.18, 0, 0)
    │   │   ├── Tube (Zylinder h=0.1, r=0.008, weiß 30% Alpha)
    │   │   ├── Bulb (Kugel r=0.012, temperaturfarben)
    │   │   └── Fill (Zylinder, Höhe temperaturabhängig, temperaturfarben)
    │   │
    │   ├── WindStreamers ("WindStreamers", Position: -0.15, 0.08, variabel)
    │   │   └── N Bänder (Boxen, Länge & Anzahl windabhängig)
    │   │       Farbe: windTeal 60% Alpha (#4DBFBF99)
    │   │
    │   └── [Wetterbedingte Entities]
    │       ├── Sun / Wolken / Regen / Schnee / Blitz
    │       └── (siehe Diorama-Details oben)
    │
    └── temperatureGauge (SwiftUI Attachment, Position: 0.22, 0.12, 0)
```

### 3D-Primitiven und Materialien

| Objekt | Geometrie | Material | Besonderheiten |
|--------|-----------|----------|----------------|
| Insel-Basis | `generateSphere(r=0.15)` | `SimpleMaterial`, grassGreen | Y-Scale 0.3 (abgeflacht) |
| Felsen | `generateSphere(r=0.12)` | `SimpleMaterial`, rockBrown | Y-Scale 0.5 |
| Gebäude | `generateBox(size)` | `SimpleMaterial`, Grautöne | 3 verschiedene Größen |
| Baumstamm | `generateCylinder(h=0.025, r=0.003)` | `SimpleMaterial`, trunkBrown | - |
| Baumkrone | `generateSphere(r=0.015)` | `SimpleMaterial`, treeGreen | - |
| Sonne | `generateSphere(r=0.035)` | `UnlitMaterial`, sunYellow | Selbstleuchtend |
| Sonnenstrahlen | `generateBox(0.005x0.025x0.005)` | `UnlitMaterial`, sunRayOrange | 8 Stück, kreisförmig |
| Wolke | 5x `generateSphere(r=0.012-0.018)` | `SimpleMaterial`, weiß/grau | Roughness 1.0 |
| Thermometer-Rohr | `generateCylinder(h=0.1, r=0.008)` | `SimpleMaterial`, weiß 30% | Halbtransparent |
| Thermometer-Kugel | `generateSphere(r=0.012)` | `SimpleMaterial`, temp-farben | Bodenkugel |
| Regen | `ParticleEmitterComponent` | Blau (#4D80E6CC) | 300/s, Größe 0.002 |
| Schnee | `ParticleEmitterComponent` | Weiß | 100/s, Größe 0.004 |
| Blitz | `generateBox(0.005x0.08x0.005)` | `UnlitMaterial`, lightningYellow | Leicht schräg |
| Wind-Band | `generateBox(length x 0.002 x 0.002)` | `SimpleMaterial`, windTeal 60% | Länge variabel |

---

## 8. Farbpalette

### Übersicht aller verwendeten Farben

```
    INSEL & VEGETATION                    GEBÄUDE
    ┌──────────────────────┐              ┌──────────────────────┐
    │ ████ grassGreen      │              │ ████ buildingGray    │
    │ RGB(89, 166, 64)     │              │ RGB(166, 166, 179)   │
    │ Gras-Oberfläche      │              │ Großes Gebäude       │
    │                      │              │                      │
    │ ████ rockBrown       │              │ ████ buildingLight   │
    │ RGB(115, 89, 64)     │              │ RGB(204, 199, 191)   │
    │ Felsschicht          │              │ Mittleres Gebäude    │
    │                      │              │                      │
    │ ████ trunkBrown      │              │ ████ buildingDark    │
    │ RGB(140, 89, 51)     │              │ RGB(128, 128, 140)   │
    │ Baumstämme           │              │ Kleines Gebäude      │
    │                      │              │                      │
    │ ████ treeGreen       │              └──────────────────────┘
    │ RGB(51, 140, 51)     │
    │ Baumkronen           │
    └──────────────────────┘

    HIMMEL & WETTER                       TEMPERATUR-SKALA
    ┌──────────────────────┐              ┌──────────────────────┐
    │ ████ sunYellow       │              │ ████ coldBlue        │
    │ RGB(255, 230, 77)    │              │ RGB(51, 102, 230)    │
    │ Sonnenkörper         │              │ unter 0°C            │
    │                      │              │                      │
    │ ████ sunRayOrange    │              │ ████ coolCyan        │
    │ RGB(255, 191, 51)    │              │ RGB(51, 179, 204)    │
    │ Sonnenstrahlen       │              │ 0-14°C               │
    │                      │              │                      │
    │ ████ cloudWhite      │              │ ████ warmOrange      │
    │ RGB(242, 242, 247)   │              │ RGB(242, 153, 51)    │
    │ Helle Wolken         │              │ 15-24°C              │
    │                      │              │                      │
    │ ████ darkCloudGray   │              │ ████ hotRed          │
    │ RGB(115, 115, 128)   │              │ RGB(230, 51, 51)     │
    │ Dunkle Wolken        │              │ 25°C+                │
    │                      │              │                      │
    │ ████ rainBlue        │              └──────────────────────┘
    │ RGB(77, 128, 230)    │
    │ 80% Alpha, Regen     │              SONSTIGES
    │                      │              ┌──────────────────────┐
    │ ████ lightningYellow │              │ ████ windTeal        │
    │ RGB(255, 255, 153)   │              │ RGB(77, 191, 191)    │
    │ Blitz (selbstleucht.)│              │ 60% Alpha            │
    └──────────────────────┘              │ Wind-Bänder          │
                                          └──────────────────────┘
```

### Temperatur-Farbzuordnung im Thermometer

```
    -10°C ─────────── 0°C ─────────── 15°C ─────────── 25°C ─────── 40°C
     ████ coldBlue    │  ████ coolCyan  │  ████ warmOrange │ ████ hotRed
     (Dunkelblau)     │  (Türkis)       │  (Orange)        │ (Rot)
                      │                 │                  │
     München (-2°C) ──┘                 │                  │
                   Hamburg (14°C) ──────┘                  │
                              Köln (18°C) ────────────────┘│
                           Frankfurt (20°C) ───────────────┘
                              Berlin (24°C) ───────────────┘
```

---

## 9. Dateistruktur & Code-Übersicht

### Projektstruktur

```
WetterVision/
├── project.yml                          ← XcodeGen-Konfiguration
├── CLAUDE.md                            ← Entwickler-Referenz
├── TUTORIAL.md                          ← Setup-Anleitung (deutsch)
├── DOKUMENTATION.md                     ← Diese Datei
└── WetterVision/
    ├── WetterVisionApp.swift            ← App-Einstiegspunkt
    │                                       Erstellt Volumetric Window
    │                                       Injiziert ViewModel
    │
    ├── Info.plist                        ← visionOS App-Konfiguration
    │                                       UIApplicationPreferredDefaultSceneSessionRole:
    │                                       UIWindowSceneSessionRoleVolumetricApplication
    │
    ├── Models/
    │   ├── WeatherCondition.swift        ← Enum: sunny, cloudy, rainy, snowy, stormy
    │   │                                    rawValue = deutscher Text
    │   │                                    sfSymbol für UI-Icons
    │   ├── WeatherData.swift             ← Struct: cityName, temperature,
    │   │                                    condition, humidity, windSpeed
    │   └── DummyWeatherProvider.swift    ← 5 statische Städte-Datensätze
    │
    ├── ViewModels/
    │   └── WeatherViewModel.swift        ← Zentraler State (ObservableObject)
    │                                       selectedCityIndex, Rotation, Scale
    │                                       Methoden für Gesten + Stadtwechsel
    │
    ├── Views/
    │   ├── DioramaRealityView.swift      ← RealityView mit 3D-Szene
    │   │                                    make/update/attachments Closures
    │   │                                    rebuildScene() bei Stadtwechsel
    │   ├── CityPickerView.swift          ← HStack mit 5 Stadt-Buttons
    │   │                                    SF-Symbole + Stadtnamen
    │   ├── WeatherInfoPanel.swift        ← Zeigt Temp, Zustand, Feuchte, Wind
    │   └── TemperatureGaugeView.swift    ← SwiftUI Gauge als 3D-Attachment
    │                                       Farbe passt sich Temperatur an
    │
    ├── Entities/
    │   ├── DioramaBuilder.swift          ← Orchestriert Szene pro Wetterlage
    │   │                                    switch auf WeatherCondition
    │   ├── IslandEntity.swift            ← Schwebende Insel (Basis + Felsen
    │   │                                    + 3 Gebäude + 2 Bäume)
    │   ├── CloudEntity.swift             ← Wolke aus 5 Kugeln (hell/dunkel)
    │   ├── SunEntity.swift               ← Sonne + 8 Strahlen (UnlitMaterial)
    │   ├── RainSystem.swift              ← Regen-ParticleEmitter (300/s)
    │   ├── SnowSystem.swift              ← Schnee-ParticleEmitter (100/s)
    │   ├── ThermometerEntity.swift       ← Glasrohr + Kugel + Füllstand
    │   └── WindStreamerEntity.swift       ← 2-6 Bänder je nach Windstärke
    │
    ├── Gestures/
    │   └── DioramaGestures.swift         ← ViewModifier für RotateGesture3D
    │                                       und MagnifyGesture
    │
    └── Utilities/
        ├── ColorPalette.swift            ← Zentrale Farbdefinitionen (UIColor)
        └── AnimationUtilities.swift      ← fadeIn() und hover() Animationen
```

### Code-Statistik

| Bereich | Dateien | Beschreibung |
|---------|---------|--------------|
| App-Entry | 1 | App-Start, Window-Konfiguration |
| Models | 3 | Datenstrukturen, Dummy-Daten |
| ViewModels | 1 | Zentraler State |
| Views | 4 | UI-Komponenten (SwiftUI + RealityKit) |
| Entities | 8 | 3D-Objekte und Szenen-Builder |
| Gestures | 1 | Gesten-Handling |
| Utilities | 2 | Farben, Animationen |
| **Gesamt** | **20 Swift-Dateien** | **~830 Zeilen Code** |

### Technologie-Stack

| Komponente | Technologie |
|-----------|-------------|
| Plattform | visionOS 2.0+ (Apple Vision Pro) |
| Sprache | Swift 6.0 (kompatibel mit 5.9) |
| UI-Framework | SwiftUI |
| 3D-Engine | RealityKit |
| Räumliche Typen | Spatial Framework (Rotation3D) |
| Build-System | XcodeGen (project.yml → .xcodeproj) |
| IDE | Xcode 16+ |
| Abhängigkeiten | Keine (nur Apple-Frameworks) |
| Architektur | MVVM mit @EnvironmentObject |
| Tests | Manuell im visionOS Simulator |

---

*Dokumentation erstellt am 17.02.2026*
