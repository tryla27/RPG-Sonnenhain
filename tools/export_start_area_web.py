"""Exportiert die isolierte Einstiegsszene ohne das Spielprojekt zu verändern.

Aufruf: python tools/export_start_area_web.py /pfad/zu/godot
Anschließend build/browser-check per lokalem HTTP-Server bereitstellen.
"""
from pathlib import Path
import json
import os
import re
import shutil
import subprocess
import sys


def copy_resource(source, destination):
    # Rohmedien werden beim Import nur gelesen. Hardlinks sparen Platz auf
    # demselben Laufwerk; alle Quellen/Importmetadaten bleiben eigene Kopien.
    media = {'.png', '.jpg', '.jpeg', '.webp', '.wav', '.ogg', '.mp3', '.glb'}
    if Path(destination).exists() and os.path.samefile(source, destination):
        return destination
    if Path(source).suffix.lower() in media and not Path(destination).exists():
        try:
            os.link(source, destination)
            return destination
        except OSError:
            pass
    return shutil.copy2(source, destination)


def main():
    root = Path(__file__).resolve().parents[1]
    probe = root / 'build' / 'start-web-project'
    output = root / 'build' / 'browser-check'
    probe.mkdir(parents=True, exist_ok=True)
    output.mkdir(parents=True, exist_ok=True)
    for folder in ('components', 'art', 'audio', 'music', 'tools'):
        shutil.copytree(root / folder, probe / folder, dirs_exist_ok=True,
                        ignore=shutil.ignore_patterns('__pycache__', '*.log'),
                        copy_function=copy_resource)
    for name in ('main.gd', 'main.tscn', 'export_presets.cfg', 'default_bus_layout.tres'):
        shutil.copy2(root / name, probe / name)
    config = (root / 'project.godot').read_text(encoding='utf-8')
    config = config.replace('run/main_scene="res://main.tscn"',
                            'run/main_scene="res://tools/capture_start_area_web.tscn"')
    (probe / 'project.godot').write_text(config, encoding='utf-8')
    engine = sys.argv[1]
    play_mode = '--play' in sys.argv[2:]
    if play_mode:
        config = config.replace('res://tools/capture_start_area_web.tscn',
                                'res://tools/play_start_area.tscn')
        (probe / 'project.godot').write_text(config, encoding='utf-8')
    for label, args in (
        ('import', ['--editor', '--import', '--quit']),
        ('export', ['--export-release', 'Web', str(output / 'index.html')]),
    ):
        result = subprocess.run([engine, '--headless', '--path', str(probe)] + args,
                                capture_output=True, text=True, encoding='utf-8',
                                errors='replace', timeout=240)
        log = result.stdout + result.stderr
        (output / (label + '.log')).write_text(log, encoding='utf-8')
        if result.returncode != 0 or 'SCRIPT ERROR:' in log:
            raise SystemExit(f'{label} fehlgeschlagen; siehe {output / (label + ".log")}')
    html = (output / 'index.html').read_text(encoding='utf-8')
    match = re.search(r'const GODOT_CONFIG = (\{.*?\});', html)
    if not match:
        raise SystemExit('Export-Konfiguration im HTML nicht gefunden.')
    config = json.loads(match[1])
    script = 'const GODOT_CONFIG = ' + json.dumps(config) + ';\n'
    script += 'GODOT_CONFIG.args=["--",String(Math.max(0,Math.min(4,Number(new URLSearchParams(location.search).get("view")||0))))];'
    if play_mode:
        script = script.replace('Math.min(4,', 'Math.min(2,').replace('get("view")', 'get("class")')
    html = html[:match.start()] + script + html[match.end():]
    nav = '<nav style="position:fixed;top:4px;left:260px;z-index:999;background:#15212b;padding:8px;color:white;font:14px sans-serif">Isolierte Sichtprüfung · '
    labels = ('Krieger', 'Magier', 'Bogenschütze') if play_mode else ('Sonnenhain', 'Ratshalle', 'Osttor', 'Blütenwiesen', 'Pilzwald')
    for index, name in enumerate(labels):
        nav += f'<a style="color:#ffe0a0;margin:6px" href="?{"class" if play_mode else "view"}={index}">{name}</a>'
    if play_mode:
        nav += ' · WASD · Maus: Angriff · E: Interaktion · Leertaste: Ausweichen'
    html = html.replace('<body>', '<body>' + nav + '</nav>')
    html = html.replace('<title>Sonnenhain RPG - Pixelwelt</title>', '<title>Sonnenhain · Einstieg prüfen</title>')
    (output / 'probe.html').write_text(html, encoding='utf-8')
    print(f'Prüfexport bereit: {output / "probe.html"}')


if __name__ == '__main__':
    main()
