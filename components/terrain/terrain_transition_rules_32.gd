extends RefCounted
## Rows in map0_transitions_32.svg. Each row has A<-B edges x=0..3 and B<-A edges x=4..7.
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

static func coord(current:String,neighbor:String,direction:int)->Vector2i:
	for row in PAIRS.size():
		var pair:Array=PAIRS[row]
		if current==pair[0] and neighbor==pair[1]:return Vector2i(direction,row)
		if current==pair[1] and neighbor==pair[0]:return Vector2i(4+direction,row)
	return Vector2i(-1,-1)
