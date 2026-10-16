extends SceneTree
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func find_skeleton(node:Node)->Skeleton3D:
	if node is Skeleton3D:return node
	for child in node.get_children():
		var result:=find_skeleton(child)
		if result!=null:return result
	return null
func find_player(node:Node)->AnimationPlayer:
	if node is AnimationPlayer:return node
	for child in node.get_children():
		var result:=find_player(child)
		if result!=null:return result
	return null
func _initialize()->void:call_deferred("run")
func run()->void:
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/models/quality_v1/manifest.json"))
	check(data["assets"].size()==23,"23 exportierte Modelle")
	for asset in data["assets"]:
		var scene:PackedScene=load("res://"+str(asset["path"]))
		check(scene!=null,"GLB lässt sich laden: "+str(asset["id"]))
		if scene==null:continue
		var model:=scene.instantiate()
		if asset["id"]=="warrior_gold":
			var skeleton:=find_skeleton(model);var player:=find_player(model)
			check(skeleton!=null and skeleton.get_bone_count()>=8,"Krieger mit gemeinsamem Skelett")
			check(player!=null,"Krieger mit Animationsspieler")
			if player!=null:
				for name in asset["animations"]:check(player.has_animation(str(name)),"Aktion fehlt: "+str(name))
		model.free()
	for name in ["attack","skill","quest","waystone","cooking","fusion"]:
		var icon:Texture2D=load("res://art/ui/quality_v1/%s_32.png"%name)
		check(icon!=null and icon.get_size()==Vector2(32,32),"Korrekte Icongröße: "+name)
	for name in ["fire","frost","poison","hit"]:
		var strip:Texture2D=load("res://art/ui/quality_v1/vfx_%s.png"%name)
		check(strip!=null and strip.get_size()==Vector2(512,64),"Acht Effektbilder: "+name)
	if failures>0:quit(1);return
	print("QUALITY_ASSETS_OK 23 Modelle, Skelett und 9 Aktionen, Icons und Effektfolgen")
	quit()
