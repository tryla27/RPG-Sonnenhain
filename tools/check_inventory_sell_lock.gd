extends SceneTree

func _initialize()->void:
	var main:=FileAccess.get_file_as_string("res://main.gd")
	assert(main.find('bool(a.get("locked",false)) == bool(b.get("locked",false))')>=0)
	# Neue Gegenstände starten entsperrt (Verhalten statt Textsuche; Bau liegt in components/item_rules.gd).
	var game=load("res://main.gd").new()
	var fresh:Dictionary=game.make_item("Probeklinge","sword",1,5,0)
	assert(fresh.has("locked") and not bool(fresh["locked"]))
	game.free()
	assert(main.find('"UNVERKÄUFLICH" if bool(item.get("locked",false))')>=0)
	assert(main.find('Color("8d9492") if is_locked')>=0)
	assert(main.find('if int(item["uid"]) in equipped_item_uids() or bool(item.get("locked",false)): continue')>=0)
	assert(main.find('if bool(inventory[index].get("locked",false))')>=0)
	assert(main.find('"inventory":inventory')>=0)
	print("INVENTORY_SELL_LOCK_OK persistent lock state; no mixed stacks; grey UI; sell protection")
	quit()
