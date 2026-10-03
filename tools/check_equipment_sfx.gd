extends SceneTree

func _initialize()->void:
	var main:=FileAccess.get_file_as_string("res://main.gd")
	var sfx:=FileAccess.get_file_as_string("res://components/equipment_sfx.gd")
	assert(main.find('sound_streams["equip"]=EquipmentSfx.make(true)')>=0)
	assert(main.find('sound_streams["unequip"]=EquipmentSfx.make(false)')>=0)
	assert(main.find('play_sound("unequip" if removing else "equip")')>=0)
	assert(main.find('play_sound("equip")')>=0)
	assert(main.find('play_sound("unequip")')>=0)
	assert(sfx.find("static func make(equipping: bool)")>=0)
	for icon in ["sword","staff","bow","armor","ring","head"]:
		assert(main.find('"'+icon+'"')>=0)
	print("EQUIPMENT_SFX_OK equip/unequip feedback wired for all wearable categories")
	quit()
