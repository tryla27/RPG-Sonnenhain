extends RefCounted
## V3 high-resolution pixel-art reference models for the isolated quality laboratory.
## Visual-only. No gameplay, save or network state is touched.

const OUTLINE := Color("0d151d")
const SHADOW := Color(0.02,0.04,0.06,0.52)
const PIXEL := 2.0

static func direction_index(v: Vector2) -> int:
	if v.length_squared() < 0.0001:
		return 0
	return posmod(roundi(atan2(v.x,v.y)/(PI/4.0)),8)

static func direction_vector(index: int) -> Vector2:
	var a: float = float(index)*PI/4.0
	return Vector2(sin(a),cos(a))

static func snapv(v: Vector2) -> Vector2:
	return Vector2(roundf(v.x/PIXEL),roundf(v.y/PIXEL))*PIXEL

static func rect_px(c: CanvasItem,r: Rect2,col: Color) -> void:
	var rr := Rect2(snapv(r.position),Vector2(maxf(PIXEL,roundf(r.size.x/PIXEL)*PIXEL),maxf(PIXEL,roundf(r.size.y/PIXEL)*PIXEL)))
	c.draw_rect(rr,OUTLINE)
	if rr.size.x>PIXEL*2.0 and rr.size.y>PIXEL*2.0:
		c.draw_rect(rr.grow(-PIXEL),col)

static func poly_px(c: CanvasItem,pts: PackedVector2Array,col: Color) -> void:
	if pts.size()<3:
		return
	var snapped := PackedVector2Array()
	var center := Vector2.ZERO
	for q in pts:
		var v: Vector2=snapv(q)
		snapped.append(v)
		center+=v
	center/=float(snapped.size())
	c.draw_colored_polygon(snapped,OUTLINE)
	var inner:=PackedVector2Array()
	for q in snapped:
		inner.append(center+(q-center)*0.94)
	c.draw_colored_polygon(inner,col)

static func ellipse_px(c: CanvasItem,p: Vector2,rx: float,ry: float,col: Color) -> void:
	# Transform-safe polygon ellipse: never resets the caller's local transform.
	var outer:=PackedVector2Array()
	var inner:=PackedVector2Array()
	for i in 20:
		var a:=float(i)/20.0*TAU
		outer.append(snapv(p+Vector2(cos(a)*rx,sin(a)*ry)))
		inner.append(snapv(p+Vector2(cos(a)*maxf(1.0,rx-PIXEL),sin(a)*maxf(1.0,ry-PIXEL))))
	c.draw_colored_polygon(outer,OUTLINE)
	c.draw_colored_polygon(inner,col)

static func line_px(c: CanvasItem,a: Vector2,b: Vector2,col: Color,width: float) -> void:
	c.draw_line(snapv(a),snapv(b),OUTLINE,width+4.0)
	c.draw_line(snapv(a),snapv(b),col,width)

static func shadow(c: CanvasItem,p: Vector2,rx: float,ry: float) -> void:
	c.draw_set_transform(p,0.0,Vector2(rx,ry))
	c.draw_circle(Vector2.ZERO,1.0,SHADOW)
	c.draw_set_transform(Vector2.ZERO)

static func mage(c: CanvasItem,p: Vector2,facing: Vector2,phase: float,state: String,state_t: float) -> void:
	var heading: int=direction_index(facing)
	var look: Vector2=direction_vector(heading)
	var profile: bool=heading in [2,6]
	var diagonal: bool=heading in [1,3,5,7]
	var back: bool=heading in [3,4,5]
	var right: Vector2=Vector2(look.y,-look.x)
	var stride: float=sin(phase)
	var bob: float=0.0
	if state=="walk":
		bob=absf(sin(phase*2.0))*3.0
	elif state=="idle":
		bob=sin(phase*0.8)*1.0
	var attack_push: float=0.0
	var staff_swing: float=0.0
	if state=="attack":
		if state_t<0.30:
			staff_swing=lerpf(0.0,-0.75,state_t/0.30)
		elif state_t<0.50:
			staff_swing=lerpf(-0.75,0.95,(state_t-0.30)/0.20)
			attack_push=sin((state_t-0.30)/0.20*PI)*10.0
		else:
			staff_swing=lerpf(0.95,0.0,clampf((state_t-0.50)/0.50,0.0,1.0))
	var recoil: float=sin(clampf(state_t,0.0,1.0)*PI)*11.0 if state=="hurt" else 0.0
	var death: float=clampf(state_t,0.0,1.0) if state=="death" else 0.0
	var base: Vector2=p+look*attack_push-look*recoil
	var fall: float=death*PI*0.48*(1.0 if look.x>=0.0 else -1.0)
	var pivot: Vector2=base+Vector2(0,-58+bob+death*34.0)
	c.draw_set_transform(pivot,fall,Vector2.ONE)
	var o:=Vector2(0,58)

	# Cape - high-res folds.
	var cape_w: float=30.0 if profile else (40.0 if diagonal else 45.0)
	poly_px(c,PackedVector2Array([
		o+Vector2(-cape_w,-70),o+Vector2(cape_w,-70),
		o+Vector2(cape_w-2,-28),o+Vector2(24,-3),
		o+Vector2(6,5),o+Vector2(-18,0),o+Vector2(-cape_w+2,-30)
	]),Color("33285f"))
	poly_px(c,PackedVector2Array([
		o+Vector2(-cape_w+6,-66),o+Vector2(cape_w-8,-66),
		o+Vector2(cape_w-10,-31),o+Vector2(18,-8),
		o+Vector2(-11,-8),o+Vector2(-cape_w+10,-32)
	]),Color("514087"))
	for x in [-18.0,0.0,18.0]:
		line_px(c,o+Vector2(x,-61),o+Vector2(x*0.6,-11),Color("6f5ca8"),2.0)

	# Legs, trousers, boots.
	var leg_phase: float=stride if state=="walk" else 0.0
	for sgn in [-1.0,1.0]:
		var step: float=leg_phase*sgn
		var lx: float=sgn*(11.0 if not profile else 7.0)
		rect_px(c,Rect2(o+Vector2(lx-7,-29+step*6),Vector2(14,27)),Color("263452"))
		rect_px(c,Rect2(o+Vector2(lx-8,-6+step*7),Vector2(16,11)),Color("725039"))
		rect_px(c,Rect2(o+Vector2(lx-10,2+step*7),Vector2(20,6)),Color("b88b52"))
		rect_px(c,Rect2(o+Vector2(lx-5,-18+step*5),Vector2(10,4)),Color("4963a1"))

	# Robe / torso with fabric and gold trim.
	var torso_w: float=26.0 if profile else (34.0 if diagonal else 38.0)
	poly_px(c,PackedVector2Array([
		o+Vector2(-torso_w,-79),o+Vector2(torso_w,-79),
		o+Vector2(torso_w+1,-42),o+Vector2(29,-18),
		o+Vector2(-29,-18),o+Vector2(-torso_w-1,-42)
	]),Color("17315f"))
	poly_px(c,PackedVector2Array([
		o+Vector2(-torso_w+6,-76),o+Vector2(torso_w-6,-76),
		o+Vector2(torso_w-8,-46),o+Vector2(21,-23),
		o+Vector2(-21,-23),o+Vector2(-torso_w+8,-46)
	]),Color("2f559e"))
	rect_px(c,Rect2(o+Vector2(-30,-45),Vector2(60,8)),Color("70482d"))
	rect_px(c,Rect2(o+Vector2(-7,-47),Vector2(14,12)),Color("e1b557"))
	rect_px(c,Rect2(o+Vector2(-3,-72),Vector2(6,31)),Color("d7b85e"))
	for y in [-68.0,-58.0,-48.0]:
		rect_px(c,Rect2(o+Vector2(-16,y),Vector2(6,4)),Color("7498dc"))

	# Arms and hands.
	var arm_swing: float=leg_phase*7.0 if state=="walk" else 0.0
	for sgn in [-1.0,1.0]:
		var ax: float=sgn*(torso_w+3.0)
		var ay: float=-70.0-arm_swing*sgn
		rect_px(c,Rect2(o+Vector2(ax-7,ay),Vector2(14,31)),Color("284985"))
		rect_px(c,Rect2(o+Vector2(ax-7,ay+25),Vector2(14,6)),Color("d2b15d"))
		rect_px(c,Rect2(o+Vector2(ax-6,ay+31),Vector2(12,10)),Color("dca57d"))
		rect_px(c,Rect2(o+Vector2(ax-5,ay+35),Vector2(10,3)),Color("f6d66e"))
		rect_px(c,Rect2(o+Vector2(ax-2,ay+33),Vector2(4,3)),Color("83e6ef"))

	# Neck and collar bridge the torso into one readable silhouette.
	rect_px(c,Rect2(o+Vector2(-11,-91),Vector2(22,18)),Color("dca77f"))
	poly_px(c,PackedVector2Array([
		o+Vector2(-25,-82),o+Vector2(-10,-93),o+Vector2(0,-86),
		o+Vector2(10,-93),o+Vector2(25,-82),o+Vector2(18,-70),o+Vector2(-18,-70)
	]),Color("223b73"))

	# HEAD - deliberately larger and below the hat, so it can never disappear.
	var head_y: float=-103.0
	var head_rx: float=18.0 if not profile else 15.0
	ellipse_px(c,o+Vector2(0,head_y),head_rx,21.0,Color("dca77f"))
	if back:
		ellipse_px(c,o+Vector2(0,head_y-1),head_rx,20.0,Color("5b3b33"))
		rect_px(c,Rect2(o+Vector2(-head_rx+3,head_y-6),Vector2(head_rx*2-6,15)),Color("70483b"))
	else:
		# Hair framing but never covering the face.
		poly_px(c,PackedVector2Array([
			o+Vector2(-head_rx,-113),o+Vector2(-8,-124),o+Vector2(10,-122),
			o+Vector2(head_rx,-111),o+Vector2(head_rx-4,-103),o+Vector2(-head_rx+4,-103)
		]),Color("5d3b32"))
		var ex: float=(7.0 if profile else (4.0 if diagonal else 0.0))*(1.0 if look.x>=0.0 else -1.0)
		if profile:
			rect_px(c,Rect2(o+Vector2(ex-1,head_y-5),Vector2(5,5)),Color("10263a"))
			rect_px(c,Rect2(o+Vector2(ex,head_y-4),Vector2(2,2)),Color("9cecff"))
		else:
			rect_px(c,Rect2(o+Vector2(-8+ex,head_y-5),Vector2(5,5)),Color("10263a"))
			rect_px(c,Rect2(o+Vector2(3+ex,head_y-5),Vector2(5,5)),Color("10263a"))
			rect_px(c,Rect2(o+Vector2(-7+ex,head_y-4),Vector2(2,2)),Color("9cecff"))
			rect_px(c,Rect2(o+Vector2(4+ex,head_y-4),Vector2(2,2)),Color("9cecff"))
		rect_px(c,Rect2(o+Vector2(-3+ex,head_y+1),Vector2(6,4)),Color("bf7d66"))
		rect_px(c,Rect2(o+Vector2(-6+ex,head_y+8),Vector2(12,3)),Color("8e4d50"))

	# Hat moved upward; brim sits above eyebrows.
	poly_px(c,PackedVector2Array([
		o+Vector2(-43,-124),o+Vector2(43,-124),o+Vector2(31,-115),o+Vector2(-34,-115)
	]),Color("211d4f"))
	poly_px(c,PackedVector2Array([
		o+Vector2(-22,-123),o+Vector2(-10,-159),o+Vector2(4,-178),
		o+Vector2(21,-151),o+Vector2(18,-123)
	]),Color("352b72"))
	rect_px(c,Rect2(o+Vector2(-26,-132),Vector2(52,7)),Color("d2a94d"))
	rect_px(c,Rect2(o+Vector2(6,-155),Vector2(7,7)),Color("75e7f3"))

	# Staff in hand with layered crystal.
	var hand: Vector2=o+Vector2(torso_w+12,-43)
	var staff_angle: float=-0.18+staff_swing
	c.draw_set_transform(pivot+hand.rotated(fall),fall+staff_angle,Vector2.ONE)
	rect_px(c,Rect2(Vector2(-4,-72),Vector2(8,110)),Color("6c472f"))
	rect_px(c,Rect2(Vector2(-7,-70),Vector2(14,7)),Color("d3a75c"))
	ellipse_px(c,Vector2(0,-84),15,15,Color("45cbe0"))
	ellipse_px(c,Vector2(0,-84),9,9,Color("a9f5ff"))
	ellipse_px(c,Vector2(-4,-88),3,3,Color.WHITE)
	if state=="attack" and state_t>=0.34 and state_t<=0.65:
		var pulse: float=15.0+sin((state_t-0.34)/0.31*PI)*12.0
		c.draw_arc(Vector2(0,-84),pulse,0,TAU,32,Color("81efff"),4.0)
		for sgn in [-1.0,1.0]:
			c.draw_line(Vector2(0,-84),Vector2(sgn*18,-84-12),Color("c4f9ff"),3.0)
	c.draw_set_transform(Vector2.ZERO)
	if state=="hurt":
		c.draw_circle(base+Vector2(0,-76),52,Color(1.0,0.65,0.55,0.10))

static func slime(c: CanvasItem,p: Vector2,facing: Vector2,phase: float,state: String,state_t: float) -> void:
	# Classic Sonnenhain slime: broad glossy dome, face embedded in gel, splash skirt.
	var heading: int=direction_index(facing)
	var look: Vector2=direction_vector(heading)
	var right:=Vector2(look.y,-look.x)
	var pulse: float=sin(phase*1.4)
	var sx: float=1.0
	var sy: float=1.0
	var hop: float=0.0
	if state=="walk":
		sx=1.0+sin(phase*2.0)*0.08
		sy=1.0-sin(phase*2.0)*0.07
		hop=maxf(0.0,sin(phase*2.0))*3.0
	elif state=="idle":
		sx=1.0+pulse*0.025
		sy=1.0-pulse*0.02
	elif state=="attack":
		var a: float=sin(clampf(state_t,0.0,1.0)*PI)
		sx=1.0+a*0.36
		sy=1.0-a*0.18
		p+=look*a*26.0
	elif state=="hurt":
		var h: float=sin(clampf(state_t,0.0,1.0)*PI)
		sx=1.0+h*0.16
		sy=1.0-h*0.22
		p-=look*h*9.0
	elif state=="death":
		sx=lerpf(1.0,1.45,state_t)
		sy=lerpf(1.0,0.14,state_t)

	shadow(c,p+Vector2(0,17),46*sx,10)
	var base_y: float=12.0-hop
	var dome:=PackedVector2Array()
	var segments: int=28
	for i in segments:
		var u: float=float(i)/float(segments-1)
		var x: float=lerpf(-46.0,46.0,u)*sx
		var norm: float=x/(46.0*sx)
		var y: float=base_y-sqrt(maxf(0.0,1.0-norm*norm))*48.0*sy
		dome.append(p+Vector2(x,y))
	dome.append(p+Vector2(42*sx,base_y+7))
	dome.append(p+Vector2(28*sx,base_y+12))
	dome.append(p+Vector2(8*sx,base_y+8))
	dome.append(p+Vector2(-13*sx,base_y+13))
	dome.append(p+Vector2(-31*sx,base_y+8))
	dome.append(p+Vector2(-46*sx,base_y+5))
	poly_px(c,dome,Color("59c96d"))
	# Dark lower gel / core like the old slime.
	poly_px(c,PackedVector2Array([
		p+Vector2(-36*sx,base_y-6),p+Vector2(-24*sx,base_y-19),
		p+Vector2(0,base_y-25),p+Vector2(27*sx,base_y-18),
		p+Vector2(36*sx,base_y-5),p+Vector2(22*sx,base_y+5),
		p+Vector2(-22*sx,base_y+5)
	]),Color("24764e"))
	# Large glossy highlights.
	ellipse_px(c,p+Vector2(-19*sx,base_y-31*sy),12*sx,8*sy,Color("a9ef84"))
	ellipse_px(c,p+Vector2(-25*sx,base_y-36*sy),5*sx,4*sy,Color("e7ffd0"))
	ellipse_px(c,p+Vector2(16*sx,base_y-26*sy),8*sx,5*sy,Color("79de76"))
	# Embedded face; eyes lean toward facing direction.
	var face_center: Vector2=p+look*7.0+Vector2(0,base_y-17*sy)
	for sgn in [-1.0,1.0]:
		var ep: Vector2=face_center+right*sgn*11.0
		ellipse_px(c,ep,6,8,Color("10282a"))
		ellipse_px(c,ep+Vector2(-1,-2),2,3,Color("fff1a8"))
	rect_px(c,Rect2(face_center+Vector2(-7,8),Vector2(14,4)),Color("f3d67b"))
	# Splash skirt and bubbles.
	for q in [Vector2(-39,12),Vector2(-22,16),Vector2(20,15),Vector2(39,11)]:
		ellipse_px(c,p+Vector2(q.x*sx,q.y-hop),9,4,Color("72dc78"))
	ellipse_px(c,p+Vector2(-47,-13-hop),4,4,Color("83ec83"))
	ellipse_px(c,p+Vector2(43,-25-hop),3,3,Color("9af198"))
	if state=="attack" and state_t>0.40 and state_t<0.72:
		for i in 4:
			var q: Vector2=p+look*(50.0+float(i)*11.0)+right*float(i-1)*4.0
			ellipse_px(c,q,4,3,Color("a3f49a"))

static func wolf(c: CanvasItem,p: Vector2,facing: Vector2,phase: float,state: String,state_t: float) -> void:
	# Dangerous low stance: oversized shoulders/head, jagged mane, fangs, claws and red eyes.
	var heading: int=direction_index(facing)
	var f: Vector2=direction_vector(heading).normalized()
	var r: Vector2=Vector2(f.y,-f.x)
	var gait: float=sin(phase*2.0)
	var body: Vector2=p-f*8.0+Vector2(0,-34)
	var lunge: float=0.0
	if state=="attack":
		lunge=sin(clampf(state_t,0.0,1.0)*PI)*30.0
	elif state=="hurt":
		lunge=-sin(clampf(state_t,0.0,1.0)*PI)*12.0
	elif state=="death":
		body.y+=state_t*26.0
	body+=f*lunge
	shadow(c,p+f*lunge+Vector2(0,15),54,12)

	# Tail: thick and spiked.
	var tail_root: Vector2=body-f*39.0
	var tail_mid: Vector2=tail_root-f*25.0+r*(12.0+sin(phase)*7.0)
	var tail_tip: Vector2=tail_mid-f*20.0+r*8.0
	line_px(c,tail_root,tail_mid,Color("444c5f"),16.0)
	line_px(c,tail_mid,tail_tip,Color("687084"),13.0)
	for k in 4:
		var t: float=float(k)/3.0
		var q: Vector2=tail_mid.lerp(tail_tip,t)
		poly_px(c,PackedVector2Array([q+r*7,q-r*7,q-f*11]),Color("7a8295"))

	# Four legs with larger forelimbs and visible claws.
	for i in 4:
		var front: float=1.0 if i>=2 else -1.0
		var side_sign: float=-1.0 if i%2==0 else 1.0
		var swing: float=gait*(1.0 if (i==0 or i==3) else -1.0) if state=="walk" else 0.0
		var hip: Vector2=body+f*front*25.0+r*side_sign*14.0
		var knee: Vector2=hip+f*swing*7.0+Vector2(0,19.0)
		var paw: Vector2=knee+f*swing*5.0+Vector2(0,20.0)
		line_px(c,hip,knee,Color("3f4658"),12.0 if front>0 else 10.0)
		line_px(c,knee,paw,Color("626a7d"),10.0)
		ellipse_px(c,paw,10,5,Color("8d94a4"))
		for claw in [-1.0,0.0,1.0]:
			line_px(c,paw+r*claw*5.0,paw+r*claw*5.0+f*7.0,Color("e2ddd0"),2.0)

	# Long, low body.
	ellipse_px(c,body,43,24,Color("454d60"))
	ellipse_px(c,body+f*16.0,31,26,Color("5f687c"))
	ellipse_px(c,body-f*15.0,25,19,Color("373f52"))

	# Jagged shoulder mane.
	var shoulder: Vector2=body+f*18.0+Vector2(0,-8)
	for i in 7:
		var off: float=float(i-3)*9.0
		var root: Vector2=shoulder+r*off
		poly_px(c,PackedVector2Array([
			root+r*6.0,root-r*6.0,root-f*(18.0+float(abs(i-3))*2.0)+Vector2(0,-10)
		]),Color("778093"))

	# Head and muzzle exaggerated for threat.
	var head: Vector2=body+f*50.0+Vector2(0,-16)
	ellipse_px(c,head,24,22,Color("596275"))
	var brow: Vector2=head+f*7.0+Vector2(0,-6)
	for sgn in [-1.0,1.0]:
		poly_px(c,PackedVector2Array([
			brow+r*sgn*3.0,brow+r*sgn*14.0+Vector2(0,-5),brow+r*sgn*10.0+f*8.0
		]),Color("303746"))
	var muzzle: Vector2=head+f*23.0+Vector2(0,7)
	ellipse_px(c,muzzle,16,10,Color("aeb1bb"))
	ellipse_px(c,muzzle+f*11.0,5,4,Color("10141a"))

	# Tall torn ears.
	for sgn in [-1.0,1.0]:
		var eb: Vector2=head-f*4.0+r*sgn*15.0+Vector2(0,-13)
		poly_px(c,PackedVector2Array([
			eb+r*sgn*6.0,eb-r*sgn*5.0,eb-f*14.0+Vector2(0,-22)
		]),Color("464e61"))
		poly_px(c,PackedVector2Array([
			eb+r*sgn*3.0,eb-r*sgn*2.0,eb-f*9.0+Vector2(0,-15)
		]),Color("8d5966"))

	# Red eyes with bright center.
	if heading not in [3,4,5]:
		var eyes: Vector2=head+f*10.0+Vector2(0,-5)
		for sgn in [-1.0,1.0]:
			ellipse_px(c,eyes+r*sgn*8.0,4,3,Color("a71126"))
			ellipse_px(c,eyes+r*sgn*8.0,2,2,Color("ff795b"))

	# Snarl and large fangs.
	var jaw: Vector2=muzzle+Vector2(0,7)
	line_px(c,jaw-r*10.0,jaw+r*10.0,Color("5b1e24"),4.0)
	for sgn in [-1.0,1.0]:
		poly_px(c,PackedVector2Array([
			jaw+r*sgn*7.0,jaw+r*sgn*3.0,jaw+r*sgn*5.0+Vector2(0,17)
		]),Color("f3ead7"))
	if state=="attack" and state_t>0.28 and state_t<0.72:
		for sgn in [-1.0,1.0]:
			poly_px(c,PackedVector2Array([
				jaw+r*sgn*11.0,jaw+r*sgn*6.0,jaw+r*sgn*8.0+Vector2(0,22)
			]),Color("fff4df"))
		c.draw_arc(head+f*13.0,26,-0.8,0.8,18,Color("d32835"),4.0)
	if state=="hurt":
		c.draw_circle(head,32,Color(1.0,0.25,0.25,0.12))
