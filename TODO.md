# WetterApp — TODO-Liste

Stand: 2026-03-11

---

## Anforderungen aus der Aufgabenstellung

### Anforderung 1: Volumetrische App (Volume)
- [x] `WindowGroup` mit `.windowStyle(.volumetric)`
- [x] Definierte Volume-Groesse (0.9 x 0.6 x 0.6 m)
- [x] Inhalte innerhalb des definierten 3D-Bereichs

### Anforderung 2: Kanonische Manipulationen (mind. 2 von 4)
- [x] **Selektieren** — SpatialTapGesture auf Stadt-Pins waehlt Stadt aus und oeffnet Schneekugel
- [x] **Rotieren** — DragGesture dreht Globus und Schneekugel unabhaengig
- [x] **Skalieren** — MagnifyGesture vergroessert/verkleinert Globus (0.5x-2.0x) und Schneekugel (0.4x-1.5x)
- [ ] Positionieren — nicht implementiert (nicht erforderlich)

### Anforderung 3: Grundlegende visionOS-Interaktionsformen
- [x] Gesten: SpatialTapGesture, DragGesture, MagnifyGesture
- [x] SwiftUI-Elemente: Stadt-Labels als Attachment mit BillboardComponent
- [x] Wetter-Info-Panel als glassmorphes SwiftUI-Overlay (.ultraThinMaterial)
- [ ] Bedienbarkeit verbessern: Pins sind noch schwer zu treffen (Collision vergroessert auf 4cm, aber ggf. noch zu klein)

### Anforderung 4: Informative und aesthetische 3D-Darstellung
- [x] 4 stadtspezifische Voxel-Szenen (Berlin, New York, Tokio, Paris) — London entfernt (zu nah an Berlin/Paris)
- [x] Wettereffekte: Sonne, Wolken, Regen, Schnee, Gewitter
- [x] Voxel-Art-Stil (prozedural, keine externen Assets)
- [x] Farbpalette konsistent in VoxelBuilder.Palette
- [ ] **Regenpartikel nicht sichtbar** — Regen wird in der Schneekugel nicht mehr angezeigt, muss debuggt werden
- [ ] **Voxelstaedte verschoenern** — Aktuelle Szenen sind funktional, aber koennten aesthetisch verbessert werden
- [ ] Performance: Lag/Crash nach mehreren Interaktionen — Entity-Anzahl reduziert (~40%), muss nochmal getestet werden

### Anforderung 5: Dummy-Daten
- [x] 4 Staedte mit Dummy-Wetterdaten in CityData.swift (Temperatur, Luftfeuchtigkeit, Wind, Zustand, Beschreibung)
- [ ] Optional: Anbindung an echte Wetter-API (Open-Meteo oder DWD Open Data) — nur in neuem Branch

---

## Bekannte Bugs / Offene Probleme

### Hoch (muss fuer Abnahme gefixt sein)
- [ ] **Performance/Crash bei Schneekugel** — App laggt sehr stark sobald eine Schneekugel angezeigt wird und stuerzt gelegentlich ab. Entity-Anzahl wurde bereits reduziert (~40%), reicht aber nicht. Mesh-Merging, Entity-Instancing oder weitere Reduktion evaluieren
- [ ] **Stadt-Labels nicht hervorgehoben** — Labels werden beim Anschauen (Eye-Tracking) nicht visuell hervorgehoben, obwohl HoverEffectComponent gesetzt ist. Selektieren einer Stadt dadurch sehr schwer — User weiss nicht, ob Label fokussiert ist
- [ ] **Regenpartikel nicht sichtbar** — Regen-Effekt wird in der Schneekugel nicht mehr angezeigt, muss debuggt werden

### Mittel (sollte gefixt werden)
- [ ] **Voxelstaedte verschoenern** — Aktuelle Szenen sind funktional, koennten aber aesthetisch verbessert werden (mehr Details, bessere Proportionen)
- [ ] **Wetter-Panel Positionierung** — UI-Element mit Wetterdaten koennte noch besser positioniert werden (aktuell unter der Schneekugel, evtl. seitlich oder als Ornament)

### Niedrig (nice to have)
- [ ] Animierte Uebergaenge beim Schneekugel-Wechsel (Fade-In/Out)
- [x] Tap auf Globus deselektiert Stadt — funktioniert

---

## Erweiterungen (optional, nur wenn Zeit reicht — jeweils in neuem Branch)

- [ ] **Echte Wetter-API** (Open-Meteo oder DWD Open Data) — nur wenn alles andere fertig ist
- [ ] **Mehr Staedte hinzufuegen** — z.B. Sydney, Kairo, Rio, Moskau
- [ ] **Schneekugel-Widgets** — Schneekugeln als platzierbare Widgets im Raum (Shared Space / Immersive Space)
- [ ] Weitere sinnvolle Funktionen brainstormen (z.B. Tageszeit-Wechsel, Jahreszeiten, AR-Modus)
- [ ] Verfeinerung der Voxel-Aufloesung fuer mehr Detail
- [x] ~~Apple-Globus-Modell aus Reality Composer Pro~~ — Earth.usdz eingebunden

---

## Dokumentation

- [x] Projektdokumentation vorhanden (WetterApp/Dokumentation.md)
- [ ] **Dokumentation aktualisieren** — Aktuelle Doku beschreibt den Stand korrekt, aber folgende Aenderungen muessen nachgetragen werden:
  - SpatialTapGesture statt TapGesture
  - HoverEffectComponent auf interaktiven Entities
  - CollisionComponent statt generateCollisionShapes
  - Performance-Optimierungen (reduzierte Entity-Anzahl)
  - Emitter-Anpassungen fuer Partikel in der Schneekugel
- [ ] **Alte DOKUMENTATION.md im Root entfernen oder archivieren** — beschreibt die alte Diorama-Architektur, die nicht mehr existiert
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
- [x] Collision-Radius von Pin-Radius getrennt (globeCollisionRadius vs globeRadius)
- [x] Label-Name gesetzt (attachment.name) — Fix fuer Stadt-Selektion
- [x] Globe bleibt links wenn Schneekugel sichtbar (snowGlobeEntity-Check)
- [x] simultaneousGesture fuer alle Gesten (Drag ohne vorheriges Tappen)
