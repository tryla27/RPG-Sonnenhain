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

## Echter Stein (Golem v2): unregelmäßige Form mit 9–12 Ecken, drei
## Helligkeitsflächen (Licht oben links, Seite, Schatten unten rechts), 2–3
## Dellen mit hellem Rand und ein feiner Riss. Gleiche Saat = gleiche Form.
static func stone_shape(seed:int,radius:float)->PackedVector2Array:
	var rng:=RandomNumberGenerator.new()
	rng.seed=seed
	var n:=rng.randi_range(9,12)
	var pts:=PackedVector2Array()
	for k in n:
		var a:=k*TAU/n+rng.randf_range(-0.16,0.16)
		var r:=radius*rng.randf_range(0.78,1.06)
		pts.append(Vector2(cos(a)*r,sin(a)*r*0.82))
	return pts

static func draw_stone(c:CanvasItem,center:Vector2,radius:float,seed:int,rot:float=0.0,fade:float=1.0,glow:float=0.0)->void:
	if radius<1.0:return
	var local:=stone_shape(seed,radius)
	var pts:=PackedVector2Array()
	for v in local:pts.append(center+v.rotated(rot))
	var outline:=PackedVector2Array()
	for v in local:outline.append(center+(v+v.normalized()*maxf(1.5,radius*0.07)).rotated(rot))
	c.draw_colored_polygon(outline,Color(OUTLINE,fade))
	c.draw_colored_polygon(pts,Color(BASALT,fade))
	# Lichtfläche: Ecken oben links, zur Mitte hin versetzt.
	var light_dir:=Vector2(-0.6,-0.8).rotated(-rot)
	var lit:=PackedVector2Array()
	var shade:=PackedVector2Array()
	for v in local:
		var d:=v.normalized().dot(light_dir)
		if d>-0.15:lit.append(center+(v*0.92+light_dir*radius*0.06).rotated(rot))
		if d<0.2:shade.append(center+(v*0.96).rotated(rot))
	if lit.size()>=3:
		lit.append(center+(light_dir*radius*0.05).rotated(rot))
		c.draw_colored_polygon(lit,Color(BASALT_LIGHT,fade))
	if shade.size()>=3:
		shade.append(center+(-light_dir*radius*0.15).rotated(rot))
		c.draw_colored_polygon(shade,Color(BASALT.darkened(0.28),fade))
	# Oberkante hell.
	var rng:=RandomNumberGenerator.new()
	rng.seed=seed*7+3
	for k in local.size():
		var a:Vector2=local[k]
		var b:Vector2=local[(k+1)%local.size()]
		if ((a+b)*0.5).normalized().dot(light_dir)>0.45:
			c.draw_line(center+a.rotated(rot),center+b.rotated(rot),Color(BASALT_TOP.lightened(0.15),fade),maxf(1.0,radius*0.06))
	# Dellen: unregelmäßige Mulden, heller Rand unten rechts; schräg versetzt,
	# damit sie nicht wie Augen nebeneinander liegen.
	var first:=rng.randf()*TAU
	for k in rng.randi_range(2,3):
		var ang:=first+k*rng.randf_range(2.0,2.6)
		var p:=Vector2(cos(ang)*rng.randf_range(0.25,0.5),sin(ang)*rng.randf_range(0.2,0.4))*radius
		var r:=radius*rng.randf_range(0.09,0.15)
		var dent:=stone_shape(seed*31+k,r)
		var rim:=PackedVector2Array()
		var hole:=PackedVector2Array()
		for v in dent:
			rim.append(center+(p+v*1.15+Vector2(r*0.3,r*0.3)).rotated(rot))
			hole.append(center+(p+v).rotated(rot))
		c.draw_colored_polygon(rim,Color(BASALT_TOP,0.75*fade))
		c.draw_colored_polygon(hole,Color(BASALT.darkened(0.45),0.9*fade))
	# Feiner Riss.
	var a0:=Vector2(rng.randf_range(-0.5,-0.1),rng.randf_range(-0.5,0.0))*radius
	var a1:=a0+Vector2(radius*0.3,radius*rng.randf_range(0.1,0.3))
	var a2:=a1+Vector2(radius*0.25,-radius*rng.randf_range(0.05,0.25))
	var line:=PackedVector2Array([center+a0.rotated(rot),center+a1.rotated(rot),center+a2.rotated(rot)])
	c.draw_polyline(line,Color(OUTLINE,0.8*fade),maxf(1.0,radius*0.05))
	if glow>0.0:c.draw_polyline(line,Color(CRACK,glow*fade),maxf(1.0,radius*0.035))

static func crack(c:CanvasItem,points:Array,u:float,glow:float)->void:
	var line:=PackedVector2Array(points)
	c.draw_polyline(line,Color(CRACK_GLOW,0.25*glow),u*2.2)
	c.draw_polyline(line,Color(CRACK,0.55+0.45*glow),maxf(1.0,u*0.8))

## Pixel-Sprite (tools/build_golem_art.py): 128×128 je Bild, Füße bei y=124.
## Zeilen: vorn, Seite (nach rechts), hinten. Spalten: FRAMES.
const SHEET:=preload("res://art/monsters/golem/golem_sheet.png")
const GLOW:=preload("res://art/monsters/golem/golem_glow.png")
const FRAME:=128.0
const FEET_Y:=124.0
const FRAMES:=["idle0","idle1","walk0","walk1","walk2","walk3","shield","scrape","stomp","scream","rise"]

## Sprite-Maßstab: großer Golem 2,5 (≈ 320 px), halber 1,25.
static func sprite_scale(type:int)->float:
	return GolemBoss.visual_scale(type)*0.625

## Spalte im Sprite-Blatt für Zustand und Zeit.
static func frame_index(state:String,walking:bool,time:float)->int:
	match state:
		"shield":return FRAMES.find("shield")
		"scrape":return FRAMES.find("scrape")
		"stomp":return FRAMES.find("stomp")
		"scream_pause":return FRAMES.find("scream")
		"rise":return FRAMES.find("rise")
	if walking:return FRAMES.find("walk0")+int(floor(time*4.0))%4
	return FRAMES.find("idle0")+int(floor(time*1.5))%2

## Zeile und Spiegelung aus der Blickrichtung.
static func view_row(facing:Vector2)->Array:
	if facing.y<-0.6 and absf(facing.x)<0.6:return [2,false]
	if absf(facing.x)>=0.6:return [1,facing.x<0.0]
	return [0,false]

## Der Golem. state: walk, shield, scrape, stomp, scream_pause, rise.
static func draw_golem(c:CanvasItem,pos:Vector2,type:int,info:Dictionary,facing:Vector2,time:float,flash:float,walking:bool=false)->void:
	var u:=GolemBoss.visual_scale(type)
	var s:=sprite_scale(type)
	var state:=str(info.get("state","walk"))
	var rise:=1.0
	if state=="rise":rise=clampf(1.0-float(info.get("timer",0.0))/2.0,0.05,1.0)
	var glow:=0.5+0.5*sin(time*2.4)
	if state=="shield":glow=0.15
	if state=="scream_pause":glow=1.0
	# Schatten
	var shadow_w:=52.0*u
	c.draw_colored_polygon(_ellipse(pos+Vector2(0,u*2),shadow_w,shadow_w*0.28),Color(0,0,0,0.30))
	var col:=frame_index(state,walking,time)
	var rv:Array=view_row(facing)
	var row:int=rv[0]
	var mirror:bool=rv[1]
	var region:=Rect2(col*FRAME,row*FRAME,FRAME,FRAME)
	var size:=Vector2(FRAME,FRAME)*s
	var top_left:=pos-Vector2(FRAME*0.5,FEET_Y)*s
	# Beim Aufstehen steigt er aus dem Boden (unten abgeschnitten, langsam sichtbar).
	if rise<1.0:
		var hidden:=(1.0-rise)*FEET_Y*0.6
		region.size.y-=hidden
		size.y-=hidden*s
		top_left.y+=hidden*s
	var dest:=Rect2(top_left,size)
	if mirror:dest=Rect2(top_left+Vector2(size.x,0),Vector2(-size.x,size.y))
	c.draw_texture_rect_region(SHEET,dest,region,Color(1,1,1,0.35+0.65*rise))
	c.draw_texture_rect_region(GLOW,dest,region,Color(1,1,1,(0.45+0.55*glow)*rise))
	if state=="shield":
		# Steinhülle: dunkler Schleier über dem gebeugten Körper
		c.draw_colored_polygon(_ellipse(pos+Vector2(0,-42*u),40*u,34*u),Color(0.10,0.09,0.13,0.40))
		c.draw_arc(pos+Vector2(0,-42*u),38*u,PI*1.05,PI*1.95,24,Color(CRACK,0.5),u)
	if flash>0.0:
		c.draw_texture_rect_region(SHEET,dest,region,Color(2.6,2.6,2.6,minf(0.55,flash*3.0)))
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

## Kartensymbol des Altars: dunkler Stein mit lila Riss, pulsiert im Kampf.
## sleeping: 15-Minuten-Pause nach dem Sieg, Symbol grau ohne Leuchten.
static func draw_map_marker(c:CanvasItem,point:Vector2,active:bool,time:float,sleeping:bool=false)->void:
	var pulse:=0.5+0.5*sin(time*(6.0 if active else 2.0))
	c.draw_circle(point,10,OUTLINE)
	c.draw_colored_polygon(PackedVector2Array([point+Vector2(-7,-4),point+Vector2(-3,-8),point+Vector2(4,-8),point+Vector2(8,-3),point+Vector2(7,5),point+Vector2(-6,6)]),Color("5c5a60") if sleeping else BASALT_LIGHT)
	if sleeping:
		c.draw_polyline(PackedVector2Array([point+Vector2(-5,-1),point+Vector2(-1,2),point+Vector2(2,-3),point+Vector2(5,1)]),Color("8d8a92"),2.0)
		c.draw_arc(point,11,0,TAU,20,Color("8d8a92",0.6),2.0)
		return
	c.draw_polyline(PackedVector2Array([point+Vector2(-5,-1),point+Vector2(-1,2),point+Vector2(2,-3),point+Vector2(5,1)]),Color(CRACK,0.7+0.3*pulse),2.0)
	c.draw_arc(point,11+(2.0*pulse if active else 0.0),0,TAU,20,Color(CRACK_GLOW,0.5+0.4*pulse),2.0)

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
		draw_stone(c,falling,13.0,int(absf(p.x)*3.0+absf(p.y)),t*5.0)
	for t in world.throws:
		var start:=Vector2(t["from"][0],t["from"][1])
		var dir:=Vector2(t["dir"][0],t["dir"][1])
		var tt:=float(t["t"])
		var p:=GolemBoss.throw_position(start,dir,tt)
		var lift:=GolemBoss.throw_height(tt)
		c.draw_colored_polygon(_ellipse(p,GolemBoss.BOULDER_RADIUS,GolemBoss.BOULDER_RADIUS*0.35),Color(0,0,0,0.3))
		draw_stone(c,p+Vector2(0,-lift-26),46.0,stone_seed(start),tt*7.0,1.0,0.5)
	# Zerbröseln nach dem Kampf: Brocken sinken ein und werden blasser.
	var keep:=clampf(world.crumble/GolemBoss.CRUMBLE_TIME,0.0,1.0) if world.crumble>0.0 else 1.0
	for b in world.boulders:
		draw_boulder(c,Vector2(b[0],b[1]),keep)

static func stone_seed(p:Vector2)->int:
	return int(absf(p.x)*13.0+absf(p.y)*7.0)

static func draw_boulder(c:CanvasItem,p:Vector2,keep:float=1.0)->void:
	c.draw_colored_polygon(_ellipse(p+Vector2(0,10),GolemBoss.BOULDER_RADIUS*keep,GolemBoss.BOULDER_RADIUS*0.32*keep),Color(0,0,0,0.3*keep))
	if keep<0.08:return
	draw_stone(c,p+Vector2(0,-16*keep),46.0*keep,stone_seed(p),0.0,clampf(keep*1.4,0.0,1.0),0.35 if keep>0.6 else 0.0)

## Vorwarnung beim Stampfen: Ring am Boden, der sich bis zum Einschlag füllt.
## ring_only: nur die Linie, über allem gezeichnet, damit der Ring auch hinter
## dem Golem sichtbar bleibt.
static func draw_stomp_warning(c:CanvasItem,info:Dictionary,type:int,ring_only:bool=false)->void:
	if str(info.get("state",""))!="stomp":return
	var at:Array=info.get("stomp_at",[0,0])
	var spot:=Vector2(float(at[0]),float(at[1]))
	var radius:=GolemBoss.STOMP_RADIUS*GolemBoss.visual_scale(type)/4.0
	var t:=1.0-clampf(float(info.get("timer",0.0))/GolemBoss.STOMP_WINDUP,0.0,1.0)
	if ring_only:
		var line:=_ellipse(spot,radius,radius*0.5)
		line.append(line[0])
		c.draw_polyline(line,Color(CRACK_GLOW,0.35+0.3*t),2.0)
		return
	c.draw_colored_polygon(_ellipse(spot,radius,radius*0.5),Color(CRACK,0.10+0.12*t))
	c.draw_colored_polygon(_ellipse(spot,maxf(1.0,radius*t),maxf(0.5,radius*0.5*t)),Color(CRACK,0.28))
	var ring:=_ellipse(spot,radius,radius*0.5)
	ring.append(ring[0])
	c.draw_polyline(ring,Color(CRACK_GLOW,0.55+0.4*t),3.0)

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
	for n in layout.size():
		var part:Array=layout[n]
		var local:Vector2=part[0]
		var out:=Vector2(local.x,0).normalized() if absf(local.x)>1.0 else Vector2.RIGHT.rotated(randf()*TAU)
		# Der Kopf (Teil 3) platzt am stärksten auseinander (Golem v2).
		var burst:=1.9 if n==3 else 1.0
		parts.append({"pos":pos+Vector2(local.x*u,0),"z":-local.y*u,"vel":(out*randf_range(40,140)+Vector2(randf_range(-30,30),randf_range(-20,40)))*u/4.0*burst,"vz":randf_range(60,220)*u/4.0*burst,"rot":0.0,"vrot":randf_range(-3,3)*burst,"size":part[1],"u":u,"life":7.0,"head":n==3})
	# Kopfsplitter: zusätzliche kleine Teile aus dem Kopf.
	for k in 6:
		var spray:=Vector2.RIGHT.rotated(randf()*TAU)
		parts.append({"pos":pos,"z":68.0*u,"vel":spray*randf_range(120,240)*u/4.0,"vz":randf_range(140,300)*u/4.0,"rot":0.0,"vrot":randf_range(-6,6),"size":Vector2(7,6),"u":u,"life":6.0})
	return parts

## Zerbröselnder Brocken: kleine Steine springen weg (gleiche Teile wie beim Zerfall).
static func make_crumble(pos:Vector2)->Array:
	var parts:Array=[]
	for k in 7:
		var out:=Vector2.RIGHT.rotated(randf()*TAU)
		parts.append({"pos":pos+out*randf_range(4,20),"z":randf_range(6,26),"vel":out*randf_range(30,90),"vz":randf_range(40,120),"rot":0.0,"vrot":randf_range(-4,4),"size":Vector2(randf_range(4,8),randf_range(4,7)),"u":2.4,"life":randf_range(2.0,3.0)})
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
		var size:Vector2=d["size"]
		draw_stone(c,p+Vector2(0,-float(d["z"])),(size.x+size.y)*0.5*float(d["u"])*0.42,int(d.get("seed",int(size.x*97+size.y*13))),float(d["rot"]),clampf(fade*1.3,0.0,1.0),0.6 if bool(d.get("head",false)) else 0.0)
