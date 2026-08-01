class_name HotelRuleBookCatalog
extends RefCounted

const RuleDefinition := preload("res://scripts/rules/rule_definition.gd")


static func build_definitions() -> Array:
	return [
		_make_rule("make_vacant_beds", 1, 1, ["rooms", "housekeeping"]),
		_make_rule("bin_room_trash", 2, 1, ["rooms", "housekeeping"]),
		_make_rule("launder_bedding_every_other_day", 3, 1, ["laundry", "housekeeping"]),
		_make_rule("remove_black_mold", 4, 2, ["room_105", "mold", "anomaly"]),
		_make_rule("ignore_room_108_light_repair", 5, 3, ["room_108", "phone", "anomaly"]),
		_make_rule("do_not_look_into_room_109", 6, 3, ["room_109", "door", "anomaly"]),
		_make_rule("answer_before_thirteenth_ring", 7, 4, ["front_desk", "phone", "anomaly"]),
		_make_rule("stop_red_washer", 8, 5, ["laundry", "anomaly"]),
		_make_rule("wait_for_washer_music", 9, 5, ["laundry", "anomaly"]),
		_make_rule("stay_during_washer_music", 10, 5, ["laundry", "anomaly"]),
		_make_rule("ignore_false_mother", 11, 6, ["room_106", "child", "anomaly"]),
		_make_rule("sing_until_child_stops", 12, 6, ["room_106", "child", "anomaly"]),
		_make_rule("hold_child_with_love", 13, 6, ["room_106", "child", "anomaly"]),
		_make_rule("leave_room_109_open", 14, 7, ["room_109", "anomaly"]),
		_make_rule("let_room_109_guest_pass", 15, 7, ["room_109", "anomaly"]),
		_make_rule("do_not_turn_until_silence", 16, 7, ["room_109", "anomaly"]),
		_make_rule("give_doll_to_cute_girl", 17, 3, ["room_107", "girl", "doll", "anomaly"]),
		_make_rule("ring_bell_and_run_from_follower", 18, 3, ["front_desk", "bell", "shadow", "anomaly"]),
	]


static func _make_rule(rule_id: String, order: int, unlock_day: int, tags: Array[String]):
	var rule := RuleDefinition.new()
	rule.id = rule_id
	rule.order = order
	rule.unlock_day = unlock_day
	rule.text_key = "ui.rule_book.rule.%d" % order
	rule.fallback_text = ""
	rule.tags = tags.duplicate()
	return rule
