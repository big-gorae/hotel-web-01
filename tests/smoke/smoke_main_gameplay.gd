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

	if main.flag_store == null or main.task_manager == null or main.interaction_runner == null:
		_fail("gameplay systems were not initialized")
		return
	for scene_id in main.HOTEL_SCENES.keys():
		if main.HOTEL_SCENES[scene_id].has("hotspots"):
			_fail("scene catalog still duplicates authored hotspots: %s" % scene_id)
			return
		if main._editor_hotspots_for_scene(scene_id).is_empty():
			_fail("scene has no GUI-authored hotspots: %s" % scene_id)
			return

	main.debug_ui_enabled = true
	main._apply_navigation_display()
	if main.filter_toggle == null or main.filter_bar == null:
		_fail("filter debug controls were not initialized")
		return
	if main.filter_bar.visible:
		_fail("filter selector should start hidden")
		return
	main._toggle_filter_selector()
	if not main.show_filter_selector or not main.filter_bar.visible:
		_fail("filter selector did not become visible")
		return
	main._on_filter_preset_selected("subtle_grain")
	if main.post_process_filter.current_preset != "subtle_grain":
		_fail("grain filter preset did not apply")
		return
	main.filter_bar._on_intensity_slider_changed(1.5)
	if main.post_process_filter.get_filter_intensity() != 1.5:
		_fail("filter intensity slider did not update the filter")
		return
	if main.filter_bar.get_filter_button_count() != 3:
		_fail("unexpected number of filter preset buttons")
		return

	main._start_shift()
	await process_frame
	main.show_scene("corridor")
	if not main.scene_transition_fader.is_transitioning():
		_fail("scene transition fader did not start")
		return
	await create_timer(0.4).timeout
	await process_frame
	if main.current_scene_id != "corridor":
		_fail("scene transition did not change scenes")
		return
	if main.scene_transition_fader.visible:
		_fail("scene transition fader did not hide after transition")
		return
	_stop_transition_audio(main)

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
	if not main.flag_store.get_bool("task.room_105.bedding.folded"):
		_fail("fold bedding behavior did not set its completion flag")
		return

	main.show_scene("room_105_bathroom", false)
	await process_frame
	if main.scene_3d_overlay == null or not main.scene_3d_overlay.visible or main.scene_3d_overlay.get_model_count() != 1:
		_fail("room 105 bathroom 3D overlay missing")
		return
	main.mouse_position = Vector2(1280.0, 720.0)
	main._update_layout()
	if main.scene_3d_overlay.position != main.photo.position:
		_fail("3D overlay parallax did not match photo position")
		return
	if main.scene_3d_overlay.size != main.photo.size:
		_fail("3D overlay parallax did not match photo size")
		return

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
	if not main.flag_store.get_bool("task.room_105.sink.cleaned"):
		_fail("clean sink behavior did not set its completion flag")
		return

	main.show_scene("laundry_room", false)
	await process_frame
	if main.scene_3d_overlay.visible:
		_fail("3D overlay should be hidden outside configured bathroom scene")
		return
	var before_open: bool = main._is_laundry_second_washer_open()
	main._run_hotspot_action("toggle_laundry_washer")
	if main._is_laundry_second_washer_open() == before_open:
		_fail("laundry washer did not toggle")
		return

	main._show_rule_book_menu_panel()
	if not main.rule_book_manager.has_read_rule("keep_washer_closed_after_11"):
		_fail("rule book read state missing")
		return

	main.localization.set_language(main.localization.Language.KOREAN)
	if not main.horror_event_manager.trigger_jumpscare("room_107_phone_jumpscare"):
		_fail("jumpscare did not start")
		return
	await process_frame
	if not main.jumpscare_controller.active:
		_fail("jumpscare controller did not lock the screen")
		return
	if main.jumpscare_controller.current_presentation.title_label.text != "전화벨":
		_fail("jumpscare presentation did not use localization")
		return
	var escape_event := InputEventKey.new()
	escape_event.keycode = KEY_ESCAPE
	escape_event.pressed = true
	main._input(escape_event)
	if main._is_menu_open():
		_fail("escape opened the menu during a jumpscare")
		return
	main.jumpscare_controller.current_presentation._finish()
	await process_frame
	if main.horror_event_manager.is_jumpscare_active():
		_fail("jumpscare did not finish through its presentation")
		return
	main.localization.set_language(main.localization.Language.ENGLISH)

	var state: Dictionary = main._capture_day_state()
	for key in ["flags", "inventory", "tasks", "horror", "rules"]:
		if not state.has(key):
			_fail("save state missing %s" % key)
			return

	main.inventory_model.add_item_by_id("collected_trash")
	main.horror_event_manager.mark_event_seen("room_107_phone_jumpscare")
	main._start_shift()
	await process_frame
	if _find_inventory_item(main, "collected_trash") != null:
		_fail("new shift retained an item from the previous run")
		return
	for initial_item_id in ["room_105_key", "small_flashlight", "guest_note", "cleaning_cloth"]:
		if _find_inventory_item(main, initial_item_id) == null:
			_fail("new shift did not restore initial item %s" % initial_item_id)
			return
	if main.horror_event_manager.get_discovered_count() != 1:
		_fail("new shift cleared the permanent horror collection")
		return

	main.queue_free()
	await process_frame
	var restored_main = packed.instantiate()
	root.add_child(restored_main)
	await process_frame
	await process_frame
	if restored_main.horror_event_manager.get_discovered_count() != 1:
		_fail("permanent horror collection did not survive an app restart")
		return
	restored_main.queue_free()
	await process_frame
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


func _stop_transition_audio(main) -> void:
	if main.footstep_timer != null:
		main.footstep_timer.stop()
	for player in main.footstep_players:
		player.stop()


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
