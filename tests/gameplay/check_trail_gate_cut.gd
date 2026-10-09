extends SceneTree
# Überlandwege enden an beiden Dorfeingängen gerade an der Mauerlinie und ragen nicht ins Dorf.

const Game=preload("res://main.gd")
const Plan=preload("res://components/map0_ground_plan_32.gd")
const Content=preload("res://components/game_content.gd")

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("TRAIL_GATE_CUT_FAIL "+label)

func _initialize()->void:
	var village:Rect2=Plan.BOUNDS
	var gate_segments:=0
	for trail in Content.TRAILS:
		for i in range(trail.size()-1):
			var a:Vector2=trail[i]
			var b:Vector2=trail[i+1]
			var pieces:Array=Game.trail_band_polygons(a,b,116.0)
			for piece in pieces:
				for v in piece:
					check(not village.grow(-0.5).has_point(v),"Weg ragt ins Dorf bei %s" % v)
			var touches_gate:bool=a.is_equal_approx(Plan.EAST_GATE) or b.is_equal_approx(Plan.EAST_GATE) or a.is_equal_approx(Plan.SOUTH_GATE) or b.is_equal_approx(Plan.SOUTH_GATE)
			if touches_gate and not village.has_point(a.lerp(b,0.5)):
				gate_segments+=1
				var on_line:=0
				for piece in pieces:
					for v in piece:
						if absf(v.x-village.end.x)<0.6 or absf(v.y-village.end.y)<0.6:on_line+=1
				check(on_line>=2,"Torweg endet gerade an der Mauerlinie (%s -> %s)" % [a,b])
	check(gate_segments>=2,"beide Torwege gefunden")
	# Wege weit weg vom Dorf bleiben ein unveraenderter Streifen.
	check(Game.trail_band_polygons(Vector2(5000,5000),Vector2(5400,5100),90.0).size()==1,"freier Weg unveraendert")
	if failures>0:
		print("TRAIL_GATE_CUT_FAILED ",failures)
		quit(1)
		return
	print("TRAIL_GATE_CUT_OK trails stop cleanly at both village gates")
	quit()
