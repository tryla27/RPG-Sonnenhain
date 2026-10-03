extends RefCounted
## Shared 32px material definitions for Sonnenhain's world builder and runtime previews.
const TILE:=32

const MATERIALS:={
	"grass_meadow":{"category":"ground","name":"Wiesengras","colors":["243f32","36563a","547452","708b58","91a869","c0be78"]},
	"grass_moss":{"category":"ground","name":"Moos","colors":["314638","405b42","58754d","738b59","9da36c"]},
	"forest_floor":{"category":"ground","name":"Waldboden","colors":["3d3a2e","554834","715b3d","8b724d","aa9264"]},
	"earth_path":{"category":"ground","name":"Erdweg","colors":["49392c","654936","865e3e","a27851","c0996c"]},
	"village_stone":{"category":"ground","name":"Dorfpflaster","colors":["4a4c48","65675e","818174","a2a08c","c4bea1","ded4b3"]},
	"old_cobble":{"category":"ground","name":"Altes Pflaster","colors":["343b3a","4b5550","667068","838a7c","a4a68f"]},
	"sand_path":{"category":"ground","name":"Heller Weg","colors":["705c40","92744e","b18f62","cfad78","e2c99b"]},
	"dungeon_stone":{"category":"ground","name":"Kalter Dungeonstein","colors":["242936","323847","454c5d","5c6474","7a8190"]},
	"dungeon_moss":{"category":"ground","name":"Moosiger Dungeon","colors":["293631","39483e","4e5a49","67705a","8b9272"]},
	"arcane_floor":{"category":"ground","name":"Arkaner Stein","colors":["28283a","3d4057","545b76","667d91","65bcd0"]},
	"wall_timber":{"category":"wall","name":"Sonnenhain-Fachwerk","colors":["352a25","543b2d","79543a","bdae8f","d7c9a5","e8dab7"]},
	"wall_player_oak":{"category":"wall","name":"Rustikales Spielerhaus","colors":["392a25","443128","67442f","8b6040","4b5053","f0ba68"]},
	"wall_village_stone":{"category":"wall","name":"Dorf-Steinbau","colors":["414744","59605a","747a70","969888","bbb69d"]},
	"wall_ruin":{"category":"wall","name":"Alte Ruinen","colors":["353b39","4a514b","60685c","78806b","556847"]},
	"wall_dungeon":{"category":"wall","name":"Dungeonmauer","colors":["171d27","222836","303747","424b5c","596273"]},
	"wall_arcane":{"category":"wall","name":"Arkane Wand","colors":["303647","484f63","397c9e","52afc2","82d7e2","72518e"]},
}

static func ids(category:String="")->Array:
	var out:Array=[]
	for id in MATERIALS:
		if category=="" or str(MATERIALS[id].get("category",""))==category:out.append(id)
	out.sort()
	return out

static func material(id:String)->Dictionary:
	return MATERIALS.get(id,{})

static func color(id:String,index:int=2)->Color:
	var row:Dictionary=material(id)
	var colors:Array=row.get("colors",["ff00ff"])
	return Color(str(colors[clampi(index,0,colors.size()-1)]))

static func display_name(id:String)->String:
	return str(material(id).get("name",id))

static func category(id:String)->String:
	return str(material(id).get("category",""))

static func transition_pairs()->Array:
	return [
		["grass_meadow","earth_path"],["grass_meadow","village_stone"],
		["grass_meadow","old_cobble"],["earth_path","village_stone"],
		["dungeon_stone","dungeon_moss"],["dungeon_stone","arcane_floor"],
		["forest_floor","earth_path"],["village_stone","wall_village_stone"]
	]
