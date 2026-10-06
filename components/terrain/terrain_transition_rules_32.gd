extends RefCounted
## 256 transition slots: eight supported material pairs, both directions, four edge directions and four local variants.
const PAIRS:=[
	["village_grass","village_path"],
	["village_grass","village_stone"],
	["village_path","village_stone"],
	["building_apron","village_path"],
	["arena_ground","arena_entry_stone"],
	["arena_entry_stone","village_stone"],
	["village_grass","old_cobble_rework"],
	["garden_path","village_path"]
]

static func edge_variant(current:String,neighbor:String,cell:Vector2i)->int:
	return posmod(cell.x*92821+cell.y*68917+current.hash()*31+neighbor.hash()*17,4)

static func coord(current:String,neighbor:String,direction:int,cell:Vector2i)->Vector2i:
	for pair_index in PAIRS.size():
		var pair:Array=PAIRS[pair_index]
		var variant:=edge_variant(current,neighbor,cell)
		if current==pair[0] and neighbor==pair[1]:
			return Vector2i(direction*4+variant,pair_index*2)
		if current==pair[1] and neighbor==pair[0]:
			return Vector2i(direction*4+variant,pair_index*2+1)
	return Vector2i(-1,-1)
