extends RefCounted
## Materialklang eines bereits beendeten Geschosses. Kollisionsregeln bleiben
## beim Spiel; diese Wiedergabe erzeugt keine zusätzlichen Hindernisse.
const MATERIAL_SOUNDS := {
	"holz": "treffer_holz",
	"stein": "treffer_stein",
	"metall": "treffer_metall",
}

static func play(g, pos: Vector2, kind: int, dir: Vector2 = Vector2.ZERO) -> void:
	if g.dedicated_server_mode or pos.distance_to(g.player_pos) >= 850: return
	g.play_sound("arrow_break" if kind == 3 else "magic_break")
	# Das Geschoss stoppt vor dem Körper; das Material liegt etwas weiter vorn.
	for reach in [6.0, 12.0, 20.0]:
		var material: String = g.projectile_material(pos + dir.normalized() * reach)
		if material == "": continue
		if MATERIAL_SOUNDS.has(material): g.play_world_sound(MATERIAL_SOUNDS[material], pos)
		return
