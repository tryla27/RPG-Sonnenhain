extends RefCounted
## Gebietshinweis beim ersten Betreten (je Charakter einmal, gleicher Auslöser
## wie das Gebietsbanner über `discovered_regions`; alte Spielstände bekommen
## deshalb keine Hinweisflut). Zeigt, was es nur in diesem Gebiet gibt: die
## Gebietsfrucht der Büsche, das Gebietskraut und Almas Rezepte, die damit
## gekocht werden. Daten kommen aus FoodSystem und der Steinrose-Küche.
## Nicht modal: pausiert nichts, schließt sich nach DURATION Sekunden oder per
## Klick auf das X. Keine Spielregeln, kein Speicherfeld.

const FoodSystem=preload("res://components/food_system.gd")
const Kitchen=preload("res://components/steinrose_kitchen.gd")

const DURATION:=16.0
const FADE:=.4
const SIZE:=Vector2(250,150)
## Rechts unter Minikarte und Gebietsname.
const ORIGIN:=Vector2(1152-SIZE.x-12,226)

var region:=-1
var timer:=0.0

## Gebietsfrucht und Gebietskraut: [{"name","kind" ("food"|"herb"), "food_id", "color"}]
static func finds(region_id:int)->Array:
	var result:Array=[]
	if region_id<1 or region_id>=FoodSystem.REGION_FOOD.size():return result
	var food_id:int=int(FoodSystem.REGION_FOOD[region_id])
	if food_id>=0 and food_id<FoodSystem.FOODS.size():
		result.append({"name":str(FoodSystem.FOODS[food_id]["name"]),"kind":"food","food_id":food_id})
	var herb:Dictionary=FoodSystem.herb_for_region(region_id)
	if not herb.is_empty():
		result.append({"name":str(herb["name"]),"kind":"herb","color":str(herb["color"])})
	return result

## Almas Rezepte, die eine der Gebietszutaten brauchen.
static func recipes_for(region_id:int)->Array:
	var names:Array=[]
	for item in finds(region_id):names.append(str(item["name"]))
	var result:Array=[]
	for recipe in Kitchen.RECIPES:
		for ingredient in recipe["ingredients"]:
			if str(ingredient) in names:
				result.append(str(recipe["name"]));break
	return result

func show(region_id:int)->void:
	if finds(region_id).is_empty():return
	region=region_id;timer=DURATION

func close()->void:
	timer=0.0

func tick(delta:float)->void:
	timer=maxf(0.0,timer-delta)

func active()->bool:
	return timer>0.0 and region>=0

func alpha()->float:
	if not active():return 0.0
	return clampf(minf((DURATION-timer)/FADE,timer/FADE),0.0,1.0)

func close_rect()->Rect2:
	return Rect2(ORIGIN+Vector2(SIZE.x-26,6),Vector2(20,20))

## Klick auf das X schließt; true, wenn der Klick verbraucht wurde.
func click(point:Vector2)->bool:
	if active() and close_rect().grow(4).has_point(point):
		close();return true
	return false

func paint(g,font:Font)->void:
	if not active():return
	var a:=alpha()
	var rect:=Rect2(ORIGIN,SIZE)
	g.draw_rect(rect.grow(2),Color(.11,.09,.08,.85*a))
	g.draw_rect(rect,Color(.15,.21,.2,.94*a))
	g.draw_rect(rect,Color(.85,.73,.44,a),false,2.0)
	g.draw_string(font,ORIGIN+Vector2(12,22),"NUR IN DIESEM GEBIET",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(.85,.79,.6,a))
	var x_rect:=close_rect()
	g.draw_rect(x_rect,Color(.25,.2,.18,a))
	g.draw_string(font,x_rect.position+Vector2(5,15),"X",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color(1,.9,.7,a))
	var y:=34.0
	for item in finds(region):
		var icon_at:=ORIGIN+Vector2(12,y)
		if str(item["kind"])=="food":FoodSystem.icon(g,icon_at,int(item["food_id"]),0.8)
		else:g.draw_item_icon(icon_at,"herb",Color(str(item["color"])),0.8)
		g.draw_string(font,ORIGIN+Vector2(50,y+18),str(item["name"]),HORIZONTAL_ALIGNMENT_LEFT,SIZE.x-60,15,Color(1,.94,.78,a))
		g.draw_string(font,ORIGIN+Vector2(50,y+33),"Fruchtbüsche" if str(item["kind"])=="food" else "Kräuterbüsche",HORIZONTAL_ALIGNMENT_LEFT,SIZE.x-60,11,Color(.75,.85,.78,a))
		y+=42.0
	var recipes:=recipes_for(region)
	if not recipes.is_empty():
		var text:="Für Alma: "+", ".join(recipes.slice(0,2))+(" …" if recipes.size()>2 else "")
		g.draw_string(font,ORIGIN+Vector2(12,y+14),text,HORIZONTAL_ALIGNMENT_LEFT,SIZE.x-24,11,Color(.9,.83,.62,a))
