extends RefCounted
## Reusable semantic ground vocabulary for overworld maps.
## Map-specific scripts decide where these families are used; other maps can reuse the same IDs.
const TILE:=32

const GRASS:="village_grass"
const MOSS:="moss_grass"
const FOREST:="forest_ground"
const PATH:="village_path"
const GARDEN_PATH:="garden_path"
const STONE:="village_stone"
const PLAZA:="plaza_stone"
const APRON:="building_apron"
const ARENA_GROUND:="arena_ground"
const ARENA_ENTRY:="arena_entry_stone"
const ARENA_BORDER:="arena_border"

const NATURAL_FAMILIES:=[GRASS,MOSS,FOREST]
const WALK_FAMILIES:=[PATH,GARDEN_PATH,STONE,PLAZA,APRON,ARENA_GROUND,ARENA_ENTRY,ARENA_BORDER]

static func soft_radius(p:Vector2,center:Vector2,radius:float,cell:Vector2i,feather:float=28.0)->bool:
	var d:=p.distance_to(center)
	if d<=radius-feather:return true
	if d>=radius+feather:return false
	var t:=clampf((radius+feather-d)/(feather*2.0),0.0,1.0)
	var n:=float(posmod(cell.x*92821+cell.y*68917,1000))/999.0
	return n<t

static func edge_noise(cell:Vector2i,amount:int=3)->float:
	return float(posmod(cell.x*97+cell.y*173+cell.x*cell.y*13,amount*2+1)-amount)
