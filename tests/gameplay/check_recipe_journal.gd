extends SceneTree
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_d:float)->void:pass
	func save_game()->void:pass
	func play_sound(_s:String)->void:pass
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error("RECIPE_JOURNAL_FAIL "+label)
func _initialize()->void:
	var g:=Game.new()
	g.panel="journal";g.gold=100
	check(g.recipe_journal.known(g)==[0],"nur tatsächlich gelernte Rezepte")
	check(g.steinrose.learn_recipe(g,3),"Rezept bei Alma lernen")
	check(g.recipe_journal.known(g)==[0,3],"neu gelernt sofort unterwegs sichtbar")
	g.inventory=[{"name":"Kristallbeeren","count":1},{"name":"Kristallbeeren","count":1}]
	var before:=g.inventory.duplicate(true)
	var rows:Array=g.recipe_journal.ingredient_rows(g,3)
	check(rows[0]["owned"]==2 and rows[0]["needed"]==2 and rows[0]["missing"]==0,"Bestand über Stapel")
	check(rows[1]["missing"]==2 and rows[1]["region"]==10,"fehlende Quellbeeren mit Fundgebiet")
	check(g.recipe_journal.ingredient_rows(g,2).is_empty(),"ungelernte Rezepte verborgen")
	g.recipe_journal.click(g,Vector2(820,110))
	check(g.recipe_journal.tab==1,"Rezepte-Reiter öffnen")
	g.recipe_journal.click(g,Vector2(200,216))
	check(g.recipe_journal.selected==3,"gelerntes Rezept auswählen")
	var saved:=g.steinrose.snapshot()
	g.steinrose.restore(saved)
	check(g.recipe_journal.known(g)==[0,3],"bestehender Speicherstand wiederverwendet")
	check(g.inventory==before,"Lesen verbraucht keine Zutaten")
	g.recipe_journal.click(g,Vector2(640,110))
	check(g.recipe_journal.tab==0,"zurück zu Quests")
	g.free();print("RECIPE_JOURNAL failures=",failures);quit(1 if failures else 0)
