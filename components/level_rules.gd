extends RefCounted
## Gemeinsame Levelregel für Spieler: XP-Bedarf, Höchststufe und Klemmen.
## Bis zum Aufstieg auf Stufe 100 gilt die bisherige Kurve
## 120 + (L−1)·85 + (L−1)²·10; ab Stufe 100 kostet jeder Aufstieg das Vierfache
## des vorigen (100 → 101 = 417.960 XP). Höchststufe 118: Darüber wären XP-Werte
## in Spielständen (JSON, Zahlen bis 2^53) nicht mehr exakt speicherbar.
## Alle Stellen (Spiel, Server, Netzwerk, Testmodus, Konten) nutzen diese Regel.
## Essenz bleibt bei 40 Punkten (essence_system.gd), Talente bekommen nichts dazu.

const MAX_LEVEL:=118
## Größte exakt speicherbare Ganzzahl in JSON/Float (2^53 − 1).
const MAX_EXACT_XP:=9007199254740991
const FIRST_STEEP_LEVEL:=100
const FIRST_STEEP_XP:=417960

static func clamp_level(value:int)->int:
	return clampi(value,1,MAX_LEVEL)

## XP für den Aufstieg von `level` auf `level + 1`; 0 auf der Höchststufe.
static func xp_required(level:int)->int:
	var current:=clamp_level(level)
	if current>=MAX_LEVEL:return 0
	if current<FIRST_STEEP_LEVEL:
		return 120+(current-1)*85+(current-1)*(current-1)*10
	return FIRST_STEEP_XP*(1<<(2*(current-FIRST_STEEP_LEVEL)))

## Gültige XP innerhalb der Stufe: 0 … Bedarf − 1, auf der Höchststufe 0.
static func clamp_xp(level:int,xp:int)->int:
	var need:=xp_required(level)
	return 0 if need<=0 else clampi(xp,0,need-1)

## XP gutschreiben. Ergebnis: {"level", "xp", "gained"} (gewonnene Stufen).
static func add_xp(level:int,xp:int,amount:int)->Dictionary:
	var current:=clamp_level(level)
	var total:=maxi(0,xp)+maxi(0,amount)
	var gained:=0
	while current<MAX_LEVEL and total>=xp_required(current):
		total-=xp_required(current)
		current+=1;gained+=1
	if current>=MAX_LEVEL:total=0
	return {"level":current,"xp":total,"gained":gained}
