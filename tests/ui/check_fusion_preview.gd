extends SceneTree
## Fusionsvorschau: öffnet per Klick eine eigene Übungswelt, die echte Fusion
## trifft die Puppe (Treffer, Schaden, Abklingzeit), „NOCHMAL“ und „ZURÜCK“
## funktionieren, Schließen des Kristalls räumt auf – und am eigentlichen Spiel
## ändern sich weder Gold, Lernstand, Inventar, Gegner noch der Spielstand.
const Preview=preload("res://components/fusion_preview.gd")
class Game extends "res://main.gd":
	var saves:=0
	func save_game()->void:saves+=1
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error("FUSION_PREVIEW_FAIL "+label)
func frames(g,count:int)->void:
	for i in count:
		g.fusion_preview.tick(g,1.0/60.0)
		await process_frame
func _initialize()->void:call_deferred("run")
func run()->void:
	var g:=Game.new();root.add_child(g)
	for i in 4:await process_frame
	g.character_created=true;g.level=30;g.class_id=0;g.gold=777;g.panel="fusion"
	g.ensure_skill_state_size()
	g.enemies.clear()
	var learned_before:Array=g.learned.duplicate()
	var levels_before:Array=g.skill_levels.duplicate()
	var inventory_before:Array=g.inventory.duplicate(true)
	# Erste Seite, dritte Zeile: Wirbelhieb · Klingenwelle (trifft sicher).
	var row:=-1
	for i in 4:
		if str(g.ABILITIES[int(g.FUSIONS[i]["id"])]["name"])=="Wirbelhieb · Klingenwelle":row=i
	check(row>=0,"Prüffusion auf Seite 1")
	g.fusion_page=0
	g.click_fusion(Vector2(660,215+row*86))
	check(g.fusion_preview.active(),"VORSCHAU öffnet die Übungswelt")
	await frames(g,int((Preview.CAST_DELAY+Preview.SETTLE)*60)+10)
	var sandbox=g.fusion_preview.sandbox
	check(g.fusion_preview.finished(),"Wirken abgeschlossen")
	check(int(sandbox.hits)>0 and float(sandbox.total_damage)>0.0,"Puppe getroffen (%d Treffer, %d Schaden)"%[sandbox.hits,int(sandbox.total_damage)])
	check(float(sandbox.cooldown_seconds)>0.0,"Abklingzeit gemessen")
	# NOCHMAL setzt zurück und wirkt erneut.
	g.click_fusion(Preview.AGAIN.get_center())
	check(int(sandbox.hits)==0 and not g.fusion_preview.finished(),"NOCHMAL setzt zurück")
	await frames(g,int((Preview.CAST_DELAY+Preview.SETTLE)*60)+10)
	check(int(sandbox.hits)>0,"NOCHMAL wirkt erneut")
	# Echtes Spiel unverändert.
	check(g.gold==777,"kein Gold verbraucht")
	check(g.learned==learned_before and g.skill_levels==levels_before,"Lernstand unverändert")
	check(g.inventory==inventory_before,"Inventar unverändert")
	check(g.enemies.is_empty(),"keine Gegner im echten Spiel")
	check(g.saves==0,"kein Speichern")
	# ZURÜCK schließt.
	g.click_fusion(Preview.BACK.get_center())
	await process_frame
	check(not g.fusion_preview.active(),"ZURÜCK schließt")
	# Kristall schließen räumt eine offene Vorschau auf.
	g.click_fusion(Vector2(660,215+row*86))
	check(g.fusion_preview.active(),"erneut geöffnet")
	g.panel=""
	await frames(g,2)
	check(not g.fusion_preview.active(),"Schließen des Kristalls beendet die Vorschau")
	g.free()
	if failures>0:quit(1);return
	print("FUSION_PREVIEW_OK")
	quit()
