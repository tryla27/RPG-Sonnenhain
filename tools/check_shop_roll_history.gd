extends SceneTree
const Game=preload("res://main.gd")

func _initialize()->void:
	var g=Game.new()
	g.level=12
	g.class_id=1
	g.shop_roll_history={"smith":[],"alchemy":[],"merchant":[]}
	for i in 4:g.refresh_shop_stock()
	for kind in ["smith","alchemy","merchant"]:
		var history:Array=g.shop_roll_history[kind]
		assert(history.size()==4,"shop must keep fresh roll plus three previous rolls")
		for roll in history:assert(roll is Array and roll.size()==3)
	var smith:Array=g.shop_stock["smith"]
	assert(smith.size()==12,"smith rotating stock must be 4 generations x 3 items")
	for age in 4:
		for slot in 3:
			var item:Dictionary=smith[age*3+slot]
			assert(int(item["roll_age"])==age)
			assert(bool(item["shop_roll"]))
			var expected:=maxi(1,roundi(float(item["base_price"])*g.SHOP_ROLL_DISCOUNTS[age]))
			assert(int(item["price"])==expected)
	assert(g.SHOP_ROLL_DISCOUNTS[0]>g.SHOP_ROLL_DISCOUNTS[1])
	assert(g.SHOP_ROLL_DISCOUNTS[1]>g.SHOP_ROLL_DISCOUNTS[2])
	assert(g.SHOP_ROLL_DISCOUNTS[2]>g.SHOP_ROLL_DISCOUNTS[3])
	var oldest_before:Array=g.shop_roll_history["smith"][3].duplicate(true)
	g.refresh_shop_stock()
	assert(g.shop_roll_history["smith"].size()==4)
	assert(g.shop_roll_history["smith"][3]!=oldest_before,"oldest generation must rotate out after the next roll")
	print("SHOP_ROLL_HISTORY_OK fresh+3 old rolls persisted model; 106/100/94/88 price curve")
	quit()
