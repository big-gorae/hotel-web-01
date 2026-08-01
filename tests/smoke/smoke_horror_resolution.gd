extends SceneTree

const SAVE_PATH := "user://hotel_save.json"
const META_SAVE_PATH := "user://hotel_meta.json"

var preserved_files: Dictionary = {}


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
	while main.is_intro_dialogue_active():
		main._advance_intro_dialogue()
	main._hide_menu()

	var rule = main.rule_book_manager.definitions_by_id.get("close_open_wardrobe")
	if rule == null or main.localization.translate(rule.text_key) != "객실 옷장 문이 열려 있으면 닫으시오.":
		_fail("wardrobe rule did not use the simplified Korean instruction")
		return

	main.closet_pig_man_system.force_event(main.closet_pig_man_system.STATE_EMERGING)
	main.show_scene("room_105_bathroom_entry", false)
	await process_frame

	var anomaly_hotspot := _find_hotspot(
		main,
		"room_105_bathroom_entry",
		main.HotelClosetPigManSystemScript.HOLD_HOTSPOT_ID,
	)
	if anomaly_hotspot.is_empty():
		_fail("open wardrobe hold hotspot missing")
		return

	main._on_anomaly_hotspot_button_down(anomaly_hotspot)
	main.closet_pig_man_system.advance(main.closet_pig_man_system.HOLD_SECONDS - 0.01)
	if not main.closet_pig_man_system.is_active():
		_fail("wardrobe resolved before the full hold duration")
		return
	main.closet_pig_man_system.advance(0.01)
	if not main.horror_event_manager.resolved_event_ids.has(main.CLOSET_PIG_MAN_EVENT_ID):
		_fail("holding the wardrobe did not push the man back and resolve the event")
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
	for path in [SAVE_PATH, META_SAVE_PATH]:
		if FileAccess.file_exists(path):
			var save_file := FileAccess.open(path, FileAccess.READ)
			preserved_files[path] = save_file.get_as_text() if save_file != null else ""


func _clear_save() -> void:
	for path in [SAVE_PATH, META_SAVE_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _restore_save() -> void:
	for path in [SAVE_PATH, META_SAVE_PATH]:
		if preserved_files.has(path):
			var save_file := FileAccess.open(path, FileAccess.WRITE)
			if save_file != null:
				save_file.store_string(String(preserved_files[path]))
		elif FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _fail(message: String) -> void:
	_restore_save()
	push_error(message)
	quit(1)
