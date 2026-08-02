extends GdUnitTestSuite

const Registry := preload("res://scripts/horror/anomaly_registry.gd")
const ContentCatalog := preload("res://scripts/horror/anomaly_content_catalog.gd")
const ContentRuntime := preload("res://scripts/horror/anomaly_content_runtime.gd")
const NightDirector := preload("res://scripts/horror/night_anomaly_director.gd")
const ClosetSystem := preload("res://scripts/horror/closet_pig_man_system.gd")
const ItemHazard := preload("res://scripts/horror/equipped_item_hazard_controller.gd")
const HorrorCatalog := preload("res://scripts/horror/horror_catalog.gd")
const CollectionContent := preload("res://scripts/horror/anomaly_collection_content.gd")
const HotelSceneCatalog := preload("res://scripts/scenes/hotel_scene_catalog.gd")
const Localization := preload("res://scripts/localization.gd")


func test_registry_covers_all_twenty_five_authored_anomalies() -> void:
	var definitions := Registry.build_definitions()
	var kind_counts := {
		Registry.KIND_ENTITY: 0,
		Registry.KIND_PHENOMENON: 0,
		Registry.KIND_DERIVED_HAZARD: 0,
	}
	for event_id in definitions:
		var kind := String(definitions[event_id].get("kind", ""))
		kind_counts[kind] = int(kind_counts.get(kind, 0)) + 1

	assert_int(definitions.size()).is_equal(25)
	assert_int(Registry.direct_event_ids().size()).is_equal(24)
	assert_dict(kind_counts).is_equal({
		Registry.KIND_ENTITY: 9,
		Registry.KIND_PHENOMENON: 15,
		Registry.KIND_DERIVED_HAZARD: 1,
	})
	assert_array(Registry.validate_all(HotelSceneCatalog.get_scene_ids())).is_empty()


func test_registry_is_the_shared_catalog_source_of_truth() -> void:
	var content_ids: Array = ContentCatalog.build_definitions().keys()
	var registry_content_ids: Array = Registry.content_event_ids(true)
	content_ids.sort()
	registry_content_ids.sort()
	assert_array(content_ids).contains_exactly(registry_content_ids)

	var horror_ids: Array[String] = []
	for definition in HorrorCatalog.build_definitions():
		horror_ids.append(String(definition.id))
	horror_ids.sort()
	assert_array(horror_ids).contains_exactly(Registry.all_event_ids())

	var collection_ids: Array = CollectionContent.ENTRIES.keys()
	collection_ids.sort()
	assert_array(collection_ids).contains_exactly(Registry.all_event_ids())


func test_registry_returns_snapshots_without_exposing_canonical_metadata() -> void:
	var all_definitions := Registry.build_definitions()
	all_definitions["front_monitor_ghost"]["placement"]["default_scene_id"] = "mutated"
	var one_definition := Registry.get_definition("front_monitor_ghost")
	one_definition["schedule"]["story_days"].append(99)

	assert_str(Registry.get_default_scene_id("front_monitor_ghost")).is_equal("front_desk")
	assert_bool(99 in Registry.get_definition("front_monitor_ghost")["schedule"]["story_days"]).is_false()


func test_every_direct_anomaly_reserves_the_primary_activation_slot() -> void:
	for event_id in Registry.direct_event_ids():
		var definition := Registry.get_definition(event_id)
		var slots: Array = definition.get("activation", {}).get("exclusive_slots", [])
		assert_array(slots).override_failure_message(
			"%s must reserve the primary anomaly slot" % event_id
		).contains([Registry.ACTIVATION_SLOT_PRIMARY])


func test_every_visible_materialization_scene_is_observation_guarded() -> void:
	for event_id in Registry.direct_event_ids():
		if Registry.get_visibility_policy(event_id) != Registry.VISIBILITY_OFFSCREEN_ONLY:
			continue
		var candidates := Registry.get_candidate_scene_ids(event_id)
		if candidates.is_empty():
			candidates = [Registry.get_default_scene_id(event_id)]
		for selected_scene_id in candidates:
			var materialization := Registry.materialization_scene_ids(event_id, selected_scene_id)
			var guards := Registry.observation_guard_scene_ids(event_id, selected_scene_id)
			assert_bool(materialization.is_empty()).override_failure_message(
				"%s must declare a materialization scene" % event_id
			).is_false()
			for scene_id in materialization:
				assert_array(guards).override_failure_message(
					"%s can materialize in %s while it is being watched" % [event_id, scene_id]
				).contains([scene_id])


func test_every_same_scene_pair_shares_a_scene_conflict_tag() -> void:
	for scene_id in HotelSceneCatalog.get_scene_ids():
		var occupants := _occupants_for_scene(String(scene_id))
		for left_index in occupants.size():
			for right_index in range(left_index + 1, occupants.size()):
				var left: Dictionary = occupants[left_index]
				var right: Dictionary = occupants[right_index]
				if String(left["event_id"]) == String(right["event_id"]):
					continue
				var left_tags := Registry.conflict_tags(left["event_id"], left["selected_scene_id"])
				var right_tags := Registry.conflict_tags(right["event_id"], right["selected_scene_id"])
				var required_tag := "scene:%s" % scene_id
				assert_array(left_tags).override_failure_message(
					"%s lacks %s" % [left["event_id"], required_tag]
				).contains([required_tag])
				assert_array(right_tags).override_failure_message(
					"%s lacks %s" % [right["event_id"], required_tag]
				).contains([required_tag])


func test_all_content_events_wait_in_queue_while_any_materialization_scene_is_watched() -> void:
	for event_id in Registry.content_event_ids(true):
		if Registry.get_visibility_policy(event_id) != Registry.VISIBILITY_OFFSCREEN_ONLY:
			continue
		var selected_scene_id := Registry.get_default_scene_id(event_id)
		for guarded_scene_id in Registry.observation_guard_scene_ids(event_id, selected_scene_id):
			var runtime = auto_free(ContentRuntime.new())
			add_child(runtime)
			runtime.start_day(1)
			runtime._planned_event_id = event_id
			runtime._current_scene_override = selected_scene_id
			runtime.enter_scene(guarded_scene_id)
			runtime.advance(runtime.SPAWN_DELAY_SECONDS + 0.01)

			assert_str(runtime.current_event_id).override_failure_message(
				"%s started while %s was visible" % [event_id, guarded_scene_id]
			).is_empty()
			assert_int(runtime.scheduler.pending_anomaly_queue.size()).is_equal(1)

			runtime.enter_scene(_safe_scene_outside_guards(event_id, selected_scene_id))
			assert_str(runtime.current_event_id).is_equal(event_id)


func test_story_and_infinity_schedules_are_registry_driven() -> void:
	var production_story := {
		2: "corridor_red_room_light",
		3: "room_107_hanging_girl",
		4: "hotel_following_shadow",
		5: "room_108_entrails_bathtub",
		6: "room_106_horrific_mirror",
	}
	var primary_story := {
		2: "room_105_closet_pig_man",
		4: "room_108_light_repair_call",
		5: "laundry_red_washer",
		6: "room_106_abandoned_child",
		7: "room_109_day7_passage",
	}
	for day in range(1, 8):
		assert_str(Registry.story_event_for_day(Registry.CHANNEL_PRODUCTION, day)).is_equal(
			String(production_story.get(day, ""))
		)
		assert_str(Registry.story_event_for_day(Registry.CHANNEL_PRIMARY_ENTITY, day)).is_equal(
			String(primary_story.get(day, ""))
		)
	assert_array(Registry.production_event_ids()).contains_exactly(Registry.PRODUCTION_INFINITY_ORDER)
	assert_array(Registry.primary_infinity_event_ids()).contains_exactly(Registry.PRIMARY_INFINITY_ORDER)


func test_runtime_tuning_and_targets_are_read_from_registry() -> void:
	var director = auto_free(NightDirector.new())
	add_child(director)
	var closet = auto_free(ClosetSystem.new())
	add_child(closet)
	var hazard := ItemHazard.new()

	assert_float(director.phone_initial_delay).is_equal(_tuning("room_108_light_repair_call", "initial_delay_seconds"))
	assert_int(director.phone_max_bells).is_equal(int(_tuning("room_108_light_repair_call", "maximum_bells")))
	assert_float(director.laundry_neglect_duration).is_equal(_tuning("laundry_red_washer", "neglect_seconds"))
	assert_float(closet.HOLD_SECONDS).is_equal(_tuning("room_105_closet_pig_man", "hold_seconds"))
	assert_str(closet._target_scene_id()).is_equal(Registry.get_default_scene_id("room_105_closet_pig_man"))
	assert_float(hazard.fatal_hold_seconds).is_equal(
		float(Registry.get_definition("hell_mirror").get("lifecycle", {}).get("fatal_seconds", 0.0))
	)


func test_every_registry_entry_has_korean_and_english_player_copy() -> void:
	var localization := Localization.new()
	for event_id in Registry.all_event_ids():
		var presentation: Dictionary = Registry.get_definition(event_id).get("presentation", {})
		for key_name in ["collection_title_key", "collection_body_key"]:
			var key := String(presentation.get(key_name, ""))
			assert_str(key).is_not_empty()
			for language in [Localization.Language.ENGLISH, Localization.Language.KOREAN]:
				assert_bool(localization.translations[language].has(key)).override_failure_message(
					"%s is missing %s" % [event_id, key]
				).is_true()
				assert_str(String(localization.translations[language].get(key, ""))).is_not_empty()


func _occupants_for_scene(scene_id: String) -> Array[Dictionary]:
	var occupants: Array[Dictionary] = []
	for event_id in Registry.direct_event_ids():
		var candidates := Registry.get_candidate_scene_ids(event_id)
		if candidates.is_empty():
			candidates = [Registry.get_default_scene_id(event_id)]
		for selected_scene_id in candidates:
			var guarded_scenes := Registry.observation_guard_scene_ids(event_id, selected_scene_id)
			if guarded_scenes.has(scene_id):
				occupants.append({
					"event_id": event_id,
					"selected_scene_id": selected_scene_id,
				})
	return occupants


func _safe_scene_outside_guards(event_id: String, selected_scene_id: String) -> String:
	var guards := Registry.observation_guard_scene_ids(event_id, selected_scene_id)
	for scene_id in HotelSceneCatalog.get_scene_ids():
		if not guards.has(String(scene_id)):
			return String(scene_id)
	return ""


func _tuning(event_id: String, key: String) -> float:
	var definition := Registry.get_definition(event_id)
	var resolution: Dictionary = definition.get("resolution", {})
	return float(resolution.get("tuning", {}).get(key, 0.0))
