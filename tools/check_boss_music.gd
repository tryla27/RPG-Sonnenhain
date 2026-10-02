extends SceneTree
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
func _initialize()->void:
	var g=Game.new()
	g.skill_levels.resize(16);g.skill_levels.fill(0)
	var failures=0
	var stream=load("res://music/konflux-pvp.ogg") as AudioStreamOggVorbis
	if stream==null or stream.get_length()<132 or stream.get_length()>133:failures+=1
	g.konflux.active=true;g.konflux.room=-1
	for direction in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
		g.player_pos=g.KonfluxMap.CENTER+direction*1199
		if g.desired_music_theme()!="dorf":failures+=1
		g.player_pos=g.KonfluxMap.CENTER+direction*1201
		if g.desired_music_theme()!="konflux-pvp":failures+=1
	g.konflux.active=false
	for index in 3:
		if g.enemy_level(index+12)!=[12,43,19][index]:failures+=1
		if not g.register_boss_defeat(index,true):failures+=1
		if g.register_boss_defeat(index,true):failures+=1
	print("BOSS_MUSIC_CHECK failures=",failures," · class boss map levels / credit dedupe / full 132s song / safe-zone borders")
	g.free()
	quit(1 if failures else 0)
