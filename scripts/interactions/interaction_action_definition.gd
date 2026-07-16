@tool
class_name HotelInteractionActionDefinition
extends Resource

@export_enum("show_dialogue", "go_to_scene", "add_item", "complete_task", "use_equipped_item_on_task", "resolve_horror_event", "trigger_jumpscare", "set_flag", "toggle_laundry_washer") var action_type := "show_dialogue"
@export var target_scene_id := ""
@export var item_id := ""
@export var task_id := ""
@export var event_id := ""
@export var flag_id := ""
@export var flag_value := true
@export var text_key := ""
@export_multiline var fallback_text := ""


func to_action_data() -> Dictionary:
	var data := {"type": action_type}
	match action_type:
		"go_to_scene":
			data["target_scene_id"] = target_scene_id
		"add_item":
			data["item_id"] = item_id
		"complete_task", "use_equipped_item_on_task":
			data["task_id"] = task_id
		"resolve_horror_event", "trigger_jumpscare":
			data["event_id"] = event_id
		"set_flag":
			data["flag_id"] = flag_id
			data["value"] = flag_value
		"show_dialogue":
			data["text_key"] = text_key
			data["fallback_text"] = fallback_text
	if not text_key.is_empty() and action_type != "show_dialogue":
		data["text_key"] = text_key
	if not fallback_text.is_empty() and action_type != "show_dialogue":
		data["fallback_text"] = fallback_text
	return data
