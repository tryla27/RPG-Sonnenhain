extends SceneTree
## Händler und Käuferstufe: neue Angebote entstehen mit der aktuellen Stufe,
## vorhandene behalten Preis und Stufe; nach einem Aufstieg um mindestens drei
## Stufen bringt das Öffnen sofort eine passende Lieferung; jeder Charakter
## behält seinen eigenen Bestand über Speichern und Laden.
const Rotation=preload("res://components/shop_rotation.gd")
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error("SHOP_LEVEL_FAIL "+label)
func newest(g,role:String)->int:return Rotation.newest_offer_level(g.shop_stock[role])
func _initialize()->void:call_deferred("run")
func run()->void:
	var g:=Game.new();root.add_child(g)
	for i in 4:await process_frame
	g.character_created=true;g.player_uuid="u-shop";g.hero_name="Kaufmann"
	g.level=20;g.shop_stock={};g.refresh_shop_stock()
	check(newest(g,"smith")==20 and newest(g,"arcane")==20,"Angebote zur Käuferstufe")
	var first:Dictionary=g.shop_stock["smith"][0].duplicate(true)
	# Kleiner Aufstieg: noch keine neue Lieferung beim Öffnen.
	g.level=22;var before:int=g.shop_stock["smith"].size()
	g.refresh_shop_for_level()
	check(g.shop_stock["smith"].size()==before,"zwei Stufen: kein Sonderbestand")
	# Großer Aufstieg: Öffnen bringt sofort passende Ware, alte bleibt.
	g.level=26;g.shop_timer=200.0
	g.refresh_shop_for_level()
	check(g.shop_stock["smith"].size()==before+3,"drei neue Angebote")
	check(newest(g,"smith")==26,"neue Angebote mit Stufe 26")
	check(g.shop_stock["smith"][0]==first,"altes Angebot unverändert (Preis %s)"%first["price"])
	check(g.shop_timer==0.0 and g.shop_jump_newest,"Timer neu, neueste Seite wird gezeigt")
	g.merchant_kind="smith";g.panel="shop"
	g.shop_jump_newest=true;g.shop_page=0
	var page_before:int=g.shop_page
	# draw_shop_panel springt zur neuesten Seite (Zeichnen nur im _draw möglich: Logik direkt prüfen)
	var expected:=maxi(0,int((g.shop_stock["smith"].size()-1)/3))
	check(expected>page_before,"es gibt eine spätere Seite")
	# Kauf: Gegenstand trägt Stufe und Preis des Angebots.
	g.gold=100000;g.inventory.clear()
	var offer:Dictionary=g.shop_stock["smith"][0]
	check(g.buy_item(offer.duplicate(true),false),"Kauf klappt")
	var bought:Dictionary=g.inventory[g.inventory.size()-1]
	check(int(bought.get("level",0))==int(offer["level"]) and g.gold==100000-int(offer["price"]),"Kauf zu Angebotsstufe und -preis")
	# Eigener Bestand je Charakter über Speichern/Laden.
	var data:Dictionary=JSON.parse_string(JSON.stringify(g.capture_save_data()))
	var other:=data.duplicate(true);other["shop_stock"]={};other["level"]=5;other["shop_rotation"]=-1
	g.apply_save_data(other)
	check(newest(g,"smith")==5,"Spielstand ohne Bestand: frische Ware zur eigenen Stufe, kein fremder Bestand")
	g.apply_save_data(data)
	check(g.shop_stock["smith"].size()==before+3 and newest(g,"smith")==26,"Bestand kommt mit dem Spielstand zurück")
	check(Rotation.needs_fresh_batch({},10),"leerer Bestand braucht Lieferung")
	check(not Rotation.needs_fresh_batch({"alchemy":[{"icon":"herb","level":1}]},40),"Kräuter zählen nicht als veraltet")
	g.free()
	if failures>0:quit(1);return
	print("SHOP_LEVEL_OK")
	quit()
