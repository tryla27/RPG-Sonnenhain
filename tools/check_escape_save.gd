extends SceneTree
class TestGame:
	extends "res://main.gd"
	func _ready():pass
	func _process(_delta):pass
	func _draw():pass
	func play_sound(_key):pass
	func slot_save_path(_index:int,_testing:bool=false)->String:return "user://escape-save-check.json"
func _initialize():call_deferred("run")
func run():
	var g:=TestGame.new();root.add_child(g)
	g.reset_class_skills()
	g.panel="pause";g.character_created=true;g.player_uuid="escape-save-check"
	g.handle_panel_click(Vector2(700,530))
	assert(g.panel=="pause")
	assert(g.pause_status.contains("Lokal gesichert"))
	assert(g.pause_status.contains("ausstehend"))
	assert(not g.pause_status.begins_with("Server gespeichert"))
	g.handle_panel_click(Vector2(250,500))
	assert(g.panel=="patches")
	assert(preload("res://components/patch_notes.gd").NOTES.size()>=10)
	g.class_id=1;g.inventory=[g.make_item("Ring A","ring",1,5,10),g.make_item("Ring B","ring",1,5,10)]
	g.inventory[0]["uid"]=11;g.inventory[1]["uid"]=12
	g.equipped_ring_uid=11;g.equipped_ring2_uid=12
	assert(g.ring_visual()==3 and g.local_player_state()["rings"]==3)
	g.panel="inventory";g.handle_panel_click(Vector2(349,479));assert(g.equipped_ring_uid==-1 and g.equipped_ring2_uid==12)
	g.handle_panel_click(Vector2(454,479));assert(g.equipped_ring2_uid==-1)
	for cls in 3:assert(preload("res://components/class_spell_preview.gd").ids(cls).size()==3)
	print("ESCAPE_SAVE_CHECK passed direct button, stays in menu, no false server confirmation")
	g.queue_free();quit()
