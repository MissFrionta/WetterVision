# WetterApp — TODO-Liste

Stand: 2026-03-10

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
- [x] 5 stadtspezifische Voxel-Szenen (Berlin, New York, Tokio, London, Paris)
- [x] Wettereffekte: Sonne, Wolken, Regen, Schnee, Gewitter
- [x] Voxel-Art-Stil (prozedural, keine externen Assets)
- [x] Farbpalette konsistent in VoxelBuilder.Palette
- [ ] Partikel (Regen/Schnee) noch teilweise ausserhalb der Schneekugel — Emitter verkleinert, muss nochmal getestet werden
- [ ] Performance: Lag/Crash nach mehreren Interaktionen — Entity-Anzahl reduziert (~40%), muss nochmal getestet werden

### Anforderung 5: Dummy-Daten
- [x] 5 Staedte mit Dummy-Wetterdaten in CityData.swift (Temperatur, Luftfeuchtigkeit, Wind, Zustand, Beschreibung)
- [ ] Optional: Anbindung an echte Wetter-API (Open-Meteo oder DWD Open Data)

---

## Bekannte Bugs / Offene Probleme

### Hoch (muss fuer Abnahme gefixt sein)
- [ ] **Pin-Tapping schwierig** — Pins auf dem Globus sind schwer mit Eye-Tracking zu treffen. Collision-Radius ist 4cm, evtl. noch groessere Hitbox oder alternative Selektion (z.B. SwiftUI-Buttons als Attachments neben den Pins)
- [ ] **Performance/Crash** — App laggt nach mehreren Stadtwechseln und stuerzt ab. Entity-Anzahl wurde reduziert, muss auf dem Geraet verifiziert werden. Falls weiterhin problematisch: Mesh-Merging oder Entity-Instancing evaluieren
- [ ] **Schneekugel-Stacking pruefen** — Es gab Hinweise, dass alte Schneekugeln nicht sauber entfernt werden. Fix wurde implementiert (explizites Children-Cleanup + Early Return), muss verifiziert werden

### Mittel (sollte gefixt werden)
- [ ] **Partikel ausserhalb der Schneekugel** — Emitter-Flaeche von 20x20cm auf 12x12cm reduziert und Position angepasst, muss auf dem Geraet getestet werden
- [ ] **Rotation noch nicht ganz sauber** — Funktioniert grundsaetzlich, aber User empfindet es als "nicht ganz sauber". Evtl. Sensitivity-Werte anpassen oder Damping hinzufuegen

### Niedrig (nice to have)
- [ ] Animierte Uebergaenge beim Schneekugel-Wechsel (Fade-In/Out)
- [ ] Tap auf Globus deselektiert Stadt (Code ist da, muss getestet werden)

---

## Erweiterungen (aus Dokumentation, optional)

- [ ] Anbindung an echte Wetter-API (Open-Meteo oder DWD Open Data)
- [ ] Nutzer:innen koennen eigene Staedte hinzufuegen
- [ ] Verfeinerung der Voxel-Aufloesung fuer mehr Detail
- [ ] Apple-Globus-Modell aus Reality Composer Pro statt Placeholder-Kugel

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

## Erledigte Aufgaben (diese Session, 2026-03-10)

- [x] Build-Fehler GlobeBuilder: generateCollisionShapes -> CollisionComponent
- [x] Build-Fehler VoxelBuilder: generateCollisionShapes -> CollisionComponent
- [x] Build-Fehler WeatherEffects: birthRate/speed/birthDirection API-Fixes
- [x] Gesten funktionieren: HoverEffectComponent, SpatialTapGesture, .gesture() statt .simultaneousGesture()
- [x] Vertikale Rotation invertiert (Hand hoch = Globus hoch)
- [x] Pin-Collision vergroessert (2.5cm -> 4cm Radius)
- [x] Pin-Head visuell vergroessert (1.4x -> 2.5x)
- [x] Partikel-Emitter verkleinert (20x20cm -> 12x12cm)
- [x] Wetter-Panel nach vorne versetzt (z=0.18)
- [x] Schneekugel-Removal robuster (Children-Cleanup + Early Return)
- [x] Entity-Anzahl reduziert (~40%): Ground-Radius 11->8, 1 statt 2 Dreckschichten, kleinere Baumkronen
