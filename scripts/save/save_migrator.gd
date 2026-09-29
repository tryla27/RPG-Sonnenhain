class_name SaveMigrator
extends RefCounted

const CURRENT_VERSION := 2

static func backup_path(path: String) -> String:
	if path.ends_with(".json"):
		return path.left(path.length() - 5) + "_pre_v28_backup.json"
	return path + "_pre_v28_backup"

static func backup_before_migration(path: String, data: Dictionary) -> void:
	if int(data.get("save_version", 0)) >= CURRENT_VERSION:
		return
	if not FileAccess.file_exists(path):
		return
	var source := FileAccess.open(path, FileAccess.READ)
	if source == null:
		return
	var raw := source.get_as_text()
	source.close()
	var backup := FileAccess.open(backup_path(path), FileAccess.WRITE)
	if backup == null:
		return
	backup.store_string(raw)
	backup.close()

static func migrate(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	var version := int(migrated.get("save_version", 0))
	if version < 1:
		_migrate_inventory_v1(migrated)
	if version < 2:
		if not migrated.has("equipped_ring2_uid"):
			migrated["equipped_ring2_uid"] = -1
		if not migrated.has("ufo_chest_opened"):
			migrated["ufo_chest_opened"] = false
	migrated["save_version"] = CURRENT_VERSION
	return migrated

static func _migrate_inventory_v1(data: Dictionary) -> void:
	var items: Variant = data.get("inventory", [])
	if not items is Array:
		return
	for raw_item in items:
		if not raw_item is Dictionary:
			continue
		if not raw_item.has("protected"):
			raw_item["protected"] = false
		if not raw_item.has("count"):
			raw_item["count"] = 1
		if not raw_item.has("stack_value"):
			raw_item["stack_value"] = int(raw_item.get("value", 0)) * maxi(1, int(raw_item.get("count", 1)))
