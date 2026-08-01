class_name HotelHorrorCatalog
extends RefCounted

const HorrorEventDefinition := preload("res://scripts/horror/horror_event_definition.gd")
const ContentCatalog := preload("res://scripts/horror/anomaly_content_catalog.gd")
const CollectionContent := preload("res://scripts/horror/anomaly_collection_content.gd")
const IMAGE_JUMPSCARE_SCENE := "res://scenes/horror/image_jumpscare_presentation.tscn"
const PIG_MASK_REFERENCE := "res://resource/images/references/entities/room_105_closet_pig_mask_man/reference_pig_mask_01.png"
const FAKE_MOTHER_REFERENCE := "res://resource/images/references/entities/room_106_fake_mother/reference_face_01.png"
const HANGING_GIRL_REFERENCE := "res://resource/images/anomalies/room_107_hanging_girl/room_107_bed_nightstand/visible.png"

const JUMPSCARE_IMAGE_BY_EVENT := {
	"room_105_closet_woman": PIG_MASK_REFERENCE,
	"room_106_abandoned_child": FAKE_MOTHER_REFERENCE,
	"room_107_hanging_girl": HANGING_GIRL_REFERENCE,
}
const JUMPSCARE_FOCUS_BY_EVENT := {
	"room_105_closet_woman": Vector2(0.5, 0.3),
	"room_106_abandoned_child": Vector2(0.5, 0.44),
	"room_107_hanging_girl": Vector2(0.5, 0.36),
}
const JUMPSCARE_FIT_BY_EVENT := {
	"room_105_closet_woman": "cover",
	"room_106_abandoned_child": "contain",
	"room_107_hanging_girl": "contain",
}
const JUMPSCARE_INITIAL_ZOOM_BY_EVENT := {
	"room_105_closet_woman": 1.02,
	"room_106_abandoned_child": 1.02,
	"room_107_hanging_girl": 1.02,
}
const JUMPSCARE_SOURCE_RECT_BY_EVENT := {
	# Tight upper-body crop: the approved Hanging Girl herself lunges forward
	# instead of presenting the entire Room 107 photograph as the subject.
	"room_107_hanging_girl": Rect2(0.587, 0.120, 0.242, 0.516),
}
const JUMPSCARE_TUNING_BY_EVENT := {
	"room_105_closet_woman": {
		"hold_seconds": 0.15,
		"lunge_seconds": 0.13,
		"lunge_zoom": 2.05,
		"duration": 1.4,
		"initial_shake": 2.0,
		"lunge_shake": 2.0,
		"audio_volume_db": -10.0,
	},
	"room_106_abandoned_child": {
		"hold_seconds": 0.25,
		"lunge_seconds": 0.15,
		"lunge_zoom": 2.0,
		"duration": 1.4,
		"initial_shake": 2.0,
		"lunge_shake": 10.0,
		"audio_volume_db": -5.0,
	},
	"room_107_hanging_girl": {
		"hold_seconds": 0.10,
		"lunge_seconds": 0.12,
		"lunge_zoom": 7.0,
		"duration": 1.35,
		"initial_shake": 2.0,
		"lunge_shake": 12.0,
		"audio_volume_db": -6.0,
	},
}


static func build_definitions() -> Array:
	var definitions := [
		_make_room_105_shadow_anomaly(),
		_make_game_over_event("room_105_closet_woman", "room_105", ["room_105_door_window", "room_105_bathroom_entry"], "Moldy Pig-Mask Man", "A man in a pale pig mask watches through the nearly closed wardrobe."),
		_make_game_over_event("room_106_abandoned_child", "room_106", ["room_106_bathroom"], "Abandoned Child", "The crying stops directly behind you."),
		_make_game_over_event("room_108_light_repair_call", "room_108", ["front_desk", "room_108_bed_window"], "Thirteenth Ring", "Room 108 calls once more. This time the voice is beside you."),
		_make_game_over_event("room_109_open_door", "room_109", ["corridor"], "Room 109", "Something inside notices you looking."),
		_make_game_over_event("laundry_red_washer", "laundry_room", ["laundry_room"], "Red Laundry", "The wet bundle moves as you look inside."),
		_make_game_over_event("vacant_room_blanket_child", "hotel", ["room_105_door_window", "room_106_bed_bathroom_entry", "room_107_bed_nightstand", "room_108_bed_window"], "Child Under the Blanket", "A voice whispers that it found you."),
		_make_collection_event({"id": "room_109_day7_passage", "scene_id": "corridor"}),
	]
	for content_id in ContentCatalog.debug_event_ids():
		if content_id == "room_109_open_door":
			continue
		var content_definition: Dictionary = ContentCatalog.build_definitions().get(content_id, {})
		if String(content_definition.get("type", "")) == ContentCatalog.TYPE_ENTITY:
			definitions.append(_make_game_over_event(
				content_id,
				_room_id_from_scene(String(content_definition.get("scene_id", ""))),
				_scene_ids(String(content_definition.get("scene_id", ""))),
				content_id.replace("_", " ").capitalize(),
				"This presence was left unattended for too long."
			))
		else:
			definitions.append(_make_collection_event(content_definition))
	definitions.append(_make_game_over_event("hell_mirror", "hotel", _scene_ids(""), "Mirror of Hell", "The screaming inside the mirror reaches the other side."))
	for definition in definitions:
		CollectionContent.apply_to_definition(definition)
	return definitions


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
	definition.jumpscare_hold_seconds = 0.3
	definition.jumpscare_lunge_seconds = 0.13
	definition.jumpscare_initial_zoom = 1.08
	definition.jumpscare_lunge_zoom = 2.05
	if JUMPSCARE_IMAGE_BY_EVENT.has(event_id):
		definition.presentation_scene_path = IMAGE_JUMPSCARE_SCENE
		definition.jumpscare_image_path = String(JUMPSCARE_IMAGE_BY_EVENT[event_id])
		definition.jumpscare_focus_point = JUMPSCARE_FOCUS_BY_EVENT.get(event_id, Vector2(0.5, 0.5))
		definition.jumpscare_fit_mode = String(JUMPSCARE_FIT_BY_EVENT.get(event_id, "cover"))
		definition.jumpscare_initial_zoom = float(JUMPSCARE_INITIAL_ZOOM_BY_EVENT.get(event_id, 1.08))
		definition.jumpscare_source_rect = JUMPSCARE_SOURCE_RECT_BY_EVENT.get(
			event_id,
			Rect2(0.0, 0.0, 1.0, 1.0),
		)
		var tuning: Dictionary = JUMPSCARE_TUNING_BY_EVENT.get(event_id, {})
		definition.jumpscare_hold_seconds = float(tuning.get("hold_seconds", definition.jumpscare_hold_seconds))
		definition.jumpscare_lunge_seconds = float(tuning.get("lunge_seconds", definition.jumpscare_lunge_seconds))
		definition.jumpscare_lunge_zoom = float(tuning.get("lunge_zoom", definition.jumpscare_lunge_zoom))
		definition.jumpscare_duration = float(tuning.get("duration", definition.jumpscare_duration))
		definition.jumpscare_initial_shake = float(tuning.get("initial_shake", definition.jumpscare_initial_shake))
		definition.jumpscare_lunge_shake = float(tuning.get("lunge_shake", definition.jumpscare_lunge_shake))
		definition.jumpscare_audio_volume_db = float(tuning.get("audio_volume_db", definition.jumpscare_audio_volume_db))
	definition.title_key = "horror_event.%s.title" % event_id
	definition.description_key = "horror_event.%s.description" % event_id
	definition.fallback_title = fallback_title
	definition.fallback_description = fallback_description
	return definition


static func _make_collection_event(content_definition: Dictionary):
	var definition := HorrorEventDefinition.new()
	definition.id = String(content_definition.get("id", ""))
	definition.event_type = HorrorEventDefinition.TYPE_ANOMALY
	definition.room_id = _room_id_from_scene(String(content_definition.get("scene_id", "")))
	definition.scene_ids = _scene_ids(String(content_definition.get("scene_id", "")))
	definition.discovery_kind = "visual_anomaly"
	definition.enabled = false
	definition.spawn_chance = 0.0
	definition.fallback_title = definition.id.replace("_", " ").capitalize()
	definition.fallback_description = "A confirmed hotel anomaly."
	return definition


static func _room_id_from_scene(scene_id: String) -> String:
	if scene_id.begins_with("room_"):
		return scene_id.get_slice("_", 0) + "_" + scene_id.get_slice("_", 1)
	if scene_id == "laundry_room":
		return "laundry_room"
	if scene_id == "front_desk":
		return "front_desk"
	if scene_id == "corridor":
		return "corridor"
	if scene_id == "exterior_stairs":
		return "exterior_stairs"
	return "hotel"


static func _scene_ids(scene_id: String) -> Array[String]:
	var scene_ids: Array[String] = []
	if not scene_id.is_empty():
		scene_ids.append(scene_id)
	return scene_ids
