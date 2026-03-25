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
- [ ] **Schnee-Partikel flackern in Berlin** — Schneepartikel erscheinen und verschwinden periodisch (Flickering). Problem ist Berlin-spezifisch, NICHT partikel-spezifisch. Regen in New York mit identischen Emitter-Parametern funktioniert einwandfrei. Details siehe unten.

### Mittel (sollte gefixt werden)
- [ ] **Farbwechsel-Bug beim Drehen** — Voxels mit Checkerboard-Farbmuster (z.B. Teich, Gras) aendern ihre sichtbare Farbe, wenn die Schneekugel gedreht wird. Ursache: benachbarte Voxels verschiedener Farben zeigen je nach Blickwinkel verschiedene Seiten. Workaround: einheitliche Farbe verwenden (wie beim Teichrand gemacht). Fuer Gras/Boden tolerierbar.

### Niedrig (nice to have)
- [ ] **Skalierungs-Begrenzung** — Globus und Schneekugel koennen sich beim Skalieren gegenseitig verdecken. Scale-Limits muessen so angepasst werden, dass beide nebeneinander sichtbar bleiben

---

## BUG-ANALYSE: Schnee-Partikel flackern in Berlin (Stand 2026-03-25)

### Symptom
- Schneepartikel in Berlin erscheinen und verschwinden periodisch ("Flickering")
- Wird schlimmer bei groesserer Schneekugel-Skalierung
- Mal schneit es normal, dann verschwindet der Schnee komplett, dann kommt er wieder
- Auf echter Apple Vision Pro reproduzierbar

### Bewiesene Fakten
1. **Regen in New York flackert NICHT** — auch nicht bei verschiedenen Skalierungen
2. **Schnee mit identischen Regen-Parametern flackert trotzdem** — also gleiche birthRate, speed, acceleration, lifeSpan, emitterShape wie Regen, nur weisse Farbe und kein stretchFactor. Flackert in Berlin weiterhin.
3. **Problem ist Berlin-spezifisch, nicht partikel-spezifisch** — gleicher Emitter-Code verhält sich in Berlin anders als in NY

### Was Berlin anders macht als New York
| Aspekt | Berlin (flackert) | New York (flackert nicht) |
|---|---|---|
| Boden | Weisser Schneeboden (UIColor white 0.95) | Beton (concrete/concreteDark) |
| Boden-Funktion | Inline Snow-Ground (nur 1 Farbe) | buildConcreteGround (2 Farben) |
| Extra-Voxels | Schneedecke auf allen Daechern/Baeumen/Mauer | Keine Extra-Schicht |
| Wolken-Typ | addClouds(dark: false) = helle Wolken | addClouds(dark: true) = dunkle Wolken |
| Wetter-Effekte | Wolken + Schnee-Partikel | Wolken + Regen + Blitz (mit Task) |
| Szene-Rotation | Keine initiale Rotation | 45° Y-Rotation (fuer Freiheitsstatue) |
| Partikel-Farbe | Weiss auf weissem Boden | Blau auf grauem Beton |

### Was bereits versucht wurde (alles OHNE Erfolg)
1. **Verschiedene Emitter-Parameter** — speed, acceleration, lifeSpan, birthRate variiert (von langsam/sparsam bis identisch zum Regen)
2. **emissionDuration/idleDuration** — Existiert nicht auf visionOS 2 ParticleEmitterComponent
3. **timing = .repeating(...)** — API-Syntax-Fehler, existiert nicht mit duration-Parameter
4. **Counter-Scale auf Partikel-Entity** — Inverse Scale auf snow/rain-Entity um effektive Scale 1.0 zu halten. Hat Problem VERSCHLIMMERT (zusaetzliche Transform-Writes)
5. **@State snowGlobeEntity entfernt** — War ein @State-Write in der update-Closure der eine Update-Schleife ausloeste. Entfernt, hat Flickering nicht geloest.
6. **isEmitting = true** — Kein Effekt

### Moegliche naechste Schritte (noch nicht versucht)
1. **Berlin temporaer auf Regen umstellen** — Bestaetigt ob das Problem wirklich an der Berlin-SZENE liegt und nicht doch an der Schnee-Partikel-Konfiguration
2. **Schneedecke entfernen** — Testen ob die extra weissen Voxels auf Daechern/Baeumen das Problem verursachen (mehr Geometrie → Performance-Drop → Partikel-Stutter?)
3. **Weissen Boden durch Gras ersetzen** — Testen ob das Problem am weissen Boden liegt (evtl. Z-Fighting oder Render-Konflikte zwischen weissen Voxels und weissen Partikeln)
4. **Helle Wolken durch dunkle ersetzen** — `addClouds(dark: false)` → `addClouds(dark: true)` testen. Evtl. rendern helle Wolken + weisse Partikel schlecht zusammen
5. **Partikel ausserhalb der Schneekugel-Hierarchie platzieren** — Snow-Entity nicht als Child des Snow-Globe, sondern als Sibling auf Scene-Root. Dann wird es nicht vom Snow-Globe-Scale beeinflusst
6. **Berlin-Szene vereinfachen** — Temporaer Landmarks reduzieren um Performance als Ursache auszuschliessen
7. **Partikel-Farbe aendern** — Leicht blaeuliches Weiss oder groessere Partikel testen, um visuellen Kontrast zum weissen Boden zu erhoehen (falls das "Flickering" teilweise ein Sichtbarkeitsproblem ist)
8. **Andere Partikel-Shape** — .sphere statt .plane als emitterShape testen

### Aktueller Stand der Dateien
- **WeatherEffects.swift addSnow()**: Identische Parameter wie addRain(), nur weiss + kein stretchFactor + birthRate 200
- **ContentView.swift**: snowGlobeEntity @State entfernt, keine Counter-Scale-Logik
- **VoxelBuilder.swift buildBerlinScene()**: Weisser Schneeboden + Schneedecke auf allen Objekten

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

## Erweiterungen (optional, nur wenn Zeit reicht — jeweils in neuem Branch)

- [ ] **Echte Wetter-API** (Open-Meteo oder DWD Open Data) — nur wenn alles andere fertig ist
- [ ] **Mehr Staedte hinzufuegen** — z.B. Sydney, Kairo, Rio, Moskau
- [ ] **Schneekugel-Widgets** — Schneekugeln als platzierbare Widgets im Raum (Shared Space / Immersive Space)
- [ ] Weitere sinnvolle Funktionen brainstormen (z.B. Tageszeit-Wechsel, Jahreszeiten, AR-Modus)
- [x] ~~Verfeinerung der Voxel-Aufloesung fuer mehr Detail~~ — Tokio auf 2x umgebaut
- [x] ~~Apple-Globus-Modell aus Reality Composer Pro~~ — Earth.usdz eingebunden

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
