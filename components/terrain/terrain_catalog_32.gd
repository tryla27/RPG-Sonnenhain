extends RefCounted
## Visual terrain families for Map 0. Logical terrain remains owned by map0_ground_plan_32.gd.
const TILE:=32
const GROUND_ATLAS:="res://art/terrain/gba_v1/ground_32.png"
const LEGACY_GROUND_ATLAS:="res://art/terrain/map0_ground_32.svg"
const GBA_OVERLAY_ATLAS:="res://art/terrain/gba_v1/foliage_32.png"
const OVERLAY_ATLAS:="res://art/terrain/map0_overlays_32.svg"
const TRANSITION_ATLAS:="res://art/terrain/map0_transitions_32.svg"
const HEIGHT_ATLAS:="res://art/terrain/map0_heights_32.svg"

const FAMILY_ORDER:=[
	"village_grass","moss_grass","forest_ground","garden_path",
	"village_path","village_stone","old_cobble_rework","plaza_stone",
	"building_apron","arena_entry_stone","arena_border","arena_ground","spawn_crossing"
]
const FAMILY_ROWS:={
	"village_grass":0,"moss_grass":1,"forest_ground":2,"garden_path":3,
	"village_path":4,"village_stone":5,"old_cobble_rework":6,"plaza_stone":7,
	"building_apron":8,"arena_entry_stone":9,"arena_border":10,"arena_ground":11,"spawn_crossing":12
}
const VARIANTS:=16

static func has(id:String)->bool:
	return FAMILY_ROWS.has(id)

static func atlas_coord(id:String,variant:int)->Vector2i:
	return Vector2i(posmod(variant,VARIANTS),int(FAMILY_ROWS.get(id,0)))

static func coherent_variant(cell:Vector2i)->int:
	# The authored 128px pattern is a coherent 4x4 arrangement, never shuffled.
	return posmod(cell.x,4)+posmod(cell.y,4)*4

static func pixel_coord(id:String,world_pixel:Vector2i)->Vector2i:
	var cell:=Vector2i(floori(world_pixel.x/32.0),floori(world_pixel.y/32.0))
	return atlas_coord(id,coherent_variant(cell))*32+Vector2i(posmod(world_pixel.x,32),posmod(world_pixel.y,32))
