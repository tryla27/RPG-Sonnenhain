extends SceneTree
const Slots=preload("res://components/landscape_atlas_slots.gd")
const Page=preload("res://components/landscape_atlas_page.gd")
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:call_deferred("run")
func run()->void:
	var slots:=Slots.new();var rows:Array=[]
	for index in 100:rows.append({"key":"wall:%d"%index,"moving":false})
	rows.append({"key":"tree:1","moving":true})
	var classify:=func(row):return bool(row["moving"])
	var first:Dictionary=slots.reconcile(rows,classify)
	check(first["added"].size()==101,"Alle Objekte erhalten einen Platz")
	check(slots.pages.size()==3,"Feste und bewegte Körper haben getrennte Seiten")
	var saved:Dictionary=slots.entries["wall:80"].duplicate()
	var source:Rect2=slots.source("wall:80")
	rows.reverse();slots.reconcile(rows,classify)
	check(slots.source("wall:80")==source,"Sortierungswechsel verschiebt keinen Atlasplatz")
	check(slots.entries["wall:80"]["page"]==saved["page"],"Seitenzuordnung bleibt stabil")
	var cropped:Array=rows.slice(0,20);slots.reconcile(cropped,classify)
	check(slots.entries.size()<=cropped.size()+Slots.KEEP_HIDDEN,"Unsichtbarer Cache bleibt begrenzt")
	var restored:Dictionary=slots.reconcile(rows,classify)
	check(slots.entries.size()==rows.size(),"Rückweg stellt entfernte Objekte wieder her")
	check(restored["added"].size()>0,"Verdrängte Objekte werden neu reserviert")
	var occupied:Dictionary={}
	for key in slots.entries:
		var allocation:Dictionary=slots.entries[key]
		var address:="%d:%d"%[allocation["page"],allocation["slot"]]
		check(not occupied.has(address),"Keine doppelten Atlasplätze");occupied[address]=true
	var host:=Node.new();root.add_child(host)
	var page:=Page.new();page.setup(host,false,0)
	var body:=Node3D.new();page.add_body("wall",body,0,{})
	page.step(.016);var updates:int=page.render_updates
	for frame in 120:page.step(.016)
	check(page.render_updates==updates,"Ruhende Mauer erzeugt keine fortlaufenden 3D-Renderupdates")
	page.set_visible_keys({});page.step(.016)
	check(not body.visible and page.render_updates==updates+1,"Entfernen aus Sicht aktualisiert die Seite einmal")
	page.set_visible_keys({"wall":true});page.step(.016)
	check(body.visible and page.render_updates==updates+2,"Rückweg verwendet denselben Körper")
	page.suspend();check(page.viewport.render_target_update_mode==SubViewport.UPDATE_DISABLED,"Pause deaktiviert Rendering")
	host.free()
	if failures>0:quit(1);return
	print("LANDSCAPE_ATLAS_OK stabile Plätze, begrenzter Cache, feste Mauern ohne dauernde Renderupdates")
	quit()
