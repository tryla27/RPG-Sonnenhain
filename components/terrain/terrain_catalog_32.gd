extends RefCounted
## Production PNG terrain families for Map 0. Logical terrain remains owned by map0_ground_plan_32.gd.
const TILE:=32
const GROUND_ATLAS:="res://art/terrain/sonnenhain/sonnenhain_ground_32.png"
const OVERLAY_ATLAS:="res://art/terrain/sonnenhain/sonnenhain_overlays_32.png"
const TRANSITION_ATLAS:="res://art/terrain/sonnenhain/sonnenhain_transitions_32.png"
const HEIGHT_ATLAS:="res://art/terrain/map0_heights_32.svg"

const FAMILY_ORDER:=[
	"village_grass","moss_grass","forest_ground","garden_path",
	"village_path","village_stone","old_cobble_rework","plaza_stone",
	"building_apron","arena_entry_stone","arena_border","arena_ground"
]
const FAMILY_ROWS:={
	"village_grass":0,"moss_grass":1,"forest_ground":2,"garden_path":3,
	"village_path":4,"village_stone":5,"old_cobble_rework":6,"plaza_stone":7,
	"building_apron":8,"arena_entry_stone":9,"arena_border":10,"arena_ground":11
}
const VARIANTS:=16

static func has(id:String)->bool:
	return FAMILY_ROWS.has(id)

static func atlas_coord(id:String,variant:int)->Vector2i:
	return Vector2i(posmod(variant,VARIANTS),int(FAMILY_ROWS.get(id,0)))
