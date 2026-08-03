extends GdUnitTestSuite

const ContentRuntime := preload("res://scripts/horror/anomaly_content_runtime.gd")
const ContentCatalog := preload("res://scripts/horror/anomaly_content_catalog.gd")
const AnomalyRegistry := preload("res://scripts/horror/anomaly_registry.gd")
const InventoryModel := preload("res://scripts/items/inventory_model.gd")
const ItemCatalog := preload("res://scripts/items/item_catalog.gd")
const GameMode := preload("res://scripts/systems/game_mode.gd")


func test_runtime_has_no_generic_action_explanation_popup_channel() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)

	assert_bool(runtime.has_signal("narrative_requested")).is_false()


func test_start_day_clears_external_anomaly_lock() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	runtime.set_external_anomaly_active(true)

	runtime.start_day(4)

	assert_bool(runtime.external_anomaly_active).is_false()


func test_scheduled_event_waits_until_player_leaves_its_scene() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	runtime.start_day(5)
	runtime.enter_scene("room_108_bathroom")

	runtime.advance(runtime.SPAWN_DELAY_SECONDS + 0.01)

	assert_str(runtime.current_event_id).is_empty()
	assert_int(runtime.scheduler.pending_anomaly_queue.size()).is_equal(1)

	runtime.enter_scene("corridor")

	assert_str(runtime.current_event_id).is_equal("room_108_entrails_bathtub")
	assert_int(runtime.scheduler.pending_anomaly_queue.size()).is_equal(0)


func test_scheduled_event_keeps_waiting_for_external_anomaly_after_scene_exit() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	runtime.start_day(5)
	runtime.enter_scene("room_108_bathroom")
	runtime.advance(runtime.SPAWN_DELAY_SECONDS + 0.01)
	runtime.set_external_anomaly_active(true)

	runtime.enter_scene("corridor")

	assert_str(runtime.current_event_id).is_empty()
	assert_int(runtime.scheduler.pending_anomaly_queue.size()).is_equal(1)

	runtime.set_external_anomaly_active(false)
	runtime.advance(0.01)

	assert_str(runtime.current_event_id).is_equal("room_108_entrails_bathtub")


func test_random_shower_target_is_fixed_before_offscreen_activation() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	runtime.start_day(1)
	runtime._planned_event_id = "bathroom_shower_legs"
	runtime._current_scene_override = "room_106_bathroom"
	runtime.enter_scene("room_106_bathroom")

	runtime.advance(runtime.SPAWN_DELAY_SECONDS + 0.01)

	assert_str(runtime.current_event_id).is_empty()
	assert_str(runtime._current_scene_override).is_equal("room_106_bathroom")
	runtime.enter_scene("front_desk")
	assert_str(runtime.current_event_id).is_equal("bathroom_shower_legs")
	assert_str(runtime.get_active_scene_id()).is_equal("room_106_bathroom")


func test_generic_hold_resolves_only_after_full_duration() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	assert_bool(runtime.force_event("front_monitor_ghost")).is_true()
	var hotspot: Dictionary = runtime.get_dynamic_hotspots("front_desk")[0]

	assert_bool(runtime.begin_pointer_hold(String(hotspot["id"]), "", Vector2.ZERO)).is_true()
	runtime.advance(1.0)
	assert_str(runtime.current_event_id).is_equal("front_monitor_ghost")
	runtime.advance(2.0)

	assert_str(runtime.current_event_id).is_empty()


func test_item_hold_silently_rejects_wrong_item_and_accepts_required_item() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	runtime.force_event("corridor_blood_puddle")
	var hotspot: Dictionary = runtime.get_dynamic_hotspots("corridor")[0]

	assert_bool(runtime.begin_item_hold(String(hotspot["id"]), "small_flashlight", Vector2.ZERO)).is_false()
	assert_bool(runtime.begin_item_hold(String(hotspot["id"]), "cleaning_cloth", Vector2.ZERO)).is_true()


func test_glass_face_requires_two_fast_triples() -> void:
	var runtime = auto_free(ContentRuntime.new())
	var cues: Array[String] = []
	runtime.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	add_child(runtime)
	runtime.force_event("front_glass_face")
	assert_array(runtime.get_dynamic_hotspots("front_desk")).is_empty()

	for _index in 3:
		assert_bool(runtime.handle_world_hotspot("desk_bell", "front_desk")).is_true()
	assert_str(runtime.current_state).is_equal("hostile")
	assert_int(cues.count("glass_face_barn_owl_call")).is_equal(1)
	for _index in 3:
		runtime.handle_world_hotspot("desk_bell", "front_desk")

	assert_str(runtime.current_event_id).is_empty()
	assert_bool(runtime.handle_world_hotspot("desk_bell", "front_desk")).is_false()
	assert_int(cues.count("glass_face_barn_owl_call")).is_equal(1)


func test_glass_face_calls_when_player_enters_front_desk() -> void:
	var runtime = auto_free(ContentRuntime.new())
	var cues: Array[String] = []
	runtime.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	add_child(runtime)
	runtime.force_event("front_glass_face")

	runtime.enter_scene("corridor")
	assert_int(cues.count("glass_face_barn_owl_call")).is_equal(0)
	runtime.enter_scene("front_desk")
	assert_int(cues.count("glass_face_barn_owl_call")).is_equal(1)
	runtime.enter_scene("front_desk")
	assert_int(cues.count("glass_face_barn_owl_call")).is_equal(1)
	runtime.enter_scene("corridor")
	runtime.enter_scene("front_desk")
	assert_int(cues.count("glass_face_barn_owl_call")).is_equal(2)


func test_phenomenon_remains_visible_until_resolution_transition_reaches_black() -> void:
	var runtime = auto_free(ContentRuntime.new())
	var transition_requests: Array[String] = []
	runtime.phenomenon_resolution_transition_requested.connect(
		func(event_id: String): transition_requests.append(event_id)
	)
	add_child(runtime)
	runtime.set_resolution_transition_enabled(true)
	runtime.force_event("front_glass_face")

	for _index in 6:
		runtime.handle_world_hotspot("desk_bell", "front_desk")

	assert_bool(runtime.is_resolution_pending()).is_true()
	assert_str(runtime.current_event_id).is_equal("front_glass_face")
	assert_str(runtime.current_state).is_equal("hostile")
	assert_array(transition_requests).contains_exactly(["front_glass_face"])

	runtime.complete_pending_phenomenon_resolution()

	assert_bool(runtime.is_resolution_pending()).is_false()
	assert_str(runtime.current_event_id).is_empty()


func test_entity_resolution_does_not_use_phenomenon_fade() -> void:
	var runtime = auto_free(ContentRuntime.new())
	var transition_requests: Array[String] = []
	runtime.phenomenon_resolution_transition_requested.connect(
		func(event_id: String): transition_requests.append(event_id)
	)
	add_child(runtime)
	runtime.set_resolution_transition_enabled(true)
	runtime.force_event(runtime.SHADOW_EVENT_ID)

	runtime._resolve_current()

	assert_str(runtime.current_event_id).is_empty()
	assert_array(transition_requests).is_empty()


func test_baby_wallpaper_closes_five_large_surfaces() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	runtime.force_event("laundry_baby_face_surfaces")

	for hotspot in runtime.get_dynamic_hotspots("laundry_room"):
		runtime.handle_click(String(hotspot["id"]))

	assert_str(runtime.current_event_id).is_empty()


func test_shower_legs_resolve_between_third_and_fifth_opening() -> void:
	var runtime = auto_free(ContentRuntime.new())
	var cues: Array[String] = []
	runtime.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	add_child(runtime)
	runtime.start_day(4)
	runtime.force_event("bathroom_shower_legs")
	var scene_id: String = runtime.get_active_scene_id()
	var required_openings: int = runtime._curtain_target_count
	assert_int(required_openings).is_between(3, 5)

	for opening_index in required_openings:
		if opening_index > 0:
			runtime.handle_curtain_toggled(scene_id, true)
		runtime.handle_curtain_toggled(scene_id, false)

	assert_str(runtime.current_event_id).is_empty()
	assert_int(cues.count("curtain_legs_reveal")).is_equal(1)


func test_shower_room_is_randomized_once_and_persists_through_save() -> void:
	var selected_rooms: Dictionary = {}
	for seed in range(12):
		var runtime = auto_free(ContentRuntime.new())
		add_child(runtime)
		runtime.set_random_seed(seed)
		runtime.start_day(4)
		runtime.force_event("bathroom_shower_legs")
		var scene_id: String = runtime.get_active_scene_id()
		assert_array(AnomalyRegistry.get_candidate_scene_ids("bathroom_shower_legs")).contains([scene_id])
		selected_rooms[scene_id] = true

		var restored = auto_free(ContentRuntime.new())
		add_child(restored)
		restored.import_state(runtime.export_state())
		assert_str(restored.get_active_scene_id()).is_equal(scene_id)

	assert_int(selected_rooms.size()).is_greater(1)


func test_empty_shower_curtain_resolves_on_first_opening() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	runtime.force_event("bathroom_shower_legs")
	var scene_id: String = runtime.get_active_scene_id()
	runtime._curtain_has_legs = false

	assert_bool(runtime.handle_curtain_toggled(scene_id, false)).is_true()
	assert_str(runtime.current_event_id).is_empty()


func test_horrific_mirror_moves_into_small_mirror_and_auto_equips() -> void:
	var inventory := InventoryModel.new()
	var dialogue_requests: Array[Array] = []
	ItemCatalog.register_defaults(inventory)
	inventory.add_item_by_id("small_mirror")
	inventory.equip_item_by_id("small_mirror")
	var runtime = auto_free(ContentRuntime.new())
	runtime.dialogue_requested.connect(
		func(message_key: String, fallback_message: String) -> void:
			dialogue_requests.append([message_key, fallback_message])
	)
	add_child(runtime)
	runtime.setup(inventory, null)
	runtime.force_event("room_106_horrific_mirror")
	var hotspot: Dictionary = runtime.get_dynamic_hotspots("room_106_bathroom")[0]

	runtime.begin_item_hold(String(hotspot["id"]), "small_mirror", Vector2.ZERO)
	runtime.advance(4.0)

	assert_bool(inventory.has_item_id("small_mirror")).is_false()
	assert_bool(inventory.has_item_id("hell_mirror")).is_true()
	assert_str(String(inventory.equipped_item.id)).is_equal("hell_mirror")
	assert_array(dialogue_requests).has_size(1)
	assert_str(String(dialogue_requests[0][0])).is_equal("horror.room_106_horrific_mirror.transferred")


func test_tv_changes_to_hostile_state_during_hold_then_resolves() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	runtime.force_event("room_108_tv_ghost")
	var hotspot: Dictionary = runtime.get_dynamic_hotspots("room_105_bathroom_entry")[0]

	runtime.begin_pointer_hold(String(hotspot["id"]), "", Vector2.ZERO)
	runtime.advance(2.0)
	assert_str(runtime.current_state).is_equal("hostile")
	runtime.advance(2.0)

	assert_str(runtime.current_event_id).is_empty()


func test_shadow_repeats_every_movement_footstep() -> void:
	var runtime = auto_free(ContentRuntime.new())
	var cues: Array[String] = []
	runtime.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	add_child(runtime)
	runtime.force_event("hotel_following_shadow")

	runtime.notify_player_action("footstep")
	runtime.advance(runtime.SHADOW_ECHO_DELAY_SECONDS - 0.01)
	assert_array(cues).is_empty()
	runtime.advance(0.02)

	assert_array(cues).contains_exactly(["footstep_echo"])


func test_shadow_is_a_day_three_production_event_with_escape_treatment() -> void:
	var definition: Dictionary = ContentCatalog.build_definitions()["hotel_following_shadow"]

	assert_int(int(definition["min_day"])).is_equal(3)
	assert_str(String(definition["treatment"])).is_equal(ContentCatalog.TREATMENT_SHADOW_ESCAPE)
	assert_array(ContentCatalog.production_event_ids()).contains(["hotel_following_shadow"])


func test_shadow_copies_each_front_desk_bell_after_the_fixed_delay() -> void:
	var runtime = auto_free(ContentRuntime.new())
	var cues: Array[String] = []
	runtime.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	add_child(runtime)
	runtime.enter_scene("front_desk")
	runtime.force_event(runtime.SHADOW_EVENT_ID)

	assert_bool(runtime.handle_world_hotspot("desk_bell", "front_desk")).is_true()
	assert_array(cues).contains_exactly(["desk_bell"])
	runtime.advance(runtime.SHADOW_ECHO_DELAY_SECONDS + 0.01)

	assert_array(cues).contains_exactly(["desk_bell", "desk_bell_echo"])


func test_shadow_fast_bell_sequence_triggers_scream_and_distress_state() -> void:
	var runtime = auto_free(ContentRuntime.new())
	var cues: Array[String] = []
	runtime.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	add_child(runtime)
	runtime.enter_scene("front_desk")
	runtime.force_event(runtime.SHADOW_EVENT_ID)

	for _index in runtime.SHADOW_BELL_PRESS_TARGET:
		runtime.handle_world_hotspot("desk_bell", "front_desk")

	assert_str(runtime.current_state).is_equal("bell_distressed")
	assert_int(cues.count("desk_bell")).is_equal(runtime.SHADOW_BELL_PRESS_TARGET)
	assert_int(cues.count("shadow_scream")).is_equal(1)


func test_shadow_slow_bell_presses_do_not_trigger_distress() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	runtime.enter_scene("front_desk")
	runtime.force_event(runtime.SHADOW_EVENT_ID)

	for _index in runtime.SHADOW_BELL_PRESS_TARGET:
		runtime.handle_world_hotspot("desk_bell", "front_desk")
		runtime.advance(runtime.SHADOW_BELL_SEQUENCE_WINDOW_SECONDS + 0.01)

	assert_str(runtime.current_state).is_equal("attached")


func test_shadow_resolves_after_fast_room_boundary_repetitions() -> void:
	var runtime = auto_free(ContentRuntime.new())
	var cues: Array[String] = []
	runtime.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	add_child(runtime)
	runtime.enter_scene("front_desk")
	runtime.force_event(runtime.SHADOW_EVENT_ID)
	for _index in runtime.SHADOW_BELL_PRESS_TARGET:
		runtime.handle_world_hotspot("desk_bell", "front_desk")

	runtime.enter_scene("corridor")
	runtime.enter_scene("room_105_door_window")
	runtime.advance(0.1)
	runtime.enter_scene("corridor")
	runtime.advance(0.1)
	runtime.enter_scene("room_105_door_window")
	runtime.advance(0.1)
	runtime.enter_scene("corridor")

	assert_str(runtime.current_event_id).is_empty()
	assert_int(cues.count("shadow_scream")).is_equal(2)


func test_shadow_room_repetition_expires_when_player_moves_too_slowly() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	runtime.enter_scene("front_desk")
	runtime.force_event(runtime.SHADOW_EVENT_ID)
	for _index in runtime.SHADOW_BELL_PRESS_TARGET:
		runtime.handle_world_hotspot("desk_bell", "front_desk")

	runtime.enter_scene("corridor")
	runtime.enter_scene("room_105_door_window")
	runtime.advance(runtime.SHADOW_ROOM_TRANSITION_WINDOW_SECONDS + 0.01)
	runtime.enter_scene("corridor")
	runtime.enter_scene("room_105_door_window")
	runtime.enter_scene("corridor")

	assert_str(runtime.current_event_id).is_equal(runtime.SHADOW_EVENT_ID)
	assert_int(runtime._shadow_room_transition_count).is_equal(3)


func test_shadow_distress_and_escape_progress_survive_save_restore() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	runtime.enter_scene("front_desk")
	runtime.force_event(runtime.SHADOW_EVENT_ID)
	for _index in runtime.SHADOW_BELL_PRESS_TARGET:
		runtime.handle_world_hotspot("desk_bell", "front_desk")
	runtime.enter_scene("corridor")
	runtime.enter_scene("room_105_door_window")
	var state: Dictionary = runtime.export_state()

	var restored = auto_free(ContentRuntime.new())
	add_child(restored)
	restored.import_state(state)

	assert_str(restored.current_state).is_equal("bell_distressed")
	assert_str(restored.current_scene_id).is_equal("room_105_door_window")
	assert_int(restored._shadow_room_transition_count).is_equal(1)
	assert_float(restored._shadow_room_transition_seconds).is_greater(0.0)


func test_entrails_bathtub_uses_replaceable_mvp_hold_treatment() -> void:
	var runtime = auto_free(ContentRuntime.new())
	var cues: Array[String] = []
	runtime.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	add_child(runtime)
	runtime.force_event("room_108_entrails_bathtub")
	var hotspots: Array = runtime.get_dynamic_hotspots("room_108_bathroom")
	assert_array(hotspots).has_size(1)

	assert_bool(runtime.begin_pointer_hold(String(hotspots[0]["id"]), "", Vector2.ZERO)).is_true()
	runtime.advance(4.3)

	assert_str(runtime.current_event_id).is_empty()
	assert_array(cues).contains_exactly(["bathtub_drain"])


func test_hanging_girl_doll_unlocks_only_survival_choice_and_is_consumed() -> void:
	var inventory := InventoryModel.new()
	ItemCatalog.register_defaults(inventory)
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	runtime.setup(inventory, null)
	runtime.force_event(ContentRuntime.HANGING_GIRL_EVENT_ID)

	var doll_hotspots: Array = runtime.get_dynamic_hotspots("laundry_room")
	assert_array(doll_hotspots).has_size(1)
	assert_bool(runtime.handle_click(String(doll_hotspots[0]["id"]))).is_true()
	assert_bool(inventory.has_item_id(ContentRuntime.HANGING_GIRL_DOLL_ITEM_ID)).is_true()
	var cute_doll = inventory.find_item_by_id(ContentRuntime.HANGING_GIRL_DOLL_ITEM_ID)
	assert_bool(cute_doll.can_equip).is_true()
	assert_bool(inventory.equip_item(cute_doll)).is_true()
	assert_object(inventory.equipped_item).is_same(cute_doll)
	# Offering Walter is inventory-gated, not equipment-gated.
	inventory.clear_equipped_item()
	assert_object(inventory.equipped_item).is_null()

	runtime.enter_scene("room_107_bed_nightstand")
	var girl_hotspot: Dictionary = runtime.get_dynamic_hotspots("room_107_bed_nightstand")[0]
	var girl_rect: Rect2 = girl_hotspot["rect"]
	assert_bool(girl_rect.has_point(Vector2(0.70, 0.40))).is_true()
	assert_bool(girl_rect.has_point(Vector2(0.45, 0.40))).is_false()
	runtime.handle_click(String(girl_hotspot["id"]))
	assert_bool(runtime.handle_choice("entry_talk")).is_true()
	assert_bool(runtime.handle_choice("fun_no")).is_true()
	assert_bool(runtime.handle_choice("walter")).is_true()
	assert_bool(runtime.handle_choice("doll_friend")).is_true()

	assert_str(runtime.current_event_id).is_empty()
	assert_bool(inventory.has_item_id(ContentRuntime.HANGING_GIRL_DOLL_ITEM_ID)).is_false()
	assert_bool(runtime.has_lingering_hanging_girl("room_107_bed_nightstand")).is_true()
	assert_str(String(runtime.get_lingering_hanging_girl_presentation_state()["event_id"])).is_equal(
		ContentRuntime.HANGING_GIRL_EVENT_ID
	)

	var restored = auto_free(ContentRuntime.new())
	add_child(restored)
	restored.import_state(runtime.export_state())
	assert_bool(restored.has_lingering_hanging_girl("room_107_bed_nightstand")).is_true()
	restored.start_day(2)
	assert_bool(restored.has_lingering_hanging_girl("room_107_bed_nightstand")).is_false()

	# Replaying the preview must bypass the previous completion cooldown and
	# create a fresh companion pickup.
	assert_bool(runtime.force_event(ContentRuntime.HANGING_GIRL_EVENT_ID)).is_true()
	assert_str(runtime.current_event_id).is_equal(ContentRuntime.HANGING_GIRL_EVENT_ID)
	assert_array(runtime.get_dynamic_hotspots("laundry_room")).has_size(1)


func test_hanging_girl_hides_walter_without_doll_and_restores_selected_markers() -> void:
	var inventory := InventoryModel.new()
	ItemCatalog.register_defaults(inventory)
	var runtime = auto_free(ContentRuntime.new())
	var latest_choices: Array = []
	runtime.choice_requested.connect(func(_key: String, _fallback: String, choices: Array):
		latest_choices.clear()
		latest_choices.append_array(choices)
	)
	add_child(runtime)
	runtime.setup(inventory, null)
	runtime.force_event(ContentRuntime.HANGING_GIRL_EVENT_ID)
	runtime.enter_scene("room_107_bed_nightstand")
	runtime.handle_click("anomaly_choice:hanging_girl")
	runtime.handle_choice("entry_talk")
	runtime.handle_choice("fun_no")

	var angry_choice_ids := latest_choices.map(func(choice): return String(choice.get("id", "")))
	assert_array(angry_choice_ids).not_contains("walter")

	var saved_state: Dictionary = runtime.export_state()
	var restored = auto_free(ContentRuntime.new())
	var restored_choices: Array = []
	restored.choice_requested.connect(func(_key: String, _fallback: String, choices: Array):
		restored_choices.clear()
		restored_choices.append_array(choices)
	)
	add_child(restored)
	restored.setup(inventory, null)
	restored.import_state(saved_state)
	restored.handle_click("anomaly_choice:hanging_girl")

	var entry_talk: Dictionary = restored_choices.filter(
		func(choice): return String(choice.get("id", "")) == "entry_talk"
	)[0]
	assert_bool(bool(entry_talk.get("selected", false))).is_true()
	restored.handle_choice("entry_talk")
	var fun_no: Dictionary = restored_choices.filter(
		func(choice): return String(choice.get("id", "")) == "fun_no"
	)[0]
	assert_bool(bool(fun_no.get("selected", false))).is_true()


func test_hanging_girl_ignore_defers_dialogue_and_wrong_choice_runs_fatal_text() -> void:
	var runtime = auto_free(ContentRuntime.new())
	var fatal_lines: Array = []
	var deaths: Array[String] = []
	runtime.fatal_narrative_requested.connect(func(lines: Array): fatal_lines.append_array(lines))
	runtime.death_requested.connect(func(event_id: String): deaths.append(event_id))
	add_child(runtime)
	runtime.force_event(ContentRuntime.HANGING_GIRL_EVENT_ID)
	runtime.enter_scene("room_107_bed_nightstand")
	var girl_hotspot: Dictionary = runtime.get_dynamic_hotspots("room_107_bed_nightstand")[0]

	runtime.handle_click(String(girl_hotspot["id"]))
	assert_bool(runtime.handle_choice("entry_ignore")).is_true()
	assert_bool(runtime._hanging_girl_dialogue_open).is_false()

	runtime.handle_click(String(girl_hotspot["id"]))
	runtime.handle_choice("entry_talk")
	runtime.handle_choice("fun_yes")
	assert_array(fatal_lines).has_size(6)
	assert_array(deaths).is_empty()

	runtime.finish_fatal_narrative()
	assert_array(deaths).contains_exactly([ContentRuntime.HANGING_GIRL_EVENT_ID])


func test_hanging_girl_ignore_resumes_timer_and_eventually_kills() -> void:
	var runtime = auto_free(ContentRuntime.new())
	var deaths: Array[String] = []
	runtime.death_requested.connect(func(event_id: String): deaths.append(event_id))
	add_child(runtime)
	runtime.force_event(ContentRuntime.HANGING_GIRL_EVENT_ID)
	runtime.enter_scene("room_107_bed_nightstand")
	runtime.handle_click("anomaly_choice:hanging_girl")
	runtime.handle_choice("entry_ignore")

	runtime.advance(48.1)

	assert_array(deaths).contains_exactly([ContentRuntime.HANGING_GIRL_EVENT_ID])


func test_every_authored_hanging_girl_wrong_answer_starts_the_same_six_line_death() -> void:
	var wrong_paths := [
		["entry_talk", "fun_yes"],
		["entry_talk", "fun_no", "changed_mind"],
		["entry_talk", "fun_no", "you_play"],
		["entry_talk", "fun_no", "better_game", "doll_play"],
		["entry_talk", "fun_no", "better_game", "hide_and_seek"],
		["entry_talk", "fun_no", "better_game", "your_mom_game"],
		["entry_talk", "fun_no", "walter", "your_mom_walter"],
	]
	for path in wrong_paths:
		var inventory := InventoryModel.new()
		ItemCatalog.register_defaults(inventory)
		if path.has("walter"):
			inventory.add_item_by_id(ContentRuntime.HANGING_GIRL_DOLL_ITEM_ID)
		var runtime = auto_free(ContentRuntime.new())
		var fatal_lines: Array = []
		runtime.fatal_narrative_requested.connect(
			func(lines: Array): fatal_lines.append_array(lines)
		)
		add_child(runtime)
		runtime.setup(inventory, null)
		runtime.force_event(ContentRuntime.HANGING_GIRL_EVENT_ID)
		runtime.enter_scene("room_107_bed_nightstand")
		runtime.handle_click("anomaly_choice:hanging_girl")
		for choice_id in path:
			assert_bool(runtime.handle_choice(String(choice_id))).is_true()
		assert_array(fatal_lines).has_size(6)
		assert_bool(runtime._hanging_girl_fatal_pending).is_true()


func test_hanging_girl_uses_laughter_as_late_timer_warning() -> void:
	var runtime = auto_free(ContentRuntime.new())
	var cues: Array[String] = []
	runtime.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	add_child(runtime)
	runtime.force_event(ContentRuntime.HANGING_GIRL_EVENT_ID)
	runtime.enter_scene("room_107_bed_nightstand")

	runtime.advance(31.0)

	assert_int(cues.count("girl_visit_laugh")).is_greater_equal(2)


func test_story_schedule_uses_the_same_authored_event_for_every_seed() -> void:
	var expected := {
		1: "",
		2: "corridor_red_room_light",
		3: ContentRuntime.HANGING_GIRL_EVENT_ID,
		4: ContentRuntime.SHADOW_EVENT_ID,
		5: "room_108_entrails_bathtub",
		6: "room_106_horrific_mirror",
		7: "",
	}
	for day in expected:
		for seed in range(4):
			var runtime = auto_free(ContentRuntime.new())
			add_child(runtime)
			runtime.set_random_seed(seed)
			runtime.start_day(day)
			assert_str(runtime.get_planned_event_id()).is_equal(expected[day])
			assert_bool(runtime.is_daily_schedule_complete()).is_equal(String(expected[day]).is_empty())


func test_infinity_schedule_spawns_only_one_random_full_pool_event() -> void:
	var selected: Dictionary = {}
	for seed in range(20):
		var runtime = auto_free(ContentRuntime.new())
		add_child(runtime)
		runtime.set_game_mode(GameMode.INFINITY)
		runtime.set_random_seed(seed)
		runtime.start_day(1)
		assert_array(ContentCatalog.production_event_ids()).contains([runtime.get_planned_event_id()])
		runtime.advance(runtime.SPAWN_DELAY_SECONDS + 0.01)
		var event_id: String = runtime.current_event_id
		assert_bool(event_id.is_empty()).is_false()
		selected[event_id] = true
		runtime._resolve_current()
		runtime.advance(runtime.SPAWN_DELAY_SECONDS * 2.0)
		assert_str(runtime.current_event_id).is_empty()
		assert_bool(runtime.is_daily_schedule_complete()).is_true()

	assert_int(selected.size()).is_greater(1)


func test_infinity_mode_and_random_plan_survive_save_restore() -> void:
	var runtime = auto_free(ContentRuntime.new())
	add_child(runtime)
	runtime.set_game_mode(GameMode.INFINITY)
	runtime.set_random_seed(17)
	runtime.start_day(12)
	var planned_event_id: String = runtime.get_planned_event_id()

	var restored = auto_free(ContentRuntime.new())
	add_child(restored)
	restored.import_state(runtime.export_state())

	assert_str(restored.game_mode).is_equal(GameMode.INFINITY)
	assert_int(restored.current_day).is_equal(12)
	assert_str(restored.get_planned_event_id()).is_equal(planned_event_id)
