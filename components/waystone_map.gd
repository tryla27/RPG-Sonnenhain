extends RefCounted
const RECT=Rect2(167,148,800,405)

static func plaque(g,region:int,rect:Rect2=RECT)->Rect2:
	var inset:=rect.grow(-7)
	var center:Vector2=inset.position+g.region_rect(region).get_center()*(inset.size/g.WORLD)
	var width:=105.0 if region in [0,6] else 130.0
	return Rect2(Vector2(clampf(center.x-width*.5,inset.position.x+3,inset.end.x-width-3),clampf(center.y-22,inset.position.y+3,inset.end.y-47)),Vector2(width,44))

static func point(g,index:int,rect:Rect2=RECT)->Vector2:
	var inset:=rect.grow(-7)
	return inset.position+g.WAYSTONES[index]*(inset.size/g.WORLD)

static func region_stone(g,region:int)->int:
	for i in g.WAYSTONES.size():
		if g.region_at(g.WAYSTONES[i])==region:return i
	return -1

static func unlocked(g,index:int)->bool:
	return index==0 or (index>=0 and index<g.waystone_unlocked.size() and bool(g.waystone_unlocked[index]))

static func source_valid(g)->bool:
	if g.konflux.active or g.interior_id>=0 or g.dungeon_id>=0 or g.arena_mode!="" or g.hp<=0:return false
	for stone in g.WAYSTONES:
		if g.player_pos.distance_to(stone)<185.0:return true
	return g.creative_mode

static func destination(g,mouse:Vector2,rect:Rect2=RECT)->int:
	if not rect.grow(-7).has_point(mouse):return -1
	# Visible cyan markers have priority over the region plaques underneath.
	for index in g.WAYSTONES.size():
		if mouse.distance_to(point(g,index,rect))<=12.0:return index
	for region in 13:
		if plaque(g,region,rect).has_point(mouse):return region_stone(g,region)
	var inset:=rect.grow(-7)
	var world:Vector2=(mouse-inset.position)/(inset.size/g.WORLD)
	return region_stone(g,g.region_at(world))

static func use_waystone(g) -> void:
	if g.konflux.active:
		if g.konflux.room<0 and g.player_pos.distance_to(g.KonfluxMap.CENTER)<185: g.konflux.leave(g, true)
		else: g.message("Der Spawnwegstein im Zentrum bringt dich nach Sonnenhain zurück.")
		return
	if not source_valid(g):return
	for i in g.WAYSTONES.size():
		if g.player_pos.distance_to(g.WAYSTONES[i])<185:
			if i>0:
				if not g.waystone_unlocked[i]:g.play_sound("wegstein_aktiviert")
				g.waystone_unlocked[i]=true;g.last_waystone=i
			g.travel_from=i;g.travel_map=true;g.panel="map"
			g.enemy_projectiles.clear()
			g.message("Wähle auf der Karte einen aktivierten Wegstein oder seine Region.")
			g.save_game();return


static func travel_to_waystone(g, index:int)->bool:
	if not g.travel_map or not source_valid(g):
		g.travel_map=false;g.message("Reisen ist nur am Spawn oder an einem Wegstein möglich.");return false
	if index<0 or index>=g.WAYSTONES.size():return false
	if not unlocked(g,index):
		g.message("Diesen Wegstein musst du zuerst vor Ort aktivieren.");return false
	var region:int=g.region_at(g.WAYSTONES[index])
	if not g.region_available(region):
		g.message("Dieses Gebiet ist noch durch ein Boss-Siegel gesperrt.");return false
	g.player_pos=g.waystone_arrival(index)
	if index>0:g.last_waystone=index
	g.panel="";g.travel_map=false
	g.stop_sprint();g.enemies.clear();g.enemy_projectiles.clear();g.projectiles.clear();g.battle_zones.clear()
	g.mark_network_teleport()
	g.play_sound("reise");g.message("Reise nach %s." % g.region_name(region))
	g.save_game();return true


## Karte zeigt Reiseziele: geöffnet am Wegstein (F) oder mit M in Wegsteinnähe.
static func travel_ready(g)->bool:
	return g.travel_map or (g.panel=="map" and g.dungeon_id<0 and source_valid(g))

static func nearest_stone(g)->int:
	for i in g.WAYSTONES.size():
		if g.player_pos.distance_to(g.WAYSTONES[i])<185.0:return i
	return 0

static func click_map(g, mouse:Vector2)->void:
	if not g.travel_map:
		if travel_ready(g):
			g.travel_map=true;g.travel_from=nearest_stone(g)
		else:
			if destination(g,mouse)>=0:g.message("Gehe zu einem Wegstein, um zu teleportieren.")
			return
	var index:=destination(g,mouse)
	if index<0:
		if RECT.has_point(mouse):g.message("Hier gibt es keinen Wegstein zum Reisen.")
		return
	travel_to_waystone(g,index)

## Reiseziele im Raster: die elf Außen-Wegsteine, dann Sonnenhain.
