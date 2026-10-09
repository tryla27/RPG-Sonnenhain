extends RefCounted
# Wo stehen Büsche, durch die man raschelnd läuft? Spiegelt die Regeln, nach
# denen main.gd Büsche zeichnet (Dorfbüsche, Blütenbüsche, Streubüsche auf dem
# Boden, Büsche an Hindernissen). Nicht hier: das Zeichnen und der Klang.

## Abstand zum Buschmittelpunkt, ab dem man „im Busch“ ist.
const BUSH_RADIUS:=30.0

## Streubusch an einer Bodenkachel? Gleiche Auswahl wie im Bodenzeichnen.
static func scatter_is_bush(zone:int,key:int)->bool:
	match zone:
		1:return key%8!=0 and key%4==0
		2:return key%6!=0 and key%4!=0 and key%3==0
		3:return key%6!=0 and key%5!=0 and key%3==0
		4:return key%4!=0 and key%7!=0 and key%3==0
	return false

## Lage des Buschs, den ein Hindernis mitzeichnet; Vector2.INF ohne Busch.
static func obstacle_bush_point(zone:int,pos:Vector2,radius:float)->Vector2:
	match zone:
		1,2:return pos+Vector2(radius*0.55,8)
		3:return pos+Vector2(radius*0.35,radius*0.34)
		8:return pos
		9:return pos+Vector2(0,radius*0.32)
	return Vector2.INF

## Mitte eines gezeichneten Buschhaufens (die Blätter liegen etwas über dem Fußpunkt).
static func cluster_center(p:Vector2)->Vector2:
	return p+Vector2(0,-3)

static func near_any(points:Array,pos:Vector2,radius:float=BUSH_RADIUS)->bool:
	for point in points:
		if pos.distance_to(point)<radius:return true
	return false
