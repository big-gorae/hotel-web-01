class_name HotelTaskManager
extends RefCounted

signal task_completed(definition)
signal tasks_changed

const TaskDefinition := preload("res://scripts/tasks/task_definition.gd")
const TaskCatalog := preload("res://scripts/tasks/task_catalog.gd")
const TaskBehaviorRegistry := preload("res://scripts/tasks/task_behavior_registry.gd")

var definitions_by_id: Dictionary = {}
var completed_task_ids: Array[String] = []
var behavior_registry = TaskBehaviorRegistry.new()


func setup_default_catalog() -> void:
	definitions_by_id.clear()
	for definition in TaskCatalog.build_definitions():
		register_definition(definition)
	tasks_changed.emit()


func start_new_run() -> void:
	completed_task_ids.clear()
	tasks_changed.emit()


func register_definition(definition) -> void:
	if definition == null or definition.id.is_empty():
		return

	definitions_by_id[definition.id] = definition.copy()


func has_definition(task_id: String) -> bool:
	return definitions_by_id.has(task_id)


func get_definition(task_id: String):
	return definitions_by_id.get(task_id)


func get_task_state(task_id: String) -> String:
	return TaskDefinition.STATE_DONE if completed_task_ids.has(task_id) else TaskDefinition.STATE_PENDING


func is_all_complete() -> bool:
	return not definitions_by_id.is_empty() and completed_task_ids.size() >= definitions_by_id.size()


func complete_task(task_id: String) -> bool:
	if not definitions_by_id.has(task_id) or completed_task_ids.has(task_id):
		return false

	var definition = definitions_by_id[task_id]
	completed_task_ids.append(task_id)
	task_completed.emit(definition)
	tasks_changed.emit()
	return true


func can_use_item(task_id: String, item_id: String) -> bool:
	var definition = definitions_by_id.get(task_id)
	if definition == null:
		return false

	var context := {"equipped_item_id": item_id}
	return behavior_registry.get_behavior(String(definition.task_type)).can_perform(definition, context)


func perform_task(task_id: String, context) -> Dictionary:
	var definition = definitions_by_id.get(task_id)
	if definition == null or completed_task_ids.has(task_id):
		return {"success": false}

	var behavior = behavior_registry.get_behavior(String(definition.task_type))
	var outcome: Dictionary = behavior.perform(definition, context)
	if not bool(outcome.get("success", false)):
		return outcome

	complete_task(task_id)
	return outcome


func get_hotspots_for_scene(scene_id: String) -> Array:
	var hotspots := []
	for definition in definitions_by_id.values():
		if not definition.applies_to_scene(scene_id):
			continue
		if completed_task_ids.has(definition.id):
			continue

		hotspots.append(_make_hotspot(definition))

	return hotspots


func get_completion_dialogue(task_id: String) -> Dictionary:
	var definition = definitions_by_id.get(task_id)
	if definition == null:
		return {}

	return {
		"key": definition.done_text_key,
		"fallback": definition.fallback_done_text,
	}


func get_blocked_dialogue(task_id: String) -> Dictionary:
	var definition = definitions_by_id.get(task_id)
	if definition == null:
		return {}

	return {
		"key": definition.blocked_text_key,
		"fallback": definition.fallback_blocked_text,
	}


func export_state() -> Dictionary:
	return {
		"completed_task_ids": completed_task_ids.duplicate(),
	}


func import_state(state: Dictionary) -> void:
	completed_task_ids.clear()
	for task_id in state.get("completed_task_ids", []):
		var safe_id := String(task_id)
		if definitions_by_id.has(safe_id) and not completed_task_ids.has(safe_id):
			completed_task_ids.append(safe_id)
	tasks_changed.emit()


func _make_hotspot(definition) -> Dictionary:
	var hotspot := {
		"id": definition.hotspot_id,
		"label": definition.fallback_label,
		"rect": definition.rect,
		"text": definition.fallback_text,
		"task_id": definition.id,
		"label_key": definition.label_key,
		"text_key": definition.text_key,
	}
	if definition.hold_seconds > 0.0:
		hotspot["task_hold_seconds"] = definition.hold_seconds

	if definition.required_item_id.is_empty():
		hotspot["actions"] = [
			{"type": "complete_task", "task_id": definition.id},
		]
	else:
		hotspot["item_actions"] = [
			{
				"item_id": definition.required_item_id,
				"actions": [
					{"type": "complete_task", "task_id": definition.id},
				],
			},
		]
		hotspot["blocked_text_key"] = definition.blocked_text_key
		hotspot["blocked_text"] = definition.fallback_blocked_text

	return hotspot
