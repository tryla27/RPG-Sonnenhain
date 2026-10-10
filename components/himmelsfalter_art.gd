extends RefCounted
## Himmelsfalter (Gegner 25, Himmelsgarten): schwebender Sternenträger.
## Konzept 10.10.2026: flauschiger dunkelvioletter Nachtfalter, große obere und
## kleinere untere Flügel, gefiederte Fühler, Lavendel/Perlmutt/Gold, sternförmige
## Augenzeichnung auf den oberen Flügeln. Flügelschlag stufenlos (untere Flügel
## folgen verzögert), Schweben auch im Stand, Neigung beim Fliegen, eigener
## Rhythmus je Falter. Angriff: Flügel spreizen, Sternaugen hellen auf,
## Sternenstaub-Schuss. Niederlage: Flügel klappen zu, Absinken, Staubpunkte.
## Eigener Entwurf, gezeichnet in Bildschirmkoordinaten (Fuß = Bodenpunkt).

const OUTLINE:=Color("1d1428")
const WING:=Color("4b3a6e")
const WING_INNER:=Color("7a64a6")
const LAVENDER:=Color("b9a2dc")
const PEARL:=Color("efe4f7")
const GOLD:=Color("e7c36a")
const BODY:=Color("3a2d52")
const FUZZ:=Color("6f5a92")

## Obere/untere Flügelform (rechte Seite, offen) relativ zur Brust.
const UPPER:=[Vector2(2,-3),Vector2(14,-22),Vector2(30,-31),Vector2(44,-27),Vector2(48,-15),Vector2(40,-3),Vector2(24,4),Vector2(7,5)]
const LOWER:=[Vector2(3,3),Vector2(18,6),Vector2(30,15),Vector2(29,27),Vector2(17,31),Vector2(7,20)]
const HOVER_HEIGHT:=44.0
## Größe im Spiel (Spannweite offen ≈ 130 px bei Maßstab 1).
const SIZE:=1.35

## Flügelöffnung 0 (zu) … 1 (offen) für obere und untere Flügel.
static func flap(clock:float,seed:float,attack:float,death:float)->Vector2:
	var rate:=8.6+fposmod(seed*13.0,1.6)
	var f:=clock*rate+seed*7.0
	var upper:=0.5+0.5*cos(f)
	var lower:=0.5+0.5*cos(f-0.7)
	if attack>=0.0:
		# Ausholen: Flügel weit auf und kurz halten, beim Schuss schlagen sie zu.
		var spread:=smoothstep(0.0,0.35,attack)*(1.0-smoothstep(0.45,0.7,attack))
		upper=lerpf(upper,1.0,spread);lower=lerpf(lower,0.95,spread)
	if death>=0.0:
		var fold:=smoothstep(0.0,0.5,death)
		upper=lerpf(upper,0.08,fold);lower=lerpf(lower,0.05,fold)
	return Vector2(upper,lower)

static func paint(c:CanvasItem,foot:Vector2,look:Vector2,phase:float,attack:float,scale:float,tint:Color,visual:Dictionary={})->void:
	scale*=SIZE
	var clock:=float(visual.get("clock",0.0))
	var seed:=float(visual.get("seed",0.0))
	var death:=float(visual.get("death",-1.0))
	var hurt:=clampf(float(visual.get("hurt",0.0))/0.18,0.0,1.0)
	var walking:=bool(visual.get("walking",absf(phase)>0.0001))
	var open:=flap(clock,seed,attack,death)
	var bob:=sin(clock*3.1+seed*4.0)*3.0
	var height:=HOVER_HEIGHT+bob
	var alpha:=1.0
	if death>=0.0:
		height=lerpf(height,6.0,smoothstep(0.1,0.7,death))
		alpha=1.0-smoothstep(0.55,1.0,death)
	# Schatten am Boden, kleiner je höher er schwebt.
	var shadow_w:=26.0*scale*(1.0-height/140.0)
	c.draw_set_transform(Vector2.ZERO)
	c.draw_colored_polygon(_ellipse(foot,shadow_w,shadow_w*0.3,14),Color(0.08,0.06,0.12,0.28*alpha))
	var side_view:=absf(look.x)>0.65
	var facing_right:=look.x>=0.0
	var back:=look.y<-0.5 and not side_view
	var tilt:=0.0
	if walking:tilt=look.x*0.16
	var thorax:=foot+Vector2(0,-height)*scale
	c.draw_set_transform(thorax,tilt,Vector2(scale,scale))
	var flash:=hurt*0.55
	var col:=func(base:Color)->Color:
		var out:=base.lerp(Color.WHITE,flash)*tint
		out.a=base.a*alpha
		return out
	# Flügel: hinter dem Körper die unteren, dann die oberen. In der Seitenansicht
	# ist der ferne Flügel schmal und dunkler.
	for layer in ["lower","upper"]:
		for side in [-1.0,1.0]:
			var far:bool=side_view and ((side>0.0)!=facing_right)
			var width:float=(0.3+0.7*(open.y if layer=="lower" else open.x))*(0.45 if far else 1.0)
			if side_view and not far:width*=0.8
			var shape:Array=LOWER if layer=="lower" else UPPER
			var pts:=PackedVector2Array()
			for v in shape:
				var pv:Vector2=v
				# Beim Zuklappen heben sich die Flügelspitzen etwas.
				pts.append(Vector2(pv.x*width*side,pv.y-(1.0-width)*pv.x*0.25))
			var base:Color=WING if layer=="upper" else WING.darkened(0.08)
			if far:base=base.darkened(0.25)
			_outlined(c,pts,col.call(base))
			# Innenfläche und Perlmuttrand.
			var inner:=PackedVector2Array()
			for p in pts:inner.append(p*0.68+Vector2(side*2.0*width,0))
			c.draw_colored_polygon(inner,col.call(WING_INNER if layer=="upper" else LAVENDER.darkened(0.25)))
			var rim:=PackedVector2Array(pts);rim.append(pts[0])
			c.draw_polyline(rim,col.call(Color(PEARL,0.55)),1.4)
			if layer=="upper" and width>0.3:
				# Sternauge, hellt beim Angriff auf.
				var eye:=Vector2(27.0*width*side,-15.0)
				var glow:=0.0
				if attack>=0.0:glow=smoothstep(0.0,0.35,attack)*(1.0-smoothstep(0.5,0.8,attack))
				if glow>0.0:c.draw_circle(eye,9.0*width+4.0*glow,col.call(Color(GOLD,0.35*glow)))
				c.draw_colored_polygon(_star(eye,6.5*maxf(0.55,width),2.8*maxf(0.55,width),side),col.call(GOLD.lerp(PEARL,glow*0.6)))
				c.draw_circle(eye,1.6*width,col.call(OUTLINE))
				# Goldene Aderlinie.
				c.draw_line(Vector2(3*side,-2),Vector2(38.0*width*side,-26),col.call(Color(GOLD,0.5)),1.2)
	# Körper: Hinterleib in Segmenten, pelzige Brust, kleiner Kopf.
	for k in 3:
		var y:=10.0+k*7.0
		var r:=6.5-k*1.6
		c.draw_colored_polygon(_ellipse(Vector2(0,y),r+1.2,4.6+1.2,10),col.call(OUTLINE))
		c.draw_colored_polygon(_ellipse(Vector2(0,y),r,4.6,10),col.call(BODY.lightened(0.05*k)))
		c.draw_line(Vector2(-r*0.6,y-2),Vector2(r*0.6,y-2),col.call(Color(LAVENDER,0.35)),1.0)
	c.draw_colored_polygon(_ellipse(Vector2(0,-1),9.0,10.0,14),col.call(OUTLINE))
	c.draw_colored_polygon(_ellipse(Vector2(0,-1),7.8,8.8,14),col.call(BODY))
	for k in 7:
		var a:=k*TAU/7.0+clock*0.3
		c.draw_circle(Vector2(cos(a)*6.0,sin(a)*6.5-2.0),2.2,col.call(FUZZ))
	c.draw_circle(Vector2(0,-3),3.0,col.call(LAVENDER.darkened(0.1)))
	var head:=Vector2(3.0 if side_view and facing_right else (-3.0 if side_view else 0.0),-11.0)
	c.draw_circle(head,5.6,col.call(OUTLINE))
	c.draw_circle(head,4.6,col.call(BODY.lightened(0.08)))
	if not back:
		for e in ([-1.0,1.0] if not side_view else [1.0 if facing_right else -1.0]):
			c.draw_circle(head+Vector2(e*2.0,0.5),1.5,col.call(PEARL))
	# Gefiederte Fühler, federn beim Flügelschlag leicht nach.
	var sway:=sin(clock*8.0+seed)*1.5*(open.x-0.5)
	for side in [-1.0,1.0]:
		var base_pt:=head+Vector2(side*2.0,-3.5)
		var tip:=base_pt+Vector2(side*9.0,-13.0+sway)
		var mid:=base_pt.lerp(tip,0.5)+Vector2(side*-2.0,-1.0)
		c.draw_polyline(PackedVector2Array([base_pt,mid,tip]),col.call(LAVENDER),1.4)
		for k in 4:
			var q:=base_pt.lerp(tip,0.3+k*0.17)
			c.draw_line(q,q+Vector2(side*2.5,1.5),col.call(Color(PEARL,0.7)),1.0)
	c.draw_set_transform(Vector2.ZERO)
	# Niederlage: helle Staubpunkte steigen auf.
	if death>=0.3:
		for k in 7:
			var t:=clampf((death-0.3)/0.7,0.0,1.0)
			var dp:=thorax+Vector2(sin(k*2.3+seed)*20.0,-t*26.0-k*3.0)*scale
			c.draw_circle(dp,2.0*scale*(1.0-t),Color(PEARL if k%2==0 else GOLD,0.8*(1.0-t)))

## Sternenstaub-Schuss: funkelnder Stern mit Staubschweif.
static func draw_shot(c:CanvasItem,p:Vector2,dir:Vector2,age:float)->void:
	var d:=dir.normalized() if dir.length_squared()>0.0001 else Vector2.RIGHT
	for k in 8:
		var q:=p-d*(8.0+k*7.0)+d.orthogonal()*sin(age*20.0+k)*3.0
		c.draw_circle(q,4.4-k*0.45,Color(LAVENDER if k%2==0 else GOLD,0.6-k*0.07))
	c.draw_circle(p,14.0,Color(LAVENDER,0.25))
	c.draw_colored_polygon(_star(p,12.0,4.6,1.0,age*6.0),Color(PEARL))
	c.draw_colored_polygon(_star(p,6.5,2.6,1.0,age*6.0),Color(GOLD))

## Fläche mit dunklem Umriss (Linie statt zweitem Polygon: bleibt auch bei
## fast zugeklappten Flügeln gültig).
static func _outlined(c:CanvasItem,pts:PackedVector2Array,color:Color)->void:
	c.draw_colored_polygon(pts,color)
	var line:=PackedVector2Array(pts);line.append(pts[0])
	c.draw_polyline(line,Color(OUTLINE,color.a),1.8)

static func _ellipse(center:Vector2,rx:float,ry:float,n:int=12)->PackedVector2Array:
	var pts:=PackedVector2Array()
	for k in n:
		var a:=k*TAU/n
		pts.append(center+Vector2(cos(a)*rx,sin(a)*ry))
	return pts

static func _star(center:Vector2,outer:float,inner:float,side:float=1.0,spin:float=0.0)->PackedVector2Array:
	var pts:=PackedVector2Array()
	for k in 10:
		var r:=outer if k%2==0 else inner
		var a:=-PI*0.5+k*PI/5.0+spin
		pts.append(center+Vector2(cos(a)*r*side,sin(a)*r))
	return pts
