extends RefCounted
# Kleine Leistungsanzeige (F3): Bilder pro Sekunde, mittlere und längste
# Bildzeit der letzten Sekunde, Gegner in der Nähe. Dient dazu, Ruckeln bei
# Spielern sichtbar zu machen (Golem-v2-Konzept, Punkt 2). Standard: aus.

var visible:=false
var fps:=0.0
var avg_ms:=0.0
var worst_ms:=0.0
var _sum:=0.0
var _worst:=0.0
var _frames:=0

static func is_toggle_key(event:InputEvent)->bool:
	if not event is InputEventKey or not event.pressed or event.echo:return false
	var key:int=event.keycode if event.keycode!=KEY_NONE else event.physical_keycode
	return key==KEY_F3

func tick(delta:float)->void:
	if not visible:return
	_sum+=delta
	_worst=maxf(_worst,delta)
	_frames+=1
	if _sum>=1.0:
		fps=_frames/_sum
		avg_ms=_sum/_frames*1000.0
		worst_ms=_worst*1000.0
		_sum=0.0;_worst=0.0;_frames=0

func text(mobs:int)->String:
	return "FPS %d · %.1f ms · max %.0f ms · Gegner %d" % [roundi(fps),avg_ms,worst_ms,mobs]

func draw(c:CanvasItem,font:Font,mobs:int)->void:
	if not visible:return
	var line:=text(mobs)
	var pos:=Vector2(c.get_viewport_rect().size.x*0.5-150.0,22.0)
	c.draw_rect(Rect2(pos-Vector2(8,16),Vector2(300,22)),Color(0,0,0,0.55))
	var color:=Color("9be59b") if worst_ms<34.0 else (Color("ffd36f") if worst_ms<70.0 else Color("ff8a7a"))
	c.draw_string(font,pos,line,HORIZONTAL_ALIGNMENT_CENTER,284,13,color)
