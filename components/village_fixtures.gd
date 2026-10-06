extends RefCounted

const LAMPS:=[Vector2(768,1248),Vector2(1056,1280),Vector2(1576,1200),Vector2(1696,1200),Vector2(640,1530)]

static func lamp(c:CanvasItem,p:Vector2)->void:
	var iron:=Color("30353c")
	c.draw_rect(Rect2(p+Vector2(-10,2),Vector2(20,8)),iron)
	c.draw_rect(Rect2(p+Vector2(-4,-60),Vector2(8,64)),iron)
	c.draw_rect(Rect2(p+Vector2(-1,-57),Vector2(2,58)),Color("666970"))
	c.draw_rect(Rect2(p+Vector2(-14,-88),Vector2(28,6)),iron)
	c.draw_rect(Rect2(p+Vector2(-10,-82),Vector2(20,24)),Color("a8682f"))
	c.draw_rect(Rect2(p+Vector2(-7,-80),Vector2(14,20)),Color("ffca5a"))
	c.draw_rect(Rect2(p+Vector2(-4,-77),Vector2(5,14)),Color("fff0b0"))
	for x in [-11,-1,8]:c.draw_rect(Rect2(p+Vector2(x,-83),Vector2(3,27)),iron)
	c.draw_rect(Rect2(p+Vector2(-13,-59),Vector2(26,5)),iron)
	c.draw_rect(Rect2(p+Vector2(-8,-94),Vector2(16,6)),Color("484850"))
	c.draw_rect(Rect2(p+Vector2(-3,-98),Vector2(6,4)),Color("c69b52"))

static func glow(c:CanvasItem,p:Vector2,night:float,phase:float)->void:
	var flicker:=1.0+0.04*sin(phase*5.0+p.x)
	for ring in range(5,0,-1):
		c.draw_circle(p+Vector2(0,-70),float(ring)*13.0*flicker,Color(1.0,0.62,0.23,(0.018+0.028*night)*flicker))
	c.draw_circle(p+Vector2(0,4),34.0,Color(1.0,0.67,0.30,0.03+0.06*night))

static func board(c:CanvasItem,p:Vector2)->void:
	for x in [-35,29]:
		c.draw_rect(Rect2(p+Vector2(x,-66),Vector2(7,78)),Color("4c3028"))
		c.draw_rect(Rect2(p+Vector2(x+2,-61),Vector2(2,70)),Color("ae7543"))
	c.draw_rect(Rect2(p+Vector2(-47,-85),Vector2(94,57)),Color("382a28"))
	for plank in 5:
		c.draw_rect(Rect2(p+Vector2(-42,-80+plank*9),Vector2(84,8)),Color("875333") if plank%2 else Color("9d653b"))
		c.draw_rect(Rect2(p+Vector2(-37+plank*7,-78+plank*9),Vector2(27,1)),Color("be854b"))
	for top in [-87,-30]:c.draw_rect(Rect2(p+Vector2(-47,top),Vector2(94,5)),Color("d49a56"))
	for note in [Rect2(-34,-74,21,29),Rect2(-6,-77,25,20),Rect2(22,-71,16,31),Rect2(-3,-51,20,15)]:
		c.draw_rect(Rect2(p+note.position+Vector2(2,2),note.size),Color("402e2a"))
		c.draw_rect(Rect2(p+note.position,note.size),Color("e9d7a3"))
		c.draw_rect(Rect2(p+note.position+Vector2(3,6),Vector2(note.size.x-6,2)),Color("896c4c"))
		c.draw_rect(Rect2(p+note.position+Vector2(3,11),Vector2(note.size.x-8,1)),Color("896c4c"))
		c.draw_rect(Rect2(p+note.position+Vector2(note.size.x/2,2),Vector2(2,2)),Color("b94732"))
