"""Static consistency checks for the generated Godot game content."""
from pathlib import Path
import re
import wave
import shutil
import subprocess

root = Path(__file__).resolve().parents[1]
source = (root / 'main.gd').read_text(encoding='utf8')

def block(name):
    match = re.search(rf'^const {name} := \[', source, re.M)
    assert match, f'{name} missing'
    depth, start = 0, match.end() - 1
    quote, escaped = False, False
    for index in range(start, len(source)):
        c = source[index]
        if quote:
            if escaped: escaped = False
            elif c == '\\': escaped = True
            elif c == '"': quote = False
        elif c == '"': quote = True
        elif c == '[': depth += 1
        elif c == ']':
            depth -= 1
            if depth == 0: return source[start:index+1]
    raise AssertionError(f'{name} not closed')

def entries(name):
    text = block(name)
    return [line for line in text.splitlines() if line.startswith('\t{') or line.startswith('\t[')]

levels = [int(x) for x in re.findall(r'\d+', block('REGION_LEVELS'))]
assert len(levels) == 13 and min(levels) == 1 and max(levels) == 40
assert len(entries('ENEMY_TYPES')) == 27
assert len(entries('QUESTS')) == 25
assert len(entries('LANDMARKS')) == 11
assert not re.search(r'\[[^\n]*\bfor\b[^\n]*\bin\b', source), 'GDScript does not support list comprehensions'
assert 'var coins: int = randi_range' in source, 'coin drop needs an explicit type'
dungeon_minimap = source.split('func draw_dungeon_minimap(', 1)[1].split('func draw_portal(', 1)[0]
assert 'circle_center' not in dungeon_minimap and 'circle_radius' not in dungeon_minimap, 'minimap references an outer function variable'
assert [int(x) for x in re.findall(r'\d+', block('DUNGEON_ENTRANCES'))] == [2, 3, 8]
assert len(re.findall(r'\"[^\"]+\"', block('DUNGEON_NAMES'))) == 3
assert re.findall(r'\[(\d+), (\d+)\]', block('DUNGEON_ENEMIES')) == [('4', '5'), ('6', '7'), ('21', '22')]
assert len(entries('PORTALS')) == 5
assert len(re.findall(r'Vector2\(', block('WAYSTONES'))) == 12
assert len(entries('ABILITIES')) == 34
for connection in ['func enter_dungeon', 'func leave_dungeon', 'func dungeon_blocked', 'func draw_dungeon_world', 'func draw_dungeon_atmosphere', 'func draw_overworld_atmosphere', 'func draw_dungeon_minimap', 'func open_dungeon_chest', '"dungeon_chests_opened":dungeon_chests_opened']:
    assert connection in source, f'missing dungeon feature: {connection}'
# The dense fog must be rendered before the player and HUD.
assert source.index('if dungeon_id >= 0: draw_dungeon_atmosphere()') < source.index('\tdraw_player()\n\tfor e in effects:')
# Every quest target resolves to an enemy, and its giver exists in the village.
quest_targets = [int(x) for x in re.findall(r'"target":(\d+)', block('QUESTS'))]
assert len(quest_targets) == 25 and all(0 <= x < 27 for x in quest_targets)
quest_npcs = set(re.findall(r'"npc":"([^"]+)"', block('QUESTS')))
assert quest_npcs == {'Mira', 'Borin', 'Liora'}
# The five arches lead from existing areas into separate level-gated stripes.
portals = entries('PORTALS')
for index, row in enumerate(portals):
    coords = [(int(x), int(y)) for x, y in re.findall(r'Vector2\((\d+),\s*(\d+)\)', row)]
    assert len(coords) == 2
    assert 11000 < coords[1][0] < 16000
    assert index * 1920 < coords[1][1] < (index + 1) * 1920
    assert int(re.search(r',\s*(\d+)\s*\]', row).group(1)) == index + 8
# Contents, navigation, UI and save state must be connected to usable calls.
for token in [
    'pending_class = candidate', 'class_id = pending_class',
    'reset_class_skills()', 'slots = [-1, -1, -1]',
    'use_ability(event.keycode - KEY_1)', 'func explode_fireball',
    'func update_impact_zones', 'impact_zones.append',
    'func draw_local_minimap', 'func click_travel',
    'waystone_unlocked[i] = true', 'shop_timer >= 420.0',
    'func draw_item_tooltip', 'draw_item_signature',
    'func quest_marker_state', 'func draw_rescue_alert',
    '"class_id":class_id', '"quests":quests',
]:
    assert token in source, f'missing feature connection: {token}'
for index in (0, 16, 25):
    assert re.search(rf'\{{"name":"[^"]+"[^\n]+"req":3, "kind":{index}\}}', source)
for index in (1, 17, 26):
    assert re.search(rf'\{{"name":"[^"]+"[^\n]+"req":8, "kind":{index}\}}', source)
for index in (2, 18, 27):
    assert re.search(rf'\{{"name":"[^"]+"[^\n]+"req":12, "kind":{index}\}}', source)
for index in (15, 24, 33):
    assert re.search(rf'\{{"name":"[^"]+"[^\n]+"req":20, "kind":{index}\}}', source)
assert 'slots = [-1, -1, -1]' in source
assert '"waystone_unlocked":waystone_unlocked' in source
assert '"shop_stock":shop_stock' in source
assert '"discovered_regions":discovered_regions' in source
# In Godot werden Ausdrücke mit Variant-Index nicht zuverlässig über := inferiert.
for declaration in ['weapon_name: String', 'weapon_word: String', 'y: float = float(border)', 'next_y: float = float(border)', 'cloth: Color', 'trim: Color', 'tint: Color', 'roof: Vector2']:
    assert declaration in source, f'editor parser type missing: {declaration}'
assert 'func equipped_weapon_stage() -> int:' in source
assert 'func weapon_visual_stage(item: Dictionary) -> int:' in source
assert 'weapon_visual_stage(item), item_design(item))' in source
for connection in ['func draw_world_atlas', 'func draw_atlas_tree', 'var radius := 1500.0', 'func normal_attack_power', 'func healing_cost', 'func visit_healer', 'func shop_preview_item', 'pending_purchase_item', 'func stack_limit', 'func add_item', 'func item_sale_value', 'CREATIVE_SAVE_PATH', 'func set_creative_level', '"MANA" if class_id == 1']:
    assert connection in source, f'missing update: {connection}'
for connection in ['func draw_volume_slider', 'func set_volume_from_mouse', '"music_volume":music_volume', '"effects_volume":effects_volume', 'func finish_intro', 'func draw_intro_panel', 'func draw_event_scene', 'func interact_world_event', '"event_progress":event_progress', 'func skill_rank_level', 'func item_design', 'func equipped_item_design']:
    assert connection in source, f'missing v20 feature: {connection}'
# Godot reports undeclared point/echo when the teleport arc escapes its loop;
# dynamic array indexing also requires an explicit Color type in this block.
teleport = source.split('\t\t19, 27:', 1)[1].split('\t\t20:', 1)[0]
assert '\t\t\t\tdraw_arc(point, 18 + echo * 4' in teleport
assert 'var hue: Color = [Color("a9eafa")' in source
for declaration in ['var edge: Vector2', 'var rut: Vector2', 'var cobble: Vector2']:
    assert declaration in source
assert '"name":"Elara"' in source
assert 'const MUSIC_FADE_SECONDS := 1.35' in source
assert 'music_incoming.volume_db' in source and 'music_player.volume_db' in source
assert 'AudioStreamOggVorbis: stream.loop = true' in source
assert '"res://music/%s.ogg" % desired' in source
for theme in ['dorf', 'blumen', 'kueste', 'pilzwald', 'ruinen', 'kristall', 'asche', 'sternen']:
    original = root / 'music' / 'source' / f'{theme}.mid'
    rendered = root / 'music' / f'{theme}.ogg'
    assert original.read_bytes()[:4] == b'MThd', f'invalid MIDI: {theme}'
    assert rendered.read_bytes()[:4] == b'OggS' and rendered.stat().st_size > 100_000, f'invalid OGG: {theme}'
    if shutil.which('ffprobe'):
        duration = float(subprocess.check_output(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', str(rendered)], text=True))
        assert 299 <= duration <= 302, f'truncated OGG: {theme} ({duration:.1f}s)'
sfx = re.findall(r'"([^"]+)"', block('SFX_NAMES'))
for name in sfx + ['dorf', 'blumen', 'pilzwald', 'ruinen', 'kristall', 'asche', 'kueste', 'sternen', 'nebel', 'bernstein', 'quelle', 'daemmer', 'himmel', 'boss']:
    path = root / 'audio' / f'{name}.wav'
    assert path.exists(), f'missing audio: {path.name}'
    with wave.open(str(path)) as wav:
        assert wav.getnframes() > 100 and wav.getframerate() > 8000, f'invalid audio: {name}'
print('OK: 10 feature areas, 13 regions, 5 connected portals, 27 enemy types, 25 quests, 34 skills, 12 stones, 3 dungeons and all audio')
