extends SceneTree
## Gebietshinweis: erscheint beim ersten Betreten eines Gebiets (je Charakter
## einmal), zeigt Gebietsfrucht, Gebietskraut und passende Rezepte, schließt
## sich per X oder nach Ablauf und erscheint nach erneutem Betreten nicht wieder.
const Finds=preload("res://components/region_finds.gd")
const Food=preload("res://components/food_system.gd")
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error("REGION_FINDS_FAIL "+label)
func _initialize()->void:call_deferred("run")
func run()->void:
	for region in range(1,13):
		var items:=Finds.finds(region)
		check(items.size()==2,"Gebiet %d: Frucht und Kraut"%region)
		check(str(items[0]["name"])==str(Food.FOODS[Food.REGION_FOOD[region]]["name"]),"Gebiet %d: Frucht aus den Buschregeln"%region)
		check(str(items[1]["name"])==str(Food.herb_for_region(region)["name"]),"Gebiet %d: Kraut aus den Buschregeln"%region)
	check(Finds.finds(0).is_empty() and Finds.finds(99).is_empty(),"Dorf und ungültige Gebiete ohne Hinweis")
	check("Waldbeer-Kompott" in Finds.recipes_for(1),"Blütenwiesen: Sonnenkraut-Rezept genannt")
	var g:=Game.new();root.add_child(g)
	for i in 4:await process_frame
	g.character_created=true;g.panel=""
	g.discovered_regions.fill(false);g.discovered_regions[0]=true
	g.player_pos=Vector2(3650,2650);g.previous_region=0
	g.update_player(0.016)
	var region:int=g.region_at(g.player_pos)
	check(g.region_finds.active() and g.region_finds.region==region,"Hinweis beim ersten Betreten")
	check(g.region_finds.click(g.region_finds.close_rect().get_center()) and not g.region_finds.active(),"X schließt")
	g.region_finds.show(region)
	for i in 200:g.region_finds.tick(.1)
	check(not g.region_finds.active(),"schließt nach Ablauf von selbst")
	# Bereits entdecktes Gebiet: kein neuer Hinweis beim Wiederbetreten.
	g.discovered_regions[region]=true;g.previous_region=0
	g.player_pos=Vector2(3650,2650)
	g.update_player(0.016)
	check(not g.region_finds.active(),"kein Hinweis bei bekanntem Gebiet")
	g.free()
	if failures>0:quit(1);return
	print("REGION_FINDS_OK")
	quit()
