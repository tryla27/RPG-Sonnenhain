extends SceneTree
func _initialize()->void:
	var main:=FileAccess.get_file_as_string("res://main.gd")
	assert(main.find('if pip_loan_received and level>pip_loan_level:')>=0)
	assert(main.find('pip_dialogue()\n\t\t\tpanel="essence"')>=0)
	print("PIP_BORIN_AUTO_RETURN_OK")
	quit()
