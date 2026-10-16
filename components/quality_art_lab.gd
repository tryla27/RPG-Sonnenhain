extends Control
## Isoliertes Grafiklabor mit echten Runtime-Exporten, ohne Spielstand oder Konto.
const MODEL_ROOT:="res://art/models/quality_v1/"
const Ragdoll=preload("res://components/quality_ragdoll.gd")
var manifest:Array=[]
var viewport:SubViewport
var stage:Node3D
var model:Node3D
var camera:Camera3D
var asset_picker:OptionButton
var animation_picker:OptionButton
var animation_player:AnimationPlayer
var info:Label
var rotation_clock:=0.0
var copies:Array=[]
var count_picker:OptionButton

func _ready()->void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop:=ColorRect.new();backdrop.color=Color("142b32");backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(backdrop)
	var title:=Label.new();title.text="SONNENHAIN · GRAFIKLABOR";title.position=Vector2(24,14);title.add_theme_font_size_override("font_size",24);add_child(title)
	var hint:=Label.new();hint.text="Isolierte Vorschau · keine Konto-/Speicheränderungen · ESC beendet";hint.position=Vector2(24,48);add_child(hint)
	var layout:=HBoxContainer.new();layout.position=Vector2(24,84);layout.size=Vector2(1232,650);add_child(layout)
	var side:=VBoxContainer.new();side.custom_minimum_size=Vector2(270,600);layout.add_child(side)
	asset_picker=OptionButton.new();side.add_child(asset_picker)
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(MODEL_ROOT+"manifest.json"))
	manifest=data["assets"]
	for asset in manifest:asset_picker.add_item(str(asset["id"]).replace("_"," "))
	asset_picker.item_selected.connect(select_model)
	animation_picker=OptionButton.new();side.add_child(animation_picker)
	animation_picker.item_selected.connect(play_animation)
	count_picker=OptionButton.new();count_picker.add_item("1 Modell");count_picker.add_item("20 Modelle");side.add_child(count_picker)
	count_picker.item_selected.connect(func(_index):select_model(asset_picker.selected))
	var rotate:=CheckButton.new();rotate.text="Modell drehen";side.add_child(rotate)
	rotate.toggled.connect(func(value):rotation_clock=1.0 if value else 0.0)
	var ragdoll_button:=Button.new();ragdoll_button.text="Ragdoll testen (Krieger)";side.add_child(ragdoll_button);ragdoll_button.pressed.connect(test_ragdoll)
	info=Label.new();info.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;info.custom_minimum_size=Vector2(270,200);side.add_child(info)
	var map_button:=Button.new();map_button.text="Kartenentwurf";side.add_child(map_button)
	map_button.pressed.connect(func():show_image("res://art/ui/quality_v1/world_map.png"))
	var ui_button:=Button.new();ui_button.text="Icons und Effekte";side.add_child(ui_button);ui_button.pressed.connect(show_ui)
	var items_button:=Button.new();items_button.text="Waffenbilder";side.add_child(items_button);items_button.pressed.connect(show_items)
	for person in ["mira","fenna","borin"]:
		var portrait_button:=Button.new();portrait_button.text=person.capitalize()+" · Porträtentwurf";side.add_child(portrait_button)
		portrait_button.pressed.connect(show_image.bind("res://art/ui/quality_v1/portrait_%s.png"%person))
	var container:=SubViewportContainer.new();container.custom_minimum_size=Vector2(930,620);container.stretch=true;layout.add_child(container)
	viewport=SubViewport.new();viewport.size=Vector2i(930,620);viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;viewport.own_world_3d=true;container.add_child(viewport)
	stage=Node3D.new();viewport.add_child(stage)
	var floor_body:=StaticBody3D.new();var floor_shape:=CollisionShape3D.new();var floor_box:=BoxShape3D.new()
	floor_box.size=Vector3(40,.2,40);floor_shape.shape=floor_box;floor_body.position.y=-.15;floor_body.add_child(floor_shape);stage.add_child(floor_body)
	camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=3.6;camera.position=Vector3(3,3.5,5);stage.add_child(camera);camera.look_at(Vector3(0,.8,0))
	var light:=DirectionalLight3D.new();light.rotation_degrees=Vector3(-45,-35,0);light.light_energy=1.0;stage.add_child(light)
	var environment:=WorldEnvironment.new();environment.environment=Environment.new();environment.environment.background_mode=Environment.BG_COLOR
	environment.environment.background_color=Color("31454a");environment.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;environment.environment.ambient_light_color=Color("e5dbc6");environment.environment.ambient_light_energy=.65;stage.add_child(environment)
	select_model(0)

func find_player(node:Node)->AnimationPlayer:
	if node is AnimationPlayer:return node
	for child in node.get_children():
		var result:=find_player(child)
		if result!=null:return result
	return null

func select_model(index:int)->void:
	for copy in copies:copy.free()
	copies.clear();animation_player=null;animation_picker.clear()
	var asset:Dictionary=manifest[index]
	var scene:PackedScene=load("res://"+str(asset["path"]))
	var count:=20 if count_picker.selected==1 else 1
	for i in count:
		var body:Node3D=scene.instantiate();stage.add_child(body);copies.append(body)
		if count>1:body.position=Vector3((i%5-2)*2.3,0,(i/5-1.5)*2.3)
	model=copies[0];animation_player=find_player(model)
	if animation_player!=null:
		for animation in animation_player.get_animation_list():
			if animation!="RESET":animation_picker.add_item(animation)
	animation_picker.visible=animation_picker.item_count>0
	camera.size=14 if count>1 else (5.0 if str(asset["kind"])=="building" else 3.6)
	info.text="%s\n\n%s\n\nQuelle: Blender\nGLB-Export, gemeinsame Materialpalette\n\nDiese Modelle sind zur Beurteilung im Labor. Bestehende Spielfiguren und Dorfgebäude bleiben verfügbar."%[asset["id"],asset["kind"]]
	if animation_picker.item_count>0:play_animation(0)

func play_animation(index:int)->void:
	var name:=animation_picker.get_item_text(index)
	for copy in copies:
		var player:=find_player(copy)
		if player!=null:player.play(name)

func test_ragdoll()->void:
	for copy in copies:
		var skeleton:=Ragdoll.find_skeleton(copy)
		if skeleton==null:continue
		var player:=find_player(copy)
		if player!=null:player.stop()
		if skeleton.get_node_or_null("QualityRagdoll")!=null:continue
		var simulator:=Ragdoll.attach(skeleton)
		simulator.physical_bones_start_simulation()
		for body in simulator.get_children():body.apply_central_impulse(Vector3(.25,0,.3))

func show_image(path:String)->void:
	var panel:=Window.new();panel.title="Sonnenhain · Entwurf";panel.size=Vector2i(1030,700)
	var image:=TextureRect.new();image.texture=load(path);image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	panel.add_child(image);image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(panel);panel.popup_centered();panel.close_requested.connect(panel.queue_free)

func show_ui()->void:
	var panel:=Window.new();panel.title="Sonnenhain · Icons und Effektfolgen";panel.size=Vector2i(720,560)
	var list:=VBoxContainer.new();list.position=Vector2(24,24);panel.add_child(list)
	for name in ["attack","skill","quest","waystone","cooking","fusion"]:
		var row:=HBoxContainer.new();list.add_child(row)
		var icon:=TextureRect.new();icon.texture=load("res://art/ui/quality_v1/%s_32.png"%name);row.add_child(icon)
		var label:=Label.new();label.text=name;row.add_child(label)
	for name in ["fire","frost","poison","hit"]:
		var strip:=TextureRect.new();strip.texture=load("res://art/ui/quality_v1/vfx_%s.png"%name);list.add_child(strip)
	add_child(panel);panel.popup_centered();panel.close_requested.connect(panel.queue_free)

func show_items()->void:
	var panel:=Window.new();panel.title="Sonnenhain · Waffenbilder aus 3D-Quellen";panel.size=Vector2i(520,480)
	var grid:=GridContainer.new();grid.columns=3;grid.position=Vector2(24,24);panel.add_child(grid)
	for kind in ["sword","staff","bow"]:
		for tier in [1,2,3]:
			var cell:=VBoxContainer.new();grid.add_child(cell)
			var icon:=TextureRect.new();icon.custom_minimum_size=Vector2(130,96);icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture=load("res://art/ui/quality_v1/items/%s_tier%d.png"%[kind,tier]);cell.add_child(icon)
			var label:=Label.new();label.text="%s · %d"%[kind,tier];cell.add_child(label)
	add_child(panel);panel.popup_centered();panel.close_requested.connect(panel.queue_free)

func _process(delta:float)->void:
	if rotation_clock>0 and is_instance_valid(model):model.rotate_y(delta*.5)
	if Input.is_action_just_pressed("ui_cancel"):get_tree().quit()
