extends RefCounted
# Independent world: logical XY is never changed by visual elevation.
const SIZE := Vector2(80000,80000)
const CENTER := Vector2(40000,40000)
const ENTRANCE := Vector2(14800,9120)
const SAFE_RADIUS := 1200.0
const CHUNK := 512
const MAX_CHUNKS := 48
const CHUNK_PRELOAD_MARGIN := 1
const CHUNKS_PER_PRELOAD_TICK := 2
const BIOMES := ["Smaragdforst", "Frostweite", "Blütenmeer", "Kupfersteppe"]
const COLORS := [Color("52703d"),Color("9ebcc5"),Color("829b50"),Color("b59455")]
const NAMES := ["Runenlichtung","Karawanenlager","Jagdloge","Geisterhain","Kristallbruch","Sturmwarte","Frostschrein","Auftauendes Siegel","Sonnenaltar","Wildgarten","Botanisches Haus","Festlichtung","Relaisstation","Sternenkrater","Werkstatt","Kupferlager"]
const LOCATIONS := [Vector2(24000,23000),Vector2(11000,29000),Vector2(18000,14000),Vector2(31000,15000),Vector2(57000,19000),Vector2(70000,29000),Vector2(64000,13000),Vector2(46000,23000),Vector2(21000,59000),Vector2(10000,71000),Vector2(18000,66000),Vector2(31000,70000),Vector2(58000,64000),Vector2(71000,74000),Vector2(66000,58000),Vector2(46000,62000)]
const BUILDING_IDS := [2,6,10,14]
const BRIDGE_X := [10000.0,24000.0,35000.0,40000.0,45000.0,56000.0,70000.0]
const PLATEAUS := [Rect2(26000,17000,3600,2400),Rect2(51000,12000,3200,2600),Rect2(24000,64000,3600,2800),Rect2(56000,70000,4000,2400)]
var tiles: Array[Image] = []
var terrain_texture: Texture2D
var props: Texture2D
var buildings: Texture2D
var events: Texture2D
var cliffs: Texture2D
var bridge: Texture2D
var chunks: Dictionary = {}
var chunk_order: Array[Vector2i] = []
var sprite_regions: Dictionary = {}
var last_preload_center := Vector2i(2147483647,2147483647)
var chunk_preload_queue: Array[Vector2i] = []
var active := false
var room := -1
var outdoor_position := CENTER
var return_position := ENTRANCE
var time := 0.0
var capture_progress := 0.0
var capture_id := -1
var score := 0
var kills := 0
var deaths := 0
var slow := 0.0
var shots: Array = []
var impacts: Array = []
var visuals: Array = []
var cast_visuals: Array = []
var fighter_stats: Dictionary = {}
var server_actions: Dictionary = {}
var hp_before := 100.0
var energy_before := 100.0
var authority_time := 0.0

func load_art() -> void:
	if terrain_texture != null: return
	terrain_texture = load("res://art/konflux/terrain.webp")
	props = load("res://art/konflux/props.webp")
	buildings = load("res://art/konflux/buildings.webp")
	events = load("res://art/konflux/events.webp")
	cliffs = load("res://art/konflux/cliffs.webp")
	bridge = load("res://art/konflux/bridge.webp")
	var atlas := terrain_texture.get_image()
	atlas.convert(Image.FORMAT_RGBA8)
	for i in 14:
		tiles.append(atlas.get_region(Rect2i((i%4)*128,(i/4)*128,128,128)))

static func biome(p: Vector2) -> int:
	return (1 if p.x >= CENTER.x else 0)+(2 if p.y >= CENTER.y else 0)

static func river_y(x: float) -> float:
	return 35000.0+x*0.10+sin(x/10000.0)*2600.0

static func river_distance(p: Vector2) -> float:
	# The river splits around the central safe island, then rejoins downstream.
	var island_factor := maxf(0.0,1.0-absf(p.x-CENTER.x)/5200.0)
	var branch := island_factor*4200.0
	var y := river_y(p.x)
	return minf(absf(p.y-y-branch),absf(p.y-y+branch))

static func on_bridge(p: Vector2, margin: float=0.0) -> bool:
	for x in BRIDGE_X:
		if absf(p.x-x)<180.0-margin and river_distance(p)<1600.0+margin: return true
	return false

static func water(p: Vector2) -> int:
	if p.distance_to(CENTER)<2600.0: return 0
	if on_bridge(p): return 0
	var d := river_distance(p)
	return 2 if d<1100.0 else (1 if d<1500.0 else 0)

static func height_at(p: Vector2) -> float:
	for i in PLATEAUS.size():
		var r: Rect2 = PLATEAUS[i]
		var h: float = [48.0,96.0,48.0,144.0][i]
		if r.has_point(p): return h
		# Broad south ramp; exactly the same rectangle drives art and movement.
		var ramp := Rect2(r.get_center().x-320,r.end.y,640,768)
		if ramp.has_point(p): return h*(1.0-(p.y-r.end.y)/768.0)
	return 0.0

static func solid(p: Vector2, radius: float=18.0) -> bool:
	for id in BUILDING_IDS:
		var base: Vector2 = LOCATIONS[id]
		if Rect2(base+Vector2(-144,-92),Vector2(288,96)).grow(radius).has_point(p): return true
	for id in LOCATIONS.size():
		if id in BUILDING_IDS: continue
		if p.distance_to(LOCATIONS[id])<40.0+radius: return true
	# Sparse cover away from event arenas and the river.
	var cell := Vector2i(floori(p.x/2048.0),floori(p.y/2048.0))
	for dx in range(-1,2):
		for dy in range(-1,2):
			var cp := cover_position(cell+Vector2i(dx,dy))
			if cover_allowed(cp) and p.distance_to(cp)<22.0+radius: return true
	return false

static func cover_position(cell: Vector2i) -> Vector2:
	var code := posmod(cell.x*73856093 ^ cell.y*19349663,104729)
	return Vector2(cell)*2048.0+Vector2(240+code%1500,240+(code*17)%1500)

static func cover_allowed(p: Vector2) -> bool:
	if p.distance_to(CENTER)<3000 or river_distance(p)<2200 or height_at(p)>0: return false
	for x in BRIDGE_X:
		if absf(p.x-x)<300 and river_distance(p)<8000: return false
	for loc in LOCATIONS:
		if p.distance_to(loc)<750: return false
	return true

static func interior_furniture_rect(interior: int, radius: float=0.0) -> Rect2:
	var furniture: Array = [Rect2(-85,-180,150,110),Rect2(-70,-195,140,140),Rect2(-85,-150,160,100),Rect2(0,-300,150,150)]
	if interior<0 or interior>=furniture.size(): return Rect2()
	var body: Rect2=furniture[interior]
	return Rect2(CENTER+body.position,body.size).grow(radius)

static func blocked(p: Vector2, from: Vector2, interior: int=-1, radius: float=18.0) -> bool:
	if interior>=0:
		if not Rect2(CENTER+Vector2(-230,-360),Vector2(460,590)).grow(-radius).has_point(p): return true
		return interior_furniture_rect(interior,radius).has_point(p)
	if not Rect2(Vector2(32,32),SIZE-Vector2(64,64)).grow(-radius).has_point(p): return true
	# Sample actor footprint, preventing edge clipping on bridges and water.
	for offset in [Vector2.ZERO,Vector2(radius,0),Vector2(-radius,0),Vector2(0,radius),Vector2(0,-radius)]:
		if water(p+offset)==2: return true
	if solid(p,radius): return true
	if absf(height_at(p)-height_at(from))>3.5: return true
	return false

static func safe(p: Vector2, interior: int=-1) -> bool:
	return interior<0 and p.distance_to(CENTER)<=SAFE_RADIUS

static func line_clear(a: Vector2,b: Vector2,interior: int=-1) -> bool:
	var steps := maxi(1,ceili(a.distance_to(b)/12.0))
	if interior>=0:
		var furniture := interior_furniture_rect(interior,4.0)
		for i in range(1,steps):
			var p := a.lerp(b,float(i)/steps)
			if furniture.has_point(p): return false
		return true
	var base_h := height_at(a)
	for i in range(steps+1):
		var p := a.lerp(b,float(i)/steps)
		if safe(p) or solid(p,4.0) or height_at(p)>base_h+20.0: return false
	return absf(height_at(b)-base_h)<22.0

func enter(g, pos: Vector2=CENTER, target_room: int=-1) -> void:
	var first_entry:=not active
	if first_entry:
		return_position = g.player_pos
		hp_before = g.hp
		energy_before = g.energy
		active = true
		g.enemies.clear()
		g.enemy_projectiles.clear()
		g.projectiles.clear()
		g.effects.clear()
		g.battle_zones.clear()
		g.impact_zones.clear()
		g.poison_clouds.clear()
		g.spell_visuals.clear()
		g.lightning_lines.clear()
		g.drops.clear()
		g.arena_mode = ""
		g.interior_id = -1
		g.dungeon_id = -1
	room = target_room
	g.player_pos = pos
	if first_entry:
		g.hp = g.max_hp()
		g.energy = g.max_energy()
	g.panel = ""
	g.camera_smooth = pos-Vector2(0,height_at(pos) if room<0 else 0)-g.VIEW*0.5
	g.camera_pos = g.camera_smooth.round()
	g.message("KONFLUX · Schutz im Zentrum. E: Gebäude / Tor · M: Karte")
	load_art()
	if room<0: preload_camera_chunks(g,true)
	announce_room(g)

func leave(g, to_start: bool = false) -> void:
	active = false
	room = -1
	shots.clear()
	impacts.clear()
	g.player_pos = g.WAYSTONES[0]+Vector2(0,105) if to_start else return_position
	g.hp = minf(g.max_hp(),maxf(1.0,hp_before))
	g.energy = minf(g.max_energy(),energy_before)
	g.panel = ""
	g.camera_smooth = g.player_pos-g.VIEW*0.5
	g.camera_pos = g.camera_smooth
	announce_room(g, to_start)
	g.save_game()

func announce_room(g, to_start: bool = false) -> void:
	if g.network_mode=="client": g.rpc_konflux_room.rpc_id(1,active,room,to_start)
	elif g.network_mode=="host":
		if active and fighter_stats.has(1): fighter_stats[1]["room"]=room
		else: register_fighter(1,active,room)

func register_fighter(peer: int, enabled: bool, target_room: int) -> void:
	if not enabled:
		fighter_stats.erase(peer)
		return
	fighter_stats[peer] = {"hp":100.0,"room":target_room,"respawn":0.0,"shield":0.0,"rage":0.0,"poison":0.0,"slow":0.0,"score":0,"dead":false,"dot":0.0,"dot_tick":1.0,"dot_owner":0,"drain":0.0,"dodge":0.0,"dodge_cd":0.0}
	fighter_stats[peer]["capture"]=-1
	fighter_stats[peer]["capture_time"]=0.0

func interact(g) -> void:
	if room>=0:
		if g.player_pos.distance_to(CENTER+Vector2(0,215))<110:
			enter(g,outdoor_position, -1)
		return
	if g.player_pos.distance_to(CENTER)<185:
		leave(g, true)
		return
	if g.player_pos.distance_to(CENTER+Vector2(0,360))<160:
		leave(g)
		return
	for i in BUILDING_IDS.size():
		var id: int = BUILDING_IDS[i]
		if g.player_pos.distance_to(LOCATIONS[id]+Vector2(0,50))<140:
			outdoor_position = LOCATIONS[id]+Vector2(0,110)
			enter(g,CENTER+Vector2(0,190),i)
			return
	for i in LOCATIONS.size():
		if i in BUILDING_IDS: continue
		if g.player_pos.distance_to(LOCATIONS[i])<250:
			if active_event(i):
				capture_id=i
				capture_progress=0.0
				if g.network_mode=="client": g.rpc_konflux_capture.rpc_id(1,i)
				elif fighter_stats.has(1):
					fighter_stats[1]["capture"]=i
					fighter_stats[1]["capture_time"]=0.0
				g.message("Runenpunkt halten: 10 Sekunden ohne Treffer")
			else: g.message("Dieser Event-Ort ruht. Drei andere sind derzeit aktiv.")
			return

func active_event(id: int) -> bool:
	var cycle := int(time/120.0)
	var eligible: Array=[0,1,3,4,5,7,8,9,11,12,13,15]
	return id==eligible[posmod(cycle*3,12)] or id==eligible[posmod(cycle*3+4,12)] or id==eligible[posmod(cycle*3+8,12)]

func update(g,delta: float) -> void:
	time += delta
	g.world_time += delta
	g.update_music(delta)
	if g.is_web_platform() and g.network_mode!="host" and not g.konflux_preview_mode:
		g.live_reconnect_timer-=delta
		if g.live_reconnect_timer<=0:
			g.live_reconnect_timer=3.0
			g.ensure_live_multiplayer()
	for field in ["attack_timer","swing_timer","dash_timer","dash_cooldown","invulnerable","shield_timer","rage_timer","drain_timer","poison_blade_timer","notice_timer","attack_anim","step_timer","chat_fade"]:
		g.set(field,maxf(0.0,float(g.get(field))-delta))
	for i in g.cooldowns.size(): g.cooldowns[i]=maxf(0.0,float(g.cooldowns[i])-delta)
	if g.panel=="" and not g.chat_open:
		g.energy=minf(g.max_energy(),g.energy+5.0*delta)
		g.update_player(delta)
		if capture_id>=0:
			if g.player_pos.distance_to(LOCATIONS[capture_id])>260 or g.invulnerable>0 or not active_event(capture_id):
				capture_id=-1
			else:
				capture_progress+=delta
				capture_progress=minf(capture_progress,10.0)
	# Offline and hosted arena use the same combat simulation as the server.
	if g.network_mode!="client": authority_update(g,delta)
	else:
		for shot in shots: shot["pos"]+=shot["dir"]*float(shot["speed"])*delta
	for i in range(visuals.size()-1,-1,-1):
		visuals[i]["life"]-=delta
		if visuals[i]["life"]<=0: visuals.remove_at(i)
	for i in range(g.effects.size()-1,-1,-1):
		g.effects[i]["life"]-=delta
		if g.effects[i]["life"]<=0: g.effects.remove_at(i)
	var target: Vector2=g.player_pos-Vector2(0,height_at(g.player_pos) if room<0 else 0)-g.VIEW*0.5
	if room<0: target=target.clamp(Vector2.ZERO,SIZE-g.VIEW)
	g.camera_smooth=g.camera_smooth.lerp(target,1.0-exp(-14.0*delta))
	g.camera_pos=g.camera_smooth.round()
	g.sync_timer-=delta
	if g.sync_timer<=0:
		g.sync_timer=0.05
		g.push_player_state()
	if room<0: preload_camera_chunks(g)
	g.save_timer+=delta
	if g.save_timer>20:
		g.save_timer=0
		g.save_game()
	g.queue_redraw()

func peer_position(g,peer: int) -> Vector2:
	if peer==1 and not g.dedicated_server_mode: return g.player_pos
	return g.network_player_position(peer)

func attack(g,id: int=-1) -> void:
	if safe(g.player_pos,room):
		g.message("Der Spawnkreis ist geschützt. Kämpfe außerhalb des Rings.")
		return
	if id in [2,19,27]:
		g.move_with_collision(g.facing*(-210.0 if id==27 else 210.0))
		g.invulnerable=0.3
	if g.network_mode=="client":
		g.rpc_konflux_attack.rpc_id(1,id,[g.facing.x,g.facing.y])
	else:
		if not fighter_stats.has(1): register_fighter(1,true,room)
		server_attack(g,1,id,g.facing,g.class_id)
	g.attack_timer=0.52
	g.swing_timer=0.24
	g.swing_duration=0.24
	g.attack_anim=0.24
	g.play_sound("swing" if id<0 else "skill_%d" % id)
	if id>=0:
		visuals.append({"kind":id,"pos":g.player_pos,"end":g.player_pos,"dir":g.facing,"rank":1,"life":0.65,"max":0.65,"room":room})

func server_attack(g,peer: int,id: int,dir: Vector2,cls: int) -> bool:
	if not fighter_stats.has(peer) or not dir.is_finite() or dir.length_squared()<0.01: return false
	var stats: Dictionary=fighter_stats[peer]
	var pr: int=stats["room"]
	var pos := peer_position(g,peer)
	if safe(pos,pr) or stats["dead"]: return false
	var key := "%d:%d" % [peer,id]
	var cooldown := 0.52 if id<0 else float(g.ABILITIES[id]["cd"])
	if authority_time<float(server_actions.get(key,-100.0))+cooldown: return false
	server_actions[key]=authority_time
	dir=dir.normalized()
	if id in [2,19,27]:
		stats["dodge"]=0.3
		if peer!=1 or g.dedicated_server_mode:
			var distance:=210.0*(-1.0 if id==27 else 1.0)
			for step in 18:
				var target:=pos+dir*distance/18.0
				if blocked(target,pos,pr): break
				pos=target
			g.remote_players[peer]["pos"]=[pos.x,pos.y]
			g.rpc_konflux_correct.rpc_id(peer,[pos.x,pos.y])
	var damage := (18.0 if id<0 else 25.0)*(1.3 if stats["rage"]>0 else 1.0)
	if id>=0: cast_visuals.append({"kind":id,"pos":pos,"end":pos,"dir":dir,"owner":peer,"room":pr,"rank":1,"life":0.65,"max":0.65})
	if id==15: stats["shield"]=5.0
	if id in [1,8,21]:
		stats["shield"]=5.0
		if id==8: stats["hp"]=minf(100.0,float(stats["hp"])+25.0)
		return true
	if id in [4,32]:
		stats["rage"]=7.0
		return true
	if id in [6,14]:
		stats["drain" if id==6 else "poison"]=8.0
		return true
	if id in [19,27]: return true
	var area := id in [0,2,5,12,13,15,17,22,23,24,31,33]
	if area:
		var center := pos+dir*(220.0 if id in [22,31,33] else 0.0)
		impacts.append({"pos":center,"origin":pos,"owner":peer,"room":pr,"height":height_at(pos) if pr<0 else 0.0,"delay":0.45 if id in [22,31,33] else 0.0,"radius":180.0 if id not in [15,24,33] else 270.0,"damage":damage,"id":id})
	else:
		var count := 3 if id in [7,20,26] else 1
		for i in count:
			shots.append({"pos":pos,"origin":pos,"dir":dir.rotated((i-(count-1)*0.5)*0.24),"height":height_at(pos) if pr<0 else 0.0,"owner":peer,"room":pr,"life":1.6,"speed":900.0 if id in [18,25] else 650.0,"damage":damage,"id":id,"kind":3 if cls==2 else 2,"melee":id<0 and cls==0,"hits":[]})
	return true

func authority_update(g,delta: float) -> void:
	authority_time+=delta
	for i in range(cast_visuals.size()-1,-1,-1):
		cast_visuals[i]["life"]-=delta
		if cast_visuals[i]["life"]<=0: cast_visuals.remove_at(i)
	for peer in fighter_stats.keys():
		var stats: Dictionary=fighter_stats[peer]
		for field in ["shield","rage","poison","slow","drain","dot","dodge","dodge_cd"]: stats[field]=maxf(0,float(stats[field])-delta)
		if stats["dead"]:
			stats["respawn"]-=delta
			if stats["respawn"]<=0:
				stats["dead"]=false
				stats["hp"]=100.0
				stats["room"]=-1
				if peer==1 and not g.dedicated_server_mode:
					room=-1
					g.player_pos=CENTER
					g.hp=g.max_hp()
					g.panel=""
				else:
					if g.remote_players.has(peer):
						g.remote_players[peer]["pos"]=[CENTER.x,CENTER.y]
						g.remote_players[peer]["room"]=-1
					g.rpc_konflux_respawn.rpc_id(peer)
			continue
		if safe(peer_position(g,peer),stats["room"]): stats["hp"]=minf(100,float(stats["hp"])+delta*12)
		elif stats["dot"]>0:
			stats["dot_tick"]-=delta
			if stats["dot_tick"]<=0:
				stats["dot_tick"]=1.0
				hurt(g,peer,3.0,stats["dot_owner"])
		var capture: int=int(stats.get("capture",-1))
		if capture>=0:
			if stats["room"]>=0 or peer_position(g,peer).distance_to(LOCATIONS[capture])>260 or not active_event(capture): stats["capture"]=-1
			else:
				stats["capture_time"]+=delta
				if stats["capture_time"]>=10:
					stats["score"]+=1
					stats["capture"]=-1
		if peer==1 and not g.dedicated_server_mode:
			g.hp=g.max_hp()*float(stats["hp"])/100.0
			score=int(stats["score"])
			capture_id=int(stats["capture"])
			slow=float(stats["slow"])
	for i in range(impacts.size()-1,-1,-1):
		var hit: Dictionary=impacts[i]
		hit["delay"]-=delta
		if hit["delay"]>0: continue
		for peer in fighter_stats.keys():
			if peer==hit["owner"] or fighter_stats[peer]["room"]!=hit["room"]: continue
			var target := peer_position(g,peer)
			if target.distance_to(hit["pos"])<hit["radius"] and not safe(target,hit["room"]) and line_clear(hit["origin"],target,hit["room"]):
				hurt(g,peer,hit["damage"],hit["owner"])
				if int(hit["id"]) in [12,17]: fighter_stats[peer]["slow"]=3.0
		impacts.remove_at(i)
	for i in range(shots.size()-1,-1,-1):
		var shot: Dictionary=shots[i]
		shot["life"]-=delta
		var old: Vector2=shot["pos"]
		var length: float=float(shot["speed"])*delta
		if shot["melee"]: length=minf(length,100.0-old.distance_to(shot["origin"]))
		var steps := maxi(1,ceili(length/10.0))
		var remove: bool = shot["life"]<=0 or (shot["melee"] and length<=0)
		for step in steps:
			if remove: break
			shot["pos"]+=shot["dir"]*length/steps
			var p: Vector2=shot["pos"]
			if g.projectile_collision(p-shot["dir"]*length/steps,p,true,"konflux",int(shot["room"]),float(shot["height"]))["hit"]:
				if not bool(shot.get("melee",false)):
					var visual:Vector2=p-Vector2(0,float(shot.get("height",0)))
					g.projectile_break(visual,shot["dir"],int(shot.get("kind",2)),("feuer" if int(shot["id"])==16 else ("eis" if int(shot["id"])==29 else "")),true,"konflux",str(shot["room"]))
				remove=true
				break
			for peer in fighter_stats.keys():
				if peer==shot["owner"] or peer in shot["hits"] or fighter_stats[peer]["room"]!=shot["room"]: continue
				var target := peer_position(g,peer)
				if safe(target,shot["room"]): continue
				if shot["room"]<0 and absf(height_at(target)-float(shot["height"]))>22: continue
				if target.distance_to(p)<28:
					hurt(g,peer,shot["damage"],shot["owner"])
					if int(shot["id"])==28 or (fighter_stats.has(shot["owner"]) and fighter_stats[shot["owner"]]["poison"]>0):
						fighter_stats[peer]["dot"]=5.0
						fighter_stats[peer]["dot_owner"]=shot["owner"]
					if int(shot["id"])==29: fighter_stats[peer]["slow"]=3.0
					shot["hits"].append(peer)
					if shot["id"] not in [18,25]: remove=true
		if remove: shots.remove_at(i)
	if g.network_mode=="host" and int(authority_time*10)!=int((authority_time-delta)*10):
		var rows: Array=[]
		for shot in shots:
			var copy: Dictionary=shot.duplicate()
			copy["pos"]=[shot["pos"].x,shot["pos"].y]
			copy["dir"]=[shot["dir"].x,shot["dir"].y]
			copy.erase("origin")
			rows.append(copy)
		var areas: Array=[]
		for zone in impacts:
			var copy: Dictionary=zone.duplicate()
			copy["pos"]=[zone["pos"].x,zone["pos"].y]
			copy.erase("origin")
			areas.append(copy)
		var casts: Array=[]
		for v in cast_visuals:
			var copy: Dictionary=v.duplicate()
			for key in ["pos","end","dir"]: copy[key]=[v[key].x,v[key].y]
			casts.append(copy)
		g.rpc_konflux_snapshot.rpc(rows,fighter_stats,time,areas,casts)

func hurt(g,peer: int,damage: float,owner: int) -> void:
	var stats: Dictionary=fighter_stats[peer]
	if stats["dead"] or stats["dodge"]>0 or safe(peer_position(g,peer),stats["room"]): return
	stats["hp"]=maxf(0,float(stats["hp"])-damage*(0.35 if stats["shield"]>0 else 1.0))
	stats["capture"]=-1
	if fighter_stats.has(owner) and fighter_stats[owner]["drain"]>0:
		fighter_stats[owner]["hp"]=minf(100.0,float(fighter_stats[owner]["hp"])+damage*0.25)
	if peer==1 and not g.dedicated_server_mode:
		g.hp=g.max_hp()*float(stats["hp"])/100.0
		capture_id=-1
	else: g.rpc_konflux_health.rpc_id(peer,float(stats["hp"]))
	if stats["hp"]<=0:
		stats["dead"]=true
		stats["respawn"]=g.DEATH_DURATION
		if fighter_stats.has(owner): fighter_stats[owner]["score"]+=1
		if peer==1 and not g.dedicated_server_mode:
			g.death_timer=g.DEATH_DURATION
			g.panel="death"
			deaths+=1

func terrain_index(p: Vector2) -> int:
	if p.distance_to(CENTER)<1050: return 6
	if on_bridge(p) and river_distance(p)<1500: return 6
	var w:=water(p)
	if w==2: return 12
	if w==1: return 13
	var b:=biome(p)
	var patch:=posmod(floori(p.x/1024)*17+floori(p.y/1024)*31,23)
	if patch==0: return 4 if b!=3 else 5
	if patch==1 and b==0: return 8
	if patch==2 and b==3: return 10
	if river_distance(p)<1700 and p.distance_to(CENTER)>2600: return 7
	if b==1: return 9
	if b==2: return 1 if posmod(floori(p.x/768)+floori(p.y/768),7)==0 else 2
	if b==3: return 11 if p.x>68000 and p.y>60000 else 3
	return 0

func touch_chunk(key: Vector2i) -> void:
	var index := chunk_order.find(key)
	if index>=0: chunk_order.remove_at(index)
	chunk_order.append(key)

func get_chunk(key: Vector2i) -> Texture2D:
	if chunks.has(key):
		touch_chunk(key)
		return chunks[key]
	return make_chunk(key)

func preload_camera_chunks(g, force: bool=false) -> void:
	var center := Vector2i(floori((g.camera_pos.x+g.VIEW.x*0.5)/CHUNK),floori((g.camera_pos.y+g.VIEW.y*0.5)/CHUNK))
	if force or center!=last_preload_center:
		last_preload_center=center
		chunk_preload_queue.clear()
		var half_x := ceili(g.VIEW.x*0.5/CHUNK)+CHUNK_PRELOAD_MARGIN
		var half_y := ceili(g.VIEW.y*0.5/CHUNK)+CHUNK_PRELOAD_MARGIN
		for y in range(center.y-half_y,center.y+half_y+1):
			for x in range(center.x-half_x,center.x+half_x+1):
				var key:=Vector2i(x,y)
				if x<0 or y<0 or x*CHUNK>=int(SIZE.x) or y*CHUNK>=int(SIZE.y) or chunks.has(key): continue
				chunk_preload_queue.append(key)
		chunk_preload_queue.sort_custom(func(a,b): return a.distance_squared_to(center)<b.distance_squared_to(center))
	var budget:=CHUNKS_PER_PRELOAD_TICK*2 if force else CHUNKS_PER_PRELOAD_TICK
	while budget>0 and not chunk_preload_queue.is_empty():
		var key:=chunk_preload_queue.pop_front()
		if not chunks.has(key): get_chunk(key)
		budget-=1

func make_chunk(key: Vector2i) -> Texture2D:
	var img:=Image.create(CHUNK,CHUNK,false,Image.FORMAT_RGBA8)
	for y in 16:
		for x in 16:
			var p:=Vector2(key)*CHUNK+Vector2(x,y)*32+Vector2(16,16)
			var index:=terrain_index(p)
			if index<14:
				var patch: Image=tiles[index]
				img.blit_rect(patch,Rect2i(posmod(key.x*16+x,4)*32,posmod(key.y*16+y,4)*32,32,32),Vector2i(x,y)*32)
			else:
				img.fill_rect(Rect2i(x*32,y*32,32,32),Color("285b80") if index==12 else Color("5eadae"))
			# Narrow banks and blended biome borders stay deterministic.
			if index<12 and river_distance(p)<1580 and p.distance_to(CENTER)>2600:
				img.fill_rect(Rect2i(x*32,y*32,32,6),Color("b3b18a"))
	var texture:=ImageTexture.create_from_image(img)
	chunks[key]=texture
	touch_chunk(key)
	while chunk_order.size()>MAX_CHUNKS:
		var expired:=chunk_order.pop_front()
		chunks.erase(expired)
	return texture

func sprite(g,tex: Texture2D,index: int,p: Vector2,size: Vector2,columns: int=4,rows: int=2) -> void:
	if tex==null: return
	var source_size:=Vector2(tex.get_size().x/columns,tex.get_size().y/rows)
	var key:=str(tex.get_instance_id())+":"+str(index)
	if not sprite_regions.has(key):
		var source:=Rect2i(Vector2(index%columns,index/columns)*source_size,source_size)
		var used:=tex.get_image().get_region(source).get_used_rect()
		sprite_regions[key]=Rect2(source.position+used.position,used.size)
	g.draw_texture_rect_region(tex,Rect2(p-size*Vector2(0.5,1),size),sprite_regions[key])

func draw(g) -> void:
	load_art()
	g.draw_set_transform(-g.camera_pos)
	g.character_canvas_offset=-g.camera_pos
	if room<0: draw_outdoors(g)
	else: draw_interior(g)
	for v in visuals+cast_visuals:
		if v.get("owner",-1)==1 and g.network_mode=="host": continue
		if int(v["room"])==room:
			var shifted: Dictionary=v.duplicate()
			shifted["pos"]=v["pos"]-Vector2(0,height_at(v["pos"]) if room<0 else 0.0)
			shifted["end"]=v["end"]-Vector2(0,height_at(v["end"]) if room<0 else 0.0)
			g.draw_spell_visual(shifted)
	g.combat_feedback.draw(g)
	for shot in shots:
		if shot["room"]!=room: continue
		var p: Vector2=shot["pos"]-Vector2(0,shot["height"])
		g.draw_line(p-shot["dir"]*28,p,Color("b8ddfa") if int(shot["id"])!=16 else Color("ffaf59"),4)
		var effect:=0 if int(shot["id"])==16 else (1 if int(shot["id"])==29 else (2 if int(shot["id"]) in [18,30] else (3 if int(shot["id"])==28 else (5 if int(shot.get("kind",2))==3 else 4))))
		g.draw_vfx_sprite(effect,p,24)
	for impact in impacts:
		if impact["room"]==room:
			g.draw_arc(impact["pos"]-Vector2(0,impact["height"]),impact["radius"],0,TAU,32,Color("e7b16d"),3)
	g.draw_set_transform(Vector2.ZERO)
	g.character_canvas_offset=Vector2.ZERO
	g.draw_hud()
	g.draw_ref_panel(Rect2(10,118,348,46))
	g.text_at(Vector2(23,138),"KONFLUX · %s" % ("SCHUTZZONE" if safe(g.player_pos,room) else "PvP AKTIV"),13,Color("a5ecdb"))
	g.text_at(Vector2(23,155),"E: Tor / Haus · M: Karte · Punkte %d" % score,13)
	if capture_id>=0: g.bar(Rect2(385,112,330,22),capture_progress,10,Color("d4b46f"),"Runenpunkt halten")
	g.draw_chat_overlay()
	g.draw_online_list()
	if g.panel!="": g.draw_panel()

func draw_outdoors(g) -> void:
	var bounds:=Rect2(g.camera_pos,g.VIEW).grow(220)
	var start:=Vector2i(floori(bounds.position.x/CHUNK),floori(bounds.position.y/CHUNK))
	var finish:=Vector2i(floori(bounds.end.x/CHUNK),floori(bounds.end.y/CHUNK))
	for y in range(start.y,finish.y+1):
		for x in range(start.x,finish.x+1):
			var key:=Vector2i(x,y)
			var tex: Texture2D=get_chunk(key)
			g.draw_texture(tex,Vector2(key)*CHUNK)
	# Bridge rails match their impassable water edges. The center stays clear.
	for x in BRIDGE_X:
		if x<bounds.position.x-200 or x>bounds.end.x+200: continue
		for y in range(floori(bounds.position.y/128)*128,ceili(bounds.end.y/128)*128,128):
			if river_distance(Vector2(x,y))>1520 or Vector2(x,y).distance_to(CENTER)<2600: continue
			for side in [-1,1]:
				var rail:=Vector2(x+side*180,y)
				g.draw_line(rail,rail+Vector2(0,128),Color("73654f"),10)
				g.draw_rect(Rect2(rail-Vector2(12,12),Vector2(24,24)),Color("c6bb90"))
	# Terraces: top, visible southern cliff face and accessible ramp.
	for i in PLATEAUS.size():
		var r: Rect2=PLATEAUS[i]
		if not bounds.intersects(r.grow(800)): continue
		var h: float=[48.0,96.0,48.0,144.0][i]
		var surface:=r.intersection(bounds.grow(h))
		for cy in range(floori(surface.position.y/CHUNK),ceili(surface.end.y/CHUNK)):
			for cx in range(floori(surface.position.x/CHUNK),ceili(surface.end.x/CHUNK)):
				var key:=Vector2i(cx,cy)
				var clip:=Rect2(Vector2(key)*CHUNK,Vector2.ONE*CHUNK).intersection(surface)
				var tex: Texture2D=get_chunk(key)
				g.draw_texture_rect_region(tex,Rect2(clip.position-Vector2(0,h),clip.size),Rect2(clip.position-Vector2(key)*CHUNK,clip.size))
		var face:=Rect2(r.position.x,r.end.y-h,r.size.x,h).intersection(bounds)
		for x in range(floori(face.position.x/256)*256,ceili(face.end.x/256)*256,256):
			var dest:=Rect2(x,r.end.y-h,256,h).intersection(face)
			var style:=1 if i==1 else (2 if i==3 else 0)
			g.draw_texture_rect_region(cliffs,dest,Rect2(style*256+dest.position.x-x,0,dest.size.x,96))
		var ramp:=Rect2(r.get_center().x-320,r.end.y,640,768)
		for y in range(0,768,32):
			var z:=h*(1.0-float(y)/768)
			var material_index: int=[4,6,4,5][i]
			for x in 20:
				var target:=Rect2(ramp.position.x+x*32,ramp.position.y+y-z,32,33+h/24)
				if not target.intersects(bounds): continue
				var source:=Rect2((material_index%4)*128+(x%4)*32,(material_index/4)*128+posmod(y/32,4)*32,32,32)
				g.draw_texture_rect_region(terrain_texture,target,source)
			if i==1: g.draw_line(Vector2(ramp.position.x,ramp.position.y+y-z),Vector2(ramp.end.x,ramp.position.y+y-z),Color("d8e4dd"),2)
		g.draw_line(Vector2(r.position.x,r.position.y-h),Vector2(r.end.x,r.position.y-h),Color("d0cc98"),5)
	var entries: Array=[]
	for id in LOCATIONS.size():
		if bounds.has_point(LOCATIONS[id]): entries.append({"y":LOCATIONS[id].y,"kind":"building" if id in BUILDING_IDS else "event","id":id,"p":LOCATIONS[id]})
	var cs:=Vector2i(floori(bounds.position.x/2048),floori(bounds.position.y/2048))
	var ce:=Vector2i(floori(bounds.end.x/2048),floori(bounds.end.y/2048))
	for y in range(cs.y,ce.y+1):
		for x in range(cs.x,ce.x+1):
			var p:=cover_position(Vector2i(x,y))
			if cover_allowed(p): entries.append({"y":p.y,"kind":"cover","p":p,"id":posmod(x+y*7,8)})
	append_actors(g,entries)
	if bounds.has_point(CENTER): entries.append({"y":CENTER.y-20,"kind":"spawn","p":CENTER})
	if g.player_pos.distance_to(CENTER)<250 and bounds.has_point(CENTER):
		g.text_at(CENTER+Vector2(-180,-130),g.binding_short("interact")+" / "+g.binding_short("waystone")+" · SONNENHAIN-SPAWN",14,Color("fff0c6"),HORIZONTAL_ALIGNMENT_CENTER,360)
	entries.sort_custom(func(a,b): return float(a["y"])<float(b["y"]))
	for entry in entries: draw_entry(g,entry)
	if bounds.intersects(Rect2(CENTER-Vector2.ONE*1300,Vector2.ONE*2600)):
		g.draw_arc(CENTER,SAFE_RADIUS,0,TAU,128,Color("81e6d8",0.8),5)
		for i in 24:
			var p:=CENTER+Vector2.RIGHT.rotated(i*TAU/24)*SAFE_RADIUS
			g.draw_rect(Rect2(p-Vector2(4,4),Vector2(8,8)),Color("ffe1a3"))
	if bounds.has_point(CENTER+Vector2(0,360)):
		g.StartScenery32.gate(g,CENTER+Vector2(0,360),false,g.camera_pos)
		g.text_at(CENTER+Vector2(-150,420),g.binding_short("interact")+" · Zurück nach Himmelsgarten",14,Color("fff0c6"),HORIZONTAL_ALIGNMENT_CENTER,300)

func append_actors(g,entries: Array) -> void:
	entries.append({"y":g.player_pos.y,"p":g.player_pos,"kind":"player"})
	for peer in g.remote_players:
		var state: Dictionary=g.remote_players[peer]
		if not state.get("konflux",false) or int(state.get("room",-1))!=room: continue
		var p: Vector2=g.network_player_position(peer)
		if g.visible_world(p,300): entries.append({"y":p.y,"p":p,"kind":"remote","peer":peer})

func draw_entry(g,e: Dictionary) -> void:
	var p: Vector2=e["p"]
	var h:=height_at(p) if room<0 else 0.0
	var visual:=p-Vector2(0,h)
	match e["kind"]:
		"building":
			var index:=BUILDING_IDS.find(e["id"])
			sprite(g,buildings,index,visual,Vector2(320,400))
			g.text_at(visual+Vector2(-160,30),g.binding_short("interact")+" · "+NAMES[e["id"]],14,Color("fff0c6"),HORIZONTAL_ALIGNMENT_CENTER,320)
		"event":
			var index: int=[0,1,0,5,2,3,0,2,4,5,0,4,6,7,0,1][int(e["id"])]
			sprite(g,events,index,visual,Vector2(210,260))
			if active_event(e["id"]): g.draw_arc(visual,220,0,TAU,48,Color("edcf8f"),4)
			g.text_at(visual+Vector2(-160,35),NAMES[e["id"]],14,Color("fff0c6"),HORIZONTAL_ALIGNMENT_CENTER,320)
		"cover": sprite(g,props,[0,3,1,2][biome(p)],visual,Vector2(180,220),4,3)
		"spawn": g.StartScenery32.waystone(g,visual,true)
		"player":
			g.draw_shadow(visual)
			g.draw_hero(visual,1,g.is_walking,g.facing,true)
			if g.swing_timer>0: g.draw_arc(visual,80,g.facing.angle()-0.8,g.facing.angle()+0.8,12,Color("ffe6b6"),4)
		"remote":
			var state: Dictionary=g.remote_players[e["peer"]]
			var d: Array=state.get("facing",[0,1])
			g.draw_shadow(visual)
			g.draw_character_sprite(visual,int(state.get("class",0)),bool(state.get("walking",false)),Vector2(d[0],d[1]),1,false,int(state.get("race",0)),int(state.get("gender",0)),int(state.get("armor",-1)),float(state.get("death_progress",-1)),clampf((float(state.get("hurt_until",0))-g.combat_feedback.clock)/.18,0,1),int(state.get("head",-1)),int(state.get("rings",0)))
			g.draw_weapon_world(visual+Vector2(0,-5),int(state.get("class",0)),int(state.get("weapon",0)),Vector2(d[0],d[1]),1)
			var stats:Dictionary=fighter_stats.get(e["peer"],{})
			g.combat_feedback.health(g,"konflux:%d"%int(e["peer"]),visual+Vector2(0,-48),float(stats.get("hp",state.get("hp",1))),100.0 if not stats.is_empty() else float(state.get("max_hp",1)),60,Color("79caa3"))
			g.text_at(visual+Vector2(-80,-65),state.get("name","Held"),13,Color("d9f6ff"),HORIZONTAL_ALIGNMENT_CENTER,160)

func draw_interior(g) -> void:
	g.draw_rect(Rect2(g.camera_pos,g.VIEW),Color("101a20"))
	# Sprite interior is scaled to its collision footprint; walls and furniture
	# stay at the perimeter, with the actual door at the bottom center.
	sprite(g,buildings,room+4,CENTER+Vector2(0,280),Vector2(600,760))
	var entries: Array=[]
	append_actors(g,entries)
	entries.sort_custom(func(a,b): return float(a["y"])<float(b["y"]))
	for entry in entries: draw_entry(g,entry)
	g.text_at(CENTER+Vector2(-180,265),"E · Gebäude verlassen",14,Color("fff0c6"),HORIZONTAL_ALIGNMENT_CENTER,360)

func draw_map(g,rect: Rect2,compact: bool=false) -> void:
	var side := minf(rect.size.x, rect.size.y)
	rect = Rect2(rect.get_center()-Vector2.ONE*side*0.5,Vector2.ONE*side)
	g.draw_rect(rect,Color("192d36"))
	var scale:=rect.size/SIZE
	for i in 4:
		g.draw_rect(Rect2(rect.position+Vector2(i%2,i/2)*rect.size*0.5,rect.size*0.5),COLORS[i])
	var last:=Vector2.ZERO
	for x in range(0,80001,1000):
		var p:=Vector2(x,river_y(x))
		var screen:=rect.position+p*scale
		if x>0: g.draw_line(last,screen,Color("427ea1"),maxf(3,2600*scale.y))
		last=screen
	g.draw_circle(rect.position+CENTER*scale,maxf(3,2600*scale.x),Color("91af68"))
	g.draw_arc(rect.position+CENTER*scale,maxf(3,SAFE_RADIUS*scale.x),0,TAU,32,Color("a8f0dc"),2)
	for x in BRIDGE_X:
		var p:=rect.position+Vector2(x,river_y(x))*scale
		g.draw_line(p-Vector2(0,12),p+Vector2(0,12),Color("e9cfa0"),3)
	for id in LOCATIONS.size():
		var p: Vector2=rect.position+LOCATIONS[id]*scale
		g.draw_circle(p,4 if not compact else 2,Color("ffe4ad") if id in BUILDING_IDS else (Color("ffbe67") if active_event(id) else Color("c2b8a3")))
		if not compact: g.text_at(p+Vector2(6,-5),NAMES[id],11)
	for r in PLATEAUS:
		g.draw_rect(Rect2(rect.position+r.position*scale,r.size*scale),Color("e6d697"),false,2)
	g.draw_circle(rect.position+(CENTER if room>=0 else g.player_pos)*scale,5,Color.WHITE)
	if not compact:
		g.text_at(rect.position+Vector2(12,25),"KONFLUX · 80.000 × 80.000 · 32-Pixel-Raster",16,Color("fff0c6"))
		g.text_at(rect.position+Vector2(12,rect.size.y-12),"Cyan: geschützter Spawn · Gold: Gebäude · Orange: aktive Event-Orte · Konturen: Höhen",12)
