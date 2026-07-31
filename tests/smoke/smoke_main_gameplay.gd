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
	if main.debug_jumpscare_lab_button == null or main.jumpscare_lab == null:
		_fail("jumpscare lab was not initialized")
		return
	main._open_jumpscare_lab()
	if not main.jumpscare_lab.visible:
		_fail("jumpscare lab did not open")
		return
	if not main.jumpscare_lab.select_event_by_id("room_105_closet_woman"):
		_fail("pig-mask jumpscare lab entry is missing")
		return
	main.jumpscare_lab.set_control_value("jumpscare_hold_seconds", 0.24)
	if not main.jumpscare_lab.preview_selected():
		_fail("jumpscare lab preview request failed")
		return
	if not main.jumpscare_controller.active:
		_fail("jumpscare lab preview did not start")
		return
	if String(main.jumpscare_controller.current_presentation.subject.texture.resource_path) != main.HotelHorrorEventManagerScript.HorrorCatalog.PIG_MASK_REFERENCE:
		_fail("jumpscare preview did not use the original pig-mask reference")
		return
	main.jumpscare_controller.stop()
	main.jumpscare_lab.close_lab()
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
	if main.current_scene_id != "front_desk" or main.lobby_overlay.visible:
		_fail("opening story did not begin on the front desk game screen")
		return
	if not main.is_intro_dialogue_active() or main.get_intro_dialogue_step() != 1:
		_fail("front desk opening dialogue did not start")
		return
	if not main.get_tree().paused or not main.intro_input_blocker.visible or not main.persistent_dialogue_panel.visible:
		_fail("gameplay was not paused behind the opening dialogue")
		return
	if not main.typewriter_dialogue_controller.is_typing() or main.persistent_dialogue_hint_label.visible:
		_fail("opening dialogue did not begin in typewriter state")
		return
	if main.persistent_dialogue_label.vertical_alignment != VERTICAL_ALIGNMENT_TOP or main.persistent_dialogue_label.horizontal_alignment != HORIZONTAL_ALIGNMENT_LEFT:
		_fail("opening dialogue text is not anchored from the upper-left")
		return
	if main.persistent_dialogue_panel.offset_top != -265.0 or main.dialogue_gradient.material == null:
		_fail("opening dialogue panel did not use the raised gradient layout")
		return
	main.typewriter_dialogue_controller._process(0.12)
	var partial_count: int = main.typewriter_dialogue_controller.get_visible_character_count()
	if partial_count <= 0 or partial_count >= main.current_persistent_dialogue_text.length():
		_fail("opening dialogue did not reveal text progressively")
		return
	var seen_seconds_before: Dictionary = main.horror_event_manager.seen_scene_seconds.duplicate(true)
	main._process(20.0)
	if main.horror_event_manager.seen_scene_seconds != seen_seconds_before:
		_fail("horror progression advanced during opening dialogue")
		return
	main.show_scene("corridor", false)
	if main.current_scene_id != "front_desk":
		_fail("scene navigation was possible during opening dialogue")
		return
	var dialogue_click := InputEventMouseButton.new()
	dialogue_click.button_index = MOUSE_BUTTON_LEFT
	dialogue_click.pressed = true
	main._on_persistent_dialogue_input(dialogue_click)
	if main.get_intro_dialogue_step() != 1 or main.typewriter_dialogue_controller.is_typing():
		_fail("first dialogue click did not complete the current line")
		return
	if not main.persistent_dialogue_hint_label.visible or main.persistent_dialogue_hint_label.text != "▼":
		_fail("completed dialogue line did not show its downward arrow")
		return
	main._on_persistent_dialogue_input(dialogue_click)
	if main.get_intro_dialogue_step() != 2 or not main.typewriter_dialogue_controller.is_typing():
		_fail("second dialogue click did not start the next line")
		return
	if not "동생" in main.localization.translations[main.localization.Language.KOREAN]["story.day.7.line.1"]:
		_fail("day seven story is missing the younger-sister reveal")
		return
	main._advance_intro_dialogue()
	main._advance_intro_dialogue()
	if main.is_intro_dialogue_active() or main.intro_input_blocker.visible:
		_fail("opening dialogue did not release its input lock")
		return
	if not main.menu_overlay.visible or not main.menu_overlay.rule_book_screen.visible:
		_fail("day one rule page did not follow the opening dialogue")
		return
	if main.menu_overlay.rule_book_screen.get_current_page_day() != 1 or main.menu_overlay.rule_book_screen.get_page_rule_count() != 3:
		_fail("day one rule page did not show exactly its three new rules")
		return
	main._hide_menu()
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
	if main.scene_3d_overlay == null or main.scene_3d_overlay.visible:
		_fail("abandoned-child 3D model appeared without its encounter")
		return
	main.show_scene("room_106_bathroom", false)
	main.night_anomaly_director.force_child_encounter()
	await process_frame
	if not main.scene_3d_overlay.visible or main.scene_3d_overlay.get_model_count() != 1:
		_fail("Room 106 abandoned-child 3D model missing during its encounter")
		return
	main.mouse_position = Vector2(1280.0, 720.0)
	main._update_layout()
	if main.scene_3d_overlay.position != main.photo.position:
		_fail("3D overlay parallax did not match photo position")
		return
	if main.scene_3d_overlay.size != main.photo.size:
		_fail("3D overlay parallax did not match photo size")
		return
	main.night_anomaly_director.start_day(1)
	main.show_scene("room_105_bathroom", false)
	await process_frame

	if main.debug_curtain_preview_selector == null or main.debug_curtain_preview_selector.disabled:
		_fail("bathroom debug curtain comparison selector is unavailable")
		return
	main._set_debug_curtain_preview_mode(main.DEBUG_CURTAIN_OPEN)
	await process_frame
	if not main.current_texture.resource_path.ends_with("room_105_bathroom.png"):
		_fail("debug curtain open preview did not load")
		return
	var debug_open_hotspot := _find_hotspot(main, "room_105_bathroom", "shower_curtain")
	var debug_open_rect: Rect2 = debug_open_hotspot.get("rect")

	main._set_debug_curtain_preview_mode(main.DEBUG_CURTAIN_CLOSED_EDIT)
	await process_frame
	if not main.current_texture.resource_path.ends_with("room_105_bathroom_curtain_closed.png"):
		_fail("debug edit_002 closed curtain preview did not load")
		return
	if main.shower_curtain_state.is_closed("room_105_bathroom"):
		_fail("debug edit_002 preview changed the saved curtain state")
		return

	main._set_debug_curtain_preview_mode(main.DEBUG_CURTAIN_CLOSED_PREV)
	await process_frame
	if main.current_texture.resource_path != main.DEBUG_CURTAIN_PREV_PHOTO:
		_fail("debug prev closed curtain preview did not load")
		return
	var debug_prev_hotspot := _find_hotspot(main, "room_105_bathroom", "shower_curtain")
	var debug_prev_rect: Rect2 = debug_prev_hotspot.get("rect")
	if debug_prev_rect.size.x <= debug_open_rect.size.x:
		_fail("debug closed preview did not use the full curtain click area")
		return
	if main.scene_3d_overlay.visible:
		_fail("room 105 tub overlay remained visible in the debug closed preview")
		return
	main._on_hotspot_pressed(debug_prev_hotspot)
	await process_frame
	if main.debug_curtain_preview_mode != main.DEBUG_CURTAIN_OPEN or main.shower_curtain_state.is_closed("room_105_bathroom"):
		_fail("clicking the debug curtain preview did not compare against the open photo")
		return
	main._set_debug_curtain_preview_mode(main.DEBUG_CURTAIN_GAMEPLAY)
	await process_frame
	if main.scene_3d_overlay.visible:
		_fail("abandoned-child 3D model returned outside its encounter")
		return

	for room_number in [105, 106, 107, 108]:
		var bathroom_scene_id := "room_%d_bathroom" % room_number
		main.show_scene(bathroom_scene_id, false)
		await process_frame
		var open_curtain_hotspot := _find_hotspot(main, bathroom_scene_id, "shower_curtain")
		if open_curtain_hotspot.is_empty():
			_fail("room %d shower curtain hotspot missing" % room_number)
			return
		var open_curtain_rect: Rect2 = open_curtain_hotspot.get("rect")
		main._on_hotspot_pressed(open_curtain_hotspot)
		await process_frame
		if not main.shower_curtain_state.is_closed(bathroom_scene_id):
			_fail("room %d shower curtain did not close" % room_number)
			return
		if not main.current_texture.resource_path.ends_with("_curtain_closed.png"):
			_fail("room %d closed curtain photo did not load" % room_number)
			return
		var closed_curtain_hotspot := _find_hotspot(main, bathroom_scene_id, "shower_curtain")
		var closed_curtain_rect: Rect2 = closed_curtain_hotspot.get("rect")
		if closed_curtain_rect.size.x <= open_curtain_rect.size.x:
			_fail("room %d closed curtain click area did not expand" % room_number)
			return
		if main.scene_3d_overlay.visible:
			_fail("abandoned-child 3D model appeared during ordinary curtain interaction")
			return
		main._on_hotspot_pressed(closed_curtain_hotspot)
		await process_frame
		if main.shower_curtain_state.is_closed(bathroom_scene_id):
			_fail("room %d shower curtain did not reopen" % room_number)
			return

	main.show_scene("room_105_bathroom", false)
	await process_frame
	if main.scene_3d_overlay.visible:
		_fail("abandoned-child 3D model appeared after reopening an ordinary curtain")
		return

	var sink_hotspot := _find_task_hotspot(main, "room_105_bathroom", "room_105_clean_sink")
	if sink_hotspot.is_empty():
		_fail("clean sink task hotspot missing")
		return

	var cloth_item = _find_inventory_item(main, "cleaning_cloth")
	if cloth_item == null or not main.inventory_model.equip_item(cloth_item):
		_fail("cleaning cloth could not be equipped")
		return
	main._apply_interaction_result(main.interaction_runner.execute_item_on_hotspot(
		sink_hotspot,
		main._make_interaction_context(sink_hotspot)
	))
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
	if not main.rule_book_manager.has_read_rule("make_vacant_beds"):
		_fail("rule book read state missing")
		return

	main.localization.set_language(main.localization.Language.KOREAN)
	if not main.horror_event_manager.trigger_jumpscare("room_108_light_repair_call"):
		_fail("lethal jumpscare did not start")
		return
	if main.jumpscare_controller == null or not main.horror_event_manager.is_jumpscare_active():
		_fail("lethal jumpscare presentation was not created")
		return
	main.jumpscare_controller.stop()
	main.horror_event_manager.finish_jumpscare()
	main.localization.set_language(main.localization.Language.ENGLISH)

	var state: Dictionary = main._capture_day_state()
	for key in ["flags", "inventory", "tasks", "horror", "rules"]:
		if not state.has(key):
			_fail("save state missing %s" % key)
			return

	main.inventory_model.add_item_by_id("collected_trash")
	main.horror_event_manager.mark_event_seen("room_108_light_repair_call")
	var collection_count_before_restart: int = main.horror_event_manager.get_discovered_count()
	main._start_shift()
	await process_frame
	_complete_intro_dialogue(main)
	main._hide_menu()
	if _find_inventory_item(main, "collected_trash") != null:
		_fail("new shift retained an item from the previous run")
		return
	for initial_item_id in ["room_105_key", "small_flashlight", "guest_note", "cleaning_cloth"]:
		if _find_inventory_item(main, initial_item_id) == null:
			_fail("new shift did not restore initial item %s" % initial_item_id)
			return
	if (
		main.horror_event_manager.get_discovered_count() != collection_count_before_restart
		or not main.horror_event_manager.collection_event_ids.has("room_108_light_repair_call")
	):
		_fail("new shift cleared the permanent horror collection")
		return

	main.queue_free()
	await process_frame
	var restored_main = packed.instantiate()
	root.add_child(restored_main)
	await process_frame
	await process_frame
	if (
		restored_main.horror_event_manager.get_discovered_count() != collection_count_before_restart
		or not restored_main.horror_event_manager.collection_event_ids.has("room_108_light_repair_call")
	):
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


func _find_hotspot(main, scene_id: String, hotspot_id: String) -> Dictionary:
	var hotspots: Array = main._scene_hotspots(scene_id, main.HOTEL_SCENES[scene_id])
	for hotspot in hotspots:
		if hotspot is Dictionary and String(hotspot.get("id", "")) == hotspot_id:
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


func _complete_intro_dialogue(main) -> void:
	while main.is_intro_dialogue_active():
		main._advance_intro_dialogue()


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
