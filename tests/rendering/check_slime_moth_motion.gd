extends SceneTree
# Waldschleim: stufenloser Hüpfbogen (keine Sprünge zwischen Bildern), Teile
# vorhanden. Himmelsfalter: Flügelschlag, Angriff spreizt, Niederlage klappt zu.

const Slime=preload("res://components/forest_slime_motion.gd")
const Moth=preload("res://components/himmelsfalter_art.gd")

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("SLIME_MOTH_FAIL "+label)

func _initialize()->void:
	for d in 8:check(Slime.available(d),"Schleim-Teile Richtung %d" % d)
	check(Slime.LEAF_PIVOTS.size()==8,"8 Blatt-Drehpunkte")
	# Stufenlos: zwischen zwei Nachbarzeitpunkten (1/240 Sprung) ändert sich die
	# Form nur wenig; Anfang und Ende sind gleich (Schleife ohne Ruck).
	var prev:=Slime.hop(0.0)
	var worst:=0.0
	var max_lift:=0.0
	var min_sy:=9.0
	for i in range(1,241):
		var k:=Slime.hop(i/240.0)
		worst=maxf(worst,maxf(absf(k.x-prev.x),maxf(absf(k.y-prev.y),absf(k.z-prev.z)/10.0)))
		max_lift=maxf(max_lift,k.z);min_sy=minf(min_sy,k.y)
		prev=k
	check(worst<0.03,"keine Sprünge im Hüpfbogen (größter Schritt %.3f)" % worst)
	check(Slime.hop(0.0).is_equal_approx(Slime.hop(1.0)),"Schleife schließt")
	check(max_lift>8.0 and min_sy<0.85,"echter Hüpfer: Flug %.1f px, Landung %.2f" % [max_lift,min_sy])
	var idle:=Slime.shape(false,0.0,1.3,0.5,Vector2.DOWN)
	check(is_zero_approx(float(idle["lift"])) and absf(float(idle["sy"])-1.0)<0.05,"Stehen: ruhiges Atmen")
	var hop_side:=Slime.shape(true,PI*0.9,0.0,0.0,Vector2.RIGHT)
	check(float(hop_side["lean"])<0.0,"lehnt sich im Flug in Laufrichtung")
	# Falter.
	var seen_open:=0.0;var seen_closed:=1.0
	for i in 60:
		var f:=Moth.flap(i/30.0,0.3,-1.0,-1.0)
		seen_open=maxf(seen_open,f.x);seen_closed=minf(seen_closed,f.x)
	check(seen_open>0.9 and seen_closed<0.1,"Flügelschlag öffnet und schließt")
	check(not is_equal_approx(Moth.flap(0.4,0.3,-1.0,-1.0).x,Moth.flap(0.4,0.3,-1.0,-1.0).y),"untere Flügel folgen verzögert")
	check(Moth.flap(0.37,0.3,0.3,-1.0).x>0.9,"Angriff: Flügel gespreizt")
	check(Moth.flap(0.37,0.3,-1.0,0.9).x<0.2,"Niederlage: Flügel zugeklappt")
	check(not is_equal_approx(Moth.flap(1.0,0.1,-1.0,-1.0).x,Moth.flap(1.0,0.9,-1.0,-1.0).x),"eigener Rhythmus je Falter")
	if failures>0:
		push_error("SLIME_MOTH_FAILED %d" % failures);quit(1);return
	print("SLIME_MOTH_OK")
	quit()
