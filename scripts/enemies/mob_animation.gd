extends RefCounted

## Gemeinsame Animationslogik für alle Mobs.
## Richtungsreihenfolge entspricht dem Spieler: down, left, right, up.

static func direction_index(direction: Vector2) -> int:
	if absf(direction.x) > absf(direction.y):
		return 2 if direction.x > 0.0 else 1
	return 0 if direction.y > 0.0 else 3

static func frame_for(data: MobData, state: Dictionary) -> int:
	if float(state.get("attack_anim", 0.0)) > 0.0:
		return data.attack_frame
	if bool(state.get("walking", false)) and not data.walk_frames.is_empty():
		var fps := maxf(1.0, data.animation_fps)
		var frame_index := int(float(state.get("anim_time", 0.0)) * fps) % data.walk_frames.size()
		return int(data.walk_frames[frame_index])
	return data.idle_frame
