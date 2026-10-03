"""Static consistency checks for the generated Godot game content."""
from pathlib import Path
import re
import wave
import shutil
import subprocess

root = Path(__file__).resolve().parents[1]
source = (root / 'main.gd').read_text(encoding='utf8')

# Catch accidental duplicate top-level function declarations before Godot does.
func_names = re.findall(r'^func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(', source, re.M)
duplicates = sorted({name for name in func_names if func_names.count(name) > 1})
assert not duplicates, f'duplicate functions: {duplicates}'

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
assert len(entries('ABILITIES')) == 44
for connection in ['func enter_dungeon', 'func leave_dungeon', 'func dungeon_blocked', 'func draw_dungeon_world', 'func draw_dungeon_atmosphere', 'func draw_overworld_atmosphere', 'func draw_dungeon_minimap', 'func open_dungeon_chest', '"dungeon_chests_opened":dungeon_chests_opened']:
    assert connection in source, f'missing dungeon feature: {connection}'
# The dense fog must be rendered before floating effects and the HUD.
assert source.index('if dungeon_id >= 0: draw_dungeon_atmosphere()') < source.index('\tfor e in effects:')
# Every quest target resolves to an enemy, and its giver exists in the village.
quest_targets = [int(x) for x in re.findall(r'"target":(\d+)', block('QUESTS'))]
assert len(quest_targets) == 25 and all(0 <= x < 27 for x in quest_targets)
quest_npcs = set(re.findall(r'"npc":"([^"]+)"', block('QUESTS')))
assert quest_npcs == {'Mira'}
# The five arches lead from existing areas into separate stripes; level values are recommendations, not access locks.
portals = entries('PORTALS')
for index, row in enumerate(portals):
    coords = [(int(x), int(y)) for x, y in re.findall(r'Vector2\((\d+),\s*(\d+)\)', row)]
    assert len(coords) == 2
    assert 11000 < coords[1][0] < 16000
    assert index * 1920 < coords[1][1] < (index + 1) * 1920
    assert int(re.search(r',\s*(\d+)\s*\]', row).group(1)) == index + 8
# Contents, navigation, UI and save state must be connected to usable calls.
for token in [
    'pending_class=cls', 'class_id = pending_class',
    'reset_class_skills()', 'slots = [-1, -1, -1]',
    'event_matches_binding(event, "ability_%d" % (slot + 1))', 'func explode_fireball',
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
for index in (15, 33):
    assert re.search(rf'\{{"name":"[^"]+"[^\n]+"req":20, "kind":{index}\}}', source)
assert re.search(r'\{"name":"[^"]+"[^\n]+"req":40, "kind":24\}', source), 'mage ultimate must unlock at level 40'
assert 'slots = [-1, -1, -1]' in source
assert '"waystone_unlocked":waystone_unlocked' in source
assert '"shop_stock":shop_stock' in source
assert '"discovered_regions":discovered_regions' in source
# In Godot werden Ausdrücke mit Variant-Index nicht zuverlässig über := inferiert.
for declaration in ['weapon_name: String', 'weapon_word: String', 'tint: Color', 'roof: Vector2']:
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
assert 'func draw_trails() -> void:' in source and 'draw_line(a, b, edge_colors[theme], 116.0, false)' in source
assert '"name":"Elara"' in source
assert 'const MUSIC_FADE_SECONDS := 1.35' in source
assert 'music_incoming.volume_db' in source and 'music_player.volume_db' in source
assert 'AudioStreamOggVorbis: stream.loop = true' in source
assert 'func music_path_for_theme(theme:String)->String:' in source
assert 'return "res://music/%s.ogg" % theme' in source
for boss_theme in ['boss_kriegsherr','boss_arkanhueter','boss_jagdmeister']:
    assert boss_theme in source, f'missing boss music routing: {boss_theme}'
sfx = re.findall(r'"([^"]+)"', block('SFX_NAMES'))
procedural_sfx = {'door_open', 'door_close'}
for name in [n for n in sfx if n not in procedural_sfx] + ['nebel', 'bernstein', 'quelle', 'daemmer', 'himmel', 'boss']:
    path = root / 'audio' / f'{name}.wav'
    assert path.exists(), f'missing audio: {path.name}'
    with wave.open(str(path)) as wav:
        assert wav.getnframes() > 100 and wav.getframerate() > 8000, f'invalid audio: {name}'
assert 'DoorSfx.make(true)' in source and 'DoorSfx.make(false)' in source, 'procedural village door sounds not wired'
atlas = (root / 'art' / 'sonnenhain_tiles.png').read_bytes()
assert atlas[:8] == b'\x89PNG\r\n\x1a\n' and int.from_bytes(atlas[16:20], 'big') == 128 and int.from_bytes(atlas[20:24], 'big') == 64
for connection in ['func draw_pixel_tile', 'func draw_tavern_world', 'func tavern_blocked', 'func draw_village_interior', 'func enter_village_house', 'func leave_village_house', 'func enter_tavern', 'func leave_tavern', 'VillageInteriors32.blocked(pos,INTERIOR_CENTER)', 'interior_return_pos if interior_id >= 0 else player_pos', '"res://art/sonnenhain_tiles.png"']:
    assert connection in source, f'missing pixel-art scene connection: {connection}'
assert source.count('draw_pixel_tile(') > 15
for connection in ['func load_bindings', 'func save_bindings', 'func reset_bindings', 'func draw_controls_panel', 'func movement_vector', 'binding_pressed("attack")', 'binding_short("ability_%d" % (slot + 1))']:
    assert connection in source, f'missing controls connection: {connection}'
assert source.count('Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)') == 1, 'attack still hardwired to mouse button'
for asset, wh in {
    'regions_16.png': (256,112),
    'weapons_32.png': (384,96),
    'weapons_world_32.png': (384,384),
    'characters_32.png': (128,2304),
    'enemies_32.png': (128,864),
    'skills_16.png': (256,48),
    'npcs_32.png': (128,384),
    'vfx_16.png': (64,128),
    'structures_16.png': (128,16),
    'houses_192.png': (768,160),
}.items():
    raw=(root/'art'/asset).read_bytes()
    assert raw[:8] == b'\x89PNG\r\n\x1a\n', f'invalid png: {asset}'
    assert (int.from_bytes(raw[16:20],'big'), int.from_bytes(raw[20:24],'big')) == wh, f'bad atlas size: {asset}'
for connection in ['func draw_region_tile', 'func draw_character_sprite', 'func draw_enemy_sprite', 'func draw_weapon_world', 'func draw_skill_sprite', 'func draw_npc_sprite', 'func draw_vfx_sprite', 'func draw_structure_tile', 'func draw_creation_panel', 'func draw_multiplayer_panel', 'func send_chat_message', 'func host_multiplayer', 'func join_multiplayer_from_code', 'hero_name', 'hero_gender', 'hero_race']:
    assert connection in source, f'missing v27 connection: {connection}'
# Top-level function names must be unique.
funcs = re.findall(r'^func\s+([A-Za-z0-9_]+)\s*\(', source, re.M)
assert len(funcs) == len(set(funcs)), 'duplicate top-level function declaration'
print('OK v27: 13 regions, 27 enemies, 25 quests, 44 abilities, 3 dungeons, character creation, chat, co-op hooks, pixel-art atlases and audio')

# v27.2 mechanics/spawn regression checks
assert 'func draw_mechanics_panel()' in source, 'missing mechanics overview panel'
assert '"mechanics":KEY_H' in source and 'event_matches_binding(event, "mechanics")' in source, 'missing H mechanics shortcut'
assert 'func spawn_position_allowed' in source, 'missing spawn exclusion logic'
assert 'distance_to_trail(p) < 165.0' in source, 'spawn path exclusion missing'
assert 'func server_region_target_mobs' in source and 'const SERVER_WORLD_MOB_CAP := 264' in source, 'regional server mob cap missing'
assert 'if player_count == 1: return 8' in source and 'if player_count == 2: return 12' in source and 'if player_count <= 4: return 16' in source and 'return 22' in source, 'regional multiplayer spawn budgets missing'
assert 'if region == 0: return' in source or 'if target_region == 0: return false' in source, 'safe-zone spawn suppression missing'
assert 'func flee_from_safe_zone' in source, 'safe-zone flee behavior missing'
assert 'const WAYSTONE_SAFE_RADIUS := 220.0' in source and 'WAYSTONE_SPAWN_BLOCK_RADIUS := 285.0' in source, 'waystone protection radii missing'
assert 'food_system.regional_props(self)' in source and 'food_system.bush(self,food_point)' in source, 'regional harvest plants are not wired into world rendering'
assert 'func move_enemy_with_collision' in source, 'collision-safe enemy knockback missing'
assert 'func safe_drop_position' in source, 'collision-safe loot placement missing'
assert 'const CHEST_RESPAWN_SECONDS := 360.0' in source and 'chest_respawn_until' in source and 'dungeon_chest_respawn_until' in source, 'six-minute chest respawn missing'
assert 'func decorative_tree_in_cell' in source and 'Nur Stamm/Wurzel blockieren' in source, 'regional tree trunk collisions missing'
assert 'Dekobuesche tragen absichtlich keine Fruechte' in source, 'decorative bushes still imply fake harvest fruit'
assert 'ENTER oder T' in source, 'chat prompt missing'
# Map 0 village-role / interior regression wiring.
for connection in [
    'const VillageInteriors32 = preload("res://components/village_interiors_32.gd")',
    'const DoorSfx = preload("res://components/door_sfx.gd")',
    'func draw_appearance_panel()',
    'func click_appearance(',
    'FENNA · CHARACTER EDITOR',
    'ELARA (HEILUNG & ALCHEMIE)',
    'func orc_jump_knockback()',
    'func rpc_orc_jump_knockback(',
    'play_sound("door_open")',
    'play_sound("door_close")',
]:
    assert connection in source, f'missing Map 0 village update: {connection}'
village_layout = (root / 'components' / 'village_layout.gd').read_text(encoding='utf8')
for resident in ['Mira','Liora','Arven','Torvald','Fenna','Pip','Elara','Alma','Borin']:
    assert f'"name":"{resident}"' in village_layout, f'missing village house: {resident}'
assert '"name":"Borin","house":Vector2(1248,320)' in village_layout, 'Borin house anchor moved'
assert 'const BORIN_MAGIC_TREE_POS := Vector2(1552,544)' in source, 'Borin magic tree anchor moved'
assert 'const BORIN_CRYSTAL_POS := Vector2(1512,736)' in source, 'Borin fusion crystal anchor moved'

# Map-0 village must remain fully inside the original wall rectangle and keep both
# live gate approach corridors clear. Check actual rendered building footprints,
# not only their anchor points.
village_bounds = (0, 0, 1780, 2600)
gate_corridors = [
    (1536, 920, 244, 400),   # east gate at 1780 / 1120
    (688, 2240, 374, 360),   # south gate at 875 / 2600
]
shop_rows = re.findall(r'\{"name":"([^"]+)","house":Vector2\((\d+),(\d+)\),"kind":"([^"]+)"[^\n]*\}', village_layout)
seen_houses = set()
for name, xs, ys, kind in shop_rows:
    x, y = int(xs), int(ys)
    key = (x, y)
    if key in seen_houses:
        continue
    seen_houses.add(key)
    if kind == 'arena':
        rect = (x - 16, y - 32, 416, 304)
    elif kind == 'borin':
        rect = (x - 16, y - 64, 288, 320)
    else:
        rect = (x - 16, y - 64, 224, 256)
    rx, ry, rw, rh = rect
    assert rx >= village_bounds[0] and ry >= village_bounds[1], f'{name} footprint leaves north/west village wall: {rect}'
    assert rx + rw <= village_bounds[2] and ry + rh <= village_bounds[3], f'{name} footprint leaves east/south village wall: {rect}'
    for gx, gy, gw, gh in gate_corridors:
        overlaps = rx < gx + gw and rx + rw > gx and ry < gy + gh and ry + rh > gy
        assert not overlaps, f'{name} footprint blocks village gate approach: {rect}'

tilemap32 = (root / 'components' / 'start_tilemap_32.gd').read_text(encoding='utf8')
map0_plan = (root / 'components' / 'map0_ground_plan_32.gd').read_text(encoding='utf8')
pads_block = map0_plan.split('const PROPERTY_PADS:=[', 1)[1].split(']', 1)[0]
pads = [(int(x), int(y), int(w), int(h)) for x, y, w, h in re.findall(r'Rect2\((\d+),(\d+),(\d+),(\d+)\)', pads_block)]
assert len(pads) == 7, f'expected 7 village property pads, got {len(pads)}'
for rect in pads:
    rx, ry, rw, rh = rect
    assert rx >= 0 and ry >= 0 and rx + rw <= 1780 and ry + rh <= 2600, f'property pad leaves village walls: {rect}'
    for gx, gy, gw, gh in gate_corridors:
        overlaps = rx < gx + gw and rx + rw > gx and ry < gy + gh and ry + rh > gy
        assert not overlaps, f'property pad blocks village gate approach: {rect}'
assert 'const EAST_GATE:=Vector2(1780,1120)' in map0_plan, 'east village gate moved'
assert 'const SOUTH_GATE:=Vector2(875,2600)' in map0_plan, 'south village gate moved'
assert 'const EAST_EXIT:=Plan.EAST_GATE' in tilemap32 and 'const SOUTH_EXIT:=Plan.SOUTH_GATE' in tilemap32, 'runtime tilemap must use authoritative Map 0 gate plan'


# v27.5 visuals, weapons, roads, daylight, performance, chat, co-op and web preset checks.
world_draw = source.split('func draw_static_overworld(bounds: Rect2) -> void:', 1)[1].split('func ', 1)[0]
assert 'region_ground_color(zone, key, wet)' in world_draw, 'overworld still uses noisy 16px terrain tiles'
assert 'draw_region_tile(zone, key % 8' not in world_draw, 'dense terrain atlas still drawn on every ground cell'
assert 'func weapon_attack_look' in source and 'lerpf(-0.95, 0.82, eased)' in source, 'weapon-specific melee swing missing'
assert 'attack_progress' in source and 'pull = 14.0 * sin' in source, 'bow draw animation missing'
assert 'var rune: Vector2 = center+side*branch*8.0*scale_factor+dir*8.0*scale_factor' in source, 'typed bow inlay vector missing'
assert 'func blocked_by_region_wall' in source and 'absf(across - float(wall["axis"])) > 51.0' in source, 'full-width wall collision missing'
wall_draw = source.split('func draw_gate_wall(', 1)[1].split('func draw_grass(', 1)[0]
assert 'for row in rows:' in wall_draw and 'var stone_len := 44.0' in wall_draw, 'wall texture does not cover full wall face'
assert 'draw_path_tile' not in source and 'paths_32.png' not in source, 'floating road texture atlas still referenced'
assert 'draw_circle(point, 58.0, edge_colors[theme_for_trail])' in source, 'rounded path joins missing'
assert 'func draw_day_night_overlay() -> void:' in source and 'fposmod(world_time, 720.0)' in source, 'day/night cycle missing'
assert 'const MobDesign32=preload("res://components/monster_design_32.gd")' in source and 'MobDesign32.paint(self,' in source, 'shared native eight-direction monster renderer is not used'
assert 'MobCombat.step(enemy,profile,targets,delta)' in source, 'server/offline shared mob combat is not used'
assert (root / 'components' / 'pixel_style_32.gd').exists(), 'shared 32-tile pixel style missing'
enemy_model = source.split('func draw_enemy_model(', 1)[1].split('func draw_crab_model(', 1)[0]
assert '\n\t\t25: #' in enemy_model and '\n\t\t26: #' in enemy_model, 'late-game enemy match cases escaped their block'
for enemy_type in range(17, 27):
    assert f'{enemy_type}: #' in source.split('func draw_enemy_model(', 1)[1].split('func draw_crab_model(', 1)[0], f'dedicated late-game enemy model missing: {enemy_type}'
assert 'var hand_side := base_look.rotated(-PI * 0.5)' in source and 'var arm_start := p + Vector2(signf(hand_offset.x)*18.0,-5.0)' in source, 'weapon arm is not anchored to the facing-side shoulder'
assert 'run/max_fps=60' in (root / 'project.godot').read_text(encoding='utf8'), 'frame cap missing'
sprite_builder = (root / 'tools' / 'build_v27_pixel_art.py').read_text(encoding='utf8')
assert 'if direction==0:' in sprite_builder and 'elif direction==1:' in sprite_builder and 'elif direction==2:' in sprite_builder and 'else:' in sprite_builder, 'directional face animation missing'
assert 'hair_dark' in sprite_builder and 'geschichteten Helm' in sprite_builder, 'female hair or warrior helmet redesign missing'
start_scenery = (root / 'components' / 'start_scenery_32.gd').read_text(encoding='utf8')
house_tiles32 = (root / 'components' / 'village_house_tiles_32.gd').read_text(encoding='utf8')
assert 'houses_192.png' not in source and 'houses_192.png' not in start_scenery, 'legacy full-house atlas is still referenced at runtime'
assert 'objects-faithful.webp' in start_scenery, 'shared scenery atlas unexpectedly removed'
assert 'VillageHouseTiles32.paint(c,p,kind)' in start_scenery and 'VillageHouseTiles32.paint(c,p,"borin")' in start_scenery and 'VillageHouseTiles32.paint(c,p,"arena")' in start_scenery, 'Map 0 houses do not route through native tile renderer'
assert 'const TILE:=32' in house_tiles32 and 'static func normal_house' in house_tiles32 and 'static func borin_house' in house_tiles32 and 'static func arena_building' in house_tiles32, 'native 32px house renderer incomplete'
assert 'var fade_alpha := 1.0 if chat_open else clampf(chat_fade / 1.25, 0.0, 1.0)' in source, 'chat inactivity fade missing'
assert 'func start_coop_world() -> void:' in source and 'WELT STARTEN' in source and 'WELT BEITRETEN' in source, 'co-op world start/join flow missing'
assert 'func is_web_platform() -> bool:' in source and 'OS.has_feature("web")' in source, 'browser networking guard missing'
assert (root / 'export_presets.cfg').exists() and 'platform="Web"' in (root / 'export_presets.cfg').read_text(encoding='utf8'), 'web export preset missing'
assert (root / 'WEB_EXPORT.md').exists(), 'web hosting guide missing'
print('OK v27.5: detailed enemy and player models, fantasy weapons, house atlas, chat fade, co-op world launch, continuous roads, day/night and Web preset')
