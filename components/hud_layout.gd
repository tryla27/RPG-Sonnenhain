extends RefCounted
const FoodSystem=preload("res://components/food_system.gd")
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
## Quadratische Minimap oben rechts mit goldenem Rahmen.
const MINIMAP_RECT:=Rect2(976,12,164,164)
## Kartenname und Stufe direkt unter der Minimap.
const MAP_LABEL_RECT:=Rect2(946,180,224,22)
## Aktionshinweis rechts unter der Minimap, rechtsbündig mit ihr.
const PROMPT_TOP:=206.0
const PROMPT_H:=26.0
const PROMPT_MAX_W:=420.0
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

## Untere Leiste ohne Hintergrund: Nur Knöpfe und belegte Fähigkeitsplätze
## bekommen einen Rahmen.
static func draw_hud_button(g,rect:Rect2,label:String,hovered:bool)->void:
	g.draw_rect(rect,Color(0.04,0.09,0.13,0.82 if hovered else 0.62))
	g.draw_rect(rect,Color("ffe0a0") if hovered else Color("c9a45e",0.85),false,1.0)
	g.text_at(rect.position+Vector2(0,rect.size.y*0.5+5),label,13,Color("fff1ce"),HORIZONTAL_ALIGNMENT_CENTER,int(rect.size.x))

static func draw_skill_slot(g,rect:Rect2,key:String,filled:bool)->void:
	if filled:
		g.draw_rect(rect,Color(0.04,0.09,0.13,0.62))
		g.draw_rect(rect,Color("c9a45e",0.85),false,1.0)
	shadow_text(g,rect.position+Vector2(8,36),key,11,Color("ffe2a3") if filled else Color("a9aa9c",0.75))

static func draw_map_frame(g,rect:Rect2)->void:
	g.draw_rect(rect.grow(2),Color("1a120a"),false,2.0)
	g.draw_rect(rect,Color("e3c077"),false,2.0)

## Rahmen des Aktionshinweises: so breit wie der Text, rechts unter der Minimap.
static func prompt_rect(g,text:String)->Rect2:
	var width:=minf(g.font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x+28.0,PROMPT_MAX_W)
	return Rect2(MINIMAP_RECT.end.x-width,PROMPT_TOP,width,PROMPT_H)

static func draw_prompt(g,text:String)->void:
	var rect:=prompt_rect(g,text)
	g.draw_rect(rect,Color(0.03,0.07,0.1,0.78))
	g.draw_rect(rect.grow(1),Color("fff3c4"),false,2.0)
	g.text_at(rect.position+Vector2(14,18),text,14,Color("fff8dc"),HORIZONTAL_ALIGNMENT_LEFT,int(rect.size.x)-20)

## Kleine Effekt-Kacheln (Essen, Snack …): 92×28 px nebeneinander, höchstens
## vier pro Reihe. Beim Darüberfahren erscheinen Name und Wirkung.
## Rückgabe: Unterkante der Kacheln.
const CHIP_SIZE:=Vector2(92,28)
const CHIPS_PER_ROW:=4
static func chip_rect(origin:Vector2,index:int)->Rect2:
	return Rect2(origin+Vector2((index%CHIPS_PER_ROW)*(CHIP_SIZE.x+4),int(index/CHIPS_PER_ROW)*(CHIP_SIZE.y+4)),CHIP_SIZE)

static func draw_effect_chips(g,origin:Vector2,chips:Array,mouse:Vector2)->float:
	var bottom:=origin.y
	var hovered:=-1
	for i in chips.size():
		var chip:Dictionary=chips[i]
		var r:=chip_rect(origin,i)
		g.draw_rect(r,Color(0.03,0.07,0.1,0.78))
		g.draw_rect(r,Color("c9a45e",0.7),false,1.0)
		if int(chip.get("icon",-1))>=0:
			FoodSystem.icon(g,r.position+Vector2(2,1),int(chip["icon"]),0.55)
		else:
			g.draw_circle(r.position+Vector2(14,14),6,Color(chip.get("color",Color.WHITE)))
		var t:=int(chip.get("time",0))
		shadow_text(g,r.position+Vector2(30,17),"%d:%02d" % [int(t/60),t%60],12,Color("e8f0ff"))
		g.draw_rect(Rect2(r.position+Vector2(30,21),Vector2(r.size.x-36,3)),Color("1b2f35"))
		g.draw_rect(Rect2(r.position+Vector2(30,21),Vector2((r.size.x-36)*clampf(float(chip.get("progress",0.0)),0.0,1.0),3)),Color(chip.get("color",Color.WHITE)))
		bottom=maxf(bottom,r.end.y)
		if r.has_point(mouse):hovered=i
	if hovered>=0:
		var chip:Dictionary=chips[hovered]
		var r:=chip_rect(origin,hovered)
		var box:=Rect2(r.position+Vector2(0,r.size.y+4),Vector2(260,40))
		g.draw_rect(box,Color(0.03,0.07,0.1,0.9))
		g.draw_rect(box,Color("c9a45e",0.8),false,1.0)
		g.text_at(box.position+Vector2(8,16),str(chip.get("title","")),12,Color("ffe5b5"))
		g.text_at(box.position+Vector2(8,32),str(chip.get("detail","")),10,Color("bde8bd"),HORIZONTAL_ALIGNMENT_LEFT,244)
	return bottom+4.0

