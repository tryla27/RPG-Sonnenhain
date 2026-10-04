extends RefCounted
## Compatibility tombstone for the removed legacy world.
## The former dedicated world simulation, chunks, interiors and rendering
## were removed on 2026-10-04. This no-op API keeps unrelated save/network code
## loadable while callers are retired incrementally.
const SIZE := Vector2.ZERO
const CENTER := Vector2.ZERO
const ENTRANCE := Vector2(-1000000,-1000000)
const SAFE_RADIUS := 0.0
const BIOMES := [""]
const COLORS := [Color.TRANSPARENT]
const NAMES := []
const LOCATIONS := []
const BUILDING_IDS := []
const PLATEAUS := []
var active := false
var room := -1
var return_position := Vector2.ZERO
var time := 0.0
var capture_progress := 0.0
var capture_id := -1
var score := 0
var kills := 0
var deaths := 0
var slow := 0.0
var shots: Array = []
var impacts: Array = []
var cast_visuals: Array = []
var fighter_stats: Dictionary = {}
var hp_before := 100.0
func load_art()->void: pass
static func biome(_p:Vector2)->int:return 0
static func river_y(_x:float)->float:return 0.0
static func river_distance(_p:Vector2)->float:return INF
static func on_bridge(_p:Vector2,_margin:float=0.0)->bool:return false
static func water(_p:Vector2)->int:return 0
static func height_at(_p:Vector2)->float:return 0.0
static func solid(_p:Vector2,_radius:float=18.0)->bool:return false
static func cover_position(_cell:Vector2i)->Vector2:return Vector2.ZERO
static func cover_allowed(_p:Vector2)->bool:return false
static func blocked(_p:Vector2,_from:Vector2,_interior:int=-1,_radius:float=18.0)->bool:return false
static func safe(_p:Vector2,_interior:int=-1)->bool:return true
static func line_clear(_a:Vector2,_b:Vector2,_interior:int=-1)->bool:return true
func enter(g,_pos:Vector2=Vector2.ZERO,_target_room:int=-1)->void:
	active=false
	if g!=null and g.has_method("message"):g.message("Dieser frühere Bereich wurde entfernt.")
func leave(_g,_to_start:bool=false)->void:active=false
func announce_room(_g,_to_start:bool=false)->void:pass
func register_fighter(peer:int,enabled:bool,target_room:int)->void:
	if enabled: return
	fighter_stats.erase(peer)
func interact(_g)->void:active=false
func active_event(_id:int)->bool:return false
func update(_g,_delta:float)->void:active=false
func peer_position(_g,_peer:int)->Vector2:return Vector2.ZERO
func attack(_g,_id:int=-1)->void:pass
func server_attack(_g,_peer:int,_id:int,_dir:Vector2,_cls:int)->bool:return false
func authority_update(_g,_delta:float)->void:pass
func hurt(_g,_peer:int,_damage:float,_owner:int)->void:pass
func terrain_index(_p:Vector2)->int:return 0
func make_chunk(_key:Vector2i)->Texture2D:return null
func sprite(_g,_tex:Texture2D,_index:int,_p:Vector2,_size:Vector2,_columns:int=4,_rows:int=2)->void:pass
func draw(_g)->void:pass
func draw_outdoors(_g)->void:pass
func append_actors(_g,_entries:Array)->void:pass
func draw_entry(_g,_e:Dictionary)->void:pass
func draw_interior(_g)->void:pass
func draw_map(_g,_rect:Rect2,_compact:bool=false)->void:pass
