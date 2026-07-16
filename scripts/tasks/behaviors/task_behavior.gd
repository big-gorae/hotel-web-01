class_name HotelTaskBehavior
extends RefCounted


func can_perform(definition, context) -> bool:
	if definition == null:
		return false
	if String(definition.required_item_id).is_empty():
		return true
	return context != null and String(context.equipped_item_id) == String(definition.required_item_id)


func perform(definition, context) -> Dictionary:
	if not can_perform(definition, context):
		return {"success": false}

	var rewards: Array[String] = []
	if not String(definition.reward_item_id).is_empty():
		rewards.append(String(definition.reward_item_id))
	return {
		"success": true,
		"effect": String(definition.task_type),
		"reward_item_ids": rewards,
		"flag_updates": _completion_flags(definition),
	}


func _completion_flags(definition) -> Dictionary:
	if definition == null or String(definition.completion_flag_id).is_empty():
		return {}
	return {String(definition.completion_flag_id): true}
