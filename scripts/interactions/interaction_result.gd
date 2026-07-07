class_name HotelInteractionResult
extends RefCounted

var changed_scene_id := ""
var dialogue_key := ""
var fallback_dialogue := ""
var should_refresh_hotspots := false
var should_refresh_photo := false
var should_save := false
var consumed := false
var blocked_reason_key := ""
var fallback_blocked_reason := ""


func has_dialogue() -> bool:
	return not dialogue_key.is_empty() or not fallback_dialogue.is_empty()


func set_dialogue(new_key: String, new_fallback: String) -> void:
	dialogue_key = new_key
	fallback_dialogue = new_fallback
	consumed = true


func set_blocked(new_key: String, new_fallback: String) -> void:
	blocked_reason_key = new_key
	fallback_blocked_reason = new_fallback
	set_dialogue(new_key, new_fallback)


func merge(other) -> void:
	if other == null:
		return

	if not other.changed_scene_id.is_empty():
		changed_scene_id = other.changed_scene_id
	if other.has_dialogue():
		dialogue_key = other.dialogue_key
		fallback_dialogue = other.fallback_dialogue
	if other.should_refresh_hotspots:
		should_refresh_hotspots = true
	if other.should_refresh_photo:
		should_refresh_photo = true
	if other.should_save:
		should_save = true
	if other.consumed:
		consumed = true
	if not other.blocked_reason_key.is_empty() or not other.fallback_blocked_reason.is_empty():
		blocked_reason_key = other.blocked_reason_key
		fallback_blocked_reason = other.fallback_blocked_reason
