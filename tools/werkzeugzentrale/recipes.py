"""Feste lokale Werkzeugaktionen; keine dynamischen Agentenrezepte."""
from pathlib import Path

def actions(config):
    p = Path(config["project"])
    t = Path(config["tools_root"])
    godot = t / "Godot/Godot_v4.7.2-stable_win64_console.exe"
    game = t / "Godot/Godot_v4.7.2-stable_win64.exe"
    blender = t / "Blender/blender.exe"
    krita = t / "Krita/bin/krita.exe"
    inkscape = t / "Inkscape-Portable/PFiles64/Inkscape/bin/inkscape.com"
    python = t / "ComfyUI-venv/Scripts/python.exe"
    pipeline = p / "tools/art_pipeline"
    registry = {}

    def add(key, title, commands, inputs=(), detached=False, timeout=600, effect=""):
        registry[key] = dict(id=key, title=title, commands=[[str(v) for v in cmd] for cmd in commands],
                             inputs=[str(v) for v in inputs], detached=detached,
                             timeout=timeout, effect=effect, cwd=str(p), cost_class="local_compute", retries=0)

    def script(key, title, name):
        target = pipeline / name
        add(key, title, [[blender, "--background", "--factory-startup", "--python", target]],
            [target], effect="Erzeugt beziehungsweise ersetzt die Ausgaben des vorhandenen Grafikskripts.")

    add("godot.version", "Godot-Version", [[godot, "--version"]], timeout=30)
    add("blender.version", "Blender-Version", [[blender, "--version"]], timeout=30)
    add("inkscape.version", "Inkscape-Version", [[inkscape, "--version"]], timeout=30)
    add("krita.version", "Krita-Version", [[krita, "--version"]], timeout=30)
    add("godot.play", "Spiel starten", [[game, "--path", p]], [p / "project.godot"], True,
        effect="Startet das konfigurierte Spiel; reguläres Spielen kann Spielstände ändern.")
    add("godot.lab", "Grafiklabor öffnen", [[game, "--path", p, "res://tools/quality_art_lab.tscn"]],
        [p / "project.godot", p / "tools/quality_art_lab.tscn"], True)
    add("godot.import", "Godot-Ressourcen importieren", [[godot, "--headless", "--path", p, "--editor", "--import", "--quit"]],
        [p / "project.godot"], effect="Aktualisiert lokale Godot-Importdateien und Caches.")
    for key, title, relative in [
        ("godot.map", "Kartendaten exportieren", "tools/art_pipeline/export_map_data.gd"),
        ("godot.check-assets", "Grafikressourcen prüfen", "tests/rendering/check_quality_assets.gd"),
    ]:
        add(key, title, [[godot, "--headless", "--path", p, "--script", "res://" + relative]],
            [p / "project.godot", p / relative], effect="Führt das vorhandene Projektwerkzeug aus.")
    script("blender.models", "Modelle und Animationen bauen", "build_blender_assets.py")
    script("blender.icons", "Waffenbilder rendern", "render_item_icons.py")
    target = pipeline / "build_vector_assets.py"
    add("inkscape.assets", "Karte, Symbole und Materialien exportieren",
        [[python, target, "--inkscape", inkscape]], [target, inkscape, p / "art/source/inkscape/map_geometry.json"],
        effect="Erzeugt beziehungsweise ersetzt SVG-, PNG- und ORA-Ausgaben des Grafikskripts.")
    commands, inputs = [], []
    for material in ("stone", "wood", "moss"):
        ora = p / f"art/source/krita/material_{material}.ora"
        kra = ora.with_suffix(".kra")
        png = p / f"art/textures/quality_v1/{material}_krita.png"
        inputs.append(ora)
        for source, output in ((ora, kra), (kra, png)):
            commands.append([krita, "--nosplash", "--export", "--export-filename", output, source])
    add("krita.materials", "Drei Krita-Materialien exportieren", commands, inputs,
        effect="Ersetzt die drei Material-KRA-Dateien aus ORA und exportiert ihre PNGs.")
    backend = t / "ComfyUI-Backend/main.py"
    add("comfy.start", "ComfyUI lokal starten", [[python, backend, "--listen", "127.0.0.1", "--port", "8188",
        "--disable-auto-launch", "--output-directory", p / "build/comfy-output"]], [backend], True,
        effect="Startet den lokalen Bildgenerator auf Port 8188; lädt kein Modell herunter.")
    target = pipeline / "generate_comfy_concepts.py"
    add("comfy.concepts", "Vorhandene vier KI-Entwürfe erzeugen", [[python, target, "--base", config["comfy_url"],
        "--server-output", p / "build/comfy-output"]], [target], timeout=3900,
        effect="Erzeugt die vier festgelegten Motive des bestehenden Skripts erneut; ersetzt deren Dateien. Benötigt laufendes ComfyUI und vorhandenes Modell.")
    return registry


WORKFLOWS = {"grafikpaket": ["godot.map", "inkscape.assets", "krita.materials", "blender.models",
                              "blender.icons", "godot.import", "godot.check-assets"]}

