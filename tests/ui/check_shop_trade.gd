extends SceneTree
# Shop: Maus + Enter kauft sofort, Mengenauswahl beim Kaufen und Verkaufen,
# angezeigter Gesamtwert stimmt mit dem echten Erlös überein.

const ShopTrade=preload("res://components/shop_trade.gd")

class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_d:float)->void:pass
	func save_game()->void:pass
	func play_sound(_n:String)->void:pass

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("SHOP_TRADE_FAIL "+label)

func _initialize()->void:call_deferred("run")

func count_named(g,name:String)->int:
	var n:=0
	for item in g.inventory:
		if str(item["name"])==name:n+=int(item.get("count",1))
	return n

func run()->void:
	var g:=Game.new()
	g.reset_class_skills();g.level=20;g.character_created=true
	g.merchant_kind="alchemy";g.shop_page=0;g.panel="shop"
	g.shop_stock={"smith":[],"alchemy":[{"name":"Heiltrank","icon":"potion","rarity":1,"power":0,"price":30,"level":20}],"arcane":[]}
	g.gold=100
	# Maus auf Angebot + Enter: genau 1 Stück.
	check(g.shop_quick_buy(ShopTrade.OFFER_RECTS[0].get_center()),"Enter über Angebot kauft")
	check(g.gold==70 and count_named(g,"Heiltrank")==1,"1 Stück gekauft (%d Gold)" % g.gold)
	check(not g.shop_quick_buy(Vector2(5,5)),"Enter ohne Angebot unter der Maus kauft nichts")
	# Dialog mit Menge: MAX begrenzt durch Gold.
	g.click_shop(ShopTrade.OFFER_RECTS[0].get_center())
	check(g.pending_purchase==0 and g.trade_quantity==1,"Kauffenster offen")
	g.click_shop(ShopTrade.MAX_BUTTON.get_center())
	check(g.trade_quantity==2,"MAX = so viel das Gold reicht (%d)" % g.trade_quantity)
	g.click_shop(ShopTrade.MINUS.get_center())
	check(g.trade_quantity==1,"Minus")
	g.click_shop(ShopTrade.PLUS.get_center())
	g.shop_quick_buy(Vector2(5,5))
	check(g.gold==10 and count_named(g,"Heiltrank")==3,"Enter im Fenster bestätigt 2 Stück")
	# Verkaufen mit Menge und Gesamtwert.
	var index:=-1
	for i in g.inventory.size():
		if str(g.inventory[i]["name"])=="Heiltrank":index=i
	g.selected_item=index
	g.click_shop(Vector2(800,580))
	check(g.pending_sale==index,"Verkaufsfenster offen")
	g.click_shop(ShopTrade.PLUS.get_center())
	var expected:=ShopTrade.stack_sale_total(g.item_sale_value(g.inventory[index]),3,2)
	var before:int=g.gold
	g.click_shop(ShopTrade.CONFIRM.get_center())
	check(g.gold-before==expected and count_named(g,"Heiltrank")==1,"2 verkauft, Erlös wie angezeigt (%d/%d)" % [g.gold-before,expected])
	# Alles verkaufen: Vorschau = Erlös.
	var preview:Array=g.sell_all_preview()
	before=g.gold
	g.sell_all_unequipped()
	check(g.gold-before==int(preview[1]),"Alles verkaufen: Gold wie angezeigt")
	g.free()
	if failures>0:
		print("SHOP_TRADE_FAILED ",failures)
		quit(1)
		return
	print("SHOP_TRADE_OK hover+enter buys, quantities for buy and sell, totals match")
	quit()
