@tool
class_name HotelItemInteractionDefinition
extends Resource

@export var item_id := ""
@export var actions: Array[HotelInteractionActionDefinition] = []


func to_item_action_data() -> Dictionary:
	var action_data := []
	for action in actions:
		if action != null:
			action_data.append(action.to_action_data())
	return {
		"item_id": item_id,
		"actions": action_data,
	}
