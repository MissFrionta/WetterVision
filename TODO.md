# WetterApp — TODO-Liste

Stand: 2026-03-16

---

## Anforderungen aus der Aufgabenstellung

### Anforderung 1: Volumetrische App (Volume)
- [x] `WindowGroup` mit `.windowStyle(.volumetric)`
- [x] Definierte Volume-Groesse (0.9 x 0.6 x 0.6 m)
- [x] Inhalte innerhalb des definierten 3D-Bereichs

### Anforderung 2: Kanonische Manipulationen (mind. 2 von 4)
- [x] **Selektieren** — SpatialTapGesture auf Stadt-Labels/Pins waehlt Stadt aus und oeffnet Schneekugel
- [x] **Rotieren** — DragGesture dreht Globus und Schneekugel unabhaengig
- [x] **Skalieren** — MagnifyGesture vergroessert/verkleinert Globus (0.5x-2.0x) und Schneekugel (0.4x-1.5x)
- [ ] Positionieren — nicht implementiert (nicht erforderlich)

### Anforderung 3: Grundlegende visionOS-Interaktionsformen
- [x] Gesten: SpatialTapGesture, DragGesture, MagnifyGesture
- [x] SwiftUI-Elemente: Stadt-Labels als Attachment mit BillboardComponent
- [x] Wetter-Info-Panel als glassmorphes SwiftUI-Overlay (.ultraThinMaterial)
- [x] HoverEffect auf Stadt-Labels (HoverEffectComponent auf Entity)

### Anforderung 4: Informative und aesthetische 3D-Darstellung
- [x] 3 stadtspezifische Voxel-Szenen (Berlin, New York, Tokio)
- [x] Wettereffekte: Sonne, Wolken, Regen, Schnee, Gewitter
- [x] Voxel-Art-Stil (prozedural, keine externen Assets)
- [x] Farbpalette konsistent in VoxelBuilder.Palette
- [x] Performance-Optimierung: Mesh-Merging via VoxelCollector (~700 Entities → ~12 pro Schneekugel)
- [ ] **Regenpartikel nicht sichtbar** — Regen wird in der Schneekugel nicht angezeigt, muss debuggt werden
- [ ] **Voxelstaedte verschoenern** — Aktuelle Szenen sind funktional, koennten aesthetisch verbessert werden

### Anforderung 5: Dummy-Daten
- [x] 3 Staedte mit Dummy-Wetterdaten in CityData.swift (Temperatur, Luftfeuchtigkeit, Wind, Zustand, Beschreibung)
- [ ] Optional: Anbindung an echte Wetter-API (Open-Meteo oder DWD Open Data) — nur in neuem Branch

---

## Bekannte Bugs / Offene Probleme

### Hoch (muss fuer Abnahme gefixt sein)
- [ ] **Schneekugel schliessen** — Tap auf Globus-Oberflaeche deselektiert die Stadt, aber es gibt keinen expliziten Close-Button. Evtl. Close-Mechanismus verbessern
- [ ] **Regenpartikel nicht sichtbar** — Regen-Effekt wird in der Schneekugel nicht angezeigt, muss debuggt werden

### Mittel (sollte gefixt werden)
- [ ] **Voxelstaedte verschoenern** — Aktuelle Szenen sind funktional, koennten aber aesthetisch verbessert werden (mehr Details, bessere Proportionen)
- [ ] **Wetter-Panel Positionierung** — UI-Element mit Wetterdaten koennte noch besser positioniert werden
- [ ] **Label-Taps unzuverlaessig** — Tap auf Stadt-Labels funktioniert nicht immer auf der echten AVP. Collision-Radius (0.025) ist klein, aber groessere Werte brechen Gesten (siehe CLAUDE.md)

### Niedrig (nice to have)
- [ ] Animierte Uebergaenge beim Schneekugel-Wechsel (Fade-In/Out)

---

## Erweiterungen (optional, nur wenn Zeit reicht — jeweils in neuem Branch)

- [ ] **Echte Wetter-API** (Open-Meteo oder DWD Open Data) — nur wenn alles andere fertig ist
- [ ] **Mehr Staedte hinzufuegen** — z.B. Sydney, Kairo, Rio, Moskau
- [ ] **Schneekugel-Widgets** — Schneekugeln als platzierbare Widgets im Raum (Shared Space / Immersive Space)
- [ ] Weitere sinnvolle Funktionen brainstormen (z.B. Tageszeit-Wechsel, Jahreszeiten, AR-Modus)
- [ ] Verfeinerung der Voxel-Aufloesung fuer mehr Detail
- [x] ~~Apple-Globus-Modell aus Reality Composer Pro~~ — Earth.usdz eingebunden

---

## KRITISCH: visionOS Gesten-Regeln (auf echter AVP bestaetigt)

Siehe CLAUDE.md fuer die vollstaendige Dokumentation. Kurzfassung:

**Diese Werte NICHT aendern ohne Test auf der echten Apple Vision Pro:**
- Globe Collision: 0.108 (= globeRadius). NICHT groesser machen!
- Label Collision: 0.025. NICHT groesser machen!
- Label Font: 11. Labels NICHT vergroessern!
- Label Background: .ultraThinMaterial. NICHT .regularMaterial verwenden!
- KEIN .hoverEffect(.highlight) auf SwiftUI-Attachment-Views!
- KEINE SwiftUI Buttons in Attachments!

**Warum:** Groessere Collision-Spheres/Labels verursachen Overlap zwischen Label- und Globus-Collision.
Continuous Gestures (Drag/Magnify) die auf ein SwiftUI-Attachment treffen werden von SwiftUI
verschluckt und erreichen nie den RealityView-Gesture-Handler. Nur der SpatialTapGesture
(diskret) funktioniert zuverlaessig auf Attachments.

Referenz-Commit mit funktionierenden Gesten: **f4937e1**

---

## Dokumentation

- [x] Projektdokumentation vorhanden (WetterApp/Dokumentation.md)
- [x] CLAUDE.md (Entwicklungshinweise fuer Claude Code, inkl. Gesten-Regeln)
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
- [x] CLAUDE.md komplett ueberarbeitet mit detaillierten Gesten-Regeln
- [x] TODO.md aktualisiert
- [x] Ursache dokumentiert: Label-Collision-Overlap + SwiftUI-Attachment-Gesten-Interception
