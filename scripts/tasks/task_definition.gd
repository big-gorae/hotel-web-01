class_name HotelTaskDefinition
extends RefCounted

const STATE_PENDING := "pending"
const STATE_DONE := "done"

var id := ""
var room_id := ""
var scene_ids: Array[String] = []
var hotspot_id := ""
var task_type := ""
var rect := Rect2()
var required_item_id := ""
var reward_item_id := ""
var label_key := ""
var text_key := ""
var done_text_key := ""
var blocked_text_key := ""
var fallback_label := ""
var fallback_text := ""
var fallback_done_text := ""
var fallback_blocked_text := ""


func applies_to_scene(scene_id: String) -> bool:
	return scene_ids.has(scene_id)


func copy():
	var definition = get_script().new()
	definition.id = id
	definition.room_id = room_id
	definition.scene_ids = scene_ids.duplicate()
	definition.hotspot_id = hotspot_id
	definition.task_type = task_type
	definition.rect = rect
	definition.required_item_id = required_item_id
	definition.reward_item_id = reward_item_id
	definition.label_key = label_key
	definition.text_key = text_key
	definition.done_text_key = done_text_key
	definition.blocked_text_key = blocked_text_key
	definition.fallback_label = fallback_label
	definition.fallback_text = fallback_text
	definition.fallback_done_text = fallback_done_text
	definition.fallback_blocked_text = fallback_blocked_text
	return definition
