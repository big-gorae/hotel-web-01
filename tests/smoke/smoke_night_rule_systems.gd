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
	var main = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main._start_shift()
	await process_frame
	while main.is_intro_dialogue_active():
		main._advance_intro_dialogue()
	if not _latest_rule_page_is_open(main, 1, 3):
		_fail("day one did not automatically open its three-rule page")
		return
	main._hide_menu()

	if main.rule_book_manager.get_visible_rules().size() != 3:
		_fail("day one should expose exactly three ordinary rules")
		return
	if _find_inventory_item(main, "mold_remover") == null:
		_fail("mold remover was not added to the initial inventory")
		return

	main._start_day(3, false, false)
	await process_frame
	if not _latest_rule_page_is_open(main, 3, 2):
		_fail("day three did not automatically open its two new rules")
		return
	main.menu_overlay.rule_book_screen.show_page(2)
	if main.menu_overlay.rule_book_screen.get_page_rule_count() != 1:
		_fail("rule book previous-page navigation did not show day two")
		return
	main.menu_overlay.rule_book_screen.set_page_image_override(2, "res://resource/images/front_desk.png")
	if not main.menu_overlay.rule_book_screen.is_page_image_mode() or main.menu_overlay.rule_book_screen.text_page_scroll.visible:
		_fail("rule book page image did not replace the generated text layout")
		return
	main.menu_overlay.rule_book_screen.set_page_image_override(2, "")
	if main.menu_overlay.rule_book_screen.is_page_image_mode() or not main.menu_overlay.rule_book_screen.text_page_scroll.visible:
		_fail("missing rule book image did not fall back to generated text")
		return
	main._hide_menu()
	main.show_scene("corridor", false)
	await process_frame
	if main.rule_book_manager.get_visible_rules().size() != 6:
		_fail("day three rules did not unlock")
		return
	if _find_dynamic_hotspot(main, "room_109_open_door").is_empty() or not main.room_109_overlay.visible:
		_fail("open Room 109 was not visible on day three")
		return

	main.show_scene("room_105_bathroom_entry", false)
	main._set_debug_mold_stage(4)
	if not main.mold_overlay.visible or main.mold_overlay.stack != 4:
		_fail("debug mold stage did not display to the right of the Room 105 closet")
		return
	main._set_debug_mold_stage(6)
	if main.mold_closet_timer != null:
		_fail("closet death timer should not exist while gimmicks are test-only")
		return
	var remover = _find_inventory_item(main, "mold_remover")
	main.inventory_model.equip_item(remover)
	main._use_equipped_item()
	if main.mold_growth_system.get_mold_stack("room_105") != 4:
		_fail("first mold remover spray did not remove two stacks")
		return
	if main.system_message_panel.visible:
		_fail("mold remover spray should not show a system message")
		return
	main._use_equipped_item()
	if main.mold_growth_system.get_mold_stack("room_105") != 2:
		_fail("second mold remover spray did not remove two stacks")
		return
	main._use_equipped_item()
	if main.mold_growth_system.get_mold_stack("room_105") != 0:
		_fail("third mold remover spray did not clear the remaining stacks")
		return
	if main.mold_spray_player == null or main.mold_spray_player.stream == null:
		_fail("mold remover spray sound was not prepared")
		return

	main.eye_close_controller.close_eyes()
	if not main.eye_close_controller.is_closed() or not main.eye_close_controller.visible:
		_fail("eye close controller did not enable its mask")
		return
	main.eye_close_controller.open_eyes()
	main.menu_overlay.show_controls()
	if not main.menu_overlay.controls_screen.visible:
		_fail("controls menu was not added to the Esc menu")
		return

	main._start_day(4, false, false)
	await process_frame
	main._hide_menu()
	main.show_scene("front_desk", false)
	main.night_anomaly_director.force_phone_ring()
	main._on_hotspot_pressed(_find_dynamic_or_editor_hotspot(main, "phone"))
	if not main.night_anomaly_director.room_108_forbidden:
		_fail("answered Room 108 repair call did not block Room 108")
		return

	main._start_day(5, false, false)
	await process_frame
	main._hide_menu()
	main.show_scene("laundry_room", false)
	main.night_anomaly_director.force_red_laundry()
	main._on_hotspot_pressed(_find_dynamic_or_editor_hotspot(main, "laundry_second_washer"))
	if main.night_anomaly_director.laundry_state != main.night_anomaly_director.LAUNDRY_MUSIC:
		_fail("red washer did not enter completion-music lock")
		return
	main.night_anomaly_director._completion_music_player.stop()
	main.night_anomaly_director._on_completion_music_finished()
	main.eye_close_controller.close_eyes()
	main._on_hotspot_pressed(_find_dynamic_or_editor_hotspot(main, "laundry_second_washer"))
	if main.night_anomaly_director.laundry_state != main.night_anomaly_director.LAUNDRY_DISCARDED:
		_fail("red laundry could not be discarded with eyes closed")
		return
	main.eye_close_controller.open_eyes()

	main._start_day(6, false, false)
	await process_frame
	main._hide_menu()
	main.show_scene("room_106_bathroom", false)
	main.night_anomaly_director.force_child_encounter()
	main.eye_close_controller.close_eyes()
	if not main.eye_close_controller.is_song_active():
		_fail("closing eyes did not automatically start the child song")
		return
	main.eye_close_controller._process(main.night_anomaly_director.child_song_duration)
	if main.night_anomaly_director.child_state != main.night_anomaly_director.CHILD_SONG_DONE:
		_fail("child did not stop crying after the full song")
		return
	main.eye_close_controller.open_eyes()
	main._on_hotspot_pressed(_find_dynamic_hotspot(main, "abandoned_child"))
	if main.night_anomaly_director.child_state != main.night_anomaly_director.CHILD_HELD:
		_fail("rule thirteen child embrace did not complete")
		return

	main._start_day(7, false, false)
	await process_frame
	if not _latest_rule_page_is_open(main, 7, 3):
		_fail("day seven did not automatically open its three new rules")
		return

	_restore_save()
	main.queue_free()
	await process_frame
	await process_frame
	print("smoke night rule systems passed")
	quit(0)


func _find_dynamic_hotspot(main, hotspot_id: String) -> Dictionary:
	for hotspot in main.night_anomaly_director.get_dynamic_hotspots(main.current_scene_id):
		if String(hotspot.get("id", "")) == hotspot_id:
			return hotspot
	return {}


func _find_dynamic_or_editor_hotspot(main, hotspot_id: String) -> Dictionary:
	for hotspot in main._scene_hotspots(main.current_scene_id, main.HOTEL_SCENES[main.current_scene_id]):
		if String(hotspot.get("id", "")) == hotspot_id:
			return hotspot
	return {}


func _find_inventory_item(main, item_id: String):
	for item in main.inventory_model.get_items():
		if String(item.id) == item_id:
			return item
	return null


func _latest_rule_page_is_open(main, day: int, rule_count: int) -> bool:
	return (
		main.menu_overlay.visible
		and main.menu_overlay.rule_book_screen.visible
		and main.menu_overlay.rule_book_screen.get_current_page_day() == day
		and main.menu_overlay.rule_book_screen.get_page_rule_count() == rule_count
	)


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
