# 3D-Assets für die Diorama-Version

## Erwartete Dateinamen

Die Diorama-Entities laden Assets nach folgenden Namen (ohne Dateiendung):

| Asset-Name     | Beschreibung                        | Verwendet in                  |
|----------------|-------------------------------------|-------------------------------|
| `terrain`      | Insel/Terrain-Landschaft            | `TerrainEntity.swift`         |
| `cloud`        | Weiße Wolke                         | `AssetCloudEntity.swift`      |
| `cloud_dark`   | Dunkle Regenwolke                   | `AssetCloudEntity.swift`      |
| `sun`          | Sonne mit Strahlen                  | `AssetSunEntity.swift`        |
| `thermometer`  | Thermometer-Körper (ohne Füllung)   | `AssetThermometerEntity.swift`|

## Format

Alle Assets müssen im **USDZ**-Format vorliegen und im Xcode-Projekt als Resources eingebunden sein.

## Empfohlene Quellen

1. **Apple Diorama Sample** — [developer.apple.com](https://developer.apple.com/documentation/visionos/diorama)
2. **Sketchfab** — Low-Poly-Modelle (GLB herunterladen, dann konvertieren)
3. **Polyhaven** — Kostenlose 3D-Assets

## Workflow am Mac

1. GLB/FBX-Datei herunterladen
2. **Reality Converter** öffnen (Apple Developer Tools)
3. Datei importieren und als `.usdz` exportieren
4. Die exportierte `.usdz`-Datei in diesen `Assets/`-Ordner legen
5. Dateinamen anpassen (siehe Tabelle oben)
6. `xcodegen generate` erneut ausführen

## Skalierung

Die Assets sollten so skaliert sein, dass sie in die Diorama-Szene passen:
- **Terrain:** ca. 0.3m Durchmesser
- **Wolken:** ca. 0.04m Durchmesser
- **Sonne:** ca. 0.08m Durchmesser
- **Thermometer:** ca. 0.12m Höhe

Falls die Skalierung nicht passt, kann sie in Reality Converter oder im Code angepasst werden.

## Fallback

Wenn keine USDZ-Dateien vorhanden sind, verwenden die Diorama-Entities automatisch verbesserte programmatische Fallback-Geometrie. Die App funktioniert also auch ohne heruntergeladene Assets.
