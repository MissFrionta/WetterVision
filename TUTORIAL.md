# WetterVision – Setup & Test Tutorial (MacBook Pro M4 Max)

## Voraussetzungen

- **MacBook Pro M4 Max** (Apple Silicon)
- **macOS 15 Sequoia** (oder neuer)
- **Xcode 16** (oder neuer) – aus dem Mac App Store installieren
- **visionOS SDK** – wird über Xcode installiert (siehe unten)

---

## 1. Xcode vorbereiten

### visionOS Simulator installieren

1. Xcode öffnen
2. **Xcode → Settings → Platforms** (⌘ + ,)
3. Auf das **+** unten links klicken
4. **visionOS 2.x** auswählen und installieren (~5 GB Download)
5. Warten bis die Installation abgeschlossen ist

### XcodeGen installieren (optional, aber empfohlen)

XcodeGen erzeugt das `.xcodeproj` automatisch aus der `project.yml`.

```bash
brew install xcodegen
```

Falls Homebrew nicht installiert ist:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## 2. Projekt auf dem Mac einrichten

### Option A: Mit XcodeGen (empfohlen)

1. Den Ordner `WetterVision/` auf den Mac kopieren (z.B. via OneDrive, AirDrop, USB-Stick)

2. Terminal öffnen und zum Projektordner navigieren:
   ```bash
   cd /pfad/zu/WetterVision
   ```

3. Xcode-Projekt generieren:
   ```bash
   xcodegen generate
   ```

4. Projekt öffnen:
   ```bash
   open WetterVision.xcodeproj
   ```

### Option B: Manuell in Xcode (ohne XcodeGen)

1. Xcode öffnen → **File → New → Project**
2. Tab **visionOS** wählen → **App** auswählen → **Next**
3. Einstellungen:
   - **Product Name:** `WetterVision`
   - **Organization Identifier:** `de.wh.d3d`
   - **Interface:** SwiftUI
   - **Immersive Space Renderer:** RealityKit
   - **Immersive Space:** None (wir nutzen ein Volumetric Window, keinen Immersive Space)
4. Projekt erstellen und speichern
5. Die automatisch erzeugten Swift-Dateien **löschen** (ContentView.swift, App-Datei etc.)
6. Im Finder: Alle Swift-Dateien aus dem `WetterVision/WetterVision/`-Ordner markieren
7. In Xcode: Rechtsklick auf die gelbe Projektgruppe → **Add Files to "WetterVision"...**
   - Alle `.swift`-Dateien und `Info.plist` auswählen
   - **"Copy items if needed"** aktivieren
   - **"Create groups"** auswählen
   - **Add** klicken
8. Die `Info.plist` zuweisen:
   - Projekt in der Seitenleiste anklicken → Target **WetterVision** → Tab **General**
   - Unter **Identity** sicherstellen, dass die Info.plist korrekt verknüpft ist
   - Alternativ: Target → **Build Settings** → Suche nach "Info.plist" → Pfad auf `WetterVision/Info.plist` setzen

---

## 3. Build Settings überprüfen

Im Xcode-Projekt → Target **WetterVision** → **Build Settings**:

| Setting | Wert |
|---|---|
| Supported Platforms | `xros` (visionOS) |
| Targeted Device Family | `7` (Apple Vision Pro) |
| Swift Language Version | `6.0` (oder `5.9`) |
| Deployment Target | `visionOS 2.0` |

> Falls Compilerfehler bei Swift 6.0 auftreten (Concurrency-Warnungen), einfach auf **Swift 5.9** umstellen unter Build Settings → Swift Compiler → Swift Language Version.

---

## 4. Bauen und im Simulator testen

### Simulator starten

1. In Xcode oben in der **Toolbar** das Zielgerät auswählen:
   - Klick auf das Device-Dropdown (neben dem Play-Button)
   - Unter **visionOS Simulators** → **Apple Vision Pro** auswählen
2. **⌘ + R** drücken (oder Play-Button klicken)
3. Der visionOS Simulator startet automatisch

### Erste Schritte im Simulator

Wenn die App gestartet ist, sollte das **volumetrische Fenster** mit dem 3D-Wetter-Diorama erscheinen:

- Schwebende Insel mit Gebäuden und Bäumen
- Wettereffekte (Sonne, Wolken, Regen, Schnee je nach Stadt)
- Thermometer rechts neben der Insel
- Ornament-Leiste unten mit Stadtauswahl und Wetterdaten

---

## 5. Interaktionen im Simulator testen

### Navigation im Simulator

| Aktion | Tastatur/Maus |
|---|---|
| Umschauen | **Maus bewegen** (Blickrichtung) |
| Tippen (Tap) | **Mausklick** |
| Im Raum bewegen | **WASD** Tasten |
| Höhe ändern | **Q** (hoch) / **E** (runter) |

### Gesten testen

#### Rotation testen
1. **Option (⌥)** gedrückt halten
2. **Maus ziehen** – simuliert eine Zwei-Finger-Rotation
3. Das Diorama sollte sich drehen

#### Skalierung (Pinch/Zoom) testen
1. **Option (⌥) + Shift (⇧)** gedrückt halten
2. **Maus nach oben/unten ziehen** – simuliert Pinch-Geste
3. Das Diorama sollte größer/kleiner werden (0.5x bis 2.0x)

#### Stadtauswahl testen
1. Mit der Maus auf einen **Stadt-Button** in der Ornament-Leiste zeigen
2. **Klicken** – die Stadt wird ausgewählt
3. Das Diorama wechselt die Wetterdarstellung:
   - **Berlin** → Sonne + leichte Wolke
   - **Hamburg** → Dunkle Wolken + Regen
   - **München** → Wolken + Schnee
   - **Köln** → Mehrere Wolken
   - **Frankfurt** → Gewitter + Blitz + Regen

---

## 6. Häufige Probleme & Lösungen

### "No such module 'RealityKit'"
→ Sicherstellen, dass das Target auf **visionOS** steht (nicht iOS/macOS).

### "UIWindowSceneSessionRoleVolumetricApplication is unavailable"
→ Deployment Target muss **visionOS 2.0** oder höher sein.

### Simulator zeigt nur schwarzen Bildschirm
→ Im Simulator-Menü: **Window → Apple Vision Pro** → Sicherstellen, dass Home Screen sichtbar ist. Die App im Home Screen suchen und öffnen.

### Swift 6 Concurrency-Fehler
→ Falls strenge Concurrency-Warnungen auftreten:
- **Build Settings** → **Strict Concurrency Checking** auf **Minimal** setzen
- Oder Swift Language Version auf **5.9** ändern

### ParticleEmitter kompiliert nicht
→ Die ParticleEmitterComponent API kann sich zwischen visionOS-Versionen ändern. Falls Fehler auftreten, die `.birthDirection`- und `.speed`-Properties prüfen – ggf. müssen sie über `mainEmitter` gesetzt werden.

### "Failed to build module 'Spatial'"
→ Xcode Command Line Tools aktualisieren:
```bash
xcode-select --install
```

---

## 7. Projektstruktur-Übersicht

```
WetterVision/
├── project.yml                          ← XcodeGen-Konfiguration
└── WetterVision/
    ├── WetterVisionApp.swift            ← App-Einstiegspunkt (Volumetric Window)
    ├── ContentView.swift                ← RealityView + Ornament
    ├── Info.plist                       ← Volumetric-App-Konfiguration
    ├── Models/                          ← Datenmodelle
    │   ├── WeatherCondition.swift       ← Enum: sunny, cloudy, rainy, snowy, stormy
    │   ├── WeatherData.swift            ← Struct mit Wetterdaten
    │   └── DummyWeatherProvider.swift   ← 5 Städte mit Dummy-Daten
    ├── ViewModels/
    │   └── WeatherViewModel.swift       ← State: Stadt, Rotation, Scale
    ├── Views/
    │   ├── DioramaRealityView.swift     ← RealityKit 3D-Szene
    │   ├── CityPickerView.swift         ← Stadtauswahl-Buttons
    │   ├── WeatherInfoPanel.swift       ← Temperatur/Wind/Feuchtigkeit
    │   └── TemperatureGaugeView.swift   ← SwiftUI-Attachment am Thermometer
    ├── Entities/                        ← 3D-Objekte (programmatisch)
    │   ├── IslandEntity.swift           ← Insel + Gebäude + Bäume
    │   ├── CloudEntity.swift            ← Wolken-Cluster
    │   ├── SunEntity.swift              ← Sonne + Strahlen
    │   ├── RainSystem.swift             ← Regen-Partikel
    │   ├── SnowSystem.swift             ← Schnee-Partikel
    │   ├── WindStreamerEntity.swift      ← Wind-Visualisierung
    │   ├── ThermometerEntity.swift      ← 3D-Thermometer
    │   └── DioramaBuilder.swift         ← Baut Szene pro Wetterlage
    ├── Gestures/
    │   └── DioramaGestures.swift        ← Rotate + Scale Gesten
    └── Utilities/
        ├── ColorPalette.swift           ← Farbdefinitionen
        └── AnimationUtilities.swift     ← Animationshelfer
```

---

## Kurzanleitung (TL;DR)

```bash
# 1. XcodeGen installieren
brew install xcodegen

# 2. Zum Projektordner navigieren
cd /pfad/zu/WetterVision

# 3. Xcode-Projekt erzeugen
xcodegen generate

# 4. Projekt öffnen
open WetterVision.xcodeproj

# 5. In Xcode: Apple Vision Pro Simulator auswählen → ⌘+R
```
