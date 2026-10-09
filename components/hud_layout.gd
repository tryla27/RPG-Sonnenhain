extends RefCounted
# Schlankes HUD: Lage der HUD-Teile und Zeichnen der Statusbalken, der
# Questzeile, der XP-Linie und des Kartennamens unter der Minimap.
# Nicht hier: Minimap selbst, Fähigkeitenleiste, Bossleiste, Interaktionshinweise
# (main.gd), Questdetails beim Darüberfahren (quest_guide.gd).

## Bereich, über dem die Zahlen der Balken erscheinen.
const STATUS_RECT:=Rect2(10,8,250,58)
const HP_BAR:=Rect2(22,31,220,9)
const ENERGY_BAR:=Rect2(22,44,220,6)
const STAMINA_BAR:=Rect2(22,54,220,4)
## Questzeile: am PC unten über der Fähigkeitenleiste, am Touchgerät oben links
## (unten liegen dort die Touch-Steuerelemente).
const QUEST_RECT_DESKTOP:=Rect2(12,559,590,24)
const QUEST_RECT_TOUCH:=Rect2(10,66,320,24)
## Kurzmeldungen stehen über der Questzeile.
const NOTICE_RECT:=Rect2(12,522,510,34)
## XP als dünne Linie unter der Fähigkeitenleiste.
const XP_LINE:=Rect2(9,641,1134,3)
const MAP_CENTER:=Vector2(1035,116)
## Kartenname und Stufe unter der Minimap (unter dem „+“-Knopf).
const MAP_LABEL_RECT:=Rect2(925,210,220,22)
const KOOP_Y:=250.0
const SAVE_NOTICE_Y:=266.0
const RIGHT_STATUS_BOTTOM:=274.0

static func quest_rect(touch:bool)->Rect2:
	return QUEST_RECT_TOUCH if touch else QUEST_RECT_DESKTOP

## Oberkante der Essensanzeige links oben (unter Balken bzw. Touch-Questzeile).
static func food_top(touch:bool)->float:
	return QUEST_RECT_TOUCH.end.y+6.0 if touch else STATUS_RECT.end.y+6.0

## Speicherstatus nur bei Problemen anzeigen.
static func save_status_visible(save_problem:bool,creative:bool,created:bool)->bool:
	return save_problem and created and not creative

static func shadow_text(g,p:Vector2,value:String,size:int,color:Color,alignment:HorizontalAlignment=HORIZONTAL_ALIGNMENT_LEFT,width:int=-1)->void:
	g.draw_string_outline(g.font,p,value,alignment,width,size,4,Color(0.02,0.04,0.06,0.78))
	g.draw_string(g.font,p,value,alignment,width,size,color)

static func slim_bar(g,rect:Rect2,value:float,maximum:float,color:Color)->void:
	g.draw_rect(rect.grow(1),Color(0.02,0.04,0.06,0.82))
	var filled:=rect.size.x*clampf(value/maxf(1.0,maximum),0.0,1.0)
	if filled<=0.0:return
	g.draw_rect(Rect2(rect.position,Vector2(filled,rect.size.y)),color)
	g.draw_rect(Rect2(rect.position,Vector2(filled,maxf(1.0,floorf(rect.size.y*0.34)))),color.lightened(0.28))

## Name, Stufe und die drei Balken ohne Hintergrundkasten.
static func draw_status(g,title:String,class_color:Color,hp:float,max_hp:float,energy:float,max_energy:float,energy_color:Color,stamina:float,max_stamina:float,stamina_color:Color)->void:
	g.draw_rect(Rect2(14,13,4,15),class_color)
	shadow_text(g,Vector2(24,26),title,15,Color("ffe9b8"))
	slim_bar(g,HP_BAR,hp,max_hp,Color("d94f4f"))
	slim_bar(g,ENERGY_BAR,energy,max_energy,energy_color)
	slim_bar(g,STAMINA_BAR,stamina,max_stamina,stamina_color)

## Zahlen beim Darüberfahren.
static func draw_status_numbers(g,lines:Array)->void:
	var box:=Rect2(STATUS_RECT.end.x+6,10,206,16+lines.size()*18)
	g.draw_rect(box,Color(0.03,0.07,0.1,0.86))
	g.draw_rect(box,Color("c9a45e",0.8),false,1.0)
	for i in lines.size():
		g.text_at(box.position+Vector2(10,22+i*18),str(lines[i]),13,Color("fff1ce"))

static func draw_xp_line(g,xp:float,required:float,mouse:Vector2,label:String)->void:
	g.draw_rect(XP_LINE,Color(0.02,0.04,0.06,0.7))
	g.draw_rect(Rect2(XP_LINE.position,Vector2(XP_LINE.size.x*clampf(xp/maxf(1.0,required),0.0,1.0),XP_LINE.size.y)),Color("e3a33a"))
	if XP_LINE.grow(4).has_point(mouse):
		var box:=Rect2(clampf(mouse.x-80,10,980),XP_LINE.position.y-30,160,24)
		g.draw_rect(box,Color(0.03,0.07,0.1,0.86))
		g.draw_rect(box,Color("c9a45e",0.8),false,1.0)
		g.text_at(box.position+Vector2(0,17),label,13,Color("ffe2a3"),HORIZONTAL_ALIGNMENT_CENTER,160)

## Eine halbtransparente Zeile mit dem aktuellen Ziel.
static func draw_quest_line(g,rect:Rect2,text:String,hovered:bool)->void:
	g.draw_rect(rect,Color(0.03,0.07,0.1,0.72 if hovered else 0.5))
	g.draw_rect(Rect2(rect.position,Vector2(3,rect.size.y)),Color("e3c077"))
	if hovered:g.draw_rect(rect,Color("ffe0a0",0.7),false,1.0)
	g.text_at(rect.position+Vector2(12,17),"ZIEL",11,Color("e3c077"))
	shadow_text(g,rect.position+Vector2(50,17),text,14,Color("fff2d9"),HORIZONTAL_ALIGNMENT_LEFT,int(rect.size.x)-60)

static func draw_map_label(g,label:String)->void:
	shadow_text(g,MAP_LABEL_RECT.position+Vector2(0,16),label,13,Color("fff0bf"),HORIZONTAL_ALIGNMENT_CENTER,int(MAP_LABEL_RECT.size.x))
