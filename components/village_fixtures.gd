extends RefCounted

const Paths=preload("res://components/village_paths.gd")
const LAMPS:=[Vector2(592,560),Vector2(616,1280),Vector2(496,1736),Vector2(496,1840),Vector2(496,2448),Vector2(880,1280),Vector2(1040,1360),Vector2(1712,1520),Vector2(1712,1840),Vector2(1712,2240),Vector2(1312,2456),Vector2(880,560)]

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

const GLOW_SIZE:=128
static var glow_map:Texture2D
static func glow_texture()->Texture2D:
	if glow_map!=null:return glow_map
	var image:=Image.create(GLOW_SIZE,GLOW_SIZE,false,Image.FORMAT_RGBA8)
	var center:=Vector2.ONE*(GLOW_SIZE-1)*0.5
	for y in GLOW_SIZE:
		for x in GLOW_SIZE:
			var distance:=Vector2(x,y).distance_to(center)/(GLOW_SIZE*0.5-1.0)
			var falloff:=pow(maxf(0.0,1.0-distance*distance),3.0)
			image.set_pixel(x,y,Color(1.0,0.84,0.54,falloff))
	glow_map=ImageTexture.create_from_image(image)
	return glow_map
static func glow_strength(night:float)->float:
	# No painted light patches in daylight. At night, one gentle cream-colored falloff.
	return 0.13*smoothstep(0.12,1.0,clampf(night,0.0,1.0))
static func glow(c:CanvasItem,p:Vector2,night:float,phase:float)->void:
	var strength:=glow_strength(night)
	if strength<=0.001:return
	var flicker:=1.0+0.015*sin(phase*5.0+p.x)
	var illuminated:=Paths.closest(p)
	var size:=Vector2.ONE*GLOW_SIZE
	# Transparent corners and rim prevent any colored quad boundary in WebGL.
	c.draw_texture_rect(glow_texture(),Rect2((illuminated-size*0.5).round(),size),false,Color(1,1,1,strength*flicker))

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
