class_name HotelHorrorCatalog
extends RefCounted

const HorrorEventDefinition := preload("res://scripts/horror/horror_event_definition.gd")


static func build_definitions() -> Array:
	return [
		_make_room_105_shadow_anomaly(),
		_make_game_over_event("room_105_closet_woman", "room_105", ["room_105_door_window", "room_105_bathroom_entry"], "Closet Woman", "The closet opens and the woman steps out."),
		_make_game_over_event("room_106_abandoned_child", "room_106", ["room_106_bathroom"], "Abandoned Child", "The crying stops directly behind you."),
		_make_game_over_event("room_108_light_repair_call", "room_108", ["front_desk", "room_108_bed_window"], "Thirteenth Ring", "Room 108 calls once more. This time the voice is beside you."),
		_make_game_over_event("room_109_open_door", "room_109", ["corridor"], "Room 109", "Something inside notices you looking."),
		_make_game_over_event("laundry_red_washer", "laundry_room", ["laundry_room"], "Red Laundry", "The wet bundle moves as you look inside."),
	]


static func _make_room_105_shadow_anomaly():
	var definition := HorrorEventDefinition.new()
	definition.id = "room_105_shadow_stain"
	definition.event_type = HorrorEventDefinition.TYPE_ANOMALY
	definition.room_id = "room_105"
	definition.scene_ids = ["room_105_door_window", "room_105_bathroom_entry"]
	definition.flag_id = "anomaly.room_105.shadow_stain.visible"
	definition.discovery_kind = "visual_anomaly"
	# Kept in the catalog for collection/save compatibility, but runtime mold is
	# now owned by MoldGrowthSystem so the legacy random stain must not spawn.
	definition.enabled = false
	definition.spawn_chance = 0.0
	definition.view_seconds_to_discover = 1.25
	definition.fallback_title = "Shadow Stain"
	definition.fallback_description = "A damp shadow has appeared where the wall was clean before."
	definition.required_rule_id = "remove_black_mold"
	definition.blocked_text_key = "horror_event.room_105_shadow_stain.blocked"
	definition.fallback_blocked_text = "The stain does not react. Check the Rule Book before deciding what this is."
	definition.reveal_hotspots = [
		{
			"id": "anomaly_room_105_shadow_stain",
			"label": "Stain",
			"rect": Rect2(0.655, 0.255, 0.120, 0.180),
			"text": "The stain is too dark for water damage. It looks recent.",
			"action": "resolve_horror_event:room_105_shadow_stain",
		},
	]
	return definition


static func _make_game_over_event(event_id: String, room_id: String, scene_ids: Array[String], fallback_title: String, fallback_description: String):
	var definition := HorrorEventDefinition.new()
	definition.id = event_id
	definition.event_type = HorrorEventDefinition.TYPE_JUMPSCARE
	definition.room_id = room_id
	definition.scene_ids = scene_ids.duplicate()
	definition.flag_id = "jumpscare.%s" % event_id
	definition.discovery_kind = "jumpscare"
	definition.spawn_chance = 0.0
	definition.jumpscare_duration = 1.5
	definition.jumpscare_outcome = HorrorEventDefinition.OUTCOME_GAME_OVER
	definition.presentation_scene_path = "res://scenes/horror/default_jumpscare_presentation.tscn"
	if event_id == "room_105_closet_woman":
		definition.presentation_scene_path = "res://scenes/horror/closet_woman_presentation.tscn"
	definition.title_key = "horror_event.%s.title" % event_id
	definition.description_key = "horror_event.%s.description" % event_id
	definition.fallback_title = fallback_title
	definition.fallback_description = fallback_description
	return definition
