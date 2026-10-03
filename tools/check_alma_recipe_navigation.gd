extends SceneTree

const SteinroseKitchen = preload("res://components/steinrose_kitchen.gd")

func _initialize() -> void:
	var missing:Array[String]=[]
	for berry in SteinroseKitchen.BERRIES:
		var used:=false
		for recipe in SteinroseKitchen.RECIPES:
			if (recipe["ingredients"] as Dictionary).has(berry):
				used=true
				break
		if not used:
			missing.append(str(berry))
	if not missing.is_empty():
		push_error("ALMA_BERRY_COVERAGE_MISSING: %s" % ", ".join(missing))
		quit(1)
		return

	var source:=FileAccess.get_file_as_string("res://components/steinrose_kitchen.gd")
	if source.find('"WIRKUNGEN"')>=0:
		push_error("ALMA_MENU_EFFECTS_TAB_STILL_PRESENT")
		quit(1)
		return
	if source.find("if tab not in [0,2]:return false")<0:
		push_error("ALMA_ARROW_NAVIGATION_NOT_ENABLED_FOR_RECIPES_AND_COOKING")
		quit(1)
		return
	if source.find("if tab==0:learn_recipe(g,selected)")<0 or source.find("else:cook(g,selected)")<0:
		push_error("ALMA_ENTER_ACTIONS_MISSING")
		quit(1)
		return

	print("ALMA_RECIPE_NAVIGATION_OK berries=%d recipes=%d" % [SteinroseKitchen.BERRIES.size(),SteinroseKitchen.RECIPES.size()])
	quit(0)
