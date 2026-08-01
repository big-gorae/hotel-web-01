extends GdUnitTestSuite

const FlagStore := preload("res://scripts/systems/flag_store.gd")
const HorrorEventManager := preload("res://scripts/horror/horror_event_manager.gd")
const HorrorEventDefinition := preload("res://scripts/horror/horror_event_definition.gd")
const Localization := preload("res://scripts/localization.gd")
const ContentCatalog := preload("res://scripts/horror/anomaly_content_catalog.gd")
const CollectionContent := preload("res://scripts/horror/anomaly_collection_content.gd")


func test_anomaly_flag_lifecycle_and_collection_survive_new_run() -> void:
	var flags := FlagStore.new()
	var manager := HorrorEventManager.new()
	manager.setup_default_catalog(flags)
	var definition := HorrorEventDefinition.new()
	definition.id = "test_room_105_anomaly"
	definition.room_id = "room_105"
	definition.scene_ids = ["room_105_door_window"]
	definition.flag_id = "test.room_105.anomaly"
	definition.discovery_kind = "visual_anomaly"
	definition.spawn_chance = 1.0
	definition.reveal_hotspots = [{"id": "test_anomaly"}]
	manager.register_definition(definition)
	definition = manager.get_definition(definition.id)
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


func test_collection_entries_separate_entity_stories_from_phenomenon_descriptions() -> void:
	var manager := HorrorEventManager.new()
	manager.setup_default_catalog()
	manager.mark_event_seen("room_105_closet_pig_man")
	manager.mark_event_seen("corridor_red_room_light")

	var entries := manager.get_discovered_entries()
	var entity: Dictionary = entries[0]
	var phenomenon: Dictionary = entries[1]
	assert_str(String(entity.get("collection_kind", ""))).is_equal("entity")
	assert_str(String(phenomenon.get("collection_kind", ""))).is_equal("phenomenon")
	assert_str(String(entity.get("body_key", ""))).ends_with(".body")
	assert_str(String(phenomenon.get("body_key", ""))).ends_with(".body")
	assert_dict(manager.get_discovered_kind_counts()).is_equal({
		"entity": 1,
		"phenomenon": 1,
	})

	var restored := HorrorEventManager.new()
	restored.setup_default_catalog()
	restored.import_collection_state(manager.export_collection_state())
	assert_dict(restored.get_discovered_kind_counts()).is_equal({
		"entity": 1,
		"phenomenon": 1,
	})


func test_collection_copy_uses_korean_and_falls_back_to_english_for_untranslated_locales() -> void:
	var localization := Localization.new()
	var story_key := "anomaly_collection.event.room_107_hanging_girl.body"

	localization.set_language(Localization.Language.KOREAN)
	assert_str(localization.translate(story_key)).contains("데롱데롱 놀이")

	localization.set_language(Localization.Language.JAPANESE)
	assert_str(localization.translate(story_key)).contains("dangle-dangle game")


func test_every_catalog_entry_has_editable_collection_copy_and_canon_kind() -> void:
	var manager := HorrorEventManager.new()
	manager.setup_default_catalog()
	var catalog_ids: Array = manager.definitions_by_id.keys()
	var collection_ids: Array = CollectionContent.ENTRIES.keys()
	catalog_ids.sort()
	collection_ids.sort()
	assert_array(collection_ids).contains_exactly(catalog_ids)
	for event_id in manager.definitions_by_id:
		var definition = manager.get_definition(event_id)
		assert_str(definition.collection_title_key).is_not_empty()
		assert_str(definition.collection_body_key).is_not_empty()
		assert_array(["entity", "phenomenon"]).contains([definition.collection_kind])
		for locale_code in ["en", "ko"]:
			var copy := CollectionContent.get_copy(event_id, locale_code)
			assert_str(String(copy.get("title", ""))).is_not_empty()
			assert_str(String(copy.get("body", ""))).is_not_empty()

	var content_definitions: Dictionary = ContentCatalog.build_definitions()
	for event_id in content_definitions:
		var content_definition: Dictionary = content_definitions[event_id]
		assert_bool(manager.definitions_by_id.has(event_id)).is_true()
		assert_str(manager.get_definition(event_id).collection_kind).is_equal(
			String(content_definition.get("type", "")),
		)
	assert_array(ContentCatalog.debug_event_ids()).contains(ContentCatalog.production_event_ids())
	assert_bool(ContentCatalog.is_event_enabled("room_109_open_door")).is_true()
	assert_array(ContentCatalog.debug_event_ids()).contains(["room_109_open_door"])
	assert_array(ContentCatalog.production_event_ids()).not_contains(["room_109_open_door"])


func test_day_seven_room_109_passage_uses_its_own_game_over_definition() -> void:
	var manager := HorrorEventManager.new()
	manager.setup_default_catalog()
	var passage = manager.get_definition("room_109_day7_passage")

	assert_str(passage.event_type).is_equal(HorrorEventDefinition.TYPE_JUMPSCARE)
	manager.mark_event_seen("room_109_day7_passage")
	assert_bool(manager.trigger_jumpscare("room_109_day7_passage")).is_true()

	var discovered_ids: Array[String] = []
	for entry in manager.get_discovered_entries():
		discovered_ids.append(String(entry.get("id", "")))
	assert_array(discovered_ids).contains(["room_109_day7_passage"])
	assert_array(discovered_ids).not_contains(["room_109_open_door"])


func test_weighted_selection_uses_definition_weights() -> void:
	var manager := HorrorEventManager.new()
	manager.setup_default_catalog()
	var zero_weight = manager.get_definition("room_105_closet_pig_man")
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
