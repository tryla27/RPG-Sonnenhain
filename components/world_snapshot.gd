extends RefCounted
# Weltpaket des Servers (Gegner, Gegner-Geschosse, Beute) pro Spieler.
#
# Früher bekam jeder Spieler alle Gegner und Beutestücke der ganzen Welt in
# einem Paket. Bei vielen Spielern in verschiedenen Gebieten und liegender
# Beute wurde das Paket größer als der WebSocket-Puffer (64 KiB) und ging
# verloren: Gegner blieben stehen, Bosse erschienen nicht. Jetzt bekommt jeder
# nur, was in seiner Nähe ist, und die Puffer sind größer.

## Sichtweite für das Paket: deutlich mehr als Bildschirm und Minikarte (1500).
const INTEREST_RANGE:=2600.0
## Puffergröße für WebSocket-Pakete (Server ausgehend, Spiel eingehend).
const BUFFER_BYTES:=1<<20

## Nur Zeilen, deren "pos" ([x, y]) höchstens `range` von `center` entfernt ist.
static func near(rows:Array,center:Vector2,range:float=INTEREST_RANGE)->Array:
	var out:Array=[]
	var limit:=range*range
	for row in rows:
		if not row is Dictionary:continue
		var p:Variant=row.get("pos",[])
		if not p is Array or p.size()<2:continue
		if Vector2(float(p[0]),float(p[1])).distance_squared_to(center)<=limit:out.append(row)
	return out

static func for_peer(base:Dictionary,center:Vector2)->Dictionary:
	var snap:=base.duplicate(false)
	snap["enemies"]=near(base.get("enemies",[]),center)
	snap["shots"]=near(base.get("shots",[]),center)
	snap["drops"]=near(base.get("drops",[]),center)
	return snap

static func widen(peer:WebSocketMultiplayerPeer)->void:
	peer.inbound_buffer_size=BUFFER_BYTES
	peer.outbound_buffer_size=BUFFER_BYTES
