class_name HotelRuleDefinition
extends RefCounted

var id := ""
var order := 0
var text_key := ""
var fallback_text := ""
var tags: Array[String] = []
var related_task_ids: Array[String] = []
var related_horror_event_ids: Array[String] = []
var related_item_ids: Array[String] = []
var unlock_flag_id := ""


func copy():
	var definition = get_script().new()
	definition.id = id
	definition.order = order
	definition.text_key = text_key
	definition.fallback_text = fallback_text
	definition.tags = tags.duplicate()
	definition.related_task_ids = related_task_ids.duplicate()
	definition.related_horror_event_ids = related_horror_event_ids.duplicate()
	definition.related_item_ids = related_item_ids.duplicate()
	definition.unlock_flag_id = unlock_flag_id
	return definition
