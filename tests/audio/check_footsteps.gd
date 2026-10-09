extends SceneTree
# Schritte je Untergrund (Schrittprobe 9.10.2026): Jede Stelle bekommt den
# gewählten Klang, und jeder Schrittklang wird tatsächlich abgespielt.

const Bank=preload("res://components/sound_bank.gd")
const Plan=preload("res://components/map0_ground_plan_32.gd")

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("FOOTSTEPS_FAIL "+label)

func _initialize()->void:call_deferred("run")

## Erste Dorfstelle mit dieser sichtbaren Bodenfamilie.
func find_family(g,family:String)->Vector2:
	for x in range(48,1760,32):
		for y in range(48,2580,32):
			var p:=Vector2(x,y)
			if g.SpawnPlatform32.bounds(g.WAYSTONES[0]).grow(-40).has_point(p):continue
			if g.StartTileMap32.visual_family_at(p)==family:return p
	return Vector2.INF

func run()->void:
	var g=load("res://main.gd").new()
	# Jeder Untergrund hat einen Klang mit Dateien.
	for surface in Bank.STEP_SURFACES:
		var sound:String=Bank.STEP_SURFACES[surface]
		check(Bank.CATALOG.has(sound),"Klang für %s fehlt" % surface)
	# Dorf: Wiese, Pflaster, Spawnstein.
	var grass:=find_family(g,"village_grass")
	var stone:=find_family(g,"plaza_stone")
	check(grass!=Vector2.INF and g.ground_surface_at(grass)=="gras","Dorfwiese klingt nach Gras")
	check(stone!=Vector2.INF and g.ground_surface_at(stone)=="pflaster","Dorfplatz klingt nach Pflaster")
	check(g.ground_surface_at(g.WAYSTONES[0]+Vector2(0,60))=="spawnstein","Spawnstein hat eigenen Klang")
	# Draußen: Gebiete und Wege.
	var by_region:={1:"gras",2:"laub",4:"moor",5:"asche",6:"sand",7:"stein"}
	for region in by_region:
		var found:=false
		var rect:Rect2=g.region_rect(region)
		for i in 400:
			var p:=rect.position+Vector2(fmod(i*137.0,rect.size.x),fmod(i*251.0,rect.size.y))
			if g.region_at(p)!=region or g.distance_to_trail(p)<120.0:continue
			check(g.ground_surface_at(p)==by_region[region],"Gebiet %d: %s statt %s" % [region,g.ground_surface_at(p),by_region[region]])
			found=true
			break
		check(found,"Prüfpunkt in Gebiet %d" % region)
	var trail_found:=false
	for i in 3000:
		var p:=Vector2(2000+fmod(i*97.0,6000),300+fmod(i*61.0,7000))
		if g.distance_to_trail(p)<30.0 and not Plan.BOUNDS.has_point(p):
			check(g.ground_surface_at(p)=="erde","Weg klingt nach Erde")
			trail_found=true
			break
	check(trail_found,"Prüfpunkt auf einem Weg")
	# Innen, Kapelle, Gewölbe, Arena.
	g.interior_id=1
	check(g.ground_surface_at(Vector2.ZERO)=="holz","Häuser innen: Holz")
	g.interior_id=g.VillageInteriors32.ELARA_ID
	check(g.ground_surface_at(Vector2.ZERO)=="stein","Kapelle: Stein")
	g.interior_id=-1
	g.dungeon_id=0
	check(g.ground_surface_at(Vector2.ZERO)=="stein","Gewölbe: Stein")
	g.dungeon_id=-1
	g.arena_mode="survival"
	check(g.ground_surface_at(Vector2.ZERO)=="sand","Arena: Sand")
	g.arena_mode=""
	# Abspielen über die Soundbank.
	g.effects_volume=1.0
	g.sound_bank.setup(root,8)
	for surface in Bank.STEP_SURFACES:
		var sound:String=Bank.STEP_SURFACES[surface]
		g.play_sound(sound)
		var playing:=false
		for i in g.sound_bank.players.size():
			if g.sound_bank.voice_info[i]["name"]==sound and g.sound_bank.players[i].playing:playing=true
		check(playing,"%s wird abgespielt" % sound)
		for player in g.sound_bank.players:player.stop()
	for p in g.sound_bank.players:
		p.stop();p.stream=null;p.free()
	for p in g.sound_bank.loop_players.values():
		p.stop();p.stream=null;p.free()
	g.free()
	if failures>0:
		print("FOOTSTEPS_FAILED ",failures)
		quit(1)
		return
	print("FOOTSTEPS_OK village grass/cobble/spawn stone, regions, trails, interiors, dungeons, arena; all step sounds play")
	quit()
