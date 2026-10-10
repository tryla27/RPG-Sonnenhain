extends RefCounted
# Aussehen des Dunklen Golems (eigener Entwurf, kein Nachbau):
# gebückter Koloss aus kantigen, steinig-schwarzen Basaltblöcken mit lila
# Elixier-Rissen, riesigen Fäusten, tief sitzendem Kopf mit zwei glühenden
# Spalten und schwebenden Brocken an den Schultern. Dazu Altar, Steinhagel,
# Brocken, Schrei-Welle und der Zerfall in Einzelteile (Ragdoll im Bild).
#
# Gezeichnet wird in Weltkoordinaten. Einheit u = visual_scale (Großer Golem 4,
# halber 2); Maße unten in u. Der große Golem ist so etwa 320 px hoch und
# 380 px breit (5× Spielergröße).

const GolemBoss=preload("res://components/golem_boss.gd")

const BASALT:=Color("2a2730")
const BASALT_LIGHT:=Color("3d3945")
const BASALT_TOP:=Color("57505f")
const OUTLINE:=Color("121016")
const CRACK:=Color("b45cff")
const CRACK_GLOW:=Color("e3b8ff")

## Ein kantiger Block: Achteck mit abgeschrägten Ecken, Lichtkante oben.
## rot dreht den Block um seine Mitte (für fliegende Teile), ohne die
## Zeichen-Transformation der Welt anzufassen.
static func block(c:CanvasItem,center:Vector2,size:Vector2,u:float,shade:Color=BASALT,rot:float=0.0)->void:
	var w:=size.x*u*0.5
	var h:=size.y*u*0.5
	var k:=minf(w,h)*0.35
	var local:=[Vector2(-w+k,-h),Vector2(w-k,-h),Vector2(w,-h+k),Vector2(w,h-k),Vector2(w-k,h),Vector2(-w+k,h),Vector2(-w,h-k),Vector2(-w,-h+k)]
	var pts:=PackedVector2Array()
	for v in local:pts.append(center+(v as Vector2).rotated(rot))
	var outline:=PackedVector2Array()
	for p in pts:outline.append(center+(p-center)*1.0+(p-center).normalized()*u*0.6)
	c.draw_colored_polygon(outline,OUTLINE)
	c.draw_colored_polygon(pts,shade)
	c.draw_colored_polygon(PackedVector2Array([pts[0],pts[1],pts[2],center+Vector2(w,-h*0.35).rotated(rot),center+Vector2(-w,-h*0.35).rotated(rot),pts[7]]),shade.lightened(0.10))
	c.draw_line(pts[0],pts[1],BASALT_TOP,maxf(1.0,u*0.9))

static func crack(c:CanvasItem,points:Array,u:float,glow:float)->void:
	var line:=PackedVector2Array(points)
	c.draw_polyline(line,Color(CRACK_GLOW,0.25*glow),u*2.2)
	c.draw_polyline(line,Color(CRACK,0.55+0.45*glow),maxf(1.0,u*0.8))

## Der Golem. state: walk, shield, scrape, scream_pause, rise.
static func draw_golem(c:CanvasItem,pos:Vector2,type:int,info:Dictionary,facing:Vector2,time:float,flash:float)->void:
	var u:=GolemBoss.visual_scale(type)
	var state:=str(info.get("state","walk"))
	var mirror:=-1.0 if facing.x<-0.2 else 1.0
	var back:=facing.y<-0.6 and absf(facing.x)<0.5
	var bob:=sin(time*3.2)*u*0.8 if state=="walk" else 0.0
	var crouch:=10.0 if state=="shield" else 0.0
	var rise:=1.0
	if state=="rise":rise=clampf(1.0-float(info.get("timer",0.0))/2.0,0.05,1.0)
	var glow:=0.5+0.5*sin(time*2.4)
	if state=="shield":glow=0.15
	if state=="scream_pause":glow=1.0
	var o:=pos+Vector2(0,(1.0-rise)*40.0*u)
	# Schatten
	var shadow_w:=52.0*u
	c.draw_colored_polygon(_ellipse(pos+Vector2(0,u*2),shadow_w,shadow_w*0.28),Color(0,0,0,0.30))
	var swing:=sin(time*3.2)
	var arm_l:=Vector2(-40,-24+swing*3)
	var arm_r:=Vector2(40,-24-swing*3)
	if state=="shield":
		arm_l=Vector2(-22,-30);arm_r=Vector2(22,-30)
	elif state=="scrape":
		var aim:=Vector2(info.get("aim",[0,1])[0],info.get("aim",[0,1])[1])
		arm_r=Vector2(40+aim.x*16*mirror,-6+aim.y*10)
	elif state=="scream_pause":
		arm_l=Vector2(-48,-44);arm_r=Vector2(48,-44)
	var P:=func(v:Vector2)->Vector2:return o+Vector2(v.x*mirror,v.y+crouch+bob/u)*u
	# Beine (kurz, stämmig)
	for side:int in [-1,1]:
		var step:float=swing*side*3.0 if state=="walk" else 0.0
		block(c,P.call(Vector2(16*side,-8+step*0.3)),Vector2(18,16),u,BASALT)
	# Arm hinten (bei Seitenansicht verdeckt)
	block(c,P.call(Vector2(arm_l.x*0.82,-48)),Vector2(22,26),u,BASALT)
	block(c,P.call(arm_l),Vector2(30,28),u,BASALT_LIGHT)
	# Rumpf
	block(c,P.call(Vector2(0,-44)),Vector2(70,50),u,BASALT if not back else BASALT.darkened(0.1))
	crack(c,[P.call(Vector2(-20,-60)),P.call(Vector2(-8,-48)),P.call(Vector2(-14,-36)),P.call(Vector2(-2,-24))],u,glow)
	crack(c,[P.call(Vector2(18,-58)),P.call(Vector2(10,-44)),P.call(Vector2(22,-30))],u,glow)
	# Schultern
	for side in [-1,1]:
		block(c,P.call(Vector2(33*side,-64)),Vector2(30,26),u,BASALT_LIGHT)
	# Kopf tief zwischen den Schultern
	if not back:
		var head_y:=-68.0 if state!="scream_pause" else -74.0
		block(c,P.call(Vector2(0,head_y)),Vector2(28,20),u,BASALT_LIGHT)
		# gesprungene Basaltplatte mit zwei glühenden Spalten
		c.draw_line(P.call(Vector2(-10,head_y-2)),P.call(Vector2(10,head_y-6)),OUTLINE,u*0.8)
		for side in [-1,1]:
			var eye:Vector2=P.call(Vector2(6*side,head_y+2))
			c.draw_rect(Rect2(eye-Vector2(3.5*u,0.9*u),Vector2(7*u,1.8*u)),Color(CRACK_GLOW,0.35+0.4*glow))
			c.draw_rect(Rect2(eye-Vector2(2.6*u,0.5*u),Vector2(5.2*u,1.0*u)),Color(CRACK,0.7+0.3*glow))
	# Arm vorn mit Faust
	block(c,P.call(Vector2(arm_r.x*0.82,-48)),Vector2(22,26),u,BASALT)
	block(c,P.call(arm_r),Vector2(32,30),u,BASALT_LIGHT)
	crack(c,[P.call(arm_r+Vector2(-8,-6)),P.call(arm_r+Vector2(2,0)),P.call(arm_r+Vector2(-2,8))],u,glow)
	# Schwebende Brocken über den Schultern
	for k in 4:
		var a:=time*0.9+k*TAU/4.0
		var stone:Vector2=P.call(Vector2(cos(a)*40,-80+sin(a*1.3)*6))
		block(c,stone,Vector2(9,8),u,BASALT_LIGHT)
		c.draw_rect(Rect2(stone-Vector2(u,u)*0.5,Vector2(u,u)),Color(CRACK,0.6*glow))
	if state=="shield":
		# Steinhülle: dunkler Schleier über dem gebeugten Körper
		c.draw_colored_polygon(_ellipse(P.call(Vector2(0,-42)),46*u,36*u),Color(0.10,0.09,0.13,0.45))
		c.draw_arc(P.call(Vector2(0,-42)),40*u,PI*1.05,PI*1.95,24,Color(CRACK,0.5),u)
	if flash>0.0:
		c.draw_colored_polygon(_ellipse(P.call(Vector2(0,-44)),36*u,30*u),Color(1,1,1,minf(0.35,flash*2.0)))
	if state=="rise":
		for k in 8:
			var d:=pos+Vector2.RIGHT.rotated(k*TAU/8.0+time)*(30*u*rise)
			c.draw_circle(d,6*u*(1.0-rise*0.5),Color("8c7d74",0.35))

static func _ellipse(center:Vector2,rx:float,ry:float)->PackedVector2Array:
	var pts:=PackedVector2Array()
	for k in 20:
		var a:=k*TAU/20.0
		pts.append(center+Vector2(cos(a)*rx,sin(a)*ry))
	return pts

## Altar im Himmelsgarten: Steinplatte mit lila Rissen und drei Opferschalen.
static func draw_altar(c:CanvasItem,pos:Vector2,active:bool,time:float)->void:
	c.draw_colored_polygon(_ellipse(pos+Vector2(0,10),120,40),Color(0,0,0,0.25))
	block(c,pos,Vector2(56,22),4.0,BASALT)
	var glow:=0.4+0.4*sin(time*2.0)
	if active:glow=0.15
	crack(c,[pos+Vector2(-80,-10),pos+Vector2(-30,4),pos+Vector2(10,-8),pos+Vector2(70,6)],3.0,glow)
	for k in 3:
		var bowl:=pos+Vector2(-60+k*60,-30)
		c.draw_rect(Rect2(bowl-Vector2(14,6),Vector2(28,10)),Color("4a4450"))
		c.draw_rect(Rect2(bowl-Vector2(10,9),Vector2(20,4)),[Color("8a8580"),Color("c84f55"),Color("547bd1")][k])

## Steinhagel-Feld, Vorwarnungen, fallende Steine, Würfe, liegende Brocken.
static func draw_world_fx(c:CanvasItem,world,time:float)->void:
	for f in world.fields:
		var center:=Vector2(f["pos"][0],f["pos"][1])
		var fade:=clampf(float(f["life"])/1.0,0.0,1.0)
		c.draw_circle(center,GolemBoss.FIELD_RADIUS,Color(CRACK,0.07*fade))
		c.draw_arc(center,GolemBoss.FIELD_RADIUS,0,TAU,72,Color(CRACK,0.6*fade),4.0)
		c.draw_arc(center,GolemBoss.FIELD_RADIUS-14,time,time+TAU*0.8,48,Color(CRACK_GLOW,0.25*fade),2.0)
	for h in world.hail:
		var p:=Vector2(h["pos"][0],h["pos"][1])
		var t:=1.0-clampf(float(h["delay"])/GolemBoss.HAIL_DELAY,0.0,1.0)
		c.draw_colored_polygon(_ellipse(p,GolemBoss.HAIL_RADIUS*(0.4+0.6*t),GolemBoss.HAIL_RADIUS*0.45*(0.4+0.6*t)),Color(0,0,0,0.18+0.25*t))
		c.draw_arc(p,GolemBoss.HAIL_RADIUS,0,TAU,24,Color(CRACK,0.35+0.4*t),2.0)
		var falling:=p+Vector2(-20,-260)*(1.0-t)
		block(c,falling,Vector2(9,8),2.6,BASALT_LIGHT)
	for t in world.throws:
		var start:=Vector2(t["from"][0],t["from"][1])
		var dir:=Vector2(t["dir"][0],t["dir"][1])
		var tt:=float(t["t"])
		var p:=GolemBoss.throw_position(start,dir,tt)
		var lift:=GolemBoss.throw_height(tt)
		c.draw_colored_polygon(_ellipse(p,GolemBoss.BOULDER_RADIUS,GolemBoss.BOULDER_RADIUS*0.35),Color(0,0,0,0.3))
		block(c,p+Vector2(0,-lift-20),Vector2(22,20),4.0,BASALT_LIGHT,tt*8.0)
	for b in world.boulders:
		draw_boulder(c,Vector2(b[0],b[1]))

static func draw_boulder(c:CanvasItem,p:Vector2)->void:
	c.draw_colored_polygon(_ellipse(p+Vector2(0,10),GolemBoss.BOULDER_RADIUS,GolemBoss.BOULDER_RADIUS*0.32),Color(0,0,0,0.3))
	block(c,p+Vector2(0,-14),Vector2(22,20),4.0,BASALT_LIGHT)
	crack(c,[p+Vector2(-18,-24),p+Vector2(-2,-14),p+Vector2(12,-22)],2.0,0.4)

## Vorwarnung beim Schaben: Linie in Wurfrichtung.
static func draw_scrape_warning(c:CanvasItem,pos:Vector2,info:Dictionary)->void:
	if str(info.get("state",""))!="scrape":return
	var dir:=Vector2(info.get("aim",[0,1])[0],info.get("aim",[0,1])[1]).normalized()
	var t:=1.0-clampf(float(info.get("timer",0.0))/GolemBoss.SCRAPE_TIME,0.0,1.0)
	var length:=GolemBoss.THROW_FLIGHT+GolemBoss.THROW_ROLL
	var side:=dir.orthogonal()*GolemBoss.BOULDER_RADIUS
	c.draw_colored_polygon(PackedVector2Array([pos-side,pos+side,pos+dir*length+side,pos+dir*length-side]),Color(CRACK,0.10+0.18*t))

## Schrei: Wellenringe, die über die ganze Map laufen (Bildschirmmitte).
static func draw_scream(c:CanvasItem,center:Vector2,age:float)->void:
	if age<0.0 or age>3.0:return
	for k in 4:
		var r:=(age-k*0.25)*1400.0
		if r<=0.0:continue
		var a:=clampf(1.0-age/3.0,0.0,1.0)
		c.draw_arc(center,r,0,TAU,96,Color(CRACK_GLOW,0.35*a),18.0)
		c.draw_arc(center,r,0,TAU,96,Color(CRACK,0.6*a),5.0)

# --- Zerfall in Einzelteile (Ragdoll im Bild) ---------------------------------

## Teile mit Flugbahn; jedes Teil: {pos, z, vel, vz, rot, vrot, size, life}
static func make_debris(pos:Vector2,type:int)->Array:
	var u:=GolemBoss.visual_scale(type)
	var parts:Array=[]
	var layout:=[[Vector2(0,-44),Vector2(70,50)],[Vector2(-36,-64),Vector2(32,26)],[Vector2(36,-64),Vector2(32,26)],[Vector2(0,-68),Vector2(28,20)],[Vector2(-44,-24),Vector2(30,28)],[Vector2(44,-24),Vector2(32,30)],[Vector2(-16,-8),Vector2(18,16)],[Vector2(16,-8),Vector2(18,16)]]
	for k in 6:layout.append([Vector2(randf_range(-40,40),randf_range(-80,-20)),Vector2(9,8)])
	for part in layout:
		var local:Vector2=part[0]
		var out:=Vector2(local.x,0).normalized() if absf(local.x)>1.0 else Vector2.RIGHT.rotated(randf()*TAU)
		parts.append({"pos":pos+Vector2(local.x*u,0),"z":-local.y*u,"vel":(out*randf_range(40,140)+Vector2(randf_range(-30,30),randf_range(-20,40)))*u/4.0,"vz":randf_range(60,220)*u/4.0,"rot":0.0,"vrot":randf_range(-3,3),"size":part[1],"u":u,"life":7.0})
	return parts

static func update_debris(parts:Array,delta:float)->void:
	for i in range(parts.size()-1,-1,-1):
		var d:Dictionary=parts[i]
		d["life"]=float(d["life"])-delta
		if float(d["life"])<=0.0:
			parts.remove_at(i);continue
		d["vz"]=float(d["vz"])-900.0*delta
		d["z"]=float(d["z"])+float(d["vz"])*delta
		if float(d["z"])<=0.0:
			d["z"]=0.0
			d["vz"]=-float(d["vz"])*0.32
			d["vel"]=Vector2(d["vel"])*0.6
			d["vrot"]=float(d["vrot"])*0.5
		d["pos"]=Vector2(d["pos"])+Vector2(d["vel"])*delta
		d["rot"]=float(d["rot"])+float(d["vrot"])*delta

static func draw_debris(c:CanvasItem,parts:Array)->void:
	for d in parts:
		var fade:=clampf(float(d["life"])/1.5,0.0,1.0)
		var p:Vector2=d["pos"]
		c.draw_colored_polygon(_ellipse(p,Vector2(d["size"]).x*float(d["u"])*0.4,Vector2(d["size"]).x*float(d["u"])*0.12),Color(0,0,0,0.25*fade))
		block(c,p+Vector2(0,-float(d["z"])),Vector2(d["size"]),float(d["u"]),BASALT_LIGHT if fade>0.5 else BASALT_LIGHT.darkened(0.3),float(d["rot"]))
