extends RefCounted
const Shapes=preload("res://components/canvas_shapes.gd")
## Vorbereitung aus denselben Reichweiten wie der Kampf; keine neue Trefferlogik.
static func outline(origin:Vector2,direction:Vector2,ability:Dictionary)->PackedVector2Array:
	var points:=PackedVector2Array([origin])
	var reach:=float(ability.get("range",0.0));var angle:=direction.angle()
	var half:=float(ability.get("half_angle",0.0))
	for i in 17:points.append(origin+Vector2.RIGHT.rotated(angle-half+half*2*i/16.0)*reach)
	return points
static func paint(c:CanvasItem,p:Vector2,direction:Vector2,ability:Dictionary,tint:Color,progress:float)->void:
	var reach:=float(ability["range"])
	var opacity:=lerpf(.08,.18,clampf(progress,0,1))
	match str(ability["shape"]):
		"cloud":
			Shapes.circle(c,p,reach,Color(tint,opacity))
			c.draw_arc(p,reach,0,TAU,48,Color("b9d965",.8),2)
			c.draw_arc(p,reach-4,-PI*.5,-PI*.5+TAU*clampf(progress,0,1),40,Color("eff4ba",.8),2)
		"leap":pass # Die bestätigte Wolfspose bleibt ohne Zielmarkierung.
		"line":
			c.draw_line(p,p+direction*reach,Color(tint,opacity),20)
			c.draw_line(p,p+direction*reach,Color(tint,.7),2)
		"arc":
			Shapes.polygon(c,outline(p,direction,ability),Color(tint,opacity))
			var half:=float(ability["half_angle"])
			c.draw_arc(p,reach,direction.angle()-half,direction.angle()+half,20,tint,2)
		_:
			c.draw_line(p,p+direction*reach,Color(tint,.4),2)
