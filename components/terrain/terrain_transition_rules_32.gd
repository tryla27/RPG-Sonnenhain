extends RefCounted
## Reusable transition lookup. Existing atlas rows are reused by semantically compatible floor pairs.
const PAIRS:=[
	["village_grass","village_path",0],
	["village_grass","village_stone",1],
	["village_path","village_stone",2],
	["building_apron","village_path",3],
	["arena_ground","arena_entry_stone",4],
	["arena_entry_stone","village_stone",5],
	["garden_path","village_path",7],
	["plaza_stone","village_path",2],
	["plaza_stone","village_grass",1],
	["building_apron","village_grass",1],
	["village_stone","village_path",2]
]

static func edge_variant(current:String,neighbor:String,cell:Vector2i)->int:
	return posmod(cell.x*92821+cell.y*68917+current.hash()*31+neighbor.hash()*17,4)

static func coord(current:String,neighbor:String,direction:int,cell:Vector2i)->Vector2i:
	for row in PAIRS:
		var variant:=edge_variant(current,neighbor,cell)
		var atlas_pair:int=int(row[2])
		if current==row[0] and neighbor==row[1]:
			return Vector2i(direction*4+variant,atlas_pair*2)
		if current==row[1] and neighbor==row[0]:
			return Vector2i(direction*4+variant,atlas_pair*2+1)
	return Vector2i(-1,-1)
