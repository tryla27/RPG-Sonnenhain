extends RefCounted
## Verborgene Funde am Nebenpfad (Gameplay-Pilot aus dem Grafik-/Gameplay-Konzept):
## Von vier frühen Wahrzeichen führt ein kleiner Trittsteinpfad abseits der Wege
## zu einem Steinmal. Einmal je Charakter: Gold, Erfahrung und ein Satz Weltgeschichte.
## Positionen sind begehbar, abseits von Wegen, Truhen, Ereignissen und Portalen
## (geprüft beim Erstellen, Test: tests/gameplay/check_hidden_finds.gd).
const RANGE:=80.0
const FINDS:=[
	{"name":"Moosige Quellschale","region":1,"from":Vector2(2937,2407),"pos":Vector2(2609,2495),"gold":80,"xp":70,
		"lore":"Jemand hat hier Blüten für die Quelle geopfert, lange bevor Blütenweiler stand."},
	{"name":"Leuchtender Sporenstein","region":2,"from":Vector2(3569,6719),"pos":Vector2(3599,7058),"gold":110,"xp":125,
		"lore":"Die Sporen ordnen sich zu einem Pfeil – er zeigt nach Osten, zum Kristallmoor."},
	{"name":"Siegel des Turmwächters","region":3,"from":Vector2(7207,1987),"pos":Vector2(7295,1659),"gold":140,"xp":185,
		"lore":"Ein gebrochenes Siegel. Dieselben Zeichen fand Serin an den Ruinen."},
	{"name":"Gefrorene Kristallträne","region":4,"from":Vector2(7219,6719),"pos":Vector2(7249,7058),"gold":170,"xp":240,
		"lore":"In der Träne spiegelt sich kurz ein Himmel ohne Sterne."},
]
var found:Array=[false,false,false,false]

func snapshot()->Array:
	return found.duplicate()

func restore(raw:Variant)->void:
	found=[false,false,false,false]
	if raw is Array:
		for i in mini(raw.size(),found.size()):found[i]=bool(raw[i])

func reset()->void:
	found=[false,false,false,false]

## Index des Fundes in Reichweite oder -1.
func nearby(point:Vector2)->int:
	for i in FINDS.size():
		if point.distance_to(FINDS[i]["pos"])<RANGE:return i
	return -1

## Einmalige Belohnung; leeres Dictionary, wenn bereits gefunden.
func claim(index:int)->Dictionary:
	if index<0 or index>=FINDS.size() or bool(found[index]):return {}
	found[index]=true
	return FINDS[index]

func prompt(index:int)->String:
	if index<0:return ""
	return "E  ·  %s untersuchen" % FINDS[index]["name"] if not bool(found[index]) else "%s · bereits untersucht" % FINDS[index]["name"]

## Trittsteine und Steinmal; nur Darstellung am Boden, keine Kollision.
func paint(canvas:CanvasItem,view:Rect2,clock:float)->void:
	for i in FINDS.size():
		var find:Dictionary=FINDS[i]
		var start:Vector2=find["from"];var goal:Vector2=find["pos"]
		if not view.grow(120).intersects(Rect2(start,Vector2.ZERO).expand(goal)):continue
		var direction:=(goal-start).normalized();var side:=Vector2(-direction.y,direction.x)
		var steps:=int(start.distance_to(goal)/46.0)
		for s in steps:
			var p:=start+direction*(s*46.0+20.0)+side*(9.0 if s%2==0 else -9.0)
			canvas.draw_rect(Rect2(p-Vector2(11,6),Vector2(22,12)),Color("6f746a"))
			canvas.draw_rect(Rect2(p-Vector2(10,7),Vector2(20,10)),Color("b6b5a4"))
			canvas.draw_rect(Rect2(p+Vector2(-8,-6),Vector2(9,3)),Color("d4d2c2"))
		paint_cairn(canvas,goal,not bool(found[i]),clock)

static func paint_cairn(canvas:CanvasItem,p:Vector2,glowing:bool,clock:float)->void:
	canvas.draw_rect(Rect2(p+Vector2(-26,4),Vector2(52,12)),Color("2c3a34",.35))
	for layer in [[Vector2(-22,-4),Vector2(44,12),"7d8173"],[Vector2(-16,-14),Vector2(32,11),"9a9c8c"],[Vector2(-10,-24),Vector2(20,10),"b9b8a7"],[Vector2(-5,-32),Vector2(10,8),"d0cebd"]]:
		canvas.draw_rect(Rect2(p+layer[0],layer[1]),Color(layer[2]))
		canvas.draw_rect(Rect2(p+layer[0],Vector2(layer[1].x,2)),Color(layer[2]).lightened(.18))
	canvas.draw_rect(Rect2(p+Vector2(12,-2),Vector2(8,4)),Color("6f9a5a"))
	if glowing:
		var pulse:=.55+.45*sin(clock*2.6)
		canvas.draw_circle(p+Vector2(0,-40),9.0+pulse*3.0,Color(1.0,.9,.55,.18*pulse))
		canvas.draw_circle(p+Vector2(0,-40),4.0,Color(1.0,.93,.65,.75))
