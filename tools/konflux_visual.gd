extends "res://main.gd"
var audit_frames:=0
var positions: Array=[Vector2(40000,40000),Vector2(18000,14150),Vector2(64000,13150),Vector2(18000,66150),Vector2(66000,58150),Vector2(16000,36600),Vector2(28000,19400)]
func _ready() -> void:
	super._ready()
	creative_mode=true
	hero_name="Konflux-Test"
	character_created=true
	level=40
	network_mode="offline"
	konflux.enter(self)
func _process(_delta: float) -> void:
	audit_frames+=1
	var index:=mini((audit_frames-1)/8,positions.size()+3)
	if index<positions.size():
		konflux.room=-1
		player_pos=positions[index]
	else:
		konflux.room=index-positions.size()
		player_pos=KonfluxMap.CENTER+Vector2(0,100)
	camera_pos=player_pos-Vector2(0,KonfluxMap.height_at(player_pos) if konflux.room<0 else 0)-VIEW*0.5
	queue_redraw()
	if audit_frames%8==0:
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://../../pvp-design/konflux-engine-%02d.png"%index)
		print("KONFLUX_VISUAL ",index)
		if index>=positions.size()+3: get_tree().quit()
