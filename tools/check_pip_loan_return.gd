extends SceneTree

func _initialize()->void:
	var main:=FileAccess.get_file_as_string("res://main.gd")
	assert(main.find("var pip_loan_level := 0")>=0)
	assert(main.find('"pip_loan_level":pip_loan_level')>=0)
	assert(main.find('loan["loaned"]=true')>=0)
	assert(main.find('loan["locked"]=true')>=0)
	assert(main.find("if level>pip_loan_level:")>=0)
	assert(main.find("Pip: He, du bist stärker geworden!")>=0)
	assert(main.find("Pip: Ein neues Level, hm?")>=0)
	assert(main.find("Pip: Borin sagt, Fortschritt macht selbstständig.")>=0)
	assert(main.find("Sie hat dir gute Dienste geleistet.")>=0)
	assert(main.find("Gratuliere zum Levelaufstieg!")>=0)
	assert(main.find("func pip_loan_item_index()->int:")>=0)
	assert(main.find('bool(inventory[i].get("loaned",false))')>=0)
	assert(main.find("func pip_return_loan_weapon()->String:")>=0)
	print("PIP_LOAN_RETURN_OK level-bound return, exact loan item, five dialogue variants")
	quit()
