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

	if main.flag_store == null or main.task_manager == null or main.interaction_runner == null:
		_fail("gameplay systems were not initialized")
		return

	main._start_shift()
	await process_frame
	main.show_scene("room_105_door_window", false)
	await process_frame

	var fold_hotspot := _find_task_hotspot(main, "room_105_door_window", "room_105_fold_bedding")
	if fold_hotspot.is_empty():
		_fail("fold bedding task hotspot missing")
		return
	main._on_hotspot_pressed(fold_hotspot)
	if main.task_manager.get_task_state("room_105_fold_bedding") != "done":
		_fail("fold bedding task did not complete")
		return

	main.show_scene("room_105_bathroom", false)
	await process_frame
	var sink_hotspot := _find_task_hotspot(main, "room_105_bathroom", "room_105_clean_sink")
	if sink_hotspot.is_empty():
		_fail("clean sink task hotspot missing")
		return

	var cloth_item = _find_inventory_item(main, "cleaning_cloth")
	if cloth_item == null or not main.inventory_model.equip_item(cloth_item):
		_fail("cleaning cloth could not be equipped")
		return
	main._on_hotspot_pressed(sink_hotspot)
	if main.task_manager.get_task_state("room_105_clean_sink") != "done":
		_fail("clean sink task did not complete")
		return

	main.show_scene("laundry_room", false)
	await process_frame
	var before_open: bool = main._is_laundry_second_washer_open()
	main._run_hotspot_action("toggle_laundry_washer")
	if main._is_laundry_second_washer_open() == before_open:
		_fail("laundry washer did not toggle")
		return

	main._show_rule_book_menu_panel()
	if not main.rule_book_manager.has_read_rule("keep_washer_closed_after_11"):
		_fail("rule book read state missing")
		return

	var state: Dictionary = main._capture_day_state()
	for key in ["flags", "inventory", "tasks", "horror", "rules"]:
		if not state.has(key):
			_fail("save state missing %s" % key)
			return

	_restore_save()
	print("smoke main gameplay passed")
	quit(0)


func _find_task_hotspot(main, scene_id: String, task_id: String) -> Dictionary:
	var hotspots: Array = main._scene_hotspots(scene_id, main.HOTEL_SCENES[scene_id])
	for hotspot in hotspots:
		if hotspot is Dictionary and String(hotspot.get("task_id", "")) == task_id:
			return hotspot
	return {}


func _find_inventory_item(main, item_id: String):
	for item in main.inventory_model.get_items():
		if item.id == item_id:
			return item
	return null


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
