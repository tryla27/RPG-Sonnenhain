extends SceneTree

const Kitchen=preload("res://components/steinrose_kitchen.gd")

class TestGame:
	extends "res://main.gd"
	func _ready()->void: pass
	func _process(_delta:float)->void: pass
	func save_game()->void: pass
	func play_sound(_key:String)->void: pass
	func message(_text:String)->void: pass

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g:=TestGame.new()
	root.add_child(g)
	var kitchen:=Kitchen.new()
	g.panel="steinrose"
	kitchen.tab=0
	kitchen.selected=0

	var right:=InputEventKey.new()
	right.keycode=KEY_D
	right.pressed=true
	assert(kitchen.keyboard_input(g,right))
	assert(kitchen.selected==1,"D must move Alma selection right")

	var left:=InputEventKey.new()
	left.keycode=KEY_LEFT
	left.pressed=true
	assert(kitchen.keyboard_input(g,left))
	assert(kitchen.selected==0,"left arrow must move Alma selection left")

	g.inventory=[
		{"name":"Himbeeren","count":2},
		{"name":"Heidelbeeren","count":2},
		{"name":"Sonnenkraut","count":1}
	]
	assert(kitchen.can_cook(g,0),"recipe 0 must glow when all ingredients are present")
	g.inventory[0]["count"]=1
	assert(not kitchen.can_cook(g,0),"recipe 0 must stop glowing when an ingredient is missing")

	var source:=FileAccess.get_file_as_string("res://components/steinrose_kitchen.gd")
	assert(source.find("func draw_recipe_table")>=0)
	assert(source.find('Color("ffd86f",pulse)')>=0)
	assert(source.find("KEY_RIGHT,KEY_D")>=0)
	print("STEINROSE_TABLE_OK A/D + arrows navigate; cookable state drives glowing table cards")
	g.queue_free()
	quit()
