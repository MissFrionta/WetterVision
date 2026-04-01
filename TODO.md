# PixelWeather — TODO-Liste

Stand: 2026-03-18

---

## Anforderungen aus der Aufgabenstellung

### Anforderung 1: Volumetrische App (Volume)
- [x] `WindowGroup` mit `.windowStyle(.volumetric)`
- [x] Definierte Volume-Groesse (0.9 x 0.6 x 0.6 m)
- [x] Inhalte innerhalb des definierten 3D-Bereichs

### Anforderung 2: Kanonische Manipulationen (mind. 2 von 4)
- [x] **Selektieren** — SpatialTapGesture auf Stadt-Labels waehlt Stadt aus und oeffnet Schneekugel
- [x] **Rotieren** — DragGesture dreht Globus (Yaw+Pitch) und Schneekugel (nur Yaw, bleibt aufrecht)
- [x] **Skalieren** — MagnifyGesture vergroessert/verkleinert Globus (0.5x-2.0x) und Schneekugel (0.4x-1.5x)
- [ ] Positionieren — nicht implementiert (nicht erforderlich)

### Anforderung 3: Grundlegende visionOS-Interaktionsformen
- [x] Gesten: SpatialTapGesture, DragGesture, MagnifyGesture
- [x] SwiftUI-Elemente: Stadt-Labels als Attachment mit BillboardComponent
- [x] Wetter-Info-Panel als glassmorphes SwiftUI-Overlay (.ultraThinMaterial)
- [x] HoverEffect auf Stadt-Labels (HoverEffectComponent mit strength 1.0)
- [x] Labels mit farbigem Rand (Pin-Farbe), .thinMaterial, Schatten

### Anforderung 4: Informative und aesthetische 3D-Darstellung
- [x] 3 stadtspezifische Voxel-Szenen (Berlin, New York, Tokio)
- [x] Wettereffekte: Sonne, Wolken, Regen, Schnee, Gewitter
- [x] Voxel-Art-Stil (prozedural, keine externen Assets)
- [x] Farbpalette konsistent in VoxelBuilder.Palette
- [x] Performance-Optimierung: Mesh-Merging via VoxelCollector (~700 Entities → ~12 pro Schneekugel)
- [x] ~~Regenpartikel nicht sichtbar~~ — gefixt (Session 2026-03-18)
- [x] **Tokio verschoenert** — 2x Voxel-Aufloesung, Torii, Steg, Laternen, Steinpfad, Kirschblueten, 3D-Wolken
- [x] **Berlin verschoenert** — 2x Voxel-Aufloesung, Fernsehturm, Brandenburger Tor, Plattenbauten, Berliner Mauer, Spree, Linden-Baeume, Strassenlaternen
- [x] **New York verschoenert** — 2x Voxel-Aufloesung, Empire State, Freiheitsstatue, Skyscrapers, Water Towers, Central Park, Yellow Cabs

### Anforderung 5: Dummy-Daten
- [x] 3 Staedte mit Dummy-Wetterdaten in CityData.swift (Temperatur, Luftfeuchtigkeit, Wind, Zustand, Beschreibung)
- [ ] Optional: Anbindung an echte Wetter-API (Open-Meteo oder DWD Open Data) — nur in neuem Branch

---

## Bekannte Bugs / Offene Probleme

### HOCH (muss gefixt werden)
- [x] ~~**Schnee-Partikel flackern in Berlin**~~ — GEFIXT (2026-04-01, auf AVP bestaetigt). Ursache: riesiges weisses Mesh (Boden+Schneedecke ~24k Vertices) verursachte Rendering-Konflikte mit Partikel-System bei Skalierung. Fix: (1) Mesh-Splitting: Schneedecke nutzt eigene Farbe (snowCover), erzwingt separates Mesh. (2) Counter-Scale auf Partikel-Entities mit dynamischer Kompensation von emitterShapeSize, birthRate und acceleration. (3) Partikel optimiert: groesser, blauer Stich, sanfteres Driften.

### Mittel (sollte gefixt werden)
- [ ] **Farbwechsel-Bug beim Drehen** — Voxels mit Checkerboard-Farbmuster (z.B. Teich, Gras) aendern ihre sichtbare Farbe, wenn die Schneekugel gedreht wird. Ursache: benachbarte Voxels verschiedener Farben zeigen je nach Blickwinkel verschiedene Seiten. Workaround: einheitliche Farbe verwenden (wie beim Teichrand gemacht). Fuer Gras/Boden tolerierbar.

### Niedrig (nice to have)
- [x] ~~**Skalierungs-Begrenzung**~~ — GEFIXT (2026-04-01). Scale-Limits angepasst (Globus max 1.5x, Schneekugel max 1.2x). Weather-Panel positioniert sich dynamisch vor der Schneekugel (statt darunter), verschwindet nicht mehr im Boden.

---

## BUG-ANALYSE: Schnee-Partikel flackern in Berlin — GELOEST (2026-04-01)

### Symptom (war)
- Schneepartikel in Berlin erschienen und verschwanden periodisch ("Flickering")
- Wurde schlimmer bei groesserer Schneekugel-Skalierung
- Auf echter Apple Vision Pro reproduzierbar

### Ursache
Zwei Faktoren zusammen:
1. **Riesiges weisses Mesh**: Boden-Schnee + Dach-Schneedecke wurden zu EINEM ModelEntity gemerged (~24.000 Vertices). Dieses Mega-Mesh verursachte Rendering-Konflikte mit dem Partikel-System.
2. **Skalierungs-Problem**: Partikel-Entity skalierte mit der Schneekugel, was bei groesseren Scales zu Rendering-Artefakten fuehrte.

### Loesung (3 Teile)
1. **Mesh-Splitting** (VoxelBuilder.swift): Schneedecke auf Daechern/Baeumen nutzt jetzt `snowCover` (RGB 0.92/0.93/0.96) statt `snow` (white 0.95). VoxelCollector erzeugt dadurch zwei separate, kleinere Meshes. Visuell kaum sichtbar, realistischer Blau-Stich.
2. **Counter-Scale mit Kompensation** (ContentView.swift): Partikel-Entities bekommen inverse Skalierung (1/snowGlobeScale), aber emitterShapeSize (×s), birthRate (×s²) und acceleration (×s) werden dynamisch kompensiert. Partikel rendern stabil UND der Emitter-Bereich passt zur Kugelgroesse.
3. **Partikel-Optimierung** (WeatherEffects.swift): Groessere Flocken (0.005), dezenter Blau-Stich, sanftes Driften (accel -0.08, speed 0.003, lifeSpan 2.0). Regen: laengere lifeSpan (1.15) damit Tropfen den Boden erreichen.

---

## WICHTIG: Anleitung zum Verschoenern der Staedte (Berlin, New York)

Tokio wurde am 2026-03-18 als erste Stadt auf 2x-Aufloesung umgebaut. Berlin und New York muessen
auf die gleiche Weise umgebaut werden. Hier ist die vollstaendige Anleitung:

### Schritt 1: Feineren VoxelCollector in buildSnowGlobe erstellen

In `VoxelBuilder.buildSnowGlobe()` wird bereits fuer Tokio ein feinerer Collector erstellt:
```swift
if cityName == "Tokio" {
    collector = VoxelCollector(blockSize: 0.005, gridSize: 0.005)
} else {
    collector = VoxelCollector()
}
```
Fuer Berlin/New York die Bedingung erweitern: `if cityName == "Tokio" || cityName == "Berlin" ...`

### Schritt 2: Alle Koordinaten verdoppeln (2x)

- Grid aendert sich von 0.010 auf 0.005 → gleiche physische Groesse bei doppelten Koordinaten
- `buildGrassGround(radius: 8)` → `radius: 22` (groesser, damit alle Elemente draufpassen)
- `buildConcreteGround(radius: 8)` → `radius: 22` (fuer New York)
- Alle Gebaeude-Positionen (gx, gz) verdoppeln
- Alle Gebaeude-Masse (w, d, h) verdoppeln
- Tier-Definitionen in Pagoda-Stil verdoppeln: z.B. `(7, 4)` → `(14, 8)`

### Schritt 3: Elemente auf Boden setzen

- Gebaeude, Baeume etc. muessen bei y=1 beginnen (direkt ueber Gras bei y=0)
- NICHT bei y=2 — das laesst eine sichtbare Luecke zum Boden
- Teiche/Wasser bei y=0 (gleiche Ebene wie Boden)

### Schritt 4: Stockwerk-Luecken vermeiden

- Bei mehrstoeckigen Gebaeuden: `currentY = roofY + 2` (NICHT +4)
- roofY + 2 bei gridSize 0.005 = physisch 0.01m Abstand → sieht buen aus
- roofY + 4 wuerde 2 leere Voxelreihen lassen → sichtbare horizontale Schnitte

### Schritt 5: Kollisionen pruefen

- Baeume haben Kronen-Radius 4 bei 2x → pruefen, ob sie in Gebaeude ragen
- Dach-Ueberhang (roofExtend = halfW + 2) → keine Elemente unter dem Dach platzieren
- Teich-Radius pruefen: keine Baeume im Teich

### Schritt 6: Tueren und Fenster anpassen

- Tuer-Oeffnung: `abs(dx) <= 2` bei 2x (statt abs(dx) <= 1)
- Tuer-Hoehe: `y < currentY + 4` bei 2x
- Fenster-Muster anpassen: z.B. `relY % 3 == 0 && abs(dx) % 4 <= 1`
- Tuer auf die Seite platzieren, wo der Zugang/Weg ist

### Schritt 7: Zusaetzliche Details (optional aber empfohlen)

Tokio hat folgende Extras bekommen, die auch fuer andere Staedte sinnvoll waeren:
- Steinpfad zwischen Elementen
- Dekorative Elemente (Laternen, Blumen, Baenke etc.)
- Bewachsene Raender um Wasserflaechen
- Baum-Stubs (Aeste) am Stamm
- Kirschblueten/Blaetter auf dem Boden

### Schritt 8: WeatherEffects beachten

- WeatherEffects.apply() bekommt bereits `voxelSize` Parameter
- Wolken sind 3D-Blob-Kugeln bei y=0.10-0.12 → hoch genug fuer alle Gebaeude
- Regen startet bei y=0.10, faellt per Gravity (kein Emitter-Rotation!)
- Bei neuen hohen Gebaeuden pruefen, ob Wolken kollidieren

### Referenz-Werte Tokio (funktioniert, auf AVP getestet):

| Parameter | Wert |
|---|---|
| gridSize / blockSize | 0.005 |
| Ground radius | 22 |
| Gebaeude start Y | 1 |
| Teich Y | 0 |
| Weg Y | 0 |
| Dach-Extend | halfW + 2 |
| Tier-Gap | roofY + 2 |
| Baum-Stamm Y | 1...10 |
| Baum-Krone centerY | 13, radius 4 |
| Wolken Y | 0.10-0.12 |
| Regen emitter Y | 0.10, lifeSpan 0.95 |

---

## Naechste Features (geplant)

### Erledigt (Session 2026-04-01, in master gemerged)
- [x] ~~**Echte Wetter-API (Open-Meteo)**~~ — WeatherService.swift: REST-Call an Open-Meteo, WMO-Code-Mapping, 10-Min-Cache, Fallback auf Dummy-Daten. Auf AVP bestaetigt.
- [x] ~~**7-Tage-Vorhersage mit Swipe-Navigation**~~ — Swipe im Weather-Panel wechselt zwischen Heute/Morgen/Uebermorgen/Wochentage. Schneekugel zeigt Wetter des gewaehlten Tages. Punkt-Indikatoren + Pfeil-Hinweise.
- [x] ~~**Dynamisches Wetter fuer alle Staedte**~~ — Jede Stadt kann jedes Wetter haben. Boden wechselt (Schnee/Gras/Beton), Schneedecke nur bei .snowy. buildSnowGlobe() bekommt condition-Parameter.
- [x] ~~**Nieselregen (.drizzle)**~~ — Feiner, langsamer Regen mit hellen Wolken. Auf AVP bestaetigt.
- [x] ~~**Wolken-Animation**~~ — Langsame Y-Rotation (200ms Update-Intervall). Auf AVP bestaetigt.
- [x] ~~**Wind-Drift auf Regen**~~ — Leichte seitliche X/Z-Komponente in Regen-Acceleration.
- [x] ~~Verfeinerung der Voxel-Aufloesung fuer mehr Detail~~ — Tokio auf 2x umgebaut
- [x] ~~Apple-Globus-Modell aus Reality Composer Pro~~ — Earth.usdz eingebunden

### Nicht umgesetzt / Verschoben
- [ ] **Windig (.windy)** — Partikel-Effekt funktionierte nicht zufriedenstellend auf AVP, entfernt. Kann spaeter erneut versucht werden.
- [ ] **Erweitertes Weather-Panel** — Vorhersage, Windrichtung, Sonnenauf-/untergang
- [ ] **Tag/Nacht-Anpassung** — Beleuchtung basierend auf Uhrzeit
- [ ] **Wetter-Icons auf Globus** — Symbole neben Stadt-Labels
- [ ] **Mehr Staedte** — Brauchen neue Voxel-Szenen
- [ ] **2D-Begleitfenster** — Separates SwiftUI-Window
- [ ] **Schneekugel-Widgets** — Platzierbar im Raum
- [ ] **Schneekugel-Schuettel-Animation** — Physik-basiert

---

## KRITISCH: visionOS Gesten-Regeln (auf echter AVP bestaetigt)

Siehe CLAUDE.md fuer die vollstaendige Dokumentation. Kurzfassung:

**Diese Werte NICHT aendern ohne Test auf der echten Apple Vision Pro:**
- Globe Collision: 0.108 (= globeRadius). NICHT groesser machen!
- Label Collision: 0.025. NICHT groesser machen!
- Label Font: 11. Labels NICHT vergroessern!
- Label Background: .thinMaterial (nicht .regularMaterial!)
- KEIN .hoverEffect(.highlight) auf SwiftUI-Attachment-Views!
- KEINE SwiftUI Buttons in Attachments!

**@State in RealityView update closure ist UNZUVERLAESSIG!**
Entity-Referenzen immer per Scene-Graph-Suche (name prefix) statt @State.
Siehe CLAUDE.md fuer Details.

Referenz-Commit mit funktionierenden Gesten: **f4937e1**

---

## Dokumentation

- [x] Projektdokumentation vorhanden (WetterApp/Dokumentation.md)
- [x] CLAUDE.md (Entwicklungshinweise fuer Claude Code, inkl. Gesten-Regeln + @State-Pitfall)
- [x] TUTORIAL.md (Setup-Anleitung)
- [ ] **TUTORIAL.md aktualisieren** — Beschreibt noch die alte Diorama-Architektur (WetterVision v1), muss auf WetterApp-Projekt aktualisiert werden
- [ ] Kurze schriftliche Doku fuer Abgabe (gerne stichpunktartig laut Aufgabenstellung)
- [ ] **Projektverzeichnis aufraeumen** — Alte Prototyp-Projekte (WetterVision v1, Diorama etc.) aus dem Repository entfernen. Nur WetterApp soll im Repo bleiben. .gitignore fuer Xcode-Userdaten (.DS_Store, xcuserstate, xcbkptlist) hinzufuegen.

---

## Erledigte Aufgaben

### Session 2026-03-10
- [x] Build-Fehler GlobeBuilder: generateCollisionShapes -> CollisionComponent
- [x] Build-Fehler VoxelBuilder: generateCollisionShapes -> CollisionComponent
- [x] Build-Fehler WeatherEffects: birthRate/speed/birthDirection API-Fixes
- [x] Gesten funktionieren: HoverEffectComponent, SpatialTapGesture
- [x] Vertikale Rotation invertiert (Hand hoch = Globus hoch)
- [x] Pin-Collision vergroessert (2.5cm -> 4cm Radius)
- [x] Pin-Head visuell vergroessert (1.4x -> 2.5x)
- [x] Partikel-Emitter verkleinert (20x20cm -> 12x12cm)
- [x] Wetter-Panel nach vorne versetzt (z=0.18)
- [x] Schneekugel-Removal robuster (Children-Cleanup + Early Return)
- [x] Entity-Anzahl reduziert (~40%): Ground-Radius 11->8, 1 statt 2 Dreckschichten, kleinere Baumkronen

### Session 2026-03-11
- [x] Earth.usdz Globus-Modell eingebunden (statt blauer Placeholder-Kugel)
- [x] Voxel-Pins ersetzt durch Stecknadel-Stil (Cylinder + Sphere)
- [x] Tappbare SwiftUI-Labels als Attachments ueber den Pins
- [x] Pin-Positionierung iteriert (globeRadius, lonOffset)
- [x] London entfernt (zu nah an Berlin/Paris auf kleinem Globus)
- [x] simultaneousGesture fuer alle Gesten (Drag ohne vorheriges Tappen)
- [x] **Performance: Mesh-Merging via VoxelCollector** — ~700 einzelne Entities pro Schneekugel auf ~12 reduziert
- [x] WeatherEffects auf VoxelCollector umgestellt (Wolken, Sonne, Blitz)
- [x] Partikel-Raten reduziert: Regen 200->150, Schnee 80->50

### Session 2026-03-16
- [x] Gesten-Bug analysiert und gefixt: Revert auf f4937e1 (ContentView + GlobeBuilder)
- [x] Paris entfernt (zu nah an Berlin auf dem kleinen Globus)
- [x] Stadt-Selektion gefixt: attachment.name fuer Tap-Erkennung
- [x] Schneekugel-Entfernung gefixt: Scene-Graph-Suche statt @State-Referenz
- [x] Schneekugel verschwindet nicht mehr bei Tap (isDragOnSnowGlobe-Check im Tap-Handler)
- [x] Schneekugel Rotation/Skalierung funktioniert (Scene-Graph-Suche fuer Transform-Anwendung)
- [x] Schneekugel-Rotation auf Y-Achse beschraenkt (bleibt aufrecht wie echte Schneekugel)
- [x] Weather-Panel bleibt fix vor Schneekugel (an scene-root statt snow globe gehaengt)
- [x] Label-Sichtbarkeit verbessert: farbiger Rand, .thinMaterial, Schatten
- [x] HoverEffect-Staerke auf Maximum (strength 1.0, weiss)
- [x] CLAUDE.md + TODO.md komplett aktualisiert inkl. @State-Pitfall-Dokumentation
- [x] Ursache dokumentiert: Label-Collision-Overlap + SwiftUI-Attachment-Gesten-Interception
- [x] Label-Taps funktionieren zuverlaessig auf echter AVP

### Session 2026-03-18
- [x] **Regen-Bug gefixt**: Emitter war nach oben gerichtet → 180°-Rotation eingefuehrt, spaeter durch Gravity-Only-Ansatz ersetzt (keine Rotation, speed=0.01, acceleration=-0.5). Regen funktioniert stabil bei Schneekugel-Drehung.
- [x] **Tokio komplett verschoenert (2x Aufloesung)**:
  - VoxelCollector um gridSize-Parameter erweitert (konfigurierbar pro Stadt)
  - gridSize/blockSize 0.005 (halbe Voxelgroesse, doppelte Koordinaten)
  - Keine Luecken zwischen Voxeln (block = grid fuer ALLE Staedte)
  - Pagode: 3 Stockwerke, Tuer auf Weg-Seite (+x), Fenster, aufgebogene Dach-Ecken, goldene Spitze
  - Torii-Tor: 2 Saeulen, Kasagi, Nuki, aufgebogene Enden
  - Holzsteg (Pier) in den Teich mit Stuetzpfosten
  - 2 Steinlaternen mit 3x3 Lichtkammer neben dem Torii
  - Steinpfad vom Torii zur Pagode
  - 3 Kirschbaeume mit Ast-Stubs und groesserer Krone (r=4)
  - Kirschblueten-Blaetter auf dem Boden
  - Teich mit bewachsenem Rand (dunkelgruen, zweifarbig)
  - Bodenplatte radius 22 (gross genug fuer alle Elemente)
- [x] **Wolken komplett ueberarbeitet**:
  - 3D-Blob-Wolken aus ueberlappenden Kugeln (keine flachen Ellipsen)
  - 6 Wolken mit individuellen Formen und Groessen
  - Positionen angehoben auf y=0.10-0.12 (ueber Gebaeuden)
  - voxelSize-Parameter an WeatherEffects durchgereicht (0.005 fuer Tokio)
- [x] **Regen-Emitter optimiert**: Start bei Wolkenebene y=0.10, Gravity-only (speed=0.01, accel=-0.5), lifeSpan=0.95, emitter 0.10x0.10
- [x] **App Icon erstellt**: Pixel-Art Wolke + Sonne, 3-Layer Parallax (Back=Himmel, Middle=Sonne, Front=Wolke)
- [x] **App umbenannt**: Display Name "PixelWeather" via CFBundleDisplayName in Info.plist

### Session 2026-03-25
- [x] **Berlin komplett verschoenert (2x Aufloesung)**:
  - VoxelCollector mit gridSize/blockSize 0.005 (wie Tokio)
  - Fernsehturm: Schaft, Aussichtsplattform, Kugel mit Ring, Antenne, rotes Licht
  - Brandenburger Tor: 6 Saeulen (2x2), Architrav, Attika, goldene Quadriga
  - 3 Plattenbauten: 2x-Masse, Tueroeffnungen, Fenstermuster, Flachdach
  - Berliner Mauer: Betonsegment mit buntem Graffiti + Rohr oben
  - Spree: Wasserstreifen (z=14..18) mit bewachsenen Uferkanten
  - 4 Linden-Baeume: Stamm mit Aesten, grosse Krone (r=4)
  - 2 Strassenlaternen mit Armen und Leuchten
  - Parkbank (Holz + Metall)
  - Kopfsteinpflaster-Weg vom Tor zum Fernsehturm
  - Falllaub auf dem Boden
  - Bodenplatte radius 22
  - Palette erweitert: sandstone/sandstoneDark fuer Brandenburger Tor
- [x] **New York komplett verschoenert (2x Aufloesung)**:
  - VoxelCollector mit gridSize/blockSize 0.005 (wie Tokio/Berlin)
  - Empire State Building: 3 Art-Deco Setback-Stufen, Fenster, Tuer, dekorative Gesimse, Spire
  - 4 Skyscrapers: 2x-Masse, Tueroeffnungen, Fenstermuster, Flachdaecher
  - Freiheitsstatue: Stufenpodest, Robe, Krone mit Spitzen, Fackel-Arm, Tablet-Arm
  - 2 Water Towers auf Daechern (Holztank auf Stahlstelzen)
  - Central Park: Gruenflaeche mit 2 Linden-Baeumen und Parkbank
  - 2 Strassen (Betonstreifen) mit 3 Yellow Cabs
  - 2 Fire Hydrants, 2 Strassenlaternen
  - Bodenplatte radius 22 (Beton)
  - Palette erweitert: libertyGreen/libertyGreenDk fuer Freiheitsstatue

### Session 2026-04-01
- [x] **Berlin Schnee-Flickering gefixt** (auf AVP bestaetigt):
  - Mesh-Splitting: Schneedecke-Farbe (snowCover) getrennt vom Boden-Schnee
  - Counter-Scale + dynamische Kompensation (emitterShapeSize, birthRate, acceleration)
  - Partikel optimiert: groesser, blauer Stich, sanftes Driften
- [x] **Regen-Reichweite** — lifeSpan erhoeht (0.95→1.15), Tropfen erreichen den Boden
- [x] **Schneefall-Physik** — deutlich langsamer, realistisches Flocken-Driften statt Regen-Geschwindigkeit
- [x] **Skalierungs-Begrenzung gefixt**:
  - Scale-Limits: Globus max 2.0→1.5x, Schneekugel max 1.5→1.2x (kein Overlap mehr)
  - Weather-Panel dynamisch vor Schneekugel positioniert (y=Basis-Hoehe, z=vor Glaskugel)
  - Panel verschwindet nicht mehr im Volume-Boden bei grosser Skalierung
- [x] **Dynamisches Wetter fuer alle Staedte** (Branch: feature/dynamic-weather, auf AVP bestaetigt):
  - buildSnowGlobe() bekommt WeatherCondition als Parameter
  - Berlin: Beton-Boden bei Nicht-Schnee, Schneeboden + Schneedecke bei .snowy
  - New York: Beton/Schnee-Boden je nach Wetter, Schneedecke auf Daechern/Statue/Baeumen
  - Tokio: Gras/Schnee-Boden je nach Wetter, Schneedecke auf Pagode/Torii/Baeumen
  - buildSnowGround() Hilfsfunktion mit Mesh-Splitting (Checkerboard gegen Flickering)
  - Schneeboden-Mesh in 2 Haelften gesplittet (2 leicht verschiedene Weisstöne)
- [x] **Nieselregen (.drizzle)** — Neuer WeatherCondition-Case. Feinere Tropfen (0.003), weniger (80 birthRate), langsamer (-0.3 accel), helle Wolken.
- [x] **Wolken-Animation** — Langsame Y-Rotation per Task (200ms Intervall, ~0.17°/Update). Vorsicht: 50ms Intervall verursacht Partikel-Flickering!
- [x] **Wind-Drift auf Regen** — Leichte seitliche Acceleration-Komponente (X=0.06, Z=0.02)
- [x] **Open-Meteo API** (WeatherService.swift):
  - REST-Call: api.open-meteo.com/v1/forecast mit current-Parametern
  - WMO-Code-Mapping auf WeatherCondition (0=sunny, 1-3=cloudy, 51-57=drizzle, 61-67=rainy, 71-86=snowy, 95-99=stormy)
  - 10-Minuten-Cache (fetchAll prueft lastFetch)
  - Fallback auf CityData.dummyWeather bei Netzwerkfehler
  - ContentView: .task{} laedt Wetter beim App-Start
  - WeatherPanelView zeigt echte API-Daten
- [x] **Alle 6 Wetter-Szenarien getestet** auf echter AVP: sunny, cloudy, drizzle, rainy, snowy, stormy
- [x] **7-Tage-Vorhersage mit Swipe-Navigation** (auf AVP bestaetigt):
  - Open-Meteo daily API: weather_code, temperature_2m_max/min, wind_speed_10m_max
  - DayForecast Struct (date, condition, tempHigh, tempLow, windSpeed)
  - WeatherPanelView: Swipe links/rechts wechselt Tage (DragGesture minimumDistance 20)
  - Tagesanzeige: "Heute", "Morgen", "Uebermorgen", dann deutsche Wochentage
  - Punkt-Indikatoren (7 Punkte) + Pfeil-Hinweise (< >)
  - Schneekugel wird bei Tag-Wechsel neu gebaut (Day-Index im Entity-Namen)
  - Heute: Temperatur + Condition + Luftfeuchtigkeit + Wind
  - Forecast: Temperatur High/Low + Condition (kein Wind/Humidity — API liefert nur daily Aggregat)
  - Stadtwechsel setzt auf "Heute" zurueck
- [x] **Feature-Branch feature/dynamic-weather in master gemerged**
