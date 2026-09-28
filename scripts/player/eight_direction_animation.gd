class_name EightDirectionAnimation
extends RefCounted

enum Direction8 {
	SOUTH,
	SOUTH_WEST,
	WEST,
	NORTH_WEST,
	NORTH,
	NORTH_EAST,
	EAST,
	SOUTH_EAST
}

static func direction_index(vector: Vector2) -> int:
	if vector.length_squared() < 0.0001:
		return Direction8.SOUTH
	var angle := wrapf(vector.angle(), -PI, PI)
	var octant := int(round((angle + PI * 0.5) / (PI / 4.0))) % 8
	if octant < 0:
		octant += 8
	return octant

static func direction_name(index: int) -> String:
	return ["south", "south_west", "west", "north_west", "north", "north_east", "east", "south_east"][clampi(index, 0, 7)]

static func animation_name(state: String, direction: Vector2) -> String:
	return "%s_%s" % [state, direction_name(direction_index(direction))]
