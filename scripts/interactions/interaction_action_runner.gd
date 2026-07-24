class_name HotelInteractionActionRunner
extends RefCounted

const InteractionResult := preload("res://scripts/interactions/interaction_result.gd")

const LAUNDRY_OPEN_FLAG := "laundry.second_washer.open"

var flag_store = null
var inventory_model = null
var task_manager = null
var horror_event_manager = null
var rule_book_manager = null


func setup(new_flag_store, new_inventory_model, new_task_manager, new_horror_event_manager, new_rule_book_manager = null) -> void:
	flag_store = new_flag_store
	inventory_model = new_inventory_model
	task_manager = new_task_manager
	horror_event_manager = new_horror_event_manager
	rule_book_manager = new_rule_book_manager


func execute_hotspot(hotspot: Dictionary, context):
	var result := InteractionResult.new()
	if hotspot.is_empty():
		return result

	var item_result = _try_execute_item_actions(hotspot, context)
	if item_result != null:
		return item_result

	if context != null and not String(context.equipped_item_id).is_empty() and hotspot.has("item_actions"):
		result.set_blocked(
			String(hotspot.get("blocked_text_key", "")),
			String(hotspot.get("blocked_text", "That does not work here.")),
		)
		return result

	if hotspot.has("actions"):
		return execute_actions(hotspot["actions"], context)

	if hotspot.has("action"):
		return execute_action(_legacy_action_to_dictionary(String(hotspot["action"])), context)

	if hotspot.has("target"):
		return execute_action({"type": "go_to_scene", "target_scene_id": hotspot["target"]}, context)

	if hotspot.has("text"):
		result.set_dialogue(String(hotspot.get("text_key", "")), String(hotspot["text"]))
		return result

	if hotspot.has("label"):
		result.set_dialogue(String(hotspot.get("label_key", "")), String(hotspot["label"]))

	return result


func execute_item_on_hotspot(hotspot: Dictionary, context):
	var result := InteractionResult.new()
	if hotspot.is_empty():
		return result

	var item_result = _try_execute_item_actions(hotspot, context)
	return item_result if item_result != null else result


func execute_actions(actions, context):
	var result := InteractionResult.new()
	if actions is Array:
		for action in actions:
			result.merge(execute_action(action, context))
	elif actions is Dictionary:
		result.merge(execute_action(actions, context))
	elif actions is String:
		result.merge(execute_action(_legacy_action_to_dictionary(actions), context))

	return result


func execute_action(action, context):
	var result := InteractionResult.new()
	if action is String:
		return execute_action(_legacy_action_to_dictionary(action), context)
	if not action is Dictionary:
		return result

	var action_type := String(action.get("type", ""))
	match action_type:
		"show_dialogue":
			result.set_dialogue(String(action.get("text_key", "")), String(action.get("fallback_text", "")))
		"go_to_scene":
			result.changed_scene_id = String(action.get("target_scene_id", ""))
			result.consumed = true
		"add_item":
			_add_item(String(action.get("item_id", "")))
			result.should_save = true
			result.consumed = true
			if action.has("fallback_text") or action.has("text_key"):
				result.set_dialogue(String(action.get("text_key", "")), String(action.get("fallback_text", "")))
		"complete_task":
			_complete_task(String(action.get("task_id", "")), context, result)
		"use_equipped_item_on_task":
			_use_equipped_item_on_task(String(action.get("task_id", "")), context, result)
		"resolve_horror_event":
			_resolve_horror_event(String(action.get("event_id", "")), result)
		"trigger_jumpscare":
			_trigger_jumpscare(String(action.get("event_id", "")), result)
		"set_flag":
			_set_flag(String(action.get("flag_id", "")), action.get("value"), result)
		"toggle_laundry_washer":
			_toggle_laundry_washer(result)
		_:
			push_warning("Unknown interaction action: %s" % action_type)

	return result


func _try_execute_item_actions(hotspot: Dictionary, context):
	if context == null or String(context.equipped_item_id).is_empty() or not hotspot.has("item_actions"):
		return null

	for item_action in hotspot["item_actions"]:
		if not item_action is Dictionary:
			continue
		if String(item_action.get("item_id", "")) == context.equipped_item_id:
			return execute_actions(item_action.get("actions", []), context)

	return null


func _legacy_action_to_dictionary(action: String) -> Dictionary:
	if action.begins_with("resolve_horror_event:"):
		return {
			"type": "resolve_horror_event",
			"event_id": action.substr("resolve_horror_event:".length()),
		}

	if action.begins_with("trigger_jumpscare:"):
		return {
			"type": "trigger_jumpscare",
			"event_id": action.substr("trigger_jumpscare:".length()),
		}

	if action == "toggle_laundry_washer":
		return {"type": "toggle_laundry_washer"}

	return {"type": action}


func _add_item(item_id: String) -> void:
	if item_id.is_empty() or inventory_model == null:
		return

	inventory_model.add_item_by_id(item_id)


func _complete_task(task_id: String, context, result) -> void:
	if task_manager == null or task_id.is_empty():
		return

	var outcome: Dictionary = task_manager.perform_task(task_id, context)
	if not bool(outcome.get("success", false)):
		var blocked_dialogue: Dictionary = task_manager.get_blocked_dialogue(task_id)
		result.set_blocked(String(blocked_dialogue.get("key", "")), String(blocked_dialogue.get("fallback", "That item does not work here.")))
		return

	for item_id in outcome.get("reward_item_ids", []):
		_add_item(String(item_id))
	for flag_id in outcome.get("flag_updates", {}).keys():
		if flag_store != null:
			flag_store.set_value(String(flag_id), outcome["flag_updates"][flag_id])

	result.should_refresh_hotspots = true
	result.should_save = true
	result.consumed = true
	var dialogue: Dictionary = task_manager.get_completion_dialogue(task_id)
	result.set_dialogue(String(dialogue.get("key", "")), String(dialogue.get("fallback", "")))


func _use_equipped_item_on_task(task_id: String, context, result) -> void:
	if task_manager == null or context == null:
		return

	if task_manager.can_use_item(task_id, String(context.equipped_item_id)):
		_complete_task(task_id, context, result)
		return

	var dialogue: Dictionary = task_manager.get_blocked_dialogue(task_id)
	result.set_blocked(String(dialogue.get("key", "")), String(dialogue.get("fallback", "That item does not work here.")))


func _resolve_horror_event(event_id: String, result) -> void:
	if horror_event_manager == null or event_id.is_empty():
		return

	var definition = horror_event_manager.get_definition(event_id)
	if definition != null and not _can_resolve_horror_event(definition):
		result.set_blocked(_horror_blocked_key(definition), _horror_blocked_text(definition))
		return

	horror_event_manager.resolve_event(event_id)
	result.should_refresh_hotspots = true
	result.should_save = true
	result.set_dialogue("horror_event.%s.resolved" % event_id, "The anomaly fades from the room.")


func _trigger_jumpscare(event_id: String, result) -> void:
	if horror_event_manager == null or event_id.is_empty():
		return

	horror_event_manager.trigger_jumpscare(event_id)
	result.consumed = true


func _set_flag(flag_id: String, value, result) -> void:
	if flag_store == null or flag_id.is_empty():
		return

	flag_store.set_value(flag_id, value)
	result.should_save = true
	result.consumed = true


func _can_resolve_horror_event(definition) -> bool:
	if definition == null:
		return false

	if not String(definition.required_item_id).is_empty():
		if inventory_model == null or inventory_model.equipped_item == null:
			return false
		if String(inventory_model.equipped_item.id) != String(definition.required_item_id):
			return false

	if not String(definition.required_rule_id).is_empty():
		if rule_book_manager == null or not rule_book_manager.has_read_rule(String(definition.required_rule_id)):
			return false

	if not String(definition.required_task_id).is_empty():
		if task_manager == null or task_manager.get_task_state(String(definition.required_task_id)) != "done":
			return false

	return true


func _horror_blocked_key(definition) -> String:
	if definition != null and not String(definition.blocked_text_key).is_empty():
		return String(definition.blocked_text_key)

	return "horror_event.%s.blocked" % String(definition.id)


func _horror_blocked_text(definition) -> String:
	if definition != null and not String(definition.fallback_blocked_text).is_empty():
		return String(definition.fallback_blocked_text)

	return "Something is missing. Check the Rule Book and your hand before trying again."


func _toggle_laundry_washer(result) -> void:
	if flag_store == null:
		return

	var is_open: bool = not flag_store.get_bool(LAUNDRY_OPEN_FLAG, true)
	flag_store.set_value(LAUNDRY_OPEN_FLAG, is_open)
	result.should_refresh_photo = true
	result.should_save = true
	var state_key := "opened" if is_open else "closed"
	var message := "The second washer door is open." if is_open else "The second washer door is closed."
	result.set_dialogue("hotspot.laundry_room.laundry_second_washer.%s" % state_key, message)
