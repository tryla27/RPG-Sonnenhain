extends SceneTree
# Schreibt die Spielregeln, die das Prüfwerkzeug für Server-Spielstände braucht:
# Mindeststufe je Quest (Stufe des Zielgebiets) und je Klassenboss.
# Aufruf: godot --headless --path . --script tools/save_audit_spec.gd -- <ziel.json>

func _initialize()->void:
	var g=load("res://main.gd").new()
	var quests:Array=[]
	for quest in g.QUESTS:
		var enemy:Dictionary=g.ENEMY_TYPES[int(quest["target"])]
		quests.append({"title":str(quest["title"]),"level":g.region_level(int(enemy["region"]))})
	var bosses:Array=[]
	for type in [12,13,14]:
		bosses.append({"name":str(g.ENEMY_TYPES[type]["name"]),"level":g.region_level(int(g.ENEMY_TYPES[type]["region"]))})
	var out:String=OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size()>0 else "user://save_audit_spec.json"
	var file:=FileAccess.open(out,FileAccess.WRITE)
	file.store_string(JSON.stringify({"quests":quests,"bosses":bosses}))
	file.close()
	g.free()
	print("SAVE_AUDIT_SPEC_OK ",out)
	quit()
