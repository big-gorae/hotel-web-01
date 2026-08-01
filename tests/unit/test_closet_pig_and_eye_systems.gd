extends GdUnitTestSuite

const ClosetPigManSystem := preload("res://scripts/horror/closet_pig_man_system.gd")
const EyeCloseController := preload("res://scripts/systems/eye_close_controller.gd")
const EyeCloseProfile := preload("res://scripts/systems/eye_close_profile.gd")


func test_closet_pig_uses_very_long_waits_and_announces_each_stage() -> void:
	var system = auto_free(ClosetPigManSystem.new())
	add_child(system)
	var cues: Array[String] = []
	system.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	system.start_day(2)

	system.advance(299.0)
	assert_str(system.current_state).is_equal(system.STATE_WAITING)
	system.advance(1.0)
	assert_str(system.current_state).is_equal(system.STATE_DOOR_OPEN)
	assert_array(cues).contains_exactly(["pig_squeal"])

	system.advance(239.0)
	assert_str(system.current_state).is_equal(system.STATE_DOOR_OPEN)
	system.advance(1.0)
	assert_str(system.current_state).is_equal(system.STATE_EMERGING)
	assert_int(cues.count("pig_squeal")).is_greater_equal(2)


func test_closet_pig_waiting_pauses_while_another_anomaly_is_active() -> void:
	var system = auto_free(ClosetPigManSystem.new())
	add_child(system)
	system.start_day(2)
	system.set_external_anomaly_active(true)
	system.advance(system.INITIAL_WAIT_SECONDS)
	assert_str(system.current_state).is_equal(system.STATE_WAITING)
	assert_float(system.stage_seconds_remaining).is_equal(system.INITIAL_WAIT_SECONDS)

	system.set_external_anomaly_active(false)
	system.advance(system.INITIAL_WAIT_SECONDS)
	assert_str(system.current_state).is_equal(system.STATE_DOOR_OPEN)


func test_closet_pig_squeals_globally_and_dies_only_after_emerging_wait() -> void:
	var system = auto_free(ClosetPigManSystem.new())
	add_child(system)
	var cues: Array[String] = []
	var deaths: Array[String] = []
	system.sound_requested.connect(func(cue_id: String): cues.append(cue_id))
	system.death_requested.connect(func(event_id: String): deaths.append(event_id))
	system.start_day(2)
	system.force_event(system.STATE_EMERGING)
	system.squeal_seconds_remaining = 0.05
	system.advance(0.05)
	assert_int(cues.count("pig_squeal")).is_greater_equal(2)
	assert_array(deaths).is_empty()

	system.advance(system.EMERGING_WAIT_SECONDS - 0.06)
	assert_array(deaths).is_empty()
	system.advance(0.01)
	assert_array(deaths).contains_exactly([system.EVENT_ID])


func test_holding_the_wardrobe_pushes_the_man_back_and_closes_the_door() -> void:
	var system = auto_free(ClosetPigManSystem.new())
	add_child(system)
	var resolved: Array[String] = []
	system.event_resolved.connect(func(event_id: String): resolved.append(event_id))
	system.start_day(2)
	system.force_event(system.STATE_EMERGING)
	var hotspots: Array = system.get_dynamic_hotspots(system.SCENE_ID)
	assert_array(hotspots).has_size(1)
	assert_bool(system.begin_pointer_hold(String(hotspots[0]["id"]), Vector2(400.0, 300.0))).is_true()

	system.advance(system.HOLD_SECONDS - 0.01)
	assert_bool(system.is_active()).is_true()
	system.advance(0.01)
	assert_str(system.current_state).is_equal(system.STATE_RESOLVED)
	assert_array(resolved).contains_exactly([system.EVENT_ID])
	assert_array(system.get_dynamic_hotspots(system.SCENE_ID)).is_empty()


func test_eye_close_profile_can_be_injected_and_song_uses_narrow_radius() -> void:
	var eyes = auto_free(EyeCloseController.new())
	var profile = EyeCloseProfile.new()
	profile.vision_radius = 180.0
	profile.anomaly_vision_radius = 82.0
	profile.song_vision_radius = 36.0
	profile.slit_height_scale = 0.46
	eyes.apply_profile(profile)

	eyes.set_anomaly_context(true)
	eyes.close_eyes()
	assert_that(eyes.is_closed()).is_true()
	assert_that(eyes.get_effective_vision_radius()).is_equal(82.0)
	assert_that(eyes.start_song(4.0)).is_true()
	assert_that(eyes.get_effective_vision_radius()).is_equal(36.0)

	eyes.set_debug_vision_radius(120.0)
	assert_that(eyes.get_effective_vision_radius()).is_equal(120.0)
	assert_float(eyes.get_effective_slit_height_scale()).is_equal(0.46)
	eyes.set_debug_slit_height_scale(0.58)
	assert_float(eyes.get_effective_slit_height_scale()).is_equal(0.58)
	eyes.open_eyes()
	assert_that(eyes.is_closed()).is_false()


func test_default_eye_radius_is_preserved_and_visible_area_uses_clean_squint_shader() -> void:
	var eyes = auto_free(EyeCloseController.new())
	add_child(eyes)

	assert_that(eyes.get_effective_vision_radius()).is_equal(150.0)
	assert_that(eyes._mask_material.shader.code).contains("textureLod")
	assert_that(eyes._mask_material.shader.code).not_contains("vhs_apply_signal")
	assert_that(eyes._mask_material.shader.code).contains("slit_half_width")
	assert_that(eyes._mask_material.shader.code).contains("lid_curve")
	assert_float(eyes.profile.slit_height_scale).is_equal(0.40)
	assert_that(eyes._mask_material.shader.code).contains("upper_opening")
	assert_that(eyes._mask_material.shader.code).contains("slit_height_scale")
	assert_that(eyes._mask_material.shader.code).not_contains("distance(pixel, focus_position)")
	assert_that(eyes.profile.visible_brightness).is_equal(0.36)
	assert_that(eyes._mask_material.shader.code).contains("visible_color *= visible_brightness")
