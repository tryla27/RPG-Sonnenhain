extends RefCounted
## Fusionsvorschau am Kristall der Verschmelzung (Arbeitsplan Aufgabe 10).
## Zeigt eine Fusion vor dem Kauf in einer abgeschlossenen Übungswelt
## (`fusion_preview_sandbox.gd`): Held, Übungspuppe, echte Wirkabläufe.
## Gemessen werden Treffer, Schaden und Abklingzeit; „NOCHMAL“ wirkt erneut.
## Verbraucht nichts und verändert weder Gold, Zutaten, Lernstand noch Spielstand.

const SANDBOX:="res://components/fusion_preview_sandbox.gd"
## Kurze Pause vor dem Wirken, damit Held und Puppe erst zu sehen sind.
const CAST_DELAY:=.45
## Danach gelten die Messwerte als abgeschlossen.
const SETTLE:=2.6
const FRAME:=Rect2(165,166,800,392)
const VIEW_RECT:=Rect2(181,182,576,324)
const AGAIN:=Rect2(781,410,168,40)
const BACK:=Rect2(781,460,168,40)

var viewport:SubViewport
var sandbox:Node
var fusion_id:=-1
var rank:=1
var cast_wait:=0.0
var since_cast:=-1.0

func active()->bool:
	return viewport!=null and is_instance_valid(viewport)

func open(g,id:int,show_rank:int)->void:
	close()
	fusion_id=id;rank=clampi(show_rank,1,4)
	viewport=SubViewport.new()
	viewport.size=Vector2i(576,324)
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	viewport.disable_3d=true
	g.add_child(viewport)
	sandbox=load(SANDBOX).new()
	viewport.add_child(sandbox)
	sandbox.setup(g,fusion_id,rank)
	cast_wait=CAST_DELAY;since_cast=-1.0

func again()->void:
	if not active():return
	sandbox.reset()
	cast_wait=CAST_DELAY;since_cast=-1.0

func close()->void:
	if active():viewport.queue_free()
	viewport=null;sandbox=null;since_cast=-1.0

func tick(g,delta:float)->void:
	if not active():return
	# Kristallfenster geschlossen: Übungswelt sofort freigeben.
	if str(g.panel)!="fusion":
		close();return
	if since_cast<0.0:
		cast_wait-=delta
		if cast_wait<=0.0:
			sandbox.cast();since_cast=0.0
	else:since_cast+=delta

func finished()->bool:
	return since_cast>=SETTLE

func click(g,mouse:Vector2)->bool:
	if not active():return false
	if AGAIN.has_point(mouse):
		again();g.play_sound("menu");return true
	if BACK.has_point(mouse):
		close();g.play_sound("menu");return true
	return FRAME.has_point(mouse)

func paint(g)->void:
	if not active():return
	g.ui_box(FRAME,Color("1d2b36"))
	g.draw_texture_rect(viewport.get_texture(),VIEW_RECT,false)
	g.draw_rect(VIEW_RECT,Color("9bead4"),false,2.0)
	var ability:Dictionary=g.ABILITIES[fusion_id]
	g.text_at(Vector2(781,204),"VORSCHAU",12,Color("cbd9da"))
	g.text_at(Vector2(781,228),str(ability["name"]),12,Color("fff1bc"),HORIZONTAL_ALIGNMENT_LEFT,175)
	g.text_at(Vector2(781,250),"Rang %d · Übungspuppe" % rank,11,Color("cbd9da"))
	var waiting:=since_cast<0.0
	var hits:int=int(sandbox.hits)
	var damage:=int(sandbox.total_damage)
	var lines:Array=[
		["Treffer", "…" if waiting else str(hits)],
		["Schaden", "…" if waiting else str(damage)],
		["Abklingzeit", "…" if waiting else "%.1f s" % float(sandbox.cooldown_seconds)],
		["Abstand", "%d px" % int(sandbox.dummy_distance)],
	]
	for i in lines.size():
		g.text_at(Vector2(781,282+i*22),str(lines[i][0]),11,Color("93a4a3"))
		g.text_at(Vector2(870,282+i*22),str(lines[i][1]),12,Color("e8f3de"))
	if finished() and hits==0:
		g.text_at(Vector2(781,384),"Kein Treffer: wirkt als Schutz oder Bewegung.",10,Color("e7c48d"),HORIZONTAL_ALIGNMENT_LEFT,170)
	g.ui_button(AGAIN,"NOCHMAL",not waiting)
	g.ui_button(BACK,"ZURÜCK")
	g.text_at(Vector2(181,530),"Übung ohne Verbrauch: kein Gold, keine Zutaten, kein Spielstand wird verändert.",11,Color("93a4a3"),HORIZONTAL_ALIGNMENT_LEFT,580)
