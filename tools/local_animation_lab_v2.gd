extends Node2D

const Models = preload("res://components/animation_lab_models.gd")

var mage_pos := Vector2(576,360)
var facing := Vector2.DOWN
var phase := 0.0
var action := "idle"
var action_t := 0.0
var selected := 0
var font: Font = ThemeDB.fallback_font

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	var move := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): move.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): move.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): move.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): move.y += 1.0
	if move.length_squared() > 0.01 and action != "death":
		facing = move.normalized()
		mage_pos += facing*150.0*delta
		phase += delta*6.0
		if action == "idle": action = "walk"
	elif action == "walk":
		action = "idle"
		phase += delta*2.0
	else:
		phase += delta*(1.2 if action=="idle" else 3.0)
	mage_pos = mage_pos.clamp(Vector2(90,205),Vector2(1060,570))
	if action in ["attack","hurt","death"]:
		action_t = minf(1.0,action_t+delta*(2.3 if action=="attack" else (3.2 if action=="hurt" else 1.1)))
		if action_t >= 1.0 and action != "death":
			action = "idle"
			action_t = 0.0
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE,KEY_ENTER:
				if action!="death": action="attack"; action_t=0.0
			KEY_H:
				if action!="death": action="hurt"; action_t=0.0
			KEY_R:
				if action=="death": action="idle"; action_t=0.0
				else: action="death"; action_t=0.0
			KEY_1: selected=0
			KEY_2: selected=1
			KEY_3: selected=2
			KEY_Q: facing=facing.rotated(-PI/4.0)
			KEY_E: facing=facing.rotated(PI/4.0)
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		if action!="death": action="attack"; action_t=0.0

func label(pos: Vector2,value: String,size := 17,color := Color("d8e6dc")) -> void:
	draw_string(font,pos,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func panel(r: Rect2,title: String,active: bool=false) -> void:
	draw_rect(r,Color("132a38"))
	draw_rect(r,Color("ffe2aa") if active else Color("456574"),false,2)
	label(r.position+Vector2(12,25),title,16,Color("ffe2aa") if active else Color("c8d8d3"))

func grid_floor() -> void:
	draw_rect(Rect2(0,0,1152,648),Color("081722"))
	for y in range(170,648,32):
		for x in range(0,1152,32):
			var cell := int(x/32)+int(y/32)
			var col := Color("123342") if posmod(cell,2)==0 else Color("102f3d")
			draw_rect(Rect2(x,y,32,32),col)
	for x in range(0,1152,32): draw_line(Vector2(x,170),Vector2(x,648),Color(0.18,0.32,0.37,0.35),1)
	for y in range(170,648,32): draw_line(Vector2(0,y),Vector2(1152,y),Color(0.18,0.32,0.37,0.35),1)

func _draw() -> void:
	grid_floor()
	label(Vector2(24,35),"SONNENHAIN · LOKALES QUALITÄTSLABOR V3 · HIGH-RES PIXELART",26,Color("ffe2aa"))
	label(Vector2(24,64),"Magier ~96×144 · Schleim ~96×72 · Wolf ~144×104 · mehr Pixel für echte Details",16,Color("b8d4ce"))
	label(Vector2(24,91),"WASD/Pfeile bewegen · Q/E Richtung · Leertaste/M1 Angriff · H Treffer · R Tod/Reset · 1–3 Fokus",15)
	label(Vector2(24,116),"Keine Serververbindung · keine Savegame-Änderung · reine Darstellungs-/Animationsprüfung",14,Color("91b6ac"))
	panel(Rect2(20,130,350,34),"1 · MAGIER / HIGH-RES LAYER",selected==0)
	panel(Rect2(401,130,350,34),"2 · SCHLEIM / KLASSISCHER BLOB",selected==1)
	panel(Rect2(782,130,350,34),"3 · WOLF / AGGRESSIVE SILHOUETTE",selected==2)

	Models.mage(self,mage_pos,facing,phase,action,action_t)
	label(mage_pos+Vector2(-78,74),"MAGIER · "+dir_name(facing),14,Color("ffe2aa"))

	var slime_pos := Vector2(255,385)
	var wolf_pos := Vector2(900,390)
	Models.slime(self,slime_pos,facing,phase,action,action_t)
	label(slime_pos+Vector2(-74,70),"SCHLEIM · "+action.to_upper(),14,Color("baf2a9"))
	Models.wolf(self,wolf_pos,facing,phase,action,action_t)
	label(wolf_pos+Vector2(-65,78),"WOLF · "+action.to_upper(),14,Color("d8dde8"))

	draw_rect(Rect2(26,515,330,91),Color(0.04,0.10,0.14,0.78))
	label(Vector2(38,540),"MAGIER",15,Color("ffe2aa"))
	label(Vector2(38,560),"• größerer Kopf / sichtbares Gesicht / Staff-Handbindung",13)
	label(Vector2(38,579),"• mehr Materialdetails, Goldkanten und Stofffalten",13)
	label(Vector2(38,598),"• Walk / Attack / Hurt / Death",13)
	draw_rect(Rect2(411,515,330,91),Color(0.04,0.10,0.14,0.78))
	label(Vector2(423,540),"SCHLEIM",15,Color("baf2a9"))
	label(Vector2(423,560),"• klassischer Sonnenhain-Blob mit Gelkern",13)
	label(Vector2(423,579),"• breite Kuppel, Glanz, Spritzrand, Blasen",13)
	label(Vector2(423,598),"• gerichteter Angriff mit Masse",13)
	draw_rect(Rect2(796,515,330,91),Color(0.04,0.10,0.14,0.78))
	label(Vector2(808,540),"WOLF",15,Color("d8dde8"))
	label(Vector2(808,560),"• tiefe Kampfhaltung + breite Schulterpartie",13)
	label(Vector2(808,579),"• Zähne, Krallen, rote Augen, zackige Mähne",13)
	label(Vector2(808,598),"• Kopf/Schweif folgen Richtung",13)

func dir_name(v: Vector2) -> String:
	return ["S","SO","O","NO","N","NW","W","SW"][Models.direction_index(v)]
