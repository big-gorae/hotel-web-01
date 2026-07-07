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
	definition.fallback_title = fallback_title
	definition.fallback_description = fallback_description
	definition.required_item_id = required_item_id
	definition.required_rule_id = required_rule_id
	definition.required_task_id = required_task_id
	definition.blocked_text_key = blocked_text_key
	definition.fallback_blocked_text = fallback_blocked_text
	return definition
