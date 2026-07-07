class_name HotelRuleBookCatalog
extends RefCounted

const RuleDefinition := preload("res://scripts/rules/rule_definition.gd")


static func build_definitions() -> Array:
	return [
		_make_rule("keep_phone_reachable", 1, ["front_desk"], [], [], []),
		_make_rule("check_room_log", 2, ["keys", "rooms"], [], [], ["room_105_key"]),
		_make_rule("keep_washer_closed_after_11", 3, ["laundry"], [], [], []),
		_make_rule("knock_before_vacant_open_room", 4, ["rooms", "doors"], [], [], []),
		_make_rule("compare_corridor_room_numbers", 5, ["corridor", "anomaly"], [], ["room_105_shadow_stain"], []),
		_make_rule("write_guest_name_before_lookup", 6, ["front_desk", "guest"], [], [], []),
		_make_rule("obey_unknown_written_rule", 7, ["anomaly", "rule_book"], [], ["room_107_phone_jumpscare"], []),
	]


static func _make_rule(rule_id: String, order: int, tags: Array[String], task_ids: Array[String], horror_event_ids: Array[String], item_ids: Array[String]):
	var rule := RuleDefinition.new()
	rule.id = rule_id
	rule.order = order
	rule.text_key = "ui.rule_book.rule.%d" % order
	rule.fallback_text = ""
	rule.tags = tags.duplicate()
	rule.related_task_ids = task_ids.duplicate()
	rule.related_horror_event_ids = horror_event_ids.duplicate()
	rule.related_item_ids = item_ids.duplicate()
	return rule
