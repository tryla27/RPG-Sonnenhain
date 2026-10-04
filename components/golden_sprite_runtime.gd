extends RefCounted
## Shared loader/drawer for authored 8-direction sprite strips.
## Strip layout is fixed to S, SW, W, NW, N, NE, E, SE.
static var _cache: Dictionary = {}

static func texture(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path]
	if not ResourceLoader.exists(path):
		_cache[path] = null
		return null
	var value := load(path) as Texture2D
	_cache[path] = value
	return value

static func draw_direction_strip(c: CanvasItem, path: String, foot: Vector2, direction: int, frame_size: Vector2, anchor_y: float, scale_factor: float=1.0, modulate: Color=Color.WHITE) -> bool:
	var tex := texture(path)
	if tex == null:
		return false
	var dir := posmod(direction, 8)
	var src := Rect2(Vector2(float(dir) * frame_size.x, 0.0), frame_size)
	var size := frame_size * scale_factor
	var top_left := foot - Vector2(frame_size.x * 0.5, anchor_y) * scale_factor
	c.draw_texture_rect_region(tex, Rect2(top_left, size), src, modulate)
	return true

static func draw_animation_strip(c: CanvasItem, path: String, foot: Vector2, frame: int, frame_count: int, destination_size: Vector2, anchor_y: float, scale_factor: float=1.0, modulate: Color=Color.WHITE) -> bool:
	var tex := texture(path)
	if tex == null or frame_count <= 0:
		return false
	var frame_width := tex.get_width() / float(frame_count)
	var src := Rect2(Vector2(frame_width * clampi(frame, 0, frame_count - 1), 0.0), Vector2(frame_width, tex.get_height()))
	var size := destination_size * scale_factor
	var top_left := foot - Vector2(destination_size.x * 0.5, anchor_y) * scale_factor
	c.draw_texture_rect_region(tex, Rect2(top_left, size), src, modulate)
	return true
