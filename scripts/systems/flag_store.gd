class_name HotelFlagStore
extends RefCounted

var values: Dictionary = {}


func set_value(flag_id: String, value) -> void:
	if flag_id.is_empty():
		return

	values[flag_id] = value


func get_value(flag_id: String, fallback = null):
	return values.get(flag_id, fallback)


func get_bool(flag_id: String, fallback := false) -> bool:
	return bool(values.get(flag_id, fallback))


func has(flag_id: String) -> bool:
	return values.has(flag_id)


func erase(flag_id: String) -> void:
	values.erase(flag_id)


func clear() -> void:
	values.clear()


func export_state() -> Dictionary:
	return values.duplicate(true)


func import_state(state: Dictionary) -> void:
	values = state.duplicate(true)
