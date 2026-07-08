extends SceneTree

const SAVE_PATH := "user://hotel_save.json"

var original_save_exists := false
var original_save_text := ""


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_preserve_save()
	_clear_save()

	var packed: PackedScene = load("res://scenes/main.tscn")
	if packed == null:
		_fail("main scene failed to load")
		return

	var main = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	main._start_shift()
	await process_frame
	main.horror_event_manager.active_event_id_by_room["room_105"] = "room_105_shadow_stain"
	main.show_scene("room_105_door_window", false)
	await process_frame

	var anomaly_hotspot := _find_hotspot(main, "room_105_door_window", "anomaly_room_105_shadow_stain")
	if anomaly_hotspot.is_empty():
		_fail("anomaly hotspot missing")
		return

	main._on_hotspot_pressed(anomaly_hotspot)
	if main.horror_event_manager.resolved_event_ids.has("room_105_shadow_stain"):
		_fail("anomaly resolved without required rule")
		return

	main.rule_book_manager.mark_rule_read("compare_corridor_room_numbers")
	main._on_hotspot_pressed(anomaly_hotspot)
	if not main.horror_event_manager.resolved_event_ids.has("room_105_shadow_stain"):
		_fail("anomaly did not resolve after required rule")
		return

	_restore_save()
	print("smoke horror resolution passed")
	quit(0)


func _find_hotspot(main, scene_id: String, hotspot_id: String) -> Dictionary:
	var hotspots: Array = main._scene_hotspots(scene_id, main.HOTEL_SCENES[scene_id])
	for hotspot in hotspots:
		if hotspot is Dictionary and String(hotspot.get("id", "")) == hotspot_id:
			return hotspot
	return {}


func _preserve_save() -> void:
	original_save_exists = FileAccess.file_exists(SAVE_PATH)
	if original_save_exists:
		var save_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		original_save_text = save_file.get_as_text() if save_file != null else ""


func _clear_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func _restore_save() -> void:
	if original_save_exists:
		var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if save_file != null:
			save_file.store_string(original_save_text)
	elif FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func _fail(message: String) -> void:
	_restore_save()
	push_error(message)
	quit(1)
