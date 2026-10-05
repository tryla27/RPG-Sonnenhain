extends SceneTree

class Board:
	extends "res://main.gd"
	var mode:="village"
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func _draw()->void:
		font=ThemeDB.fallback_font
		character_canvas_offset=Vector2.ZERO
		if mode=="village":
			SpawnPlatform32.platform(self,WAYSTONES[0])
			var props:=village_props()
			props.append({"kind":"qa_spawn","point":WAYSTONES[0],"depth":WAYSTONES[0].y})
			props.sort_custom(func(a,b):return float(a["depth"])<float(b["depth"]))
			for prop in props:
				if prop["kind"]=="qa_spawn":draw_waystone(prop["point"])
				else:paint_village_prop(prop)
			draw_fusion_crystal()
			draw_character_sprite(waystone_arrival(0),0,false,Vector2.DOWN,WORLD_CHARACTER_SCALE,false,0,0)
			text_at(WAYSTONES[0]+Vector2(-80,155),"SPAWN",20,Color.WHITE)
			for house in VillageLayout.SHOPS:
				var door:=village_house_door(house)
				draw_character_sprite(door+Vector2(0,40),0,false,Vector2.DOWN,WORLD_CHARACTER_SCALE,false,0,0)
				text_at(door+Vector2(-64,78),str(house["name"]),16,Color.WHITE)
		elif mode=="arena":
			ArenaInterior.paint(self,Vector2(1024,1024),640)
			draw_character_sprite(Vector2(1024,1024),0,false,Vector2.DOWN,WORLD_CHARACTER_SCALE,false,0,0)
		elif mode=="lobby":
			ArenaInterior.lobby(self,Vector2(672,384),font,"E")
			draw_character_sprite(Vector2(672,289),0,false,Vector2.DOWN,WORLD_CHARACTER_SCALE,false,0,0)
		elif mode=="fusion":
			draw_rect(Rect2(0,0,1152,648),Color("15242e"))
			draw_fusion_panel()
		else:
			draw_rect(Rect2(0,0,1600,1600),Color("283c35"))
			for row in 10:
				for col in 8:
					var look:=Vector2(sin(col*PI/4),cos(col*PI/4))
					var p:=Vector2(110+col*192,120+row*144)
					player_pos=p;hero_race=2 if mode=="heads" else 0
					cosmetic_hair=row+1 if mode=="heads" else 0
					cosmetic_jewelry=row+1;cosmetic_cloak=2;cosmetic_accent=3
					class_id=1;walk_phase=row*0.65;world_time=walk_phase
					death_timer=0;dash_timer=0
					if mode=="motion":
						class_id=0;hero_race=2;cosmetic_hair=col+1
						if row>=7:death_timer=DEATH_DURATION*(1.0-float(row-6)/4)
						elif row>=4:dash_timer=dodge_duration*(1.0-float(row-3)/4);dash_dir=look
						else:swing_timer=0.25 if row==2 else 0.0
					draw_hero(p,1.5,row%2==1,look,true)
					text_at(p+Vector2(-44,50),str(row+1),13)

func _initialize()->void:
	call_deferred("capture")

func capture()->void:
	DirAccess.make_dir_recursive_absolute("res://.godot/qa")
	for mode in ["village","arena","lobby","heads","badges","motion","fusion"]:
		var vp:=SubViewport.new()
		vp.size=Vector2i(1780,2600) if mode=="village" else (Vector2i(2048,2048) if mode=="arena" else (Vector2i(1152,648) if mode=="fusion" else Vector2i(1600,1600)))
		if mode=="lobby":vp.size=Vector2i(1344,768)
		vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		root.add_child(vp)
		var board:=Board.new()
		board.mode=mode;board.reset_class_skills();board.level=50;board.gold=100000
		board.learned[0]=true;board.learned[1]=true;board.skill_levels[0]=1;board.skill_levels[1]=1
		if mode=="village":
			var map=load("res://components/start_tilemap_32.gd").new()
			map.road_distance=Callable(board,"distance_to_trail")
			vp.add_child(map)
		vp.add_child(board)
		await process_frame
		await RenderingServer.frame_post_draw
		await process_frame
		await RenderingServer.frame_post_draw
		assert(vp.get_texture().get_image().save_png("res://.godot/qa/%s.png" % mode)==OK)
		vp.queue_free()
		await process_frame
	print("VILLAGE_RENDER_QA_OK")
	quit()
