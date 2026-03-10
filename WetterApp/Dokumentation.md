# WetterApp — Praktikumsdokumentation

**Kurs:** Design für 3D User Interfaces (D3D), WS 25/26
**Dozent:** Prof. Dr.-Ing. Sebastian Büttner
**Hochschule:** Westfälische Hochschule, FB Informatik und Kommunikation
**Bearbeitung:** Einzelarbeit
**Datum:** WS 2025/26

---

## 1. Konzept

### Idee
Eine 3D-Wetter-App für Apple Vision Pro, die Wetterdaten als interaktive Voxel-Schneekugeln visualisiert. Die App kombiniert zwei zentrale 3D-Elemente:

- **Erdglobus** — Ein realistisches Earth-USDZ-Modell (Apple) mit Stecknadel-Pins als Stadtmarker und schwebenden Labels
- **Schneekugeln** — Pro Stadt eine eigene Voxel-Miniaturwelt mit stadtspezifischer Szenerie und Wettereffekten

### Designentscheidungen
- **Voxel-Art-Stil:** Alle Schneekugel-Inhalte werden prozedural aus kleinen Würfeln (Voxeln) aufgebaut. Dieser Stil wurde bewusst gewählt, da er ohne externe 3D-Assets auskommt und gleichzeitig einen wiedererkennbaren, ästhetisch ansprechenden Look erzeugt.
- **Schneekugel-Metapher:** Die Schneekugel dient als natürlicher Rahmen für die Wettervisualisierung — Partikeleffekte wie Regen und Schnee wirken innerhalb einer Glaskugel besonders stimmig.
- **Zwei-Objekt-Layout:** Globus und Schneekugel werden nebeneinander im Volume angezeigt. So behält der User den Überblick und kann schnell zwischen Städten wechseln.
- **Earth.usdz:** Statt einer einfarbigen Placeholder-Kugel wird Apples Earth-Modell über Reality Composer Pro eingebunden — realistischer Look bei minimalem Aufwand.

---

## 2. Erfüllung der Anforderungen

### Anforderung 1: Volumetrische App
- Die App wird als `WindowGroup` mit `.windowStyle(.volumetric)` realisiert
- Volume-Größe: 90 × 60 × 60 cm
- Alle 3D-Inhalte befinden sich innerhalb dieses definierten Bereichs

### Anforderung 2: Kanonische Manipulationen (3 von 4 umgesetzt)

| Manipulation | Umsetzung | Geste |
|---|---|---|
| **Selektieren** | Tap auf Stadt-Label oder Pin-Marker am Globus wählt eine Stadt aus und öffnet die zugehörige Schneekugel | `SpatialTapGesture().targetedToAnyEntity()` |
| **Rotieren** | Drag auf dem Globus dreht die Erdkugel; Drag auf der Schneekugel dreht diese unabhängig davon | `DragGesture().targetedToAnyEntity()` |
| **Skalieren** | Pinch-Geste vergrößert/verkleinert Globus (0.5×–2.0×) oder Schneekugel (0.4×–1.5×) | `MagnifyGesture().targetedToAnyEntity()` |

Die Erkennung, welches Objekt manipuliert wird, erfolgt durch Traversierung der Entity-Hierarchie (Name-basiert: `snowglobe-*` vs. `globe-*`). Alle Gesten werden als `.simultaneousGesture()` registriert.

### Anforderung 3: Native visionOS-Interaktionen
- **Gesten:** SpatialTapGesture, DragGesture, MagnifyGesture — alle nativ über SwiftUI/RealityKit
- **SwiftUI-Elemente:**
  - Stadt-Labels als `Attachment` mit `BillboardComponent` (drehen sich automatisch zum User)
  - Wetter-Info-Panel als glassmorphes SwiftUI-Overlay (`.ultraThinMaterial`)
  - SF Symbols für Wetter-Icons (Thermometer, Wind, Luftfeuchtigkeit)
- **Interaction Feedback:** `HoverEffectComponent` auf interaktiven Entities (Globus, Labels, Schneekugel)
- **Collision:** Explizite `CollisionComponent` auf allen interaktiven Entities; separater `globeCollisionRadius` für den Globus, der zur visuellen Größe passt

### Anforderung 4: Informative und ästhetische 3D-Darstellung

**Stadtspezifische Szenen:**

| Stadt | Wahrzeichen | Besonderheiten |
|---|---|---|
| Berlin | Fernsehturm (mit Kugel + Antenne) | Plattenbauten, grüne Landschaft |
| New York | Wolkenkratzer-Skyline | Betonboden, gelbes Taxi-Detail, Antenne |
| Tokio | Dreistöckige Pagode | Kirschblütenbäume (rosa), Teich, Steinlaterne |
| Paris | Eiffelturm (4 Beine, 2 Plattformen) | Pariser Häuser mit Mansarddächern |

**Wettervisualisierung:**

| Wetterzustand | Visuelle Effekte |
|---|---|
| Sonnig | Voxel-Sonne mit Strahlen (Billboard, dreht sich zum User) |
| Bewölkt | 3 Wolken-Cluster aus weißen/grauen Voxeln |
| Regnerisch | Dunkle Wolken + Regen-Partikelsystem (blaue Tropfen) |
| Schnee | Wolken + Schnee-Partikelsystem (weiße Flocken, langsam) |
| Gewitter | Dunkle Wolken + Regen + Voxel-Blitz |

**Farbpalette:** Konsistente, warme Farben mit Schattenvarianten für visuelle Tiefe. Alle Farben zentral in `VoxelBuilder.Palette` definiert.

### Anforderung 5: Dummy-Daten
- 4 Städte mit fest definierten Wetterdaten (Temperatur, Luftfeuchtigkeit, Windgeschwindigkeit, Wetterzustand, Beschreibung)
- Daten zentral in `CityData.swift` verwaltet

---

## 3. Technische Architektur

### Technologien
- **Plattform:** visionOS 2.0+, Apple Vision Pro
- **IDE:** Xcode 16+ (Xcode 26.1)
- **Sprache:** Swift
- **Frameworks:** SwiftUI, RealityKit, RealityKitContent (keine externen Abhängigkeiten)
- **3D-Assets:** Earth.usdz (Apple, via Reality Composer Pro eingebunden)

### Dateistruktur

| Datei | Verantwortung |
|---|---|
| `WetterAppApp.swift` | App-Einstiegspunkt, Volume-Konfiguration |
| `ContentView.swift` | Hauptview: Layout, Gesten, Szenen-Management, WeatherPanelView |
| `GlobeBuilder.swift` | Baut den Erdglobus (Earth.usdz) mit Stecknadel-Pins |
| `VoxelBuilder.swift` | Baut stadtspezifische Voxel-Szenen in Schneekugeln |
| `WeatherEffects.swift` | Wettervisualisierungen (Sonne, Wolken, Partikel, Blitz) |
| `CityData.swift` | Datenmodell: Städte, Koordinaten, Dummy-Wetterdaten |
| `AppModel.swift` | App-weiter State (von Xcode-Template) |

### Prozedurale 3D-Generierung
Alle Schneekugel-Inhalte werden **vollständig aus Code** generiert. Jedes sichtbare Element besteht aus `MeshResource.generateBox()` (Voxel), `generateSphere()` (Glaskugel, Pins) oder `generateCylinder()` (Pin-Sticks, Sockel). Der Erdglobus nutzt ein USDZ-Modell von Apple.

**Voxel-System:**
- Rastergröße (Grid): 1.0 cm — Abstand zwischen Voxel-Mittelpunkten
- Blockgröße: 0.9 cm — tatsächliche Würfelgröße
- Die Differenz (0.1 cm) erzeugt sichtbare Lücken zwischen den Blöcken — der Schlüssel zum Voxel-Look
- Ein gemeinsames `MeshResource` wird für alle Voxel wiederverwendet (Performance)
- Materialien (`SimpleMaterial`) werden pro Farbe einmal erstellt und geteilt

**Globus-Pins:**
- Stecknadel-Stil: dünner weißer Cylinder (1.5cm Höhe, 1mm Radius) + farbige Kugel (3mm Radius)
- Positionierung über sphärische Koordinatenumrechnung (Lat/Lon → 3D-Position)
- `lonOffset` korrigiert den Versatz zur Earth-Textur
- Separater `globeCollisionRadius` (0.155) für Interaktion vs. `globeRadius` (0.108) für Pin-Platzierung

**Partikelsysteme:**
- Regen: `ParticleEmitterComponent`, 200 Partikel/s, blaue Tropfen, Beschleunigung nach unten
- Schnee: `ParticleEmitterComponent`, 80 Partikel/s, weiße Flocken, langsame Drift

### Interaktionsarchitektur
- Gesten werden auf der `RealityView` als `.simultaneousGesture()` registriert und nutzen `.targetedToAnyEntity()`
- Zur Unterscheidung zwischen Globus und Schneekugel wird die Entity-Hierarchie per Name-Matching traversiert (`isDragOnSnowGlobe()`)
- Rotation und Skalierung werden als SwiftUI `@State` gespeichert, getrennt für Globus und Schneekugel
- Die `update`-Closure der `RealityView` synchronisiert State → Entity-Transforms
- Stadt-Labels als SwiftUI Attachments mit explizitem `attachment.name` für Tap-Erkennung

---

## 4. Interaktionsfluss

```
App-Start
    │
    ▼
┌─────────────────────────┐
│  Erdglobus (zentriert)  │
│  mit 4 Stadt-Pins       │
│  + schwebenden Labels   │
└─────────┬───────────────┘
          │ Drag → Globus rotieren
          │ Pinch → Globus skalieren
          │ Tap auf Label/Pin ↓
          ▼
┌────────────┐  ┌──────────────────┐
│  Globus    │  │  Schneekugel     │
│  (links)   │  │  (rechts)        │
│            │  │  + Wettereffekte  │
│            │  │  + Info-Panel     │
└────────────┘  └──────────────────┘
                    │ Drag → Kugel rotieren
                    │ Pinch → Kugel skalieren
                    │
  Tap auf anderen Pin → Schneekugel wechselt
  Tap auf Globus → Schneekugel schließt
```

---

## 5. Herausforderungen und Lösungen

### Asset-Problem
- **Problem:** Keine 3D-Modelle oder Texturen vorhanden
- **Lösung:** Voxel-Art-Ansatz für Schneekugel-Inhalte; Earth.usdz von Apple für den Globus

### Gesten-Disambiguierung
- **Problem:** Drag- und Pinch-Gesten müssen zwischen zwei interaktiven 3D-Objekten unterscheiden
- **Lösung:** Entity-Hierarchie-Traversierung beim Gesture-Event (`isDragOnSnowGlobe()`)

### Pin-Positionierung auf Kugeloberfläche
- **Problem:** Stadt-Pins müssen an echten Geo-Koordinaten auf der Kugeloberfläche platziert und korrekt nach außen orientiert werden
- **Lösung:** Sphärische Koordinatenumrechnung (Lat/Lon → 3D-Position) + `look(at: center)` mit 90°-Flip-Rotation

### Collision vs. Pin-Radius
- **Problem:** Der Globus braucht eine große Collision-Sphere für einfache Interaktion, aber Pins müssen näher an der visuellen Oberfläche platziert werden
- **Lösung:** Zwei separate Radien — `globeCollisionRadius` (0.155) für die Interaktion, `globeRadius` (0.108) für die Pin-Positionierung

### Entwicklungsworkflow
- **Besonderheit:** Code wurde auf Windows (ohne Xcode/Simulator) geschrieben und per Git synchronisiert; Testen nur am Mac möglich
- **Lösung:** Sorgfältige Code-Architektur und modularer Aufbau, um blinde Fehler zu minimieren

---

## 6. Mögliche Erweiterungen

- Anbindung an echte Wetter-API (Open-Meteo oder DWD Open Data)
- Mehr Städte hinzufügen (z.B. Sydney, Kairo, Rio)
- Schneekugeln als platzierbare Widgets im Raum
- Animierte Übergänge beim Szenen-Wechsel
- Verfeinerung der Voxel-Auflösung für mehr Detail

---

## 7. Verwendete Quellen und Referenzen

- LaViola, J. J., Kruijff, E., McMahan, R. P., Bowman, D. A., & Poupyrev, I. (2017). *3D User Interfaces: Theory and Practice* (2. Auflage). Addison-Wesley. — Insbesondere S. 259 ff. zu kanonischen Manipulationen.
- Apple Developer Documentation: [RealityKit](https://developer.apple.com/documentation/realitykit), [SwiftUI](https://developer.apple.com/documentation/swiftui), [visionOS](https://developer.apple.com/documentation/visionos)
- Apple Human Interface Guidelines: [Spatial Design](https://developer.apple.com/design/human-interface-guidelines/spatial-layout)
