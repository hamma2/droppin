<!-- Copilot / AI agent instructions for the Droppin Godot project -->
# Kurzreferenz für KI-Coding-Agenten

Ziel: Schnell einsatzfähiges, präzises Kontextwissen bereitstellen, damit eine KI-Code-Assistenz in diesem Godot-Projekt sofort produktiv ist.

- Projektart: Godot-Projekt (Projektdatei: `project.godot`). Struktur trennt `Scenes/`, `Scripts/`, `Shaders/`, `Textures/`, `UnitTests/`.
- Einstiegspunkt: Öffne das Projekt in der Godot-Editor-App (empfohlen) oder per CLI (`godot --path .`). Die Szene `Scenes/main.tscn` ist die Spiel-Startszene.

Wichtige Orte und Rollen
- `Scenes/main.tscn`: Einstiegsszene - orchestriert Spielstart.
- `Scripts/GameManager.gd`: zentrale Spiel-Logik/State-Management.
- `Scripts/Player.gd`, `Scripts/Ball.gd`: Spielobjekt-Verhalten (Player, Ball).
- `Scripts/BarrierGenerator.gd`, `Scenes/Barrier.tscn`, `Scripts/Barrier.gd`: Barrieren-Spawn und Verhalten.
- `UnitTests/`: enthält projekt-spezifische Tests (Prüfe, ob GUT oder ein anderer Test-Runner benutzt wird).

Architektur — Big picture
- Godot-typisches, datenzentriertes Scene-Tree-Design: einzelne `Scene`-Dateien mit zugehörigen `Script`-Dateien.
- Steuerung/Orchestrierung passiert in `GameManager.gd`; viele Spielobjekte kommunizieren über Godot-Signale oder direkte Node-Referenzen.
- Ressourcen (z. B. `export_presets.cfg`, `Scenes/`, `Textures/`) werden über Scenes instanziert und per `preload()`/`load()` im Code verwendet.

Konventionen & Muster (aus dem Code ableitbar)
- Dateiorganisation: logische Trennung nach `Scenes/` vs `Scripts/`.
- Scripts sind pro-Node zuständig (ein Script ≈ ein Node-Verhalten). Suche nach `extends` und `_ready()` / `_process()`-Hooks.
- UID-Dateien (`*.gd.uid`) liegen neben Scripts — ignorier diese für Änderungen.

Entwickler-Workflows (erkennbar / empfohlen)
- Lokales Testen: Öffne das Projekt in Godot und starte `main.tscn` im Editor.
- CLI-basiert: `godot --path .` öffnet das Projekt; zur CI/Headless-Ausführung `godot --path . --no-window` (prüfe die lokale Godot-Version auf unterstützte Flags).
- Tests: `UnitTests/` prüfen; wenn das Projekt GUT verwendet, starte die GUT-Runner-Szene oder nutze das GUT-CLI-Plugin.

Worauf KI-Assistenten achten sollten
- Keine globalen Refactors ohne Tests: ändere nur lokale Funktionen, wenn du sicher bist, dass `GameManager.gd` und Start-Szene kompatibel bleiben.
- Node-Pfade sind empfindlich — when changing node names, update any `get_node("...")` string paths.
- Ressourcen- und Preload-Pfade sind hartkodiert; prefer relative `res://`-Pfadkorrektur nur wenn nötig.

Integration & externe Abhängigkeiten
- Externe Abhängigkeiten nicht sichtbar im Repo (keine package-lock). Erwartung: Godot-Editor + Projekt-Plugins (prüfe `project.godot` auf add-ins).
- Export/Presets: `export_presets.cfg` vorhanden — CI/automation sollte Exporte über Godot-CLI oder Editor ausführen.

Konkrete Beispiele (verwende sie als Referenz/Pattern)
- Neue Barriere-Logik hinzufügen: folge `Scenes/Barrier.tscn` + `Scripts/Barrier.gd` + inkrementiere Spawn-Logik in `Scripts/BarrierGenerator.gd`.
- Ball-Verhalten anpassen: öffne `Scripts/Ball.gd` und `BallCamera.gd` um physics & camera-following zusammen zu betrachten.

Wenn etwas unklar ist
- Öffne die relevanten Dateien im Editor, simuliere das Spiel und beobachte Node-Hierarchie/Signals im Debugger.
- Wenn Tests fehlen: erstelle kleine Szenen-Testfälle unter `UnitTests/` und dokumentiere den Test-Runner.

Änderungsvorschläge / Pull-Request-Checks für Agenten
- Beschreibe Änderungen im PR: betroffene Szenen, veränderte Node-Pfade, notwendige Editor-Einstellungen.
- Vermeide API-Breaks in `GameManager.gd` ohne Rücksprache.

Frage an Maintainer nach dem Commit
- Fehlt etwas Wichtigeres (z. B. ein spezifischer Test-Runner oder CI-Workflow)? Bitte kurz beschreiben, damit diese Datei präzisiert werden kann.

-- Ende
