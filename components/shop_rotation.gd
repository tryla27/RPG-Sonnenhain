extends RefCounted
## Prepared ten-step stock cycle. A reset always advances, including after reload.
const THEMES=[
	{"suffix":"der Wiesen","element":"eis"},
	{"suffix":"des Nebels","element":"blitz"},
	{"suffix":"der Funken","element":"gift"},
	{"suffix":"der Gezeiten","element":"eis"},
	{"suffix":"des Morgenrots","element":"blitz"},
	{"suffix":"des Himmels","element":"gift"},
	{"suffix":"der Sternennacht","element":"eis"},
	{"suffix":"des Gewitters","element":"blitz"},
	{"suffix":"des Dornwalds","element":"gift"},
	{"suffix":"des Kristallmoors","element":"eis"}]
static func next_index(current:int)->int:return posmod(current+1,THEMES.size())
const BATCH_SIZE:=3
const STOCK_CAP:=30
static func append_offers(previous:Array,batch:Array)->Array:
	var combined:=previous.duplicate(true)
	for offer in batch.slice(0,BATCH_SIZE):combined.append(offer.duplicate(true))
	return combined.slice(maxi(0,combined.size()-STOCK_CAP))
static func restore(data:Dictionary)->int:
	if data.has("shop_rotation"):return clampi(int(data["shop_rotation"]),-1,THEMES.size()-1)
	var stock:Dictionary=data.get("shop_stock",{})
	var smith:Array=stock.get("smith",[]).duplicate()
	smith.reverse()
	for offer in smith:
		for i in THEMES.size():
			if str(offer.get("name","")).ends_with(THEMES[i]["suffix"]):return i
	return -1
