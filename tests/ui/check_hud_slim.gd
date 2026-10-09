extends SceneTree
# Schlankes HUD und lesbare Patch Notes: Lage der HUD-Teile, Speicherstatus
# nur bei Problemen, Klicks in der Patch-Notes-Liste und ein Zeichendurchlauf.

const Hud=preload("res://components/hud_layout.gd")
const Notes=preload("res://components/patch_notes.gd")
const SaveClient=preload("res://components/server_save_client.gd")

class Board extends "res://main.gd":
	var drawn:=0
	func _ready()->void:
		font=ThemeDB.fallback_font
		reset_class_skills()
		for i in QUESTS.size():quests.append({"state":0,"progress":0})
		for i in BORIN_QUESTS.size():borin_quests.append({"state":0,"progress":0})
		for i in WORLD_EVENTS.size():
			event_states.append(0)
			event_progress.append(0)
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
	func _draw()->void:
		apply_ui_transform()
		draw_hud()
		panel="patches"
		draw_panel()
		patch_view["open"]=0
		draw_panel()
		panel=""
		drawn+=1

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("HUD_SLIM_FAIL "+label)

func _initialize()->void:call_deferred("run")

func run()->void:
	check_layout()
	check_save_status()
	check_patch_notes()
	await check_draw()
	if failures>0:
		print("HUD_SLIM_FAILED ",failures)
		quit(1)
		return
	print("HUD_SLIM_OK slim bars, quest line, map label, save status, patch notes list")
	quit()

func check_layout()->void:
	var bottom_bar:=Rect2(9,586,1134,53)
	var prompt:=Rect2(610,549,520,36)
	var quest:=Hud.quest_rect(false)
	check(quest.end.y<=bottom_bar.position.y,"Questzeile über der Fähigkeitenleiste")
	check(quest.size.y<=26,"Questzeile ist eine Zeile")
	check(not quest.intersects(prompt),"Questzeile neben dem Aktionshinweis")
	check(not quest.intersects(Hud.NOTICE_RECT),"Meldung über der Questzeile")
	check(not Hud.quest_rect(true).intersects(Hud.STATUS_RECT),"Touch-Questzeile unter den Balken")
	check(Hud.XP_LINE.position.y>=bottom_bar.end.y and Hud.XP_LINE.end.y<=648,"XP-Linie unter der Fähigkeitenleiste")
	for bar in [Hud.HP_BAR,Hud.ENERGY_BAR,Hud.STAMINA_BAR]:
		check(Hud.STATUS_RECT.encloses(bar),"Balken im Statusbereich")
		check(bar.size.y<=10,"Balken schmal")
	var minimap:Rect2=Hud.MINIMAP_RECT
	check(is_equal_approx(minimap.size.x,minimap.size.y) and minimap.size.x>=150.0,"Minimap quadratisch und größer als vorher (140)")
	check(minimap.end.x<=1152 and minimap.position.y>=0,"Minimap im Bild")
	check(Hud.MAP_LABEL_RECT.position.y>=minimap.end.y+2,"Kartenname unter der Minimap")
	check(absf(Hud.MAP_LABEL_RECT.get_center().x-minimap.get_center().x)<2.0,"Kartenname mittig unter der Minimap")
	check(not Hud.MAP_LABEL_RECT.intersects(minimap),"Kartenname nicht hinter der Minimap")
	check(Hud.KOOP_Y>Hud.MAP_LABEL_RECT.end.y and Hud.SAVE_NOTICE_Y>Hud.KOOP_Y,"Koop und Speicherhinweis darunter")
	var g:=Board.new()
	check(g.multiplayer_debug_rect().position.y>=Hud.RIGHT_STATUS_BOTTOM,"Netzwerkanzeige unter allem rechts oben")
	check(g.quest_hud_rect()==Hud.quest_rect(false),"Spiel nutzt die Questzeile")
	# Aktionshinweis: rechts unter der Minimap, kurz, rechtsbündig.
	g.font=ThemeDB.fallback_font
	var short_prompt:Rect2=Hud.prompt_rect(g,"F  ·  Wegstein: Reiseziele wählen")
	check(short_prompt.position.y>=Hud.MAP_LABEL_RECT.end.y,"Hinweis unter Minimap und Kartenname")
	check(is_equal_approx(short_prompt.end.x,minimap.end.x),"Hinweis rechtsbündig mit der Minimap")
	check(short_prompt.size.x<360.0,"Hinweis so kurz wie sein Text")
	check(Hud.KOOP_Y-12.0>=short_prompt.end.y,"Koop-Anzeige unter dem Hinweis")
	var long_prompt:Rect2=Hud.prompt_rect(g,"E  ·  Heilungsfeld am Altar · HP & Energie auffüllen und noch viel mehr Text")
	check(long_prompt.position.x>=600.0,"Langer Hinweis bleibt rechts")
	g.free()

func check_save_status()->void:
	var save:=SaveClient.new()
	check(not Hud.save_status_visible(save.problem,false,true),"Normalfall: keine Statuszeile")
	save.disconnected()
	check(Hud.save_status_visible(save.problem,false,true),"Verbindung weg: Statuszeile")
	check(not Hud.save_status_visible(save.problem,true,true),"Testmodus: keine Statuszeile")
	save.restore({"player_uuid":"x"})
	check(not save.problem,"Neuer Stand setzt Problem zurück")

func check_patch_notes()->void:
	check(Notes.headline(0)!="" and Notes.category(0)!="","Neuester Eintrag hat Bereich und Überschrift")
	for i in Notes.NOTES.size():
		check(Notes.headline(i).length()<=80,"Überschrift %d kurz genug" % i)
	var view:=Notes.new_view()
	var first_row:=Notes.row_rect(0).get_center()
	check(Notes.row_at(view,first_row)==0,"erste Zeile = neuester Eintrag")
	check(Notes.click(view,Notes.row_rect(2).get_center()) and int(view["open"])==2,"Klick öffnet Eintrag")
	check(Notes.row_at(view,first_row)==-1,"im Detail keine Listentreffer")
	check(Notes.click(view,Notes.NEXT_RECT.get_center()) and int(view["open"])==3,"Älter blättert weiter")
	check(Notes.click(view,Notes.PREV_RECT.get_center()) and int(view["open"])==2,"Neuer blättert zurück")
	check(Notes.back(view) and int(view["open"])==-1,"Escape führt zur Liste")
	check(not Notes.back(view),"Escape in der Liste schließt")
	Notes.scroll(view,-5)
	check(int(view["scroll"])==0,"nicht über den Anfang")
	Notes.scroll(view,100000)
	check(int(view["scroll"])==Notes.max_scroll(),"nicht über das Ende")
	var last:=Notes.NOTES.size()-1
	check(Notes.row_at(view,Notes.row_rect(Notes.ROWS-1).get_center())==last,"ältester Eintrag erreichbar")
	check(not Notes.click(view,Vector2(985,108)),"Schließen-Knopf bleibt dem Fenster")
	# Über das Spiel: Klick in die Liste öffnet, Klick auf X schließt.
	var g:=Board.new()
	g.panel="patches"
	g.handle_panel_click(Notes.row_rect(1).get_center())
	check(g.panel=="patches" and int(g.patch_view["open"])==1,"Spiel öffnet Eintrag per Klick")
	g.handle_panel_click(Vector2(985,108))
	check(g.panel=="","X schließt Patch Notes")
	g.free()

func check_draw()->void:
	var vp:=SubViewport.new()
	vp.size=Vector2i(1152,648)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var g:=Board.new()
	vp.add_child(g)
	g.character_created=true
	g.server_save.disconnected()
	g.queue_redraw()
	for i in 3:
		await process_frame
	check(g.drawn>0 or DisplayServer.get_name()=="headless","HUD gezeichnet")
	vp.queue_free()
	await process_frame
