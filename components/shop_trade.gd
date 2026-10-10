extends RefCounted
# Handel im Shop (Wunsch 10.10.2026):
# - Maus auf ein Angebot + Enter kauft sofort 1 Stück.
# - Kaufen und Verkaufen mit Mengenauswahl (−, +, MAX) im Bestätigungsfenster.
# - Vor jedem Verkauf steht der Gesamtwert, auch bei „Alles verkaufen“.
#
# Hier liegen Mengenregeln, Wertberechnung und das Zeichnen/Klicken der
# Mengenzeile. Kaufen/Verkaufen selbst bleibt in main.gd (buy_item, sell_item).

const OFFER_RECTS:=[Rect2(168,210,245,125),Rect2(426,210,245,125),Rect2(684,210,245,125)]
const MINUS:=Rect2(413,342,40,30)
const PLUS:=Rect2(511,342,40,30)
const MAX_BUTTON:=Rect2(561,342,72,30)
const CONFIRM:=Rect2(352,391,204,45)
const CANCEL:=Rect2(578,391,204,45)
const DIALOG:=Rect2(315,210,522,247)
const MAX_BUY:=99

## Angebot unter der Maus (0–2) oder -1.
static func offer_at(mouse:Vector2,count:int)->int:
	for i in mini(count,OFFER_RECTS.size()):
		if OFFER_RECTS[i].has_point(mouse):return i
	return -1

## Höchstens so viele, wie das Gold reicht (und MAX_BUY).
static func max_buy(price:int,gold:int)->int:
	if price<=0:return MAX_BUY
	return clampi(int(gold/price),0,MAX_BUY)

static func clamp_quantity(quantity:int,maximum:int)->int:
	return clampi(quantity,1,maxi(1,maximum))

## Erlös, wenn `amount` Stück eines Stapels einzeln verkauft werden. Gleiche
## Rechnung wie sell_item: jedes Stück bringt Restwert / Reststück (gerundet).
static func stack_sale_total(stack_value:int,count:int,amount:int)->int:
	var total:=0
	var value:=stack_value
	var left:=maxi(1,count)
	for i in clampi(amount,0,left):
		var gain:=int(round(float(value)/maxi(1,left)))
		total+=gain
		value=maxi(0,value-gain)
		left-=1
	return total

## Mengenzeile im Fenster: − Zahl + MAX, darunter der Gesamtbetrag.
static func draw_quantity(g,quantity:int,maximum:int,total_label:String)->void:
	g.text_at(Vector2(345,364),"MENGE",14,Color("e9cc90"))
	g.ui_button(MINUS,"−",quantity>1)
	g.text_at(Vector2(453,364),str(quantity),18,Color("fff1cf"),HORIZONTAL_ALIGNMENT_CENTER,58)
	g.ui_button(PLUS,"+",quantity<maximum)
	g.ui_button(MAX_BUTTON,"MAX",quantity<maximum)
	g.text_at(Vector2(645,364),total_label,15,Color("f6dca1"),HORIZONTAL_ALIGNMENT_LEFT,180)

## Neue Menge nach einem Klick auf −, + oder MAX; -1 wenn kein Mengenknopf.
static func click_quantity(mouse:Vector2,quantity:int,maximum:int)->int:
	if MINUS.has_point(mouse):return clamp_quantity(quantity-1,maximum)
	if PLUS.has_point(mouse):return clamp_quantity(quantity+1,maximum)
	if MAX_BUTTON.has_point(mouse):return clamp_quantity(maximum,maximum)
	return -1
