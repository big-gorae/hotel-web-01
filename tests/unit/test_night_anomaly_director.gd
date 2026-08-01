extends GdUnitTestSuite

const NightAnomalyDirector := preload("res://scripts/horror/night_anomaly_director.gd")
const EyeCloseController := preload("res://scripts/systems/eye_close_controller.gd")
const InventoryModel := preload("res://scripts/items/inventory_model.gd")
const ItemCatalog := preload("res://scripts/items/item_catalog.gd")
const GameMode := preload("res://scripts/systems/game_mode.gd")


func test_start_day_clears_external_anomaly_lock() -> void:
	var director = auto_free(NightAnomalyDirector.new())
	director.set_external_anomaly_active(true)

	director.start_day(4)

	assert_bool(director.external_anomaly_active).is_false()


func test_room_108_phone_kills_on_thirteenth_bell_and_blocks_room_after_answer() -> void:
	var director = auto_free(NightAnomalyDirector.new())
	var deaths := []
	director.death_requested.connect(func(event_id: String) -> void: deaths.append(event_id))
	director.start_day(4)
	director.force_phone_ring()
	for _index in range(12):
		director.advance(director.phone_bell_interval)
	assert_that(deaths).is_empty()
	director.advance(director.phone_bell_interval)
	assert_that(deaths).is_empty()
	director.advance(director.phone_death_delay)
	assert_that(deaths).is_equal([NightAnomalyDirector.PHONE_EVENT_ID])

	deaths.clear()
	director.force_phone_ring()
	assert_that(director.handle_hotspot("phone")).is_true()
	assert_that(director.room_108_forbidden).is_true()
	assert_that(director.can_change_scene("room_108_bed_window")).is_false()
	assert_that(deaths).is_equal([NightAnomalyDirector.PHONE_EVENT_ID])


func test_answered_phone_expires_then_completes_the_only_daily_entity() -> void:
	var director = auto_free(NightAnomalyDirector.new())
	var survived: Array[String] = []
	director.event_survived.connect(func(event_id: String): survived.append(event_id))
	director.start_day(4)
	director.force_phone_ring()
	director.handle_hotspot("phone")

	assert_bool(director.has_active_anomaly()).is_true()
	director.advance(director.phone_forbidden_duration)

	assert_bool(director.room_108_forbidden).is_false()
	assert_bool(director.is_daily_schedule_complete()).is_true()
	assert_array(survived).contains_exactly([NightAnomalyDirector.PHONE_EVENT_ID])


func test_each_story_day_plans_its_single_fixed_entity() -> void:
	var expected := {
		2: NightAnomalyDirector.CLOSET_PIG_EVENT_ID,
		4: NightAnomalyDirector.PHONE_EVENT_ID,
		5: NightAnomalyDirector.LAUNDRY_EVENT_ID,
		6: NightAnomalyDirector.CHILD_EVENT_ID,
		7: NightAnomalyDirector.ROOM_109_PASSAGE_EVENT_ID,
	}
	for day in expected:
		var director = auto_free(NightAnomalyDirector.new())
		director.start_day(day)
		assert_str(director.get_planned_event_id()).is_equal(expected[day])
	for day in [1, 3]:
		var director = auto_free(NightAnomalyDirector.new())
		director.start_day(day)
		assert_str(director.get_planned_event_id()).is_empty()
		assert_bool(director.is_daily_schedule_complete()).is_true()


func test_infinity_plans_one_random_reusable_main_event_on_every_night() -> void:
	var pool := [
		NightAnomalyDirector.CLOSET_PIG_EVENT_ID,
		NightAnomalyDirector.PHONE_EVENT_ID,
		NightAnomalyDirector.LAUNDRY_EVENT_ID,
		NightAnomalyDirector.CHILD_EVENT_ID,
		NightAnomalyDirector.BLANKET_CHILD_EVENT_ID,
	]
	var selected: Dictionary = {}
	for seed in range(30):
		var director = auto_free(NightAnomalyDirector.new())
		director.set_game_mode(GameMode.INFINITY)
		director.set_random_seed(seed)
		director.start_day(1)
		var event_id: String = director.get_planned_event_id()
		assert_array(pool).contains([event_id])
		selected[event_id] = true
	assert_int(selected.size()).is_greater(1)


func test_external_closet_pig_completes_the_director_schedule() -> void:
	var director = auto_free(NightAnomalyDirector.new())
	director.start_day(2)

	assert_bool(director.notify_external_planned_event_started(NightAnomalyDirector.CLOSET_PIG_EVENT_ID)).is_true()
	assert_bool(director.is_daily_schedule_complete()).is_false()
	assert_bool(director.notify_external_planned_event_completed(NightAnomalyDirector.CLOSET_PIG_EVENT_ID)).is_true()
	assert_bool(director.is_daily_schedule_complete()).is_true()


func test_room_109_hotspot_only_exists_while_the_passage_event_is_active() -> void:
	var director = auto_free(NightAnomalyDirector.new())
	director.start_day(3)
	assert_that(director.get_dynamic_hotspots("corridor")).is_empty()
	director.room_109_passage_state = NightAnomalyDirector.ROOM_109_PASSAGE_WAITING
	assert_that(director.get_dynamic_hotspots("corridor").size()).is_equal(1)
	assert_that(director.get_dynamic_hotspots("corridor")[0].get("id", "")).is_equal("room_109_open_door")


func test_child_song_only_runs_while_f_is_held_and_silence_counts_toward_death() -> void:
	var eyes = auto_free(EyeCloseController.new())
	var director = auto_free(NightAnomalyDirector.new())
	var deaths := []
	director.death_requested.connect(func(event_id: String) -> void: deaths.append(event_id))
	director.setup(eyes)
	director.start_day(6)
	director.force_child_encounter()

	eyes.close_eyes()
	assert_bool(eyes.is_song_active()).is_false()
	assert_bool(director.begin_hand_action()).is_true()
	assert_that(eyes.is_song_active()).is_true()
	director.release_hand_action()
	assert_bool(eyes.is_song_active()).is_false()
	assert_that(deaths).is_empty()
	director.advance(director.child_response_seconds)
	assert_that(deaths).is_equal([NightAnomalyDirector.CHILD_EVENT_ID])


func test_child_prompt_appears_after_closing_eyes_and_song_completion_resolves_immediately() -> void:
	var eyes = auto_free(EyeCloseController.new())
	var director = auto_free(NightAnomalyDirector.new())
	var messages := []
	var survived := []
	director.dialogue_requested.connect(func(message_key: String) -> void: messages.append(message_key))
	director.event_survived.connect(func(event_id: String) -> void: survived.append(event_id))
	director.setup(eyes)
	director.start_day(6)
	director.force_child_encounter()

	eyes.close_eyes()
	assert_that(messages).is_equal(["night.child.hold_f_to_sing"])
	assert_bool(director.begin_hand_action()).is_true()
	eyes._process(director.child_song_duration)

	assert_bool(eyes.is_closed()).is_false()
	assert_str(director.child_state).is_equal(NightAnomalyDirector.CHILD_RESOLVED)
	assert_bool(director.is_daily_schedule_complete()).is_true()
	assert_that(survived).is_equal([NightAnomalyDirector.CHILD_EVENT_ID])
	assert_that(director.get_dynamic_hotspots("room_106_bathroom")).is_empty()


func test_nonlethal_mode_keeps_anomalies_but_never_requests_death() -> void:
	var eyes = auto_free(EyeCloseController.new())
	var director = auto_free(NightAnomalyDirector.new())
	var deaths := []
	director.death_requested.connect(func(event_id: String) -> void: deaths.append(event_id))
	director.setup(eyes)
	director.set_lethal_outcomes_enabled(false)

	director.start_day(4)
	director.force_phone_ring()
	for _index in range(14):
		director.advance(director.phone_bell_interval)
	assert_that(deaths).is_empty()
	assert_that(director.can_change_scene("room_108_bed_window")).is_true()

	director.start_day(6)
	director.force_child_encounter()
	eyes.close_eyes()
	director.begin_hand_action()
	eyes.open_eyes()
	assert_that(deaths).is_empty()


func test_blanket_child_pauses_danger_while_eyes_are_closed_in_its_room() -> void:
	var eyes = auto_free(EyeCloseController.new())
	var director = auto_free(NightAnomalyDirector.new())
	director.setup(eyes)
	director.set_lethal_outcomes_enabled(false)
	director.start_day(4)
	director.force_blanket_child("room_108_bed_window")
	director.enter_scene("room_108_bed_window")
	assert_str(director.blanket_state).is_equal(NightAnomalyDirector.BLANKET_VISIBLE)

	eyes.close_eyes()
	director.advance(director.blanket_eye_close_duration)

	assert_str(director.blanket_state).is_equal(NightAnomalyDirector.BLANKET_RESOLVED)


func test_blanket_child_plays_found_cue_before_delayed_death() -> void:
	var director = auto_free(NightAnomalyDirector.new())
	var deaths: Array[String] = []
	var cues: Array[String] = []
	director.death_requested.connect(func(event_id: String): deaths.append(event_id))
	director.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	director.start_day(4)
	director.force_blanket_child("room_108_bed_window")
	director.enter_scene("room_108_bed_window")

	director.advance(director.blanket_response_seconds)
	assert_array(cues).contains(["blanket_found_japanese"])
	assert_array(deaths).is_empty()
	director.advance(director.blanket_death_delay)

	assert_array(deaths).contains_exactly([NightAnomalyDirector.BLANKET_CHILD_EVENT_ID])


func test_clicking_blanket_child_only_plays_laughter() -> void:
	var director = auto_free(NightAnomalyDirector.new())
	var deaths: Array[String] = []
	var cues: Array[String] = []
	director.death_requested.connect(func(event_id: String): deaths.append(event_id))
	director.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	director.start_day(4)
	director.force_blanket_child("room_108_bed_window")
	director.enter_scene("room_108_bed_window")

	assert_bool(director.handle_hotspot("blanket_child")).is_true()

	assert_array(cues).contains_exactly(["blanket_laugh_soft"])
	assert_array(deaths).is_empty()
	assert_str(director.blanket_state).is_equal(NightAnomalyDirector.BLANKET_VISIBLE)


func test_red_washer_neglect_timer_starts_only_after_discovery_and_kills_at_thirty_seconds() -> void:
	var director = auto_free(NightAnomalyDirector.new())
	var deaths: Array[String] = []
	director.death_requested.connect(func(event_id: String): deaths.append(event_id))
	director.start_day(5)
	director.enter_scene("laundry_room")

	assert_str(director.laundry_state).is_equal(NightAnomalyDirector.LAUNDRY_RED)
	assert_bool(director.laundry_discovered).is_false()
	director.advance(director.laundry_neglect_duration + 10.0)
	assert_array(deaths).is_empty()
	assert_bool(director.discover_red_laundry()).is_true()
	director.advance(director.laundry_neglect_duration - 0.1)
	assert_array(deaths).is_empty()
	director.advance(0.2)

	assert_array(deaths).contains_exactly([NightAnomalyDirector.LAUNDRY_EVENT_ID])


func test_red_washer_uses_circular_hold_and_resolves_when_closed_eye_music_ends() -> void:
	var eyes = auto_free(EyeCloseController.new())
	var director = auto_free(NightAnomalyDirector.new())
	var deaths: Array[String] = []
	var hold_modes: Array[String] = []
	director.death_requested.connect(func(event_id: String): deaths.append(event_id))
	director.hold_started.connect(func(mode: String, _position: Vector2): hold_modes.append(mode))
	director.setup(eyes)
	director.start_day(5)
	director.enter_scene("laundry_room")

	assert_str(director.laundry_state).is_equal(NightAnomalyDirector.LAUNDRY_RED)
	assert_bool(director.begin_laundry_stop_hold(Vector2(320.0, 180.0))).is_true()
	assert_array(hold_modes).contains_exactly(["circular"])
	director.advance(director.laundry_stop_hold_duration)
	assert_str(director.laundry_state).is_equal(NightAnomalyDirector.LAUNDRY_MUSIC)
	assert_bool(director.handle_hotspot("laundry_second_washer")).is_true()
	assert_array(deaths).is_empty()

	eyes.close_eyes()
	director.advance(director.laundry_music_duration)
	assert_str(director.laundry_state).is_equal(NightAnomalyDirector.LAUNDRY_RESOLVED)
	assert_bool(director.is_laundry_washer_locked_closed()).is_false()
	assert_bool(director.is_daily_schedule_complete()).is_true()
	eyes.open_eyes()
	assert_bool(director.can_change_scene("front_desk")).is_true()
	assert_array(deaths).is_empty()


func test_red_washer_music_requires_closed_eyes_but_reclicking_is_safe() -> void:
	var eyes = auto_free(EyeCloseController.new())
	var director = auto_free(NightAnomalyDirector.new())
	var deaths: Array[String] = []
	director.death_requested.connect(func(event_id: String): deaths.append(event_id))
	director.setup(eyes)
	director.start_day(5)
	director.enter_scene("laundry_room")
	director.begin_laundry_stop_hold(Vector2.ZERO)
	director.advance(director.laundry_stop_hold_duration)

	director.handle_hotspot("laundry_second_washer")
	assert_array(deaths).is_empty()
	director.advance(director.laundry_eye_close_grace_duration)

	assert_array(deaths).contains_exactly([NightAnomalyDirector.LAUNDRY_EVENT_ID])


func test_day_seven_room_109_passage_forbids_turning_until_footsteps_end() -> void:
	var director = auto_free(NightAnomalyDirector.new())
	var deaths: Array[String] = []
	director.death_requested.connect(func(event_id: String): deaths.append(event_id))
	director.start_day(7)
	assert_str(director.get_planned_event_id()).is_equal(NightAnomalyDirector.ROOM_109_PASSAGE_EVENT_ID)
	director.enter_scene("corridor")
	assert_str(director.room_109_passage_state).is_equal(NightAnomalyDirector.ROOM_109_PASSAGE_WAITING)
	assert_bool(director.can_change_scene("front_desk")).is_false()
	assert_array(deaths).contains_exactly([NightAnomalyDirector.ROOM_109_EVENT_ID])
	deaths.clear()
	director.advance(director.room_109_passage_wait_seconds)

	assert_str(director.room_109_passage_state).is_equal(NightAnomalyDirector.ROOM_109_PASSAGE_FOOTSTEPS)
	assert_bool(director.can_change_scene("front_desk")).is_false()
	assert_array(deaths).contains_exactly([NightAnomalyDirector.ROOM_109_EVENT_ID])

	director.set_lethal_outcomes_enabled(false)
	director.advance(director.room_109_passage_footstep_seconds)
	assert_str(director.room_109_passage_state).is_equal(NightAnomalyDirector.ROOM_109_PASSAGE_DONE)
	assert_bool(director.is_daily_schedule_complete()).is_true()


func test_hell_mirror_is_destroyed_only_in_idle_laundry_washer() -> void:
	var inventory := InventoryModel.new()
	ItemCatalog.register_defaults(inventory)
	inventory.add_item_by_id(NightAnomalyDirector.HELL_MIRROR_ITEM_ID)
	var director = auto_free(NightAnomalyDirector.new())
	var cues: Array[String] = []
	director.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	director.start_day(3)

	director.enter_scene("front_desk")
	assert_bool(director.destroy_hell_mirror_in_washer(inventory)).is_false()
	director.enter_scene("laundry_room")
	assert_bool(director.destroy_hell_mirror_in_washer(inventory)).is_true()

	assert_bool(inventory.has_item_id(NightAnomalyDirector.HELL_MIRROR_ITEM_ID)).is_false()
	assert_array(cues).contains_exactly(["hell_mirror_washer_destroy"])
