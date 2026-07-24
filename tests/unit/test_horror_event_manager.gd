extends GdUnitTestSuite

const FlagStore := preload("res://scripts/systems/flag_store.gd")
const HorrorEventManager := preload("res://scripts/horror/horror_event_manager.gd")


func test_anomaly_flag_lifecycle_and_collection_survive_new_run() -> void:
	var flags := FlagStore.new()
	var manager := HorrorEventManager.new()
	manager.setup_default_catalog(flags)
	var definition = manager.get_definition("room_105_shadow_stain")
	definition.enabled = true
	definition.spawn_chance = 1.0
	manager.rng.seed = 7

	manager.enter_scene("room_105_door_window")

	assert_that(manager.active_event_id_by_room.get("room_105", "")).is_equal(definition.id)
	assert_that(flags.get_bool(definition.flag_id)).is_true()
	assert_that(manager.get_revealed_hotspots("room_105_door_window").size()).is_equal(1)

	manager.resolve_event(definition.id)

	assert_that(flags.get_bool(definition.flag_id)).is_false()
	assert_that(manager.get_discovered_count()).is_equal(1)
	assert_that(manager.get_discovered_entries()[0].get("resolved", false)).is_true()

	manager.start_new_run()

	assert_that(manager.discovered_event_ids).is_empty()
	assert_that(manager.get_discovered_count()).is_equal(1)


func test_collection_state_round_trips_independently_from_run_state() -> void:
	var manager := HorrorEventManager.new()
	manager.setup_default_catalog()
	manager.mark_event_seen("room_108_light_repair_call")

	var restored := HorrorEventManager.new()
	restored.setup_default_catalog()
	restored.import_collection_state(manager.export_collection_state())

	assert_that(restored.get_discovered_count()).is_equal(1)
	assert_that(restored.discovered_event_ids).is_empty()
	assert_that(restored.get_discovered_entries()[0].get("id", "")).is_equal("room_108_light_repair_call")


func test_weighted_selection_uses_definition_weights() -> void:
	var manager := HorrorEventManager.new()
	manager.setup_default_catalog()
	var zero_weight = manager.get_definition("room_105_shadow_stain")
	var selected = manager.get_definition("room_108_light_repair_call")
	zero_weight.random_weight = 0.0
	selected.random_weight = 1.0

	assert_that(manager._choose_weighted([zero_weight, selected])).is_same(selected)


func test_jumpscares_can_be_disabled_for_story_prototype() -> void:
	var manager := HorrorEventManager.new()
	manager.setup_default_catalog()
	manager.set_jumpscares_enabled(false)

	assert_that(manager.trigger_jumpscare("room_108_light_repair_call")).is_false()
	assert_that(manager.is_jumpscare_active()).is_false()
