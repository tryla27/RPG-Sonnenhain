extends RefCounted
## Ruinenhof hinter dem Mauertor (Spielpilot „Kleiner Hof hinter einem Tor“):
## gepflasterter Hof um Serins Lager in den Alten Ruinen mit niedrigen
## Grundmauern, zwei Feuerschalen am Eingang und einem Siegelstein. Die
## Herausforderung ist das vorhandene Weltereignis „Serin“ (gleiche Gegner,
## gleiches Ziel, gleiche Belohnung); der Hof macht Anfang, Kampf und Abschluss
## sichtbar: Feuerschalen kalt → rot flackernd → golden, Siegel leuchtet.
## Die Grundmauern sind kniehoch und sperren nichts. Bäume, Felsen und Deko
## halten Abstand (clears()), Darstellung und Kollision bleiben gleich.
## Keine Spielregeln, kein Speicherfeld.

const Shapes=preload("res://components/canvas_shapes.gd")

## Weltereignis, das im Hof stattfindet (GameContent.WORLD_EVENTS).
const EVENT_INDEX:=3
const RECT:=Rect2(5720,1660,440,340)
## Breite des Eingangs in der Nordmauer (zum Hauptweg hin).
const GATE_WIDTH:=150.0
const GATE_X:=5940.0
const SEAL:=Vector2(5940,1880)
const BRAZIERS:=[Vector2(5940-GATE_WIDTH*.5-14,1664),Vector2(5940+GATE_WIDTH*.5+14,1664)]

const STONE:=[Color("858276"),Color("8e8b7e"),Color("7c7a6f"),Color("969386")]
const DUST:=Color("6b6352")
const MORTAR:=Color("5f5d54")
const MOSS:=Color("6d8a57")
const WALL:=Color("7b786d")
const WALL_TOP:=Color("a9a596")
const WALL_SHADOW:=Color("3f4741")

## Liegt ein Punkt (mit Abstand margin) im Hof? Bäume, Felsen und Deko
## werden dort nicht gesetzt.
static func clears(point:Vector2,margin:float=0.0)->bool:
	return RECT.grow(margin).has_point(point)

static func _hash(x:int,y:int)->int:
	return absi((x*73856093)^(y*19349663))

## Fester Boden (wird mit dem Gelände zwischengespeichert).
static func paint_floor(c:CanvasItem)->void:
	# Fugen als Grundfläche, darauf versetzte Platten.
	c.draw_rect(RECT,MORTAR.lerp(DUST,.5))
	var row:=0
	var y:=RECT.position.y
	while y<RECT.end.y:
		var height:=28.0
		var x:=RECT.position.x-(20.0 if row%2==1 else 0.0)
		var column:=0
		while x<RECT.end.x:
			var width:=40.0+float(_hash(column,row)%3)*6.0
			var stone:=Rect2(Vector2(x+1,y+1),Vector2(width-2,height-2)).intersection(RECT)
			var code:=_hash(column+11,row+5)
			# Zum Rand hin fehlen mehr Platten: der Hof franst aus.
			var edge:=minf(minf(stone.position.x-RECT.position.x,RECT.end.x-stone.end.x),minf(stone.position.y-RECT.position.y,RECT.end.y-stone.end.y)) if stone.has_area() else 0.0
			var missing:=code%9==0 or (edge<40.0 and code%3==0) or (edge<80.0 and code%5==0)
			if stone.has_area() and not missing:
				var tint:Color=STONE[code%STONE.size()]
				c.draw_rect(stone,tint)
				c.draw_rect(Rect2(stone.position,Vector2(stone.size.x,2)),tint.lightened(.12))
				if code%11==0:c.draw_rect(Rect2(stone.position+Vector2(4,stone.size.y-7),Vector2(minf(12,stone.size.x-6),4)),MOSS)
				elif code%5==0:
					# Feiner Riss aus wenigen versetzten Pixeln.
					var start:=stone.position+Vector2(stone.size.x*(.25+float(code%3)*.15),3)
					for step in 4:c.draw_rect(Rect2(start+Vector2(float(step%2)*2.0,step*5.0),Vector2(2,5)),MORTAR)
			elif stone.has_area():
				# Fehlende Platte: staubiger Boden, selten etwas Moos.
				c.draw_rect(stone,DUST)
				c.draw_rect(Rect2(stone.position+Vector2(6,6),Vector2(4,2)),DUST.lightened(.18))
				c.draw_rect(Rect2(stone.position+Vector2(stone.size.x*.6,stone.size.y*.55),Vector2(2,2)),DUST.lightened(.25))
				if code%3==0:c.draw_rect(Rect2(stone.get_center()-Vector2(6,2),Vector2(12,4)),MOSS.darkened(.1))
			x+=width;column+=1
		y+=height;row+=1
	# Eingemeißelter Siegelring in der Hofmitte.
	for ring in [[46.0,Color("6d6a60")],[42.0,Color("a7a394")],[30.0,Color("6d6a60")],[27.0,Color("9a978a")]]:
		Shapes.circle(c,SEAL,float(ring[0]),ring[1])
	for spoke in 6:
		var direction:=Vector2.RIGHT.rotated(spoke*TAU/6.0)
		c.draw_line(SEAL+direction*12.0,SEAL+direction*40.0,Color("6d6a60"),3.0)
	_walls(c)

## Niedrige Grundmauern: West, Ost, Süd geschlossen mit Bruchstellen, Nord mit
## breitem Eingang. Ecken mit Pfeilerstümpfen.
static func _walls(c:CanvasItem)->void:
	var left:=RECT.position.x;var right:=RECT.end.x;var top:=RECT.position.y;var bottom:=RECT.end.y
	var segments:=[
		[Vector2(left,top),Vector2(GATE_X-GATE_WIDTH*.5,top)],
		[Vector2(GATE_X+GATE_WIDTH*.5,top),Vector2(right,top)],
		[Vector2(left,top),Vector2(left,bottom)],
		[Vector2(right,top),Vector2(right,bottom)],
		[Vector2(left,bottom),Vector2(right,bottom)],
	]
	for index in segments.size():
		var a:Vector2=segments[index][0];var b:Vector2=segments[index][1]
		var vertical:=is_equal_approx(a.x,b.x)
		var length:=a.distance_to(b)
		var steps:=int(length/24.0)
		for s in steps:
			# Bruchstellen: einzelne Blöcke fehlen oder sind niedriger.
			var code:=_hash(index*31+s,7)
			var p:=a.lerp(b,(s+.5)/maxf(1,steps))
			if code%6==0:
				# Eingestürzt: zwei Brocken liegen davor.
				var outward:=Vector2(-1 if index==2 else (1 if index==3 else 0),-1 if index<2 else (1 if index==4 else 0))
				for piece in 2:
					var rubble:=p+outward*float(10+piece*9)+Vector2(float(piece*7-4),float(piece*3))
					c.draw_rect(Rect2(rubble,Vector2(8,6)),WALL)
					c.draw_rect(Rect2(rubble,Vector2(8,2)),WALL_TOP)
				continue
			var low:=code%3==0
			var block:=Rect2(p-(Vector2(6,12) if vertical else Vector2(12,6)),Vector2(12,24) if vertical else Vector2(24,12))
			c.draw_rect(Rect2(block.position+Vector2(0,block.size.y),Vector2(block.size.x,4)),WALL_SHADOW)
			c.draw_rect(block,WALL)
			c.draw_rect(Rect2(block.position,Vector2(block.size.x,4 if low else 6)),WALL_TOP)
			c.draw_rect(Rect2(block.position+Vector2(block.size.x-2,0),Vector2(2,block.size.y)),MORTAR)
	for corner in [RECT.position,Vector2(right,top),Vector2(left,bottom),RECT.end]:
		_pillar(c,corner)
	for gate_side in [-1,1]:
		_pillar(c,Vector2(GATE_X+gate_side*GATE_WIDTH*.5,top))

static func _pillar(c:CanvasItem,p:Vector2)->void:
	c.draw_rect(Rect2(p+Vector2(-14,6),Vector2(28,6)),WALL_SHADOW)
	c.draw_rect(Rect2(p+Vector2(-12,-20),Vector2(24,28)),WALL)
	c.draw_rect(Rect2(p+Vector2(-12,-20),Vector2(24,5)),WALL_TOP)
	c.draw_rect(Rect2(p+Vector2(-12,-8),Vector2(24,2)),MORTAR)
	c.draw_rect(Rect2(p+Vector2(6,-14),Vector2(4,8)),MOSS)

## Veränderlicher Teil: Feuerschalen und Siegel je Ereigniszustand
## (0 offen, 1 läuft, 2 geschafft, 3 abgeschlossen).
static func paint_state(c:CanvasItem,state:int,clock:float)->void:
	var cleared:=state>=2
	for index in BRAZIERS.size():
		var p:Vector2=BRAZIERS[index]
		c.draw_rect(Rect2(p+Vector2(-3,-6),Vector2(6,20)),Color("4a4038"))
		c.draw_rect(Rect2(p+Vector2(-11,10),Vector2(22,4)),Color("3a332d"))
		c.draw_rect(Rect2(p+Vector2(-13,-12),Vector2(26,8)),Color("5c5048"))
		c.draw_rect(Rect2(p+Vector2(-13,-12),Vector2(26,2)),Color("8a7a6a"))
		if state<=0:
			c.draw_rect(Rect2(p+Vector2(-7,-14),Vector2(14,3)),Color("3b3532"))
			continue
		var flicker:=sin(clock*(9.0 if not cleared else 5.0)+index*1.7)
		var flame:Color=Color("ffd86b") if cleared else Color("e2553f")
		var core:Color=Color("fff4c4") if cleared else Color("ffb36a")
		var height:=(14.0 if cleared else 9.0)+flicker*3.0
		Shapes.circle(c,p+Vector2(0,-16),(26.0 if cleared else 16.0)+flicker*2.0,Color(flame,.14))
		c.draw_rect(Rect2(p+Vector2(-8,-12-height),Vector2(16,height)),flame)
		c.draw_rect(Rect2(p+Vector2(-4,-10-height*.7),Vector2(8,height*.7)),core)
	if cleared:
		var pulse:=.6+.4*sin(clock*2.2)
		Shapes.circle(c,SEAL,48.0+pulse*4.0,Color(1.0,.88,.48,.10+.06*pulse))
		for spoke in 6:
			var direction:=Vector2.RIGHT.rotated(spoke*TAU/6.0)
			c.draw_line(SEAL+direction*12.0,SEAL+direction*40.0,Color(1.0,.9,.55,.55+.25*pulse),3.0)
		Shapes.circle(c,SEAL,9.0,Color(1.0,.93,.65,.8))
	elif state==1:
		# Laufender Kampf: Siegel glimmt rot, solange Streuner im Hof sind.
		Shapes.circle(c,SEAL,10.0+sin(clock*6.0)*2.0,Color(.9,.3,.25,.45))
