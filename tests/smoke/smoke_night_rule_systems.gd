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

	for task_id in main.task_manager.definitions_by_id.keys():
		main.task_manager.complete_task(String(task_id))
	main.show_scene("front_desk", false)
	main._update_shift_end_button()
	if not main.end_shift_button.visible:
		_fail("completed first shift did not expose the front-desk end-shift action")
		return
	main._end_shift()
	await process_frame
	_finish_story(main)
	if main.day_save_manager.current_day != 2:
		_fail("end-shift action did not advance to day two")
		return
	main._hide_menu()

	main._start_day(3, false, false)
	await process_frame
	_finish_story(main)
	if not _latest_rule_page_is_open(main, 3, 4):
		_fail("day three did not automatically open its four new rules")
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
	if main.rule_book_manager.get_visible_rules().size() != 8:
		_fail("day three rules did not unlock")
		return
	main.anomaly_content_runtime.force_event("room_109_open_door")
	main._on_content_anomaly_state_changed()
	if _find_dynamic_or_editor_hotspot(main, "room_109_open_door").is_empty():
		_fail("forced Room 109 entity was not visible on day three")
		return
	if main.room_109_overlay.visible:
		_fail("forced Room 109 rendered both the authored image and procedural door")
		return
	if not main.anomaly_presentation_layer.is_rendering_artifact():
		_fail("forced Room 109 authored open-door image was not rendered")
		return

	var glass_preview_index := _find_anomaly_preview_index(main, "front_glass_face")
	if glass_preview_index < 0:
		_fail("front glass face was missing from the debug selector")
		return
	main._on_debug_anomaly_selected(glass_preview_index)
	await process_frame
	if main.current_scene_id != "front_desk" or main.anomaly_content_runtime.current_event_id != "front_glass_face":
		_fail("front glass face debug preview did not open at the front desk")
		return
	var desk_bell_hotspot := _find_dynamic_or_editor_hotspot(main, "desk_bell")
	if desk_bell_hotspot.is_empty():
		_fail("front glass face debug preview could not use the real desk bell")
		return
	for _press in 3:
		main._on_hotspot_pressed(desk_bell_hotspot)
	if main.anomaly_content_runtime.current_state != "hostile":
		_fail("first debug bell triple did not reveal the hostile glass face")
		return
	for _press in 3:
		main._on_hotspot_pressed(desk_bell_hotspot)
	if not main.anomaly_content_runtime.current_event_id.is_empty():
		_fail("second debug bell triple did not resolve the glass face")
		return

	var mold_preview_index := _find_anomaly_preview_index(main, main.MOLD_PIG_MASK_EVENT_ID)
	if mold_preview_index < 0:
		_fail("mold pig-mask event was missing from the integrated anomaly preview selector")
		return
	main._on_debug_anomaly_selected(mold_preview_index)
	if main.current_scene_id != "room_105_bathroom_entry":
		_fail("integrated mold preview did not open the Room 105 closet scene")
		return
	if not main.mold_overlay.visible or main.mold_overlay.stack != 6:
		_fail("integrated mold preview did not begin at the fatal sixth mold stack")
		return
	if main.mold_closet_timer == null or main.mold_closet_timer.is_stopped():
		_fail("integrated mold preview did not start the pig-mask threat timer")
		return
	if (
		main.anomaly_presentation_layer._active_event_id != main.MOLD_PIG_MASK_EVENT_ID
		or main.anomaly_presentation_layer._active_state_id != "door_open"
		or not main.anomaly_presentation_layer.is_rendering_artifact()
	):
		_fail("sixth mold stack did not reveal the authored open-closet phase")
		return
	main.mold_closet_timer.start(4.9)
	main._sync_anomaly_visual_overlay()
	if (
		main.anomaly_presentation_layer._active_state_id != "face"
		or not main.anomaly_presentation_layer.is_rendering_artifact()
	):
		_fail("closet threat did not advance to the pig-mask man in the door gap")
		return
	main.mold_closet_timer.start(0.05)
	await create_timer(0.08).timeout
	if not main.jumpscare_controller.active or not main.horror_event_manager.is_jumpscare_active():
		_fail("pig-mask preview timer did not trigger the real fatal jumpscare")
		return
	if (
		main.jumpscare_controller.current_presentation == null
		or String(main.jumpscare_controller.current_presentation.subject.texture.resource_path)
			!= main.HotelHorrorEventManagerScript.HorrorCatalog.PIG_MASK_REFERENCE
	):
		_fail("pig-mask fatal phase did not use the approved reference image")
		return
	main.jumpscare_controller.stop()
	main.horror_event_manager.active_jumpscare_id = ""
	if not main.mold_overlay.visible or main.mold_overlay.stack != 6:
		_fail("mold stack was not preserved for cleanup after preview")
		return
	var remover = _find_inventory_item(main, "mold_remover")
	main.inventory_model.equip_item(remover)
	main.system_message_panel.visible = false
	main._use_equipped_item()
	if main.mold_growth_system.get_mold_stack("room_105") != 4:
		_fail(
			"first mold remover spray did not remove two stacks "
			+ "(stack=%d, equipped=%s, room=%s, overlay=%s, eyes_closed=%s)"
			% [
				main.mold_growth_system.get_mold_stack("room_105"),
				String(main.inventory_model.equipped_item.id) if main.inventory_model.equipped_item != null else "none",
				String(main.horror_event_manager.room_registry.get_room_id(main.current_scene_id)),
				str(main.mold_overlay.visible),
				str(main.eye_close_controller.is_closed()),
			]
		)
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
	await process_frame
	if main.mold_spray_player == null or main.mold_spray_player.stream == null:
		_fail("mold remover spray sound was not prepared")
		return

	main.anomaly_content_runtime.force_event("laundry_baby_face_surfaces")
	main.show_scene("laundry_room", false)
	if not main.anomaly_presentation_layer.is_rendering_artifact() or main.anomaly_presentation_layer.get_child_count() != 1:
		_fail("generated baby-face wallpaper was not rendered in the laundry room")
		return
	var baby_hotspots: Array = main.anomaly_content_runtime.get_dynamic_hotspots("laundry_room")
	main._on_hotspot_pressed(baby_hotspots[0])
	if main.anomaly_presentation_layer.get_child_count() != 2:
		_fail("clicked baby-wallpaper surface did not restore the original room area")
		return
	if main.anomaly_audio_controller._stream_for_cue("baby_short_cry").resource_path != main.anomaly_audio_controller.BABY_WALLPAPER_CRY_PATH:
		_fail("baby-wallpaper interaction did not use the recorded cry")
		return

	var shadow_cues: Array[String] = []
	main.anomaly_content_runtime.sound_requested.connect(func(cue_id: String): shadow_cues.append(cue_id))
	main.anomaly_content_runtime.force_event("hotel_following_shadow")
	main._play_transition_footsteps()
	if main.anomaly_content_runtime._shadow_echo_queue.size() != 1:
		_fail("one shadow movement preview did not queue exactly one repeated footstep sequence")
		return
	main.anomaly_content_runtime.advance(main.anomaly_content_runtime.SHADOW_ECHO_DELAY_SECONDS + 0.01)
	if shadow_cues.count("footstep_echo") != 1:
		_fail("shadow movement preview did not replay the footstep sequence")
		return
	main.footstep_timer.stop()
	for player in main.footstep_players:
		player.stop()
	main.show_scene("front_desk", false)
	var desk_bell: Dictionary = _find_dynamic_or_editor_hotspot(main, "desk_bell")
	for _index in main.anomaly_content_runtime.SHADOW_BELL_PRESS_TARGET:
		main._on_hotspot_pressed(desk_bell)
	if main.anomaly_content_runtime.current_state != "bell_distressed":
		_fail("rapid front-desk bell presses did not distress the following shadow")
		return
	if not main.anomaly_audio_controller.is_shadow_heartbeat_active():
		_fail("shadow distress did not start the player heartbeat")
		return
	main.anomaly_visual_overlay._process(0.08)
	if main.anomaly_visual_overlay.get_shadow_flicker_alpha() <= 0.0:
		_fail("shadow distress did not start screen flicker")
		return
	main.show_scene("corridor", false)
	main.show_scene("room_105_door_window", false)
	main.show_scene("corridor", false)
	main.show_scene("room_105_door_window", false)
	main.show_scene("corridor", false)
	if not main.anomaly_content_runtime.current_event_id.is_empty():
		_fail("fast repeated room transitions did not resolve the following shadow")
		return
	if main.anomaly_audio_controller.is_shadow_heartbeat_active():
		_fail("shadow heartbeat continued after the shadow disappeared")
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
	_finish_story(main)
	main._hide_menu()
	main.night_anomaly_director.force_blanket_child("room_108_bed_window")
	main.show_scene("room_108_bed_window", false)
	if not main.anomaly_presentation_layer.is_rendering_artifact():
		_fail("blanket-child MVP image was not rendered")
		return
	main.eye_close_controller.close_eyes()
	main.night_anomaly_director.advance(main.night_anomaly_director.blanket_eye_close_duration)
	main.eye_close_controller.open_eyes()
	if main.night_anomaly_director.blanket_state != main.night_anomaly_director.BLANKET_RESOLVED:
		_fail(
			"blanket child did not resolve after the closed-eye hold "
			+ "(state=%s, external=%s, content=%s, mold=%d)"
			% [
				main.night_anomaly_director.blanket_state,
				str(main.night_anomaly_director.external_anomaly_active),
				main.anomaly_content_runtime.current_event_id,
				main.mold_growth_system.get_mold_stack("room_105"),
			]
		)
		return
	main.show_scene("front_desk", false)
	main.night_anomaly_director.force_phone_ring()
	main._on_hotspot_pressed(_find_dynamic_or_editor_hotspot(main, "phone"))
	if not main.night_anomaly_director.room_108_forbidden:
		_fail("answered Room 108 repair call did not block Room 108")
		return

	main._start_day(5, false, false)
	await process_frame
	_finish_story(main)
	main._hide_menu()
	main.show_scene("laundry_room", false)
	main.night_anomaly_director.force_red_laundry()
	if not main.anomaly_presentation_layer.is_rendering_artifact():
		_fail("red washer MVP image was not rendered")
		return
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
	_finish_story(main)
	main._hide_menu()
	main.show_scene("room_106_bathroom", false)
	main.night_anomaly_director.force_child_encounter()
	if not main.anomaly_presentation_layer.is_rendering_artifact():
		_fail("fake-mother MVP image was not rendered")
		return
	if not main.scene_3d_overlay.visible or main.scene_3d_overlay.get_model_count() != 1:
		_fail("registered child 3D model was not layered over the fake mother")
		return
	main.eye_close_controller.close_eyes()
	if main.eye_close_controller.is_song_active():
		_fail("closing eyes started the child song without holding F")
		return
	if not main.night_anomaly_director.begin_hand_action() or not main.eye_close_controller.is_song_active():
		_fail("holding F with closed eyes did not start the child song")
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

	main.anomaly_content_runtime.force_event("room_108_tv_ghost")
	main.show_scene("room_105_bathroom_entry", false)
	var tv_hotspots: Array = main.anomaly_content_runtime.get_dynamic_hotspots("room_105_bathroom_entry")
	if tv_hotspots.size() != 1 or not main.anomaly_presentation_layer.is_rendering_artifact():
		_fail("TV ghost MVP encounter did not render with its hold hotspot")
		return
	main._on_anomaly_hotspot_button_down(tv_hotspots[0])
	main.anomaly_content_runtime.advance(2.0)
	if main.anomaly_content_runtime.current_state != "hostile":
		_fail("TV ghost did not switch to its hostile image during the hold")
		return
	main.anomaly_content_runtime.advance(2.0)
	if not main.anomaly_content_runtime.current_event_id.is_empty():
		_fail("TV ghost hold did not resolve")
		return

	main._start_day(7, false, false)
	await process_frame
	_finish_story(main)
	if not _latest_rule_page_is_open(main, 7, 3):
		_fail("day seven did not automatically open its three new rules")
		return
	main._hide_menu()
	main.show_scene("corridor", false)
	if main.night_anomaly_director.room_109_passage_state != main.night_anomaly_director.ROOM_109_PASSAGE_WAITING:
		_fail("day seven Room 109 passage did not start on corridor entry")
		return
	main.night_anomaly_director.advance(main.night_anomaly_director.room_109_passage_wait_seconds)
	main.night_anomaly_director.advance(main.night_anomaly_director.room_109_passage_footstep_seconds)
	if not main.night_anomaly_director.is_daily_schedule_complete():
		_fail("day seven Room 109 passage did not complete after the footsteps")
		return

	main.inventory_model.add_item_by_id("hell_mirror")
	main.inventory_model.equip_item_by_id("hell_mirror")
	main.show_scene("laundry_room", false)
	main.system_message_panel.visible = false
	if not main._try_dispose_equipped_hell_mirror("laundry_second_washer"):
		_fail("hell mirror could not be destroyed in the second washer")
		return
	if main.inventory_model.has_item_id("hell_mirror") or main.system_message_panel.visible:
		_fail("washer disposal kept the mirror or opened an explanatory popup")
		return
	main.inventory_model.add_item_by_id("hell_mirror")
	if not main._must_die_from_hell_mirror_at_shift_end():
		_fail("keeping the hell mirror until shift end was not lethal")
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


func _finish_story(main) -> void:
	while main.is_intro_dialogue_active():
		main._advance_intro_dialogue()


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


func _find_anomaly_preview_index(main, event_id: String) -> int:
	for index in main.debug_anomaly_selector.item_count:
		var metadata = main.debug_anomaly_selector.get_item_metadata(index)
		if metadata != null and String(metadata) == event_id:
			return index
	return -1


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
