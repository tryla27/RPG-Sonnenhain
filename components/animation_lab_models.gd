extends RefCounted
## High-detail local reference models for the isolated animation laboratory.
## No combat, save, network or production renderer state is changed.

const OUTLINE := Color("101a22")
const SHADOW := Color(0.02,0.05,0.07,0.48)

static func direction_index(v: Vector2) -> int:
	if v.length_squared() < 0.0001:
		return 0
	return posmod(roundi(atan2(v.x,v.y)/(PI/4.0)),8)

static func direction_vector(index: int) -> Vector2:
	var a := float(index)*PI/4.0
	return Vector2(sin(a),cos(a))

static func rect_px(c: CanvasItem, r: Rect2, col: Color) -> void:
	var rr := Rect2(r.position.round(),r.size.round())
	c.draw_rect(rr,OUTLINE)
	if rr.size.x > 3.0 and rr.size.y > 3.0:
		c.draw_rect(rr.grow(-1.0),col)

static func poly_px(c: CanvasItem, pts: PackedVector2Array, col: Color) -> void:
	if pts.size() < 3:
		return
	c.draw_colored_polygon(pts,OUTLINE)
	var center := Vector2.ZERO
	for p in pts:
		center += p
	center /= float(pts.size())
	var inner := PackedVector2Array()
	for p in pts:
		inner.append(center+(p-center)*0.91)
	c.draw_colored_polygon(inner,col)

static func ellipse(c: CanvasItem, pos: Vector2, rx: float, ry: float, col: Color) -> void:
	c.draw_set_transform(pos,0.0,Vector2(rx,ry))
	c.draw_circle(Vector2.ZERO,1.0,OUTLINE)
	c.draw_set_transform(pos,0.0,Vector2(maxf(0.01,rx-1.2),maxf(0.01,ry-1.2)))
	c.draw_circle(Vector2.ZERO,1.0,col)
	c.draw_set_transform(Vector2.ZERO)

static func shadow(c: CanvasItem, p: Vector2, rx: float, ry: float) -> void:
	c.draw_set_transform(p,0.0,Vector2(rx,ry))
	c.draw_circle(Vector2.ZERO,1.0,SHADOW)
	c.draw_set_transform(Vector2.ZERO)

static func mage(c: CanvasItem,p: Vector2,facing: Vector2,phase: float,state: String,state_t: float) -> void:
	var heading: int = direction_index(facing)
	var look: Vector2 = direction_vector(heading)
	var side := Vector2(look.y,-look.x)
	var profile := heading in [2,6]
	var diagonal := heading in [1,3,5,7]
	var back := heading in [3,4,5]
	var stride := sin(phase)
	var bob := 0.0
	if state == "walk":
		bob = absf(sin(phase*2.0))*2.0
	elif state == "idle":
		bob = sin(phase*0.7)*0.8
	var attack_push := 0.0
	var staff_swing := 0.0
	if state == "attack":
		if state_t < 0.32:
			staff_swing = lerpf(0.0,-0.85,state_t/0.32)
		elif state_t < 0.48:
			staff_swing = lerpf(-0.85,0.95,(state_t-0.32)/0.16)
			attack_push = sin((state_t-0.32)/0.16*PI)*7.0
		else:
			staff_swing = lerpf(0.95,0.0,clampf((state_t-0.48)/0.52,0.0,1.0))
	var recoil := 0.0
	if state == "hurt":
		recoil = sin(clampf(state_t,0.0,1.0)*PI)*8.0
	var death := clampf(state_t,0.0,1.0) if state == "death" else 0.0
	var base := p + look*attack_push - look*recoil
	var fall_angle := death*(PI*0.48)*(1.0 if look.x >= 0.0 else -1.0)
	var pivot := base+Vector2(0,-44+bob+death*24.0)
	c.draw_set_transform(pivot,fall_angle,Vector2.ONE)
	var o := Vector2(0,44)

	# Layer 1: cape behind body.
	var cape_w := 23.0 if profile else (31.0 if diagonal else 35.0)
	poly_px(c,PackedVector2Array([
		o+Vector2(-cape_w,-51),o+Vector2(cape_w,-51),
		o+Vector2(cape_w-4,-15),o+Vector2(9,-5),
		o+Vector2(-14,-7),o+Vector2(-cape_w+4,-18)
	]),Color("43356f"))
	poly_px(c,PackedVector2Array([
		o+Vector2(-cape_w+5,-48),o+Vector2(cape_w-5,-48),
		o+Vector2(cape_w-9,-18),o+Vector2(5,-10),
		o+Vector2(-10,-12),o+Vector2(-cape_w+9,-21)
	]),Color("5b4b8f"))

	# Layer 2: legs / boots with visible foot planting.
	var leg_phase := stride if state == "walk" else 0.0
	for sgn in [-1.0,1.0]:
		var step: float = leg_phase*float(sgn)
		var lx: float = float(sgn)*(8.0 if not profile else 5.0)
		rect_px(c,Rect2(o+Vector2(lx-5,-20+step*4),Vector2(10,20)),Color("27364b"))
		rect_px(c,Rect2(o+Vector2(lx-6,-3+step*5),Vector2(13,7)),Color("6a4b35"))
		rect_px(c,Rect2(o+Vector2(lx-7,2+step*5),Vector2(15,3)),Color("b29057"))

	# Layer 3: torso / robe / belt.
	var torso_w := 20.0 if profile else (27.0 if diagonal else 30.0)
	poly_px(c,PackedVector2Array([
		o+Vector2(-torso_w,-58),o+Vector2(torso_w,-58),
		o+Vector2(torso_w-2,-31),o+Vector2(21,-14),
		o+Vector2(-22,-14),o+Vector2(-torso_w+2,-31)
	]),Color("243b72"))
	poly_px(c,PackedVector2Array([
		o+Vector2(-torso_w+5,-55),o+Vector2(torso_w-5,-55),
		o+Vector2(torso_w-7,-35),o+Vector2(15,-18),
		o+Vector2(-16,-18),o+Vector2(-torso_w+7,-35)
	]),Color("36539a"))
	rect_px(c,Rect2(o+Vector2(-23,-33),Vector2(46,6)),Color("6e4d32"))
	rect_px(c,Rect2(o+Vector2(-4,-34),Vector2(8,8)),Color("e2b85d"))
	for y in [-50.0,-43.0,-36.0]:
		rect_px(c,Rect2(o+Vector2(-2,y),Vector2(4,3)),Color("d7c06d"))

	# Layer 4: arms / hands / rings.
	var arm_swing := leg_phase*5.0 if state == "walk" else 0.0
	for sgn in [-1.0,1.0]:
		var ax: float = float(sgn)*(torso_w+2.0)
		var ay: float = -51.0-arm_swing*float(sgn)
		rect_px(c,Rect2(o+Vector2(ax-5,ay),Vector2(10,23)),Color("304c8f"))
		rect_px(c,Rect2(o+Vector2(ax-5,ay+18),Vector2(10,5)),Color("d1b46e"))
		rect_px(c,Rect2(o+Vector2(ax-4,ay+23),Vector2(8,7)),Color("d8a37a"))
		rect_px(c,Rect2(o+Vector2(ax-3,ay+25),Vector2(6,2)),Color("f2d36f" if sgn>0 else Color("a9e8ef")))

	# Layer 5: head, hair and direction-specific face.
	var head_y := -75.0
	ellipse(c,o+Vector2(0,head_y),15.0 if not profile else 12.0,17.0,Color("d8a57c"))
	if back:
		ellipse(c,o+Vector2(0,head_y-1),15.0 if not profile else 12.0,16.0,Color("714a3e"))
	else:
		var eye_shift := 6.0 if profile else (4.0 if diagonal else 0.0)
		var ex := eye_shift*(1.0 if look.x>=0.0 else -1.0)
		if profile:
			rect_px(c,Rect2(o+Vector2(ex-1,head_y-4),Vector2(4,4)),Color("13243b"))
		else:
			rect_px(c,Rect2(o+Vector2(-7+ex,head_y-4),Vector2(4,4)),Color("13243b"))
			rect_px(c,Rect2(o+Vector2(3+ex,head_y-4),Vector2(4,4)),Color("13243b"))
		rect_px(c,Rect2(o+Vector2(-5+ex,head_y+5),Vector2(10,2)),Color("a85e58"))
		poly_px(c,PackedVector2Array([
			o+Vector2(-15,head_y-10),o+Vector2(0,head_y-18),o+Vector2(15,head_y-10),
			o+Vector2(12,head_y-4),o+Vector2(-12,head_y-4)
		]),Color("6b4739"))

	# Layer 6: hat.
	poly_px(c,PackedVector2Array([
		o+Vector2(-34,-93),o+Vector2(34,-93),o+Vector2(24,-86),o+Vector2(-28,-86)
	]),Color("2e285f"))
	poly_px(c,PackedVector2Array([
		o+Vector2(-17,-92),o+Vector2(-5,-122),o+Vector2(6,-136),
		o+Vector2(18,-118),o+Vector2(15,-92)
	]),Color("3f347b"))
	rect_px(c,Rect2(o+Vector2(-19,-99),Vector2(37,5)),Color("d1a951"))
	rect_px(c,Rect2(o+Vector2(3,-120),Vector2(5,5)),Color("83e3ef"))

	# Layer 7: staff and spell, kept in hand through the entire attack.
	var hand := o+Vector2(torso_w+8,-31)
	var staff_angle := -0.2+staff_swing
	c.draw_set_transform(pivot+hand.rotated(fall_angle),fall_angle+staff_angle,Vector2.ONE)
	rect_px(c,Rect2(Vector2(-3,-54),Vector2(6,82)),Color("765136"))
	rect_px(c,Rect2(Vector2(-5,-52),Vector2(10,5)),Color("d4aa65"))
	ellipse(c,Vector2(0,-60),10,10,Color("5ed8e8"))
	ellipse(c,Vector2(0,-60),5,5,Color("efffff"))
	if state == "attack" and state_t >= 0.36 and state_t <= 0.62:
		var pulse := 9.0+sin((state_t-0.36)/0.26*PI)*8.0
		c.draw_arc(Vector2(0,-60),pulse,0,TAU,24,Color("91f0ff"),3.0)
		c.draw_line(Vector2(0,-60),Vector2(look.x*55,-60+look.y*20),Color("9defff"),5.0)
	c.draw_set_transform(Vector2.ZERO)
	if state == "hurt":
		c.draw_circle(base+Vector2(0,-50),38,Color(1,0.75,0.65,0.11))

static func slime(c: CanvasItem,p: Vector2,facing: Vector2,phase: float,state: String,state_t: float) -> void:
	var heading: int = direction_index(facing)
	var look: Vector2 = direction_vector(heading)
	var t := phase
	var squash := 1.0
	var stretch := 1.0
	var lift := 0.0
	if state == "walk":
		squash = 1.0+sin(t*2.0)*0.12
		stretch = 1.0-sin(t*2.0)*0.09
		lift = maxf(0.0,sin(t*2.0))*2.0
	elif state == "idle":
		squash = 1.0+sin(t)*0.04
		stretch = 1.0-sin(t)*0.03
	elif state == "attack":
		var pulse := sin(clampf(state_t,0.0,1.0)*PI)
		stretch = 1.0+pulse*0.55
		squash = 1.0-pulse*0.28
		p += look*pulse*24.0
	elif state == "hurt":
		squash = 1.0-sin(state_t*PI)*0.25
		stretch = 1.0+sin(state_t*PI)*0.18
		p -= look*sin(state_t*PI)*8.0
	elif state == "death":
		squash = lerpf(1.0,0.18,state_t)
		stretch = lerpf(1.0,1.55,state_t)
	shadow(c,p+Vector2(0,13),30*stretch,7)
	var pts := PackedVector2Array()
	var segments := 20
	for i in segments:
		var a := float(i)/float(segments)*TAU
		var wave := sin(a*3.0+t*1.7)*2.0
		var rx := (27.0+wave)*stretch
		var ry := (22.0+wave*0.4)*squash
		var yy := sin(a)*ry
		if yy > 5.0:
			yy = 5.0+yy*0.32
		pts.append(p+Vector2(cos(a)*rx,yy-8.0-lift))
	poly_px(c,pts,Color("55c85f"))
	ellipse(c,p+Vector2(-8,-18-lift),11,8,Color("84e77b"))
	ellipse(c,p+Vector2(4,-13-lift),13,6,Color("68d969"))
	var eye_center: Vector2 = p+look*6.0+Vector2(0,-12-lift)
	var right: Vector2 = Vector2(look.y,-look.x)
	if heading in [2,6]:
		ellipse(c,eye_center+right*3,3.5,5,Color("112b35"))
		ellipse(c,eye_center+right*4+Vector2(-1,-2),1.2,1.6,Color.WHITE)
	else:
		for sgn in [-1.0,1.0]:
			var ep: Vector2 = eye_center+right*float(sgn)*7.0
			ellipse(c,ep,3.5,5,Color("112b35"))
			ellipse(c,ep+Vector2(-1,-2),1.2,1.6,Color.WHITE)
	if state == "attack" and state_t > 0.4 and state_t < 0.7:
		for i in 5:
			var q: Vector2 = p+look*(30.0+float(i)*9.0)+right*float(i-2)*3.0
			ellipse(c,q,3.0,2.0,Color("9af58c"))

static func wolf(c: CanvasItem,p: Vector2,facing: Vector2,phase: float,state: String,state_t: float) -> void:
	var heading: int = direction_index(facing)
	var f: Vector2 = direction_vector(heading).normalized()
	var r: Vector2 = Vector2(f.y,-f.x)
	var gait := sin(phase*2.0)
	var body_center: Vector2 = p-f*4.0+Vector2(0,-23)
	var lunge := 0.0
	if state == "attack":
		lunge = sin(clampf(state_t,0.0,1.0)*PI)*22.0
	elif state == "hurt":
		lunge = -sin(clampf(state_t,0.0,1.0)*PI)*10.0
	elif state == "death":
		body_center.y += state_t*18.0
		f = f.rotated(state_t*0.7*(1.0 if heading<4 else -1.0))
		r = Vector2(f.y,-f.x)
	body_center += f*lunge
	shadow(c,p+f*lunge+Vector2(0,10),34,8)

	# Tail behind body.
	var tail_root: Vector2 = body_center-f*24.0
	var tail_tip: Vector2 = tail_root-f*25.0+r*(10.0+sin(phase)*5.0)
	c.draw_line(tail_root,tail_tip,OUTLINE,12.0)
	c.draw_line(tail_root,tail_tip,Color("596175"),8.0)
	ellipse(c,tail_tip,7,7,Color("80879a"))

	# Four independently planted legs.
	for i in 4:
		var front := 1.0 if i>=2 else -1.0
		var side_sign := -1.0 if i%2==0 else 1.0
		var swing := gait*(1.0 if (i==0 or i==3) else -1.0) if state=="walk" else 0.0
		var hip: Vector2 = body_center+f*front*16.0+r*side_sign*10.0
		var paw: Vector2 = hip+f*swing*7.0+Vector2(0,24.0+absf(swing)*2.0)
		c.draw_line(hip,paw,OUTLINE,9.0)
		c.draw_line(hip,paw,Color("555e72"),5.0)
		ellipse(c,paw,6,3.5,Color("c4c7cf"))

	# Body and shoulder mass.
	ellipse(c,body_center,30,18,Color("596175"))
	ellipse(c,body_center+f*10.0,21,17,Color("6d7488"))
	ellipse(c,body_center-f*11.0+r*4.0,13,10,Color("83899a"))

	# Head, muzzle, ears, all positioned from actual 8-direction vector.
	var head: Vector2 = body_center+f*31.0+Vector2(0,-5)
	ellipse(c,head,15,14,Color("697186"))
	var muzzle: Vector2 = head+f*13.0+Vector2(0,4)
	ellipse(c,muzzle,10,7,Color("b5b8c2"))
	var ear_base_l: Vector2 = head-f*2.0+r*9.0+Vector2(0,-9)
	var ear_base_r: Vector2 = head-f*2.0-r*9.0+Vector2(0,-9)
	poly_px(c,PackedVector2Array([
		ear_base_l+r*3.0,ear_base_l-r*3.0,ear_base_l-f*9.0+Vector2(0,-11)
	]),Color("555d72"))
	poly_px(c,PackedVector2Array([
		ear_base_r+r*3.0,ear_base_r-r*3.0,ear_base_r-f*9.0+Vector2(0,-11)
	]),Color("555d72"))
	# Eyes only on visible/front-ish views.
	if heading not in [3,4,5]:
		var eye_f: Vector2 = head+f*6.0+Vector2(0,-3)
		for sgn in [-1.0,1.0]:
			ellipse(c,eye_f+r*sgn*5.0,2.5,2.5,Color("b91f32"))
	ellipse(c,muzzle+f*7.0,3.5,3.0,Color("151a20"))
	if state == "attack" and state_t>0.33 and state_t<0.72:
		c.draw_arc(muzzle+f*8.0,12,-0.7,0.7,12,Color("f2e8d5"),3.0)
		c.draw_line(muzzle+f*8.0,muzzle+f*23.0,Color("d94343"),3.0)
	if state == "hurt":
		c.draw_circle(head,22,Color(1,0.45,0.45,0.12))
