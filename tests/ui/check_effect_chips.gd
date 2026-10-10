extends SceneTree
# Kompakte Effekt-Kacheln links oben: klein, nebeneinander, höchstens 4 pro Reihe.
const HudLayout=preload("res://components/hud_layout.gd")
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("EFFECT_CHIPS_FAIL "+label)
func _initialize()->void:
	var o:=Vector2(10,72)
	var a:=HudLayout.chip_rect(o,0);var b:=HudLayout.chip_rect(o,1);var e:=HudLayout.chip_rect(o,4)
	check(a.size.x<=100 and a.size.y<=30,"Kachel klein (%s)" % a.size)
	check(is_equal_approx(b.position.y,a.position.y) and b.position.x>a.end.x,"nebeneinander")
	check(e.position.y>a.end.y and is_equal_approx(e.position.x,a.position.x),"fünfte Kachel in neuer Reihe")
	check(HudLayout.chip_rect(o,3).end.x<420.0,"vier Kacheln bleiben im linken Viertel")
	check(a.size.y*2<58,"zwei Effekte brauchen weniger Höhe als vorher einer (58 px)")
	if failures>0:
		push_error("EFFECT_CHIPS_FAILED %d" % failures);quit(1);return
	print("EFFECT_CHIPS_OK")
	quit()
