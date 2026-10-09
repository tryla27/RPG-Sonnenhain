extends SceneTree
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass

var failures:=0
func check(v:bool,label:String)->void:
	if not v:
		failures+=1
		print("FAIL ",label)

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g=Game.new()
	g.player_pos=Vector2(1000,1000)
	g.enemies=[]
	check(is_equal_approx(g.party_widget_rect().position.y,12.0),"party widget normal y")
	var boss:=g.make_enemy(12,g.player_pos+Vector2(120,0))
	boss["hp"]=100.0;boss["max_hp"]=100.0
	g.enemies=[boss]
	check(is_equal_approx(g.party_widget_rect().position.y,82.0),"party widget shifts below boss bar")
	var debug:Rect2=g.multiplayer_debug_rect()
	check(not debug.intersects(Rect2(918,8,234,30)),"network debug vs region header")
	check(not debug.intersects(Rect2(980,61,110,110)),"network debug vs minimap")
	check(debug.position.y>=218.0,"network debug below right HUD")
	var source:=FileAccess.get_file_as_string("res://main.gd")
	check("draw_ref_panel(Rect2(362,540,405,32))" not in source,"duplicate fruit prompt removed")
	check(source.count("HudLayout.draw_prompt(self") == 1,"single desktop interaction prompt channel")
	check("food_system.regrow_remaining(nearby_food[\"point\"])" in source,"fruit timer routed through interaction prompt")
	print("HUD_LAYOUT_CHECK failures=",failures," · boss/party/right-status/bottom prompts separated")
	g.free()
	quit(1 if failures else 0)
