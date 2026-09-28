class_name ItemProtection
extends RefCounted

static func is_protected(item: Dictionary) -> bool:
	return bool(item.get("protected", false))

static func toggle(item: Dictionary) -> bool:
	var next_state := not is_protected(item)
	item["protected"] = next_state
	return next_state
