extends SceneTree
const Fog=preload("res://components/world_fog.gd")
const Builder=preload("res://components/world_builder.gd")
const Palette=preload("res://components/world_material_palette_32.gd")
const Game=preload("res://main.gd")

func _initialize()->void:
	var g=Game.new()
	g.player_pos=Vector2(1740,1120)
	g.character_created=true
	var fog=Fog.new()
	fog.configure(g.WORLD)
	fog.update_from_game(g)
	assert(fog.explored_world(Vector2(1740,1120)))
	# Vision must cross the Map-0 east border instead of stopping at a region boundary.
	assert(g.region_at(Vector2(1779,1120))==0)
	assert(g.region_at(Vector2(1801,1120))==1)
	assert(fog.explored_world(Vector2(1801,1120)))

	# A party member nearby shares vision; one far away does not.
	g.party_state={"members":[
		{"uuid":g.player_uuid,"context":"world","instance_id":"world","pos":[1740.0,1120.0]},
		{"uuid":"friend","context":"world","instance_id":"world","pos":[2940.0,1120.0]},
		{"uuid":"far","context":"world","instance_id":"world","pos":[7200.0,3200.0]}
	]}
	fog.update_from_game(g)
	assert(fog.explored_world(Vector2(3400,1120)))
	assert(not fog.explored_world(Vector2(7200,3200)))
	var before:=fog.snapshot()
	var restored=Fog.new()
	restored.restore([],g.WORLD,before)
	assert(restored.explored_world(Vector2(3400,1120)))
	assert(restored.explored_world(Vector2(1801,1120)))
	assert(fog.legacy_snapshot().size()<=512)

	# Material families stay native 32px and contain both floor and wall sets.
	assert(Palette.TILE==32)
	assert(Palette.ids("ground").size()>=10)
	assert(Palette.ids("wall").size()>=6)
	assert(Palette.transition_pairs().size()>=8)

	var b=Builder.new()
	var cell:=Vector2i(10,10)
	b.layer="ground";b.selection_id="grass_meadow";b.paint(cell)
	assert(str(b.cells["ground"].get(b.key(cell),""))=="grass_meadow")
	b.undo();assert(not b.cells["ground"].has(b.key(cell)))
	b.redo();assert(b.cells["ground"].has(b.key(cell)))

	# Gate validator must reject a wall placed in a village gate approach.
	b.layer="walls";b.selection_id="wall_village_stone"
	var gate_cell:=Vector2i(floori(g.VILLAGE_GATES[0].x/32),floori(g.VILLAGE_GATES[0].y/32))
	b.paint(gate_cell)
	assert(not b.validate(g).is_empty())
	b.undo()
	assert(b.validate(g).is_empty())

	assert(b.save_file())
	var loaded=Builder.new()
	assert(loaded.load_file())
	assert(loaded.cells["ground"].has(loaded.key(cell)))

	g.free()
	print("WORLD_BUILDER_FOG_OK 32px palettes, undo/redo, validation, export, cross-region and nearby party vision")
	quit()
