class_name HotelHorrorCatalog
extends RefCounted

const HorrorEventDefinition := preload("res://scripts/horror/horror_event_definition.gd")
const ContentCatalog := preload("res://scripts/horror/anomaly_content_catalog.gd")
const CollectionContent := preload("res://scripts/horror/anomaly_collection_content.gd")
const AnomalyRegistry := preload("res://scripts/horror/anomaly_registry.gd")
const IMAGE_JUMPSCARE_SCENE := "res://scenes/horror/image_jumpscare_presentation.tscn"
const PIG_MASK_REFERENCE := "res://resource/images/references/entities/room_105_closet_pig_mask_man/reference_pig_mask_01.png"
const FAKE_MOTHER_REFERENCE := "res://resource/images/references/entities/room_106_fake_mother/reference_face_01.png"
const HANGING_GIRL_REFERENCE := "res://resource/images/anomalies/room_107_hanging_girl/room_107_bed_nightstand/visible.png"

const JUMPSCARE_IMAGE_BY_EVENT := {
	"room_105_closet_pig_man": PIG_MASK_REFERENCE,
	"room_106_abandoned_child": FAKE_MOTHER_REFERENCE,
	"room_107_hanging_girl": HANGING_GIRL_REFERENCE,
}
const JUMPSCARE_FOCUS_BY_EVENT := {
	"room_105_closet_pig_man": Vector2(0.5, 0.3),
	"room_106_abandoned_child": Vector2(0.5, 0.44),
	"room_107_hanging_girl": Vector2(0.5, 0.36),
}
const JUMPSCARE_FIT_BY_EVENT := {
	"room_105_closet_pig_man": "cover",
	"room_106_abandoned_child": "contain",
	"room_107_hanging_girl": "contain",
}
const JUMPSCARE_INITIAL_ZOOM_BY_EVENT := {
	"room_105_closet_pig_man": 1.02,
	"room_106_abandoned_child": 1.02,
	"room_107_hanging_girl": 1.02,
}
const JUMPSCARE_SOURCE_RECT_BY_EVENT := {
	# Tight upper-body crop: the approved Hanging Girl herself lunges forward
	# instead of presenting the entire Room 107 photograph as the subject.
	"room_107_hanging_girl": Rect2(0.587, 0.120, 0.242, 0.516),
}
const JUMPSCARE_TUNING_BY_EVENT := {
	"room_105_closet_pig_man": {
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
	var definitions := []
	var content_definitions := ContentCatalog.build_definitions()
	for event_id in AnomalyRegistry.all_event_ids():
		var metadata := AnomalyRegistry.get_definition(event_id)
		var presentation: Dictionary = metadata.get("presentation", {})
		if String(metadata.get("kind", "")) == AnomalyRegistry.KIND_PHENOMENON:
			definitions.append(_make_collection_event(
				content_definitions.get(event_id, {}),
				metadata,
			))
		else:
			definitions.append(_make_game_over_event(
				event_id,
				String(presentation.get("room_id", "hotel")),
				_string_array(presentation.get("game_over_scene_ids", [])),
				event_id.replace("_", " ").capitalize(),
				"This presence was left unattended for too long.",
			))
	for definition in definitions:
		CollectionContent.apply_to_definition(definition)
	return definitions


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


static func _make_collection_event(content_definition: Dictionary, metadata: Dictionary):
	var definition := HorrorEventDefinition.new()
	definition.id = String(content_definition.get("id", ""))
	definition.event_type = HorrorEventDefinition.TYPE_ANOMALY
	var presentation: Dictionary = metadata.get("presentation", {})
	definition.room_id = String(presentation.get("room_id", "hotel"))
	definition.scene_ids = AnomalyRegistry.materialization_scene_ids(
		definition.id,
		AnomalyRegistry.get_default_scene_id(definition.id),
	)
	definition.discovery_kind = "visual_anomaly"
	definition.enabled = false
	definition.spawn_chance = 0.0
	definition.fallback_title = definition.id.replace("_", " ").capitalize()
	definition.fallback_description = "A confirmed hotel anomaly."
	return definition


static func _string_array(raw_values) -> Array[String]:
	var values: Array[String] = []
	for raw_value in raw_values:
		values.append(String(raw_value))
	return values
