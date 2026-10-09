extends RefCounted
const TILE := 32
const ELARA_ID := 7
const ELARA_CONCEPT := "res://art/concepts/map0/elara_church_interior_32px.webp"
const NAMES := ["Alma","Mira","Liora","Arven","Torvald","Fenna","Pip","Elara","Borin"]
const KINDS := ["inn","elder","elder","arena","smith","style","apprentice","healer","magic"]
const ROLES := [
	"Wirtin der Steinrose · Küche & Rezepte",
	"Älteste · alle Sonnenhain-Quests",
	"Forscherin · Wissen & Quest-Hinweise",
	"Arenameister · Endlose Prüfung",
	"Schmied · Waffenmeister",
	"Stilistin · Character Editor",
	"Borins Lehrling",
	"Heilerin · Tränke & Alchemie",
	"Skillzauberer · Fähigkeiten"
]

static func id_for_name(name:String)->int:
	return NAMES.find(name)

static func name_for_id(id:int)->String:
	return NAMES[id] if id>=0 and id<NAMES.size() else ""

static func kind_for_id(id:int)->String:
	return KINDS[id] if id>=0 and id<KINDS.size() else ""

static func role_for_id(id:int)->String:
	return ROLES[id] if id>=0 and id<ROLES.size() else ""

static func exit_offset(id:int)->Vector2:
	return Vector2(0,340) if id==3 else (Vector2(0,168) if id==6 else Vector2(0,210))

## Erhöhtes, begehbares Steinpodest unter Elaras Heilfeld (vor dem Altar).
const DAIS_SIZE:=Vector2(108,58)
static func dais_rect(field:Vector2)->Rect2:
	return Rect2(field-Vector2(DAIS_SIZE.x*.5,DAIS_SIZE.y*.5),DAIS_SIZE)

static func paint_healing_dais(c:CanvasItem,field:Vector2)->void:
	var top:=dais_rect(field)
	var front:=Rect2(top.position+Vector2(0,top.size.y),Vector2(top.size.x,8))
	var step:=Rect2(front.position+Vector2(10,8),Vector2(top.size.x-20,6))
	c.draw_rect(Rect2(top.position+Vector2(3,4),top.size+Vector2(0,14)),Color(0,0,0,0.18))
	c.draw_rect(step,Color("8a8389"))
	c.draw_rect(Rect2(step.position,Vector2(step.size.x,2)),Color("a9a2a6"))
	c.draw_rect(front,Color("6f6870"))
	c.draw_rect(top,Color("8d868c"))
	c.draw_rect(top.grow(-3),Color("b3aca9"))
	c.draw_rect(Rect2(top.position+Vector2(3,3),Vector2(top.size.x-6,2)),Color("cfc8c3"))
	for x in range(int(top.position.x)+18,int(top.end.x)-6,26):
		c.draw_line(Vector2(x,top.position.y+4),Vector2(x,top.end.y-4),Color("9e9797"),1.0)
	c.draw_arc(field,17.0,0.0,TAU,32,Color("8fe3d6"),2.0)
	c.draw_arc(field,10.0,0.0,TAU,24,Color(0.62,0.95,0.88,0.55),1.0)
	for k in 4:
		var dir:=Vector2.RIGHT.rotated(k*PI*0.5)
		c.draw_rect(Rect2(field+dir*22.0-Vector2(2,2),Vector2(4,4)),Color("8fe3d6"))

static func healing_field_pos(center:Vector2,id:int)->Vector2:
	return center+pixel_point(id,Vector2(830,433)) if id==ELARA_ID else Vector2(-100000,-100000)

# Geometry is authored in each source image's pixel coordinates and mapped by
# the same transform as the renderer. Floors/rugs stay walkable; furniture does not.
const ROOMS := {
	0:{"asset":"taverne","source_size":Vector2(1659,948),"floor":Rect2(236,345,1190,397),"objects":[Rect2(242,223,510,127),Rect2(515,315,55,65),Rect2(1110,180,315,171),Rect2(1353,305,72,78),Rect2(348,415,146,140),Rect2(284,435,58,98),Rect2(499,435,55,99),Rect2(1165,461,146,146),Rect2(1107,483,54,98),Rect2(1315,482,58,98),Rect2(473,590,142,142),Rect2(411,614,54,100),Rect2(624,614,54,100)]},
	1:{"asset":"ratshalle","source_size":Vector2(1660,948),"floor":Rect2(145,230,1370,474),"objects":[Rect2(615,302,432,176),Rect2(701,239,60,63),Rect2(885,238,70,64),Rect2(535,346,63,85),Rect2(1060,346,62,85),Rect2(164,609,242,91),Rect2(1260,154,117,196),Rect2(1403,190,98,196),Rect2(304,178,66,94)]},
	3:{"asset":"arena-eingangshalle","source_size":Vector2(1660,948),"floor":Rect2(98,234,1465,502),"objects":[Rect2(158,248,315,90),Rect2(175,155,63,88),Rect2(236,190,46,55),Rect2(1295,147,129,126),Rect2(1430,177,94,96),Rect2(99,436,56,195),Rect2(1505,437,63,195)]},
	4:{"asset":"schmiede","source_size":Vector2(1659,948),"floor":Rect2(171,284,1319,456),"objects":[Rect2(295,277,219,102),Rect2(553,301,106,133),Rect2(520,278,47,61),Rect2(187,239,78,101),Rect2(209,307,56,57),Rect2(181,385,75,205),Rect2(183,545,448,129),Rect2(355,508,53,38),Rect2(1217,350,263,183),Rect2(1348,505,70, 70),Rect2(1294,218,93,116),Rect2(1390,217,92,123)]},
	5:{"asset":"fenna-atelier","source_size":Vector2(1660,948),"floor":Rect2(204,308,1310,397),"objects":[Rect2(320,94,259,225),Rect2(644,164,283,140),Rect2(929,97,168,185),Rect2(1182,156,219,152),Rect2(1277,266, 60, 70),Rect2(1385,360,92,145),Rect2(1391,512,88,165),Rect2(205,373,76,222),Rect2(261,572,52,62)]},
	6:{"asset":"pip","source_size":Vector2(1536,1024),"floor":Rect2(333,321,872,434),"objects":[Rect2(354,208,171,158),Rect2(640,288,255,140),Rect2(953,216,135,156),Rect2(1114,283,89,132),Rect2(350,647, 70,84)]},
	7:{"asset":"kapelle","source_size":Vector2(1659,948),"floor":Rect2(255,287,1150,466),"objects":[Rect2(306,173,170,168),Rect2(480,271,50,65),Rect2(722,251,216,126),Rect2(1185,205,151,134),Rect2(1340,286,36,64),Rect2(397,440,277,62),Rect2(984,440,280,62),Rect2(397,591,277,58),Rect2(984,591,280,58)]},
	8:{"asset":"borin-skillhaus","source_size":Vector2(1659,948),"floor":Rect2(262,279,1135,474),"objects":[Rect2(302,122,237,235),Rect2(680,195,305,143),Rect2(795,305,70,85),Rect2(1236,233,130,113),Rect2(1298,442,103,309),Rect2(1230,621,66, 80),Rect2(270,606, 70,120),Rect2(1352,376,46,67)]}
}
static var textures:Dictionary={}

static func room(id:int)->Dictionary:
	return ROOMS.get(1 if id==2 else id,ROOMS[0])

static func room_size(id:int)->Vector2:
	return Vector2(1344,768) if id==3 else Vector2(896,512)

static func pixel_point(id:int,pixel:Vector2)->Vector2:
	var size:=room_size(id)
	return (pixel/Vector2(room(id)["source_size"])*size-size*.5).round()

static func pixel_rect(id:int,rect:Rect2)->Rect2:
	return Rect2(pixel_point(id,rect.position),pixel_point(id,rect.end)-pixel_point(id,rect.position))

static func furniture(id:int)->Array[Rect2]:
	var items:Array[Rect2]=[]
	for rect in room(id)["objects"]:items.append(pixel_rect(id,rect))
	return items

static func actor_offset(id:int,owner:String)->Vector2:
	var pixels:Dictionary={"Alma":Vector2(850,390),"Mira":Vector2(675,520),"Liora":Vector2(990,520),"Arven":Vector2(540,375),"Torvald":Vector2(695,465),"Fenna":Vector2(835,390),"Pip":Vector2(970,450),"Elara":Vector2(570,369),"Borin":Vector2(670,412)}
	return pixel_point(id,pixels.get(owner,Vector2(830,430)))

static func link_offset(id:int)->Vector2:
	return Vector2(-306,-4) if id==8 else Vector2(-100000,-100000)

static func blocked(pos:Vector2,center:Vector2,id:int=-1,radius:float=16.0)->bool:
	var local:=pos-center
	var floor_area:=pixel_rect(id,room(id)["floor"])
	var exit:=exit_offset(id)
	var approach:=Rect2(-48,floor_area.end.y-40,96,exit.y-floor_area.end.y+radius+56)
	if not floor_area.grow(-radius).has_point(local) and not approach.grow(-radius).has_point(local):return true
	for rect in furniture(id):
		if rect.grow(radius).has_point(local):return true
	return false

static func paint(c:CanvasItem,center:Vector2,id:int,font:Font,touch_enabled:bool,interact_label:String)->void:
	var asset:String=room(id)["asset"]
	if not textures.has(asset):textures[asset]=load("res://art/village/interiors/%s.png" % asset)
	c.draw_texture_rect(textures[asset],Rect2(center-room_size(id)*.5,room_size(id)),false)
	if id==ELARA_ID:paint_healing_dais(c,healing_field_pos(center,id))
	if id==8:
		var p:=center+link_offset(id)
		c.draw_rect(Rect2(p+Vector2(-12,-42),Vector2(24,54)),Color("352e35"))
		c.draw_rect(Rect2(p+Vector2(-9,-39),Vector2(18,48)),Color("875c3d"))
		c.draw_rect(Rect2(p+Vector2(3,-14),Vector2(4,4)),Color("e0ba68"))
		c.draw_string(font,p+Vector2(-28,26),"PIP",HORIZONTAL_ALIGNMENT_CENTER,56,11,Color("e2cda4"))
	var title:="Mira & Liora · Ratshalle" if id in [1,2] else "%s · %s" % [name_for_id(id),role_for_id(id)]
	c.draw_string(font,center+Vector2(-320,-room_size(id).y*.5+20),title,HORIZONTAL_ALIGNMENT_CENTER,640,16,Color("ffe8b4"))
	var label:="ZU BORIN" if id==6 else "ZURÜCK INS DORF"
	c.draw_string(font,center+exit_offset(id)+Vector2(-140,28),"%s · %s" % ["AKTION" if touch_enabled else interact_label,label],HORIZONTAL_ALIGNMENT_CENTER,280,12,Color("fff0c9"))
