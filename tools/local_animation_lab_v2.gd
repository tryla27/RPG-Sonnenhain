extends Node2D

const Models = preload("res://components/animation_lab_models.gd")

var mage_pos := Vector2(800,390)
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
		mage_pos += move.normalized()*150.0*delta
		phase += delta*6.0
		if action == "idle": action = "walk"
	elif action == "walk":
		action = "idle"
		phase += delta*2.0
	else:
		phase += delta*(1.2 if action=="idle" else 3.0)
	mage_pos = mage_pos.clamp(Vector2(120,220),Vector2(1480,540))
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
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		if action!="death": action="attack"; action_t=0.0

func label(pos: Vector2,value: String,size := 17,color := Color("d8e6dc")) -> void:
	draw_string(font,pos,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func panel(r: Rect2,title: String,active: bool=false) -> void:
	draw_rect(r,Color("132a38"))
	draw_rect(r,Color("ffe2aa") if active else Color("456574"),false,2)
	label(r.position+Vector2(12,25),title,16,Color("ffe2aa") if active else Color("c8d8d3"))

func grid_floor() -> void:
	draw_rect(Rect2(0,0,1600,900),Color("081722"))
	for y in range(170,900,32):
		for x in range(0,1600,32):
			var cell := int(x/32)+int(y/32)
			var col := Color("123342") if posmod(cell,2)==0 else Color("102f3d")
			draw_rect(Rect2(x,y,32,32),col)
	for x in range(0,1600,32): draw_line(Vector2(x,170),Vector2(x,900),Color(0.18,0.32,0.37,0.35),1)
	for y in range(170,900,32): draw_line(Vector2(0,y),Vector2(1600,y),Color(0.18,0.32,0.37,0.35),1)

func _draw() -> void:
	grid_floor()
	label(Vector2(24,35),"SONNENHAIN · LOKALES QUALITÄTSLABOR V5 · SILHOUETTE + ATTACK",26,Color("ffe2aa"))
	label(Vector2(24,64),"High-Res Pixelart · Cursor steuert Blickrichtung · 8 Richtungen · Attack-Choreografie mit Wind-up / Impact / Recovery",16,Color("b8d4ce"))
	label(Vector2(24,91),"WASD/Pfeile Magier bewegen · Maus = Blickrichtung für jede Einheit · Leertaste/M1 Angriff · H Treffer · R Tod/Reset · 1–3 Galerie",15)
	label(Vector2(24,116),"Nur Qualitätslabor · keine Server-/Savegame-Änderung · Leertaste/M1 testet die neuen Angriffe",14,Color("91b6ac"))
	panel(Rect2(20,130,500,34),"1 · MAGIER / SILHOUETTE + KOPF",selected==0)
	panel(Rect2(550,130,500,34),"2 · SCHLEIM / KLASSISCHER BLOB",selected==1)
	panel(Rect2(1080,130,500,34),"3 · WOLF / AGGRESSIVE SILHOUETTE",selected==2)

	var mouse:=get_local_mouse_position()
	var slime_pos := Vector2(320,420)
	var wolf_pos := Vector2(1280,420)
	var mage_face := (mouse-mage_pos).normalized()
	var slime_face := (mouse-slime_pos).normalized()
	var wolf_face := (mouse-wolf_pos).normalized()
	if mage_face.length_squared()<0.01: mage_face=Vector2.DOWN
	if slime_face.length_squared()<0.01: slime_face=Vector2.DOWN
	if wolf_face.length_squared()<0.01: wolf_face=Vector2.DOWN

	Models.mage(self,mage_pos,mage_face,phase,action,action_t)
	label(mage_pos+Vector2(-120,92),"MAGIER · "+dir_name(mage_face)+" · "+action.to_upper(),14,Color("ffe2aa"))
	Models.slime(self,slime_pos,slime_face,phase,action,action_t)
	label(slime_pos+Vector2(-115,82),"SCHLEIM · "+dir_name(slime_face)+" · "+action.to_upper(),14,Color("baf2a9"))
	Models.wolf(self,wolf_pos,wolf_face,phase,action,action_t)
	label(wolf_pos+Vector2(-110,100),"WOLF · "+dir_name(wolf_face)+" · "+action.to_upper(),14,Color("d8dde8"))

	# Attack phase strip for timing review.
	draw_rect(Rect2(20,535,1560,40),Color(0.04,0.09,0.13,0.9))
	var attack_phase: String="IDLE"
	if action=="attack":
		attack_phase="WIND-UP" if action_t<0.30 else ("IMPACT" if action_t<0.58 else "RECOVERY")
	label(Vector2(34,561),"ATTACK TEST · "+attack_phase+" · Leertaste/M1 startet alle drei Referenzangriffe synchron",14,Color("f2d69a"))

	# Fixed eight-direction gallery for silhouette review.
	draw_rect(Rect2(20,585,1560,285),Color(0.035,0.08,0.11,0.92))
	label(Vector2(34,612),"8-RICHTUNGS-GALERIE · "+["MAGIER","SCHLEIM","WOLF"][selected],18,Color("ffe2aa"))
	label(Vector2(34,636),"S · SO · O · NO · N · NW · W · SW — gleiche Figur, echte Seiten-/Rückenlesbarkeit",14,Color("a9c9be"))
	for i in 8:
		var gp:=Vector2(110+i*195,795)
		var gv:=Models.direction_vector(i)
		draw_rect(Rect2(gp+Vector2(-88,-142),Vector2(176,190)),Color(0.05,0.12,0.16,0.7))
		draw_rect(Rect2(gp+Vector2(-88,-142),Vector2(176,190)),Color("34505d"),false,1)
		match selected:
			0: Models.mage(self,gp,gv,phase,"idle",0.0)
			1: Models.slime(self,gp,gv,phase,"idle",0.0)
			2: Models.wolf(self,gp,gv,phase,"idle",0.0)
		label(gp+Vector2(-18,56),["S","SO","O","NO","N","NW","W","SW"][i],13,Color("e8e0ca"))

func dir_name(v: Vector2) -> String:
	return ["S","SO","O","NO","N","NW","W","SW"][Models.direction_index(v)]
