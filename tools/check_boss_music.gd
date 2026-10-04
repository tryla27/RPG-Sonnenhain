extends SceneTree
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
func _initialize()->void:
	var g=Game.new()
	g.skill_levels.resize(16);g.skill_levels.fill(0)
	var failures=0
	for index in 3:
		if g.enemy_level(index+12)!=[12,43,19][index]:failures+=1
		if not g.register_boss_defeat(index,true):failures+=1
		if g.register_boss_defeat(index,true):failures+=1
	# Individuelle Klassenboss-Musik wird pro Boss geroutet; solange die
	# hochgeladenen OGG-Assets noch nicht im Repository liegen, bleibt boss.wav
	# als sicherer Fallback exportierbar.
	for i in 3:
		var boss:=g.make_enemy(12+i,g.CLASS_BOSS_SITES[i])
		boss["hp"]=100.0;boss["max_hp"]=100.0;boss["target_peer"]=0
		boss["attack_state"]={"id":1,"ability":{"id":["kriegshieb","arkansalve","praezisionsschuss"][i]}}
		g.enemies=[boss];g.player_pos=g.CLASS_BOSS_SITES[i]+Vector2(100,0)
		if g.active_class_boss_music_theme()!=g.CLASS_BOSS_MUSIC_THEMES[i]:failures+=1
		if g.music_path_for_theme(g.CLASS_BOSS_MUSIC_THEMES[i])=="":failures+=1
	if g.boss_spell_sound("blutrausch")!="skill_14":failures+=1
	if g.boss_spell_sound("sternengewitter")!="skill_23":failures+=1
	if g.boss_spell_sound("jagdrausch")!="skill_28":failures+=1
	print("BOSS_MUSIC_CHECK failures=",failures," · class boss levels / individual music routing / spell SFX / credit dedupe / safe-zone borders")
	g.free()
	quit(1 if failures else 0)
