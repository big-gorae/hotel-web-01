extends GdUnitTestSuite

const NightAnomalyDirector := preload("res://scripts/horror/night_anomaly_director.gd")
const EyeCloseController := preload("res://scripts/systems/eye_close_controller.gd")


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
	assert_that(deaths).is_equal([NightAnomalyDirector.PHONE_EVENT_ID])

	deaths.clear()
	director.force_phone_ring()
	assert_that(director.handle_hotspot("phone")).is_true()
	assert_that(director.room_108_forbidden).is_true()
	assert_that(director.can_change_scene("room_108_bed_window")).is_false()
	assert_that(deaths).is_equal([NightAnomalyDirector.PHONE_EVENT_ID])


func test_room_109_only_appears_from_third_day() -> void:
	var director = auto_free(NightAnomalyDirector.new())
	director.start_day(2)
	assert_that(director.get_dynamic_hotspots("corridor")).is_empty()
	director.start_day(3)
	assert_that(director.get_dynamic_hotspots("corridor").size()).is_equal(1)
	assert_that(director.get_dynamic_hotspots("corridor")[0].get("id", "")).is_equal("room_109_open_door")


func test_child_song_starts_when_eyes_close_and_opening_early_is_fatal() -> void:
	var eyes = auto_free(EyeCloseController.new())
	var director = auto_free(NightAnomalyDirector.new())
	var deaths := []
	director.death_requested.connect(func(event_id: String) -> void: deaths.append(event_id))
	director.setup(eyes)
	director.start_day(6)
	director.force_child_encounter()

	eyes.close_eyes()
	assert_that(eyes.is_song_active()).is_true()
	eyes.open_eyes()
	assert_that(deaths).is_equal([NightAnomalyDirector.CHILD_EVENT_ID])


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
	eyes.open_eyes()
	assert_that(deaths).is_empty()
