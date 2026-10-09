extends SceneTree
const Map=preload("res://components/waystone_map.gd")
const Interiors=preload("res://components/village_interiors_32.gd")
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
func _initialize()->void:call_deferred("run")
func run()->void:
	var g:=Game.new();g.skill_levels.resize(44);g.skill_levels.fill(0);g.panel="";g.hp=100
	g.waystone_unlocked.resize(g.WAYSTONES.size());g.waystone_unlocked.fill(false)
	g.player_pos=g.WAYSTONES[0]+Vector2(100,0);var start:=g.player_pos
	g.use_waystone();assert(g.panel=="map" and g.travel_map and g.player_pos==start,"spawn opens map without teleport")
	g.click_map(Map.point(g,1));assert(g.player_pos==start,"inactive stone cannot travel")
	g.waystone_unlocked[1]=true
	g.click_map(Map.plaque(g,1).get_center())
	assert(g.panel=="" and g.player_pos.distance_to(g.waystone_arrival(1))<1 and g.teleport_serial==1)
	assert(g.valid_network_teleport(start,g.player_pos,{"hp":100},"world"),"server accepts map travel")
	var outside:=g.WAYSTONES[2]+Vector2(100,0);g.player_pos=outside
	g.use_waystone();assert(g.panel=="map" and g.player_pos==outside and g.waystone_unlocked[2],"outside stone activates and opens map")
	g.click_map(Map.point(g,0));assert(g.region_at(g.player_pos)==0 and g.panel=="","map return to village")
	g.player_pos=g.WAYSTONES[0]+Vector2(100,0);g.use_waystone();g.waystone_unlocked[4]=true
	g.click_map(Map.plaque(g,4).get_center());assert(g.region_at(g.player_pos)==0,"boss seal remains enforced")
	g.bosses_defeated[0]=true;g.click_map(Map.plaque(g,4).get_center());assert(g.region_at(g.player_pos)==4)
	g.player_pos=Vector2(3000,2500);g.travel_map=true;g.panel="map"
	assert(not g.travel_to_waystone(0),"cannot travel away from a source")
	g.travel_map=false;var position:=g.player_pos;g.click_map(Map.point(g,0));assert(g.player_pos==position,"ordinary M map is read-only")
	g.player_pos=g.WAYSTONES[0]+Vector2(100,0);g.use_waystone()
	for i in g.WAYSTONES.size():assert(Map.destination(g,Map.point(g,i))==i,"marker click geometry")
	# Enlarged chapel: both directions in both side aisles clear normal and larger bodies.
	var id:=Interiors.ELARA_ID
	assert(Interiors.room_size(id).x>1000 and Interiors.room_size(id).y>600)
	for side in [-1,1]:
		for radius in [g.hero_collision_radius(),18.0]:
			for direction in [-1,1]:
				for step in 49:
					var y:float=lerpf(-42.0,178.0,float(step)/48.0) if direction>0 else lerpf(178.0,-42.0,float(step)/48.0)
					assert(not Interiors.blocked(g.INTERIOR_CENTER+Vector2(side*66.0,y),g.INTERIOR_CENTER,id,radius),"both chapel aisles allow travel both directions")
	assert(not Interiors.blocked(g.INTERIOR_CENTER+Interiors.exit_offset(id)-Vector2(0,40),g.INTERIOR_CENTER,id,g.hero_collision_radius()),"chapel entry remains clear")
	for direction in [-1,1]:
		for step in 81:
			var x:float=lerpf(-270.0,270.0,float(step)/80.0)*direction
			assert(not Interiors.blocked(g.INTERIOR_CENTER+Vector2(x,-50),g.INTERIOR_CENTER,id,18),"front aisle crosses between altar and benches in both directions")
	g.free();print("WAYSTONE_MAP_OK spawn + outside map / activation / label + marker clicks / return / seals / source check / accepted teleport / enlarged chapel aisles both ways")
	quit()
