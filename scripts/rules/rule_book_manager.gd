class_name HotelRuleBookManager
extends RefCounted

const RuleBookCatalog := preload("res://scripts/rules/rule_book_catalog.gd")

var definitions_by_id: Dictionary = {}
var read_rule_ids: Array[String] = []
var current_day := 1


func setup_default_catalog() -> void:
	definitions_by_id.clear()
	for definition in RuleBookCatalog.build_definitions():
		register_definition(definition)


func register_definition(definition) -> void:
	if definition == null or definition.id.is_empty():
		return

	definitions_by_id[definition.id] = definition.copy()


func get_visible_rules() -> Array:
	var rules := []
	for definition in definitions_by_id.values():
		if definition.unlock_day <= current_day:
			rules.append(definition)
	rules.sort_custom(func(a, b): return a.order < b.order)
	return rules


func get_rules_for_day(day: int) -> Array:
	var safe_day := clampi(day, 1, current_day)
	var rules := []
	for definition in definitions_by_id.values():
		if definition.unlock_day == safe_day:
			rules.append(definition)
	rules.sort_custom(func(a, b): return a.order < b.order)
	return rules


func get_latest_page_day() -> int:
	return current_day


func set_current_day(day: int) -> void:
	current_day = maxi(day, 1)


func mark_rule_read(rule_id: String) -> void:
	if definitions_by_id.has(rule_id) and not read_rule_ids.has(rule_id):
		read_rule_ids.append(rule_id)


func mark_all_visible_read() -> void:
	for definition in get_visible_rules():
		mark_rule_read(definition.id)


func mark_day_read(day: int) -> void:
	for definition in get_rules_for_day(day):
		mark_rule_read(definition.id)


func has_read_rule(rule_id: String) -> bool:
	return read_rule_ids.has(rule_id)


func export_state() -> Dictionary:
	return {
		"read_rule_ids": read_rule_ids.duplicate(),
		"current_day": current_day,
	}


func import_state(state: Dictionary) -> void:
	current_day = maxi(int(state.get("current_day", current_day)), 1)
	read_rule_ids.clear()
	for rule_id in state.get("read_rule_ids", []):
		var safe_id := String(rule_id)
		if definitions_by_id.has(safe_id) and not read_rule_ids.has(safe_id):
			read_rule_ids.append(safe_id)
