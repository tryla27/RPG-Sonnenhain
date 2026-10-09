extends RefCounted
## Native combat particles: the visible circle is also the damage radius.
static func cloud(c:CanvasItem,p:Vector2,radius:float,age:float,life:float)->void:
	var opacity:=clampf(life/.45,0.0,1.0)
	c.draw_circle(p,radius,Color("779a3c",.13*opacity))
	c.draw_arc(p,radius,0,TAU,48,Color("b9d965",.65*opacity),2)
	for mote in 24:
		var angle:=mote*2.39996+age*.35
		var reach:=radius*(.2+.72*float(mote%7)/6.0)
		var point:=(p+Vector2.RIGHT.rotated(angle)*reach+Vector2(0,sin(age*3.0+mote)*5.0)).round()
		var size:=2.0+float(mote%3)
		c.draw_rect(Rect2(point-Vector2.ONE*size*.5,Vector2.ONE*size),Color("c4dd72" if mote%3 else "738b37",.8*opacity))

static func secretion(c:CanvasItem,p:Vector2,dir:Vector2)->void:
	c.draw_line(p-dir*13.0,p,Color("778b32",.7),4)
	c.draw_circle(p,5,Color("293d20"))
	c.draw_circle(p,3.5,Color("b6d753"))
	c.draw_rect(Rect2(p+Vector2(-2,-2),Vector2(2,2)),Color("ebefa5"))

static func glands(c:CanvasItem,p:Vector2,dir:Vector2,scale_factor:float,progress:float)->void:
	var side:=dir.orthogonal()
	var strength:=clampf(progress/.4,0.0,1.0) if progress>=0 else 0.0
	for flank in [-1,1]:
		var gland:Vector2=p+(dir*16.0+side*5.0*flank+Vector2(0,-8))*scale_factor
		c.draw_circle(gland,2.5*scale_factor,Color("394a20"))
		c.draw_circle(gland,1.5*scale_factor,Color("a1bc50").lerp(Color("ecf1a1"),strength))

static func leap_height(progress:float)->float:
	return sin(clampf((progress-.4)/.15,0.0,1.0)*PI)*22.0 if progress>=.4 and progress<=.55 else 0.0
