extends SceneTree

const KonfluxMap = preload("res://components/konflux_map.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var center := KonfluxMap.CENTER
	var blocked_a := center + Vector2(-150,-125)
	var blocked_b := center + Vector2(110,-125)
	assert(not KonfluxMap.line_clear(blocked_a,blocked_b,0), "Interior furniture must block Konflux area line of sight")

	var clear_a := center + Vector2(-180,120)
	var clear_b := center + Vector2(180,120)
	assert(KonfluxMap.line_clear(clear_a,clear_b,0), "Open interior lane should remain clear")

	var map := KonfluxMap.new()
	map.touch_chunk(Vector2i(0,0))
	map.touch_chunk(Vector2i(1,0))
	map.touch_chunk(Vector2i(2,0))
	map.touch_chunk(Vector2i(0,0))
	assert(map.chunk_order == [Vector2i(1,0),Vector2i(2,0),Vector2i(0,0)], "Chunk cache must refresh recently used entries")

	var source := FileAccess.get_file_as_string("res://components/konflux_map.gd")
	assert(source.contains('int(state.get("rings",0))'), "Konflux remote renderer must forward synchronized ring visuals")
	assert(source.contains("CHUNKS_PER_PRELOAD_TICK"), "Konflux chunk preloading must remain budgeted")

	print("KONFLUX_PVP_RENDER_FIXES_OK: interior LOS, LRU cache, remote rings, preload budget")
	quit()
