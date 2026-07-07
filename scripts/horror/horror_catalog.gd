class_name HotelHorrorCatalog
extends RefCounted

const HorrorEventDefinition := preload("res://scripts/horror/horror_event_definition.gd")


static func build_definitions() -> Array:
	return [
		_make_room_105_shadow_anomaly(),
		_make_room_107_phone_jumpscare(),
	]


static func _make_room_105_shadow_anomaly():
	var definition := HorrorEventDefinition.new()
	definition.id = "room_105_shadow_stain"
	definition.event_type = HorrorEventDefinition.TYPE_ANOMALY
	definition.room_id = "room_105"
	definition.scene_ids = ["room_105_door_window", "room_105_bathroom_entry"]
	definition.flag_id = "anomaly.room_105.shadow_stain.visible"
	definition.discovery_kind = "visual_anomaly"
	definition.spawn_chance = 0.18
	definition.view_seconds_to_discover = 1.25
	definition.fallback_title = "Shadow Stain"
	definition.fallback_description = "A damp shadow has appeared where the wall was clean before."
	definition.required_rule_id = "compare_corridor_room_numbers"
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


static func _make_room_107_phone_jumpscare():
	var definition := HorrorEventDefinition.new()
	definition.id = "room_107_phone_jumpscare"
	definition.event_type = HorrorEventDefinition.TYPE_JUMPSCARE
	definition.room_id = "room_107"
	definition.scene_ids = ["room_107_bed_nightstand", "room_107_bathroom_entry"]
	definition.flag_id = "jumpscare.room_107.phone_ring"
	definition.discovery_kind = "jumpscare"
	definition.spawn_chance = 0.0
	definition.jumpscare_duration = 1.4
	definition.jumpscare_outcome = HorrorEventDefinition.OUTCOME_CONTINUE
	definition.fallback_title = "Phone Ring"
	definition.fallback_description = "The phone rings once, impossibly close."
	return definition
