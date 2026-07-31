class_name HotelHorrorEventDefinition
extends RefCounted

const TYPE_ANOMALY := "anomaly"
const TYPE_JUMPSCARE := "jumpscare"
const OUTCOME_CONTINUE := "continue"
const OUTCOME_GAME_OVER := "game_over"

var id := ""
var event_type := TYPE_ANOMALY
var room_id := ""
var scene_ids: Array[String] = []
var flag_id := ""
var discovery_kind := ""
var reveal_hotspots: Array[Dictionary] = []
var view_seconds_to_discover := 1.0
var random_weight := 1.0
var spawn_chance := 0.0
var enabled := true
var jumpscare_duration := 1.2
var jumpscare_outcome := OUTCOME_CONTINUE
var presentation_scene_path := ""
var jumpscare_image_path := ""
var jumpscare_source_rect := Rect2(0.0, 0.0, 1.0, 1.0)
var jumpscare_audio_path := ""
var jumpscare_audio_profile := "shared_shock_v1"
var jumpscare_fit_mode := "cover"
var jumpscare_hold_seconds := 0.3
var jumpscare_lunge_seconds := 0.13
var jumpscare_initial_zoom := 1.08
var jumpscare_lunge_zoom := 2.05
var jumpscare_focus_point := Vector2(0.5, 0.5)
var jumpscare_initial_shake := 9.0
var jumpscare_lunge_shake := 14.0
var jumpscare_audio_volume_db := -7.0
var title_key := ""
var description_key := ""
var fallback_title := ""
var fallback_description := ""
var required_item_id := ""
var required_rule_id := ""
var required_task_id := ""
var blocked_text_key := ""
var fallback_blocked_text := ""


func applies_to_scene(scene_id: String) -> bool:
	return scene_ids.has(scene_id)


func copy():
	var definition = get_script().new()
	definition.id = id
	definition.event_type = event_type
	definition.room_id = room_id
	definition.scene_ids = scene_ids.duplicate()
	definition.flag_id = flag_id
	definition.discovery_kind = discovery_kind
	definition.reveal_hotspots = reveal_hotspots.duplicate(true)
	definition.view_seconds_to_discover = view_seconds_to_discover
	definition.random_weight = random_weight
	definition.spawn_chance = spawn_chance
	definition.enabled = enabled
	definition.jumpscare_duration = jumpscare_duration
	definition.jumpscare_outcome = jumpscare_outcome
	definition.presentation_scene_path = presentation_scene_path
	definition.jumpscare_image_path = jumpscare_image_path
	definition.jumpscare_source_rect = jumpscare_source_rect
	definition.jumpscare_audio_path = jumpscare_audio_path
	definition.jumpscare_audio_profile = jumpscare_audio_profile
	definition.jumpscare_fit_mode = jumpscare_fit_mode
	definition.jumpscare_hold_seconds = jumpscare_hold_seconds
	definition.jumpscare_lunge_seconds = jumpscare_lunge_seconds
	definition.jumpscare_initial_zoom = jumpscare_initial_zoom
	definition.jumpscare_lunge_zoom = jumpscare_lunge_zoom
	definition.jumpscare_focus_point = jumpscare_focus_point
	definition.jumpscare_initial_shake = jumpscare_initial_shake
	definition.jumpscare_lunge_shake = jumpscare_lunge_shake
	definition.jumpscare_audio_volume_db = jumpscare_audio_volume_db
	definition.title_key = title_key
	definition.description_key = description_key
	definition.fallback_title = fallback_title
	definition.fallback_description = fallback_description
	definition.required_item_id = required_item_id
	definition.required_rule_id = required_rule_id
	definition.required_task_id = required_task_id
	definition.blocked_text_key = blocked_text_key
	definition.fallback_blocked_text = fallback_blocked_text
	return definition
