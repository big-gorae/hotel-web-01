class_name HotelInventoryModel
extends RefCounted

signal items_changed
signal equipped_item_changed(item)
signal combination_succeeded(rule)
signal combination_failed(source_item, target_item)

var items: Array = []
var equipped_item = null
var item_catalog: Dictionary = {}
var combination_rules: Array = []


func add_item(item) -> void:
	if item == null:
		return

	items.append(item)
	items_changed.emit()


func register_item_definition(item) -> void:
	if item == null or item.id.is_empty():
		return

	item_catalog[item.id] = item


func add_item_by_id(item_id: String) -> void:
	var item = create_item(item_id)
	if item != null:
		add_item(item)


func create_item(item_id: String):
	var definition = item_catalog.get(item_id)
	if definition == null:
		push_warning("Unknown inventory item id: %s" % item_id)
		return null

	if definition.has_method("copy"):
		return definition.copy()

	return definition


func add_combination_rule(rule) -> void:
	if rule == null:
		return

	combination_rules.append(rule)


func get_items() -> Array:
	return items.duplicate()


func export_state() -> Dictionary:
	var item_ids := []
	for item in items:
		item_ids.append(String(item.id))

	return {
		"item_ids": item_ids,
		"equipped_item_id": String(equipped_item.id) if equipped_item != null else "",
	}


func import_state(state: Dictionary) -> void:
	items.clear()
	equipped_item = null

	for item_id in state.get("item_ids", []):
		var item = create_item(String(item_id))
		if item != null:
			items.append(item)

	var equipped_item_id := String(state.get("equipped_item_id", ""))
	if not equipped_item_id.is_empty():
		for item in items:
			if item.id == equipped_item_id:
				equipped_item = item
				break

	items_changed.emit()
	equipped_item_changed.emit(equipped_item)


func equip_item(item) -> bool:
	if item == null or not item.can_equip or not items.has(item):
		return false

	equipped_item = item
	equipped_item_changed.emit(equipped_item)
	return true


func clear_equipped_item() -> void:
	equipped_item = null
	equipped_item_changed.emit(equipped_item)


func combine_items(source_item, target_item) -> bool:
	if source_item == null or target_item == null or source_item == target_item:
		combination_failed.emit(source_item, target_item)
		return false

	if not items.has(source_item) or not items.has(target_item):
		combination_failed.emit(source_item, target_item)
		return false

	var rule = _find_combination_rule(source_item, target_item)
	if rule == null:
		combination_failed.emit(source_item, target_item)
		return false

	var should_clear_equipped := false
	for item in [source_item, target_item]:
		if rule.should_consume(item):
			should_clear_equipped = should_clear_equipped or equipped_item == item
			items.erase(item)

	for item_id in rule.result_item_ids:
		var result_item = create_item(item_id)
		if result_item != null:
			items.append(result_item)

	if should_clear_equipped:
		clear_equipped_item()

	items_changed.emit()
	combination_succeeded.emit(rule)
	return true


func _find_combination_rule(source_item, target_item):
	for rule in combination_rules:
		if rule.matches(source_item, target_item):
			return rule

	return null
