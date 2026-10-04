extends SceneTree
class Game extends "res://main.gd":
	var pip_calls:=0
	func _ready()->void:pass
	func _draw()->void:pass
	func _process(_delta:float)->void:pass
	func pip_dialogue()->void:pip_calls+=1
func _initialize()->void:
	var g:=Game.new()
	g.level=14;g.pip_loan_level=13;g.pip_loan_received=false
	g.interact_interior_owner("Borin")
	assert(g.pip_calls==0 and g.panel=="essence")
	g.pip_loan_received=true;g.pip_loan_level=14
	g.interact_interior_owner("Borin")
	assert(g.pip_calls==0 and g.panel=="essence")
	g.level=15;g.interact_interior_owner("Borin")
	assert(g.pip_calls==1 and g.panel=="essence")
	print("PIP_BORIN_AUTO_RETURN_OK actual interaction: only due loans summon Pip; Borin still opens essence")
	g.free();quit()
