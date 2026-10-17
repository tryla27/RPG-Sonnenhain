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

## Ab so vielen Stufen Rückstand bringt das Öffnen eines Händlers sofort eine
## neue Lieferung zur aktuellen Stufe (statt bis zu 7 Minuten zu warten).
const LEVEL_GAP:=3
## Stufe der neuesten stufenabhängigen Angebote; -1, wenn keine (Kräuter,
## Tränke, Essen haben keine Stufe im eigentlichen Sinn).
static func newest_offer_level(offers:Array)->int:
	var newest:=-1
	for offer in offers.slice(maxi(0,offers.size()-BATCH_SIZE)):
		if offer is Dictionary and offer.has("level") and str(offer.get("icon","")) not in ["herb","potion","food"]:
			newest=maxi(newest,int(offer["level"]))
	return newest
## Braucht der Bestand eine frische Lieferung für diese Käuferstufe?
static func needs_fresh_batch(stock:Dictionary,level:int)->bool:
	if stock.is_empty():return true
	var newest:=-1
	for role in stock:
		if stock[role] is Array:newest=maxi(newest,newest_offer_level(stock[role]))
	return newest>=0 and newest<=level-LEVEL_GAP
