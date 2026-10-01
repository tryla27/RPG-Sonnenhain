extends RefCounted
## Native design renderer. Preview only; no combat stats or loot changes.
const Combat=preload("res://components/mob_combat.gd")
const Hero=preload("res://components/rpg_hero.gd")
const HEAVY=[4,7,9,12,13,14,16,24,26]
const ARMED=[2,4,7,8,9,12,13,14,15,16,20,24,26]
static func tier(level:int)->int:
	return Combat.weapon_tier(level)
static func box(c:CanvasItem,p:Vector2,x:float,y:float,w:float,h:float,col:Color)->void:
	var rect=Rect2((p+Vector2(x,y)*2).round(),Vector2(w,h)*2)
	c.draw_rect(rect,Color("17242a"))
	if w>=5 and h>=5:
		c.draw_rect(rect.grow(-2),col)
		c.draw_rect(Rect2(rect.position+Vector2(2,2),Vector2(rect.size.x-4,2)),col.lightened(.22))
		c.draw_rect(Rect2(rect.position+Vector2(2,4),Vector2(2,rect.size.y-6)),col.lightened(.12))
		c.draw_rect(Rect2(rect.position+Vector2(rect.size.x-4,4),Vector2(2,rect.size.y-6)),col.darkened(.24))
		c.draw_rect(Rect2(rect.position+Vector2(2,rect.size.y-4),Vector2(rect.size.x-4,2)),col.darkened(.32))
	else:
		c.draw_rect(rect.grow(-.5),col)
static func diamond(c:CanvasItem,p:Vector2,col:Color,size:float)->void:
	c.draw_colored_polygon(PackedVector2Array([p+Vector2(0,-size-2),p+Vector2(size*.6+2,0),p+Vector2(0,size+2),p+Vector2(-size*.6-2,0)]),Color("17242a"))
	c.draw_colored_polygon(PackedVector2Array([p+Vector2(0,-size),p+Vector2(size*.6,0),p+Vector2(0,size),p+Vector2(-size*.6,0)]),col)
	c.draw_colored_polygon(PackedVector2Array([p+Vector2(0,-size),p,p+Vector2(-size*.6,0)]),col.lightened(.3))
	c.draw_colored_polygon(PackedVector2Array([p,p+Vector2(size*.6,0),p+Vector2(0,size)]),col.darkened(.25))
static func weapon(c:CanvasItem,p:Vector2,t:int,level:int,side:int,back:bool,look:Vector2,attack:float=-1.0)->void:
	var rank=tier(level)
	var metal=[Color("8d795b"),Color("aa967a"),Color("b9c7cd"),Color("83dbe5"),Color("f6aa65"),Color("dbbaf2")][rank]
	var hand=p+Vector2(side*35,-9)
	var swing=0.0
	var heavy=HEAVY.has(t)
	if attack>=0.0:
		if t in [2,13,15,20]: swing=-.28*sin(attack*PI)*side
		elif heavy:
			if attack<.35: swing=lerpf(0.0,-1.1,smoothstep(0.0,.35,attack))*side
			elif attack<.43: swing=lerpf(-1.1,1.25,smoothstep(.35,.43,attack))*side
			elif attack<.72: swing=lerpf(1.25,0.0,smoothstep(.43,.72,attack))*side
		else: swing=lerpf(-.65,.95,smoothstep(.22,.55,attack))*side
	var angle=look.angle()+PI*.5
	c.draw_set_transform(hand,angle*.2+swing)
	hand=Vector2.ZERO
	box(c,hand,-3,5,6,5,Color("ac9876"))
	box(c,hand,-1,-9,2,28,Color("674b38"))
	if t in [2,13,15,20]:
		diamond(c,hand+Vector2(0,-28),metal,7+rank)
		if rank>=2: box(c,hand,-5,-11,10,2,Color("d9b964"))
	elif t in [4,7,9,16]:
		box(c,hand,-9 if heavy else -6,-19 if heavy else -15,18+rank if heavy else 12+rank,11 if heavy else 8,metal)
		box(c,hand,-9 if heavy else -6,-19 if heavy else -15,18+rank if heavy else 12+rank,2,metal.lightened(.25))
	else:
		box(c,hand,-2,-20-rank,4,23+rank,metal)
		box(c,hand,-5,2,10,2,Color("d9b964"))
		if rank>=3: box(c,hand,-1,-17,2,13,Color("fff0cd"))
	if rank>=4:
		diamond(c,hand+Vector2(0,8),metal.lightened(.3),4)
	c.draw_set_transform(Vector2.ZERO)
static func paint(c:CanvasItem,p:Vector2,t:int,level:int,look:Vector2,base:Color,phase:float=0.0,attack:float=-1.0)->void:
	var heading=Hero.direction_index(look)
	look=Vector2(sin(heading*PI/4.0),cos(heading*PI/4.0))
	var foot=p
	# Ground shadow remains fixed while the attack leans or lunges.
	box(c,foot,-19,13,38,4,Color("1a2929"))
	box(c,foot,-14,12,28,2,Color("21322f"))
	if attack>=0.0:
		var lunge=sin(smoothstep(.2,.8,attack)*PI)*9
		if HEAVY.has(t):
			lunge=0.0
			if attack>=.35 and attack<.43:lunge=lerpf(0.0,8.0,smoothstep(.35,.43,attack))
			elif attack>=.43 and attack<.72:lunge=lerpf(8.0,0.0,smoothstep(.43,.72,attack))
		p+=look*lunge
	else:
		p.y-=absf(sin(phase))*(.7 if HEAVY.has(t) else 2.0)
	var back=heading in [3,4,5]
	var profile=heading in [2,6]
	var side=-1 if heading in [5,6,7] else 1
	var diag=heading in [1,3,5,7]
	var stride=roundi(sin(phase)*(1.0 if HEAVY.has(t) else 2.0))
	var dark=base.darkened(.4)
	var light=base.lightened(.25)
	var eye=p+Vector2(side*(10 if diag else 16),-24)
	# All bodies stay upright. Back and side views change visible anatomy.
	if ARMED.has(t):
		if back: weapon(c,p,t,level,side,true,look,attack)
		var breadth=(14 if profile else 19) if HEAVY.has(t) else (12 if profile else 16)
		box(c,p,-breadth,-19,breadth*2,25,dark)
		box(c,p,-breadth+2,-18,breadth*2-4,20,base)
		for leg in [-1,1]:
			box(c,p,leg*7-3,5+stride*leg,6,10,dark)
			box(c,p,leg*7-4,13+stride*leg,8,3,Color("544439"))
		box(c,p,-9,-32,18,14,base)
		box(c,p,-11,-22,22,3,dark)
		if not back:
			if profile or diag: box(c,eye,-1,0,3,2,Color("fff0ba"))
			else:
				box(c,p,-6,-26,3,2,Color("fff0ba"))
				box(c,p,3,-26,3,2,Color("fff0ba"))
			diamond(c,p+Vector2(0,-13),light,6)
		else:
			box(c,p,-breadth+3,-17,breadth*2-6,22,dark)
			box(c,p,-1,-17,2,22,light)
		if t==2:
			box(c,p,-17,-34,34,7,Color("bb7882"))
			box(c,p,-11,-39,22,6,Color("bb7882"))
			for x in [-10,2,10]: box(c,p,x,-34,3,2,Color("f7e6be"))
		elif t in [7,13]:
			for x in [-1,1]: diamond(c,p+Vector2(x*28,-25),light,13)
		elif t in [8,14]:
			for x in [-1,1]: box(c,p,x*10-2,-40,4,12,Color("f4b279"))
		elif t==20:
			diamond(c,p+Vector2(0,-42),base,14)
		elif t in [12,24,26]:
			box(c,p,-11,-33,22,4,Color("d9b964"))
			if t==26:
				for x in [-8,0,8]: box(c,p,x,-40,3,8,Color("d9b964"))
			if not back: box(c,p,-11,-27,22,4,dark)
		if not back: weapon(c,p,t,level,side,false,look,attack)
	elif t in [3,17,21,23]:
		var width=21 if profile else 15
		box(c,p,-width,-13,width*2,21,base)
		for leg in [-1,1]:
			box(c,p,leg*(width-4)-2,6+stride*leg,4,10,dark)
		var hx=side*(width-3) if profile else (side*7 if diag else 0)
		box(c,p,hx-8,-28,16,18,light)
		if not back:
			box(c,p,hx+side*5,-21,7,6,Color("decba6"))
			box(c,p,hx-3,-24,2,2,Color("fff0b5"))
		else: box(c,p,hx-7,-28,14,12,dark)
		if t==17:
			for x in [-1,1]:
				box(c,p,hx+x*7,-41,2,15,Color("d9c9a9"))
				box(c,p,hx+x*9-3,-40,6,2,Color("d9c9a9"))
		elif t==23:
			for x in [-1,1]:
				box(c,p,x*19-7,-21,14,16,base.darkened(.2))
				box(c,p,x*22-6,-26,12,6,light)
		elif t==3:
			for x in [-1,1]: box(c,p,hx+x*6-2,-34,4,8,dark)
			box(c,p,-side*27,-5,12,4,dark)
		else:
			for x in [-1,1]: diamond(c,p+Vector2(x*20,-8),light,7)
	elif t in [1,6,10,19,25]:
		for x in [-1,1]:
			for leg in 3: box(c,p,x*19-3,-12+leg*9+stride*x,9,3,dark)
		box(c,p,-14,-23,28,34,base)
		box(c,p,-11,-25,22,5,light)
		box(c,p,-1,-23,2,32,dark)
		var hy=-28 if heading==4 else (-22 if back else (0 if heading==0 else -12))
		var hx=side*18 if profile else side*7 if diag else 0
		box(c,p,hx-7,hy,14,9,dark)
		if not back: box(c,p,hx-4,hy+2,8,2,Color("fff0b5"))
		if t in [6,10]:
			for x in [-1,1]: box(c,p,x*25-5,-26,10,10,light)
		elif t==25:
			for x in [-1,1]:
				box(c,p,x*22-9,-30,18,21,light)
				box(c,p,x*20-7,-3,14,17,base)
				diamond(c,p+Vector2(x*43,-36),dark,6)
		else:
			for x in [-1,1]: box(c,p,hx+x*6,-34 if back else hy-7,2,9,dark)
		if t in [6,19]: diamond(c,p+Vector2(0,-15),light,13)
	else:
		box(c,p,-15,-22,30,31,base)
		box(c,p,-11,-29,22,7,light)
		box(c,p,-19,-12,38,19,dark)
		box(c,p,-15,-13,30,19,base)
		if t in [11,18,22]:
			diamond(c,p+Vector2(0,-31),light,12)
			for x in [-1,1]: box(c,p,x*20-3,-10,6,17,light)
		if t==5:
			for x in [-1,1]:
				box(c,p,x*18-2,-35,4,20,dark)
				diamond(c,p+Vector2(x*36,-71),light,6)
		if not back:
			if t in [5,18,22]: diamond(c,p+Vector2(side*8 if profile else 0,-20),Color("f0ead2"),10)
			else:
				var x=side*11 if profile else side*5 if diag else 0
				box(c,p,x-6,-12,3,3,Color("243b3b"))
				if not profile: box(c,p,x+3,-12,3,3,Color("243b3b"))
		else: box(c,p,-8,-20,16,3,light)

	# Species-specific material detail and orientation, no rotated front-body sprites.
	if ARMED.has(t):
		if t in [4,7,9,13,16]:
			for joint in [-1,1]:
				box(c,p,joint*12-3,-17,6,6,base.darkened(.25))
				box(c,p,joint*10-2,3,4,3,light)
			if t==9:
				for crack in 3: box(c,p,-8+crack*6,-13+crack*5,2,6,Color("f4a660"))
			elif t in [4,16]: box(c,p,-8,-10,9,2,base.darkened(.55))
		else:
			for shoulder in [-1,1]:
				box(c,p,shoulder*13-4,-20,8,7,base.lightened(.05))
			box(c,p,-12,0,24,3,Color("574c43"))
			box(c,p,-2,0,4,4,Color("d9b964"))
			if back and heading!=4:
				box(c,p,side*8,-27,3,7,base.lightened(.1))
			if t in [12,24]:
				var shield=p+Vector2(-side*29,-1)
				diamond(c,shield,base.darkened(.15),18)
				diamond(c,shield+Vector2(-2,-3),Color("d9b964"),6)
	elif t in [3,17,21,23]:
		for mark in 3: box(c,p,-9+mark*7,-8,3,2,light)
		if t==3:
			box(c,p,-7,1,14,3,base.darkened(.3))
			if attack>=.35 and attack<=.7 and not back:
				box(c,p,side*10,-15,9,4,Color("f0e6cd"))
		elif t==21:
			for mark in [-1,1]: diamond(c,p+Vector2(mark*19,-16),light,5)
		elif t==23:
			for feather in 3:
				box(c,p,-25,-17+feather*4,8,2,light)
				box(c,p,17,-17+feather*4,8,2,light)
	elif t in [1,6,10,19,25]:
		for side_mark in [-1,1]:
			for mark in 2: box(c,p,side_mark*8-2,-16+mark*10,4,3,light)
	else:
		if t==0:
			box(c,p,-10,-23,7,3,base.lightened(.45))
			box(c,p,-6,3,16,2,base.darkened(.25))
		elif t==22:
			for shell in [-1,1]:
				box(c,p,shell*11,-22,2,25,base.lightened(.4))
			diamond(c,p+Vector2(0,-15),Color("f5f6e6"),8)
		elif t in [11,18]:
			for wisp in [-1,1]: box(c,p,wisp*8-2,7,4,8,base.lightened(.2))
	if (attack>=.35 and attack<=.45) if HEAVY.has(t) else (attack>=.4 and attack<=.72):
		var impact=p+look*44+Vector2(0,-12)
		if t in [2,5,11,15,18,20,22,25]:
			diamond(c,impact,base.lightened(.45),8)
			box(c,impact-look*12,-2,-1,4,2,base.lightened(.25))
		else:
			diamond(c,impact,Color("ffe5a7"),7)
			box(c,impact,-6,-1,12,2,Color("fff3d0"))

	if t==13:
		for shard in [-1,1]:
			diamond(c,p+Vector2(shard*42,-32),base.lightened(.3),18)
			diamond(c,p+Vector2(shard*42,-32),base.darkened(.1),8)
		diamond(c,p+Vector2(0,-30),base,40)
		if not back:diamond(c,p+Vector2(side*8 if profile else 0,-29),Color("dbfcff"),20)
		else:diamond(c,p+Vector2(0,-34),base.darkened(.18),22)
	elif t==14:
		for mark in 3:box(c,p,-11+mark*8,-14+mark*4,3,9,Color("efae6b"))
		box(c,p,-19,4,38,4,Color("733b37"))
	elif t==12:
		box(c,p,-12,-37,24,5,Color("d8c58b"))
		box(c,p,-2,-44,4,10,Color("d8c58b"))
		if not back:box(c,p,-8,-25,16,3,Color("d8c58b"))
