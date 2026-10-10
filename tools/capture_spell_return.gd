extends SceneTree
# Vorschau: Borins Spell-Abgabe (Liste, Infos, Spruch) und Skillfenster mit 4/4.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_spell_return.gd -- <ordner>

class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass

func _initialize()->void:call_deferred("capture")

func shot(vp:SubViewport,path:String)->void:
	for i in 8:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(path)
	print("CAPTURED ",path)

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(out)
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for i in 40:await process_frame
	g.class_id=1;g.reset_class_skills();g.level=40;g.character_created=true;g.hero_name="Angelo";g.skill_points=12
	var count:=0
	for id in g.SKILL_TREES[1]:
		if count>=4:break
		if id in g.CLASS_ULTIMATES or id in [9,10,11] or not g.fusion_definition_by_id(id).is_empty():continue
		g.learned[id]=true;g.skill_levels[id]=1+count%4;count+=1
	g.slots=[-1,-1,-1]
	var known:Array=g.learned_loadout_skills()
	for k in mini(3,known.size()):g.slots[k]=known[k]
	g.panel="skills";g.skill_tree_tab=1;g.menu_scroll=0
	await shot(vp,out.path_join("1-skills-4-von-4.png"))
	g.panel="spell_return";g.menu_scroll=0;g.spell_return_selected=int(known[1]);g.spell_return_confirm=true
	await shot(vp,out.path_join("2-borin-abgeben.png"))
	g.give_back_spell(int(known[1]));g.panel="spell_return"
	await shot(vp,out.path_join("3-borin-spruch.png"))
	quit()
