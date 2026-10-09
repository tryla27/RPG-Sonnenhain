extends RefCounted
## Zustandslose Weltgeometrie: Gebietsgrenzen, Wegabstände, Wegsteine und die
## Lage der Klassenboss-Arenen und -Häuser.
##
## main.gd stellt alle Konstanten und Methoden unter denselben Namen weiter
## bereit. Methoden, die Unterklassen überschreiben (z. B. region_at in Tests),
## werden in main.gd weiterhin über die eigene Methode aufgerufen.
## Siehe docs/architecture/main-modularization.md, Schritt 2.

const GameContent = preload("res://components/game_content.gd")
const WAYSTONES := [Vector2(825, 915), Vector2(3300, 1900), Vector2(3200, 6200), Vector2(6700, 1950), Vector2(6700, 6250), Vector2(9750, 3900), Vector2(1000, 6100), Vector2(13500, 950), Vector2(13500, 2850), Vector2(13500, 4750), Vector2(13500, 6650), Vector2(13500, 8550)]
const CLASS_BOSS_SITES := [Vector2(430,6500),Vector2(9700,6500),Vector2(14300,1200)] # Map 06 / 07 / 08
const CLASS_BOSS_ARENA_RADIUS := 410.0
const CLASS_BOSS_HOUSE_POS := [Vector2(430,5940),Vector2(9700,5940),Vector2(14300,640)]
const CLASS_BOSS_HOUSE_SIZE := Vector2(192,160)

static func region_at(p: Vector2) -> int:
	if p.x >= 11000: return clampi(int(p.y / 1920.0) + 8, 8, 12)
	if p.x < 1780:
		return 0 if p.y < 2600 else 6
	if p.x < 5000:
		return 1 if p.y < 4200 else 2
	if p.x < 8500:
		return 3 if p.y < 4200 else 4
	return 5 if p.y < 4200 else 7

static func region_rect(id: int) -> Rect2:
	if id >= 8: return Rect2(11000, (id - 8) * 1920, 5000, 1920)
	match id:
		0: return Rect2(0, 0, 1780, 2600)
		1: return Rect2(1780, 0, 3220, 4200)
		2: return Rect2(1780, 4200, 3220, 4300)
		3: return Rect2(5000, 0, 3500, 4200)
		4: return Rect2(5000, 4200, 3500, 4300)
		5: return Rect2(8500, 0, 2500, 4200)
		6: return Rect2(0, 2600, 1780, 5900)
		_: return Rect2(8500, 4200, 2500, 4300)

static func distance_to_trail(p: Vector2) -> float:
	var best := INF
	for trail in GameContent.TRAILS:
		for i in range(trail.size() - 1):
			var a: Vector2 = trail[i]
			var b: Vector2 = trail[i + 1]
			var segment := b - a
			var t := clampf((p - a).dot(segment) / segment.length_squared(), 0.0, 1.0)
			best = minf(best, p.distance_to(a + segment * t))
	return best

static func nearest_waystone(p: Vector2) -> Vector2:
	var best: Vector2 = WAYSTONES[0]
	var best_distance := INF
	for stone in WAYSTONES:
		var distance := p.distance_to(stone)
		if distance < best_distance:
			best_distance = distance
			best = stone
	return best

static func hash_cell(x: int, y: int) -> int:
	var n := x * 92821 + y * 68917 + x * y * 31
	return absi(n ^ (n >> 11)) % 997

static func class_boss_arena_index_at(p: Vector2, extra: float = 0.0) -> int:
	for i in CLASS_BOSS_SITES.size():
		if p.distance_to(CLASS_BOSS_SITES[i]) <= CLASS_BOSS_ARENA_RADIUS + extra: return i
	return -1

static func class_boss_house_rect(index: int) -> Rect2:
	var center: Vector2 = CLASS_BOSS_HOUSE_POS[clampi(index, 0, 2)]
	return Rect2(center - Vector2(CLASS_BOSS_HOUSE_SIZE.x * .5, CLASS_BOSS_HOUSE_SIZE.y), CLASS_BOSS_HOUSE_SIZE)

static func point_near_class_boss_house(p: Vector2, margin: float = 0.0) -> bool:
	for i in CLASS_BOSS_HOUSE_POS.size():
		if class_boss_house_rect(i).grow(margin).has_point(p): return true
	return false
