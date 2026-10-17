extends RefCounted
## Gebietsbanner beim ersten Betreten eines Gebiets (je Charakter einmal,
## über das vorhandene Speicherfeld discovered_regions). Zeigt Wappen, Namen,
## empfohlene Stufe und den Erkundungsspruch. Nur Darstellung, keine Regeln.
## Wappen: art/source/inkscape/regions/*.svg, mit Inkscape zu PNG gerendert.
const DURATION:=5.0
const FADE:=.45
const SIZE:=Vector2(520,104)
const EMBLEMS:=[
	preload("res://art/ui/regions/region_00.png"),preload("res://art/ui/regions/region_01.png"),
	preload("res://art/ui/regions/region_02.png"),preload("res://art/ui/regions/region_03.png"),
	preload("res://art/ui/regions/region_04.png"),preload("res://art/ui/regions/region_05.png"),
	preload("res://art/ui/regions/region_06.png"),preload("res://art/ui/regions/region_07.png"),
	preload("res://art/ui/regions/region_08.png"),preload("res://art/ui/regions/region_09.png"),
	preload("res://art/ui/regions/region_10.png"),preload("res://art/ui/regions/region_11.png"),
	preload("res://art/ui/regions/region_12.png"),
]
const WHISPERS:=["", "Unter den Blüten liegt etwas Dunkles.", "Die Pilze leuchten, obwohl kein Sonnenstrahl hierher reicht.", "Der Turm bewacht ein vergessenes Versprechen.", "Im Kristall spiegelt sich ein Himmel ohne Sterne.", "Die Asche trägt Spuren eines alten Feuers.", "Das Meer flüstert Namen aus vergangenen Tagen.", "Jenseits des Bruchs wartet die Quelle des Unheils.", "Eine Glocke schlägt tief im Nebel.", "Goldenes Harz verschließt die Wunden des Waldes.", "Wasser steigt aus der Erde und singt eine Warnung.", "Am Grat verlischt das letzte Wachtfeuer.", "Über den Gärten sammelt sich das Licht der Morgenwache."]

var region:=-1
var title:=""
var level:=1
var timer:=0.0

static func whisper(region_id:int)->String:
	return WHISPERS[clampi(region_id,0,WHISPERS.size()-1)]

func show(region_id:int,region_title:String,recommended_level:int)->void:
	region=clampi(region_id,0,EMBLEMS.size()-1);title=region_title;level=recommended_level;timer=DURATION

func tick(delta:float)->void:
	timer=maxf(0.0,timer-delta)

func active()->bool:
	return timer>0.0 and region>=0

## Deckkraft für sanftes Ein- und Ausblenden.
func alpha()->float:
	if not active():return 0.0
	var shown:=DURATION-timer
	return clampf(minf(shown/FADE,timer/FADE),0.0,1.0)

func paint(canvas:CanvasItem,view_width:float,font:Font)->void:
	if not active():return
	var a:=alpha()
	var rect:=Rect2(Vector2((view_width-SIZE.x)*.5,74),SIZE)
	canvas.draw_rect(rect.grow(3),Color(.11,.09,.08,.85*a))
	canvas.draw_rect(rect,Color(.16,.22,.21,.92*a))
	canvas.draw_rect(rect,Color(.85,.73,.44,a),false,2.0)
	canvas.draw_texture_rect(EMBLEMS[region],Rect2(rect.position+Vector2(12,8),Vector2(88,88)),false,Color(1,1,1,a))
	var x:=rect.position.x+114
	canvas.draw_string(font,Vector2(x,rect.position.y+34),"NEUES GEBIET",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(.85,.79,.6,a))
	canvas.draw_string(font,Vector2(x,rect.position.y+62),title,HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color(1,.94,.76,a))
	if region>0:
		var hint:="Empfohlen ab Stufe %d"%level
		var width:=font.get_string_size(hint,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x
		canvas.draw_string(font,Vector2(rect.end.x-14-width,rect.position.y+34),hint,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(.75,.9,.78,a))
	canvas.draw_string(font,Vector2(x,rect.position.y+88),whisper(region),HORIZONTAL_ALIGNMENT_LEFT,SIZE.x-128,14,Color(.9,.93,.86,a))
