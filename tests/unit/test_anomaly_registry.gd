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
const ItemCatalog := preload("res://scripts/items/item_catalog.gd")
const InventoryModel := preload("res://scripts/items/inventory_model.gd")


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
	assert_array(Registry.validate_all(HotelSceneCatalog.get_scene_ids(), _known_item_ids())).is_empty()


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
	for event_id in Registry.all_event_ids():
		var expected_kind := String(
			Registry.get_definition(event_id).get("presentation", {}).get("collection_kind", "")
		)
		assert_str(CollectionContent.get_kind(event_id)).is_equal(expected_kind)
		assert_str(String(CollectionContent.ENTRIES[event_id].get("kind", ""))).is_equal(expected_kind)


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

	var director_tuning := {
		"phone_initial_delay": ["room_108_light_repair_call", "initial_delay_seconds"],
		"phone_repeat_delay": ["room_108_light_repair_call", "repeat_delay_seconds"],
		"phone_bell_interval": ["room_108_light_repair_call", "bell_interval_seconds"],
		"phone_death_delay": ["room_108_light_repair_call", "death_delay_seconds"],
		"phone_forbidden_duration": ["room_108_light_repair_call", "forbidden_seconds"],
		"laundry_music_duration": ["laundry_red_washer", "music_seconds"],
		"laundry_stop_hold_duration": ["laundry_red_washer", "hold_seconds"],
		"laundry_eye_close_grace_duration": ["laundry_red_washer", "eye_close_grace_seconds"],
		"laundry_neglect_duration": ["laundry_red_washer", "neglect_seconds"],
		"child_appearance_delay": ["room_106_abandoned_child", "appearance_delay_seconds"],
		"child_response_seconds": ["room_106_abandoned_child", "response_seconds"],
		"child_song_duration": ["room_106_abandoned_child", "song_seconds"],
		"blanket_response_seconds": ["vacant_room_blanket_child", "response_seconds"],
		"blanket_eye_close_duration": ["vacant_room_blanket_child", "eye_close_seconds"],
		"blanket_death_delay": ["vacant_room_blanket_child", "death_delay_seconds"],
		"room_109_passage_wait_seconds": ["room_109_day7_passage", "wait_seconds"],
		"room_109_passage_footstep_seconds": ["room_109_day7_passage", "footstep_seconds"],
	}
	for property_name in director_tuning:
		var metadata_path: Array = director_tuning[property_name]
		assert_float(float(director.get(property_name))).override_failure_message(
			"%s drifted from registry tuning" % property_name
		).is_equal(_tuning(String(metadata_path[0]), String(metadata_path[1])))
	assert_int(director.phone_max_bells).is_equal(int(_tuning("room_108_light_repair_call", "maximum_bells")))
	var closet_tuning := {
		"INITIAL_WAIT_MIN_SECONDS": "initial_wait_min_seconds",
		"INITIAL_WAIT_MAX_SECONDS": "initial_wait_max_seconds",
		"DOOR_OPEN_WAIT_SECONDS": "door_open_seconds",
		"EMERGING_WAIT_SECONDS": "emerging_seconds",
		"HOLD_SECONDS": "hold_seconds",
		"SQUEAL_INTERVAL_BASE_SECONDS": "squeal_interval_seconds",
		"SQUEAL_INTERVAL_JITTER_SECONDS": "squeal_jitter_seconds",
	}
	for property_name in closet_tuning:
		assert_float(float(closet.get(property_name))).override_failure_message(
			"%s drifted from registry tuning" % property_name
		).is_equal(_tuning("room_105_closet_pig_man", String(closet_tuning[property_name])))
	assert_str(closet._target_scene_id()).is_equal(Registry.get_default_scene_id("room_105_closet_pig_man"))
	assert_float(hazard.fatal_hold_seconds).is_equal(
		float(Registry.get_definition("hell_mirror").get("lifecycle", {}).get("fatal_seconds", 0.0))
	)


func test_registry_item_flows_match_runtime_and_item_catalog() -> void:
	var hanging_resolution: Dictionary = Registry.get_definition("room_107_hanging_girl").get("resolution", {})
	assert_str(String(hanging_resolution.get("required_item_id", ""))).is_equal(ContentRuntime.HANGING_GIRL_DOLL_ITEM_ID)
	assert_str(String(hanging_resolution.get("pickup_item_id", ""))).is_equal(ContentRuntime.HANGING_GIRL_DOLL_ITEM_ID)
	assert_str(String(hanging_resolution.get("consumed_item_id", ""))).is_equal(ContentRuntime.HANGING_GIRL_DOLL_ITEM_ID)

	var mirror_resolution: Dictionary = Registry.get_definition("room_106_horrific_mirror").get("resolution", {})
	var hazard_resolution: Dictionary = Registry.get_definition("hell_mirror").get("resolution", {})
	assert_str(String(mirror_resolution.get("required_item_id", ""))).is_equal(Registry.SMALL_MIRROR_ITEM_ID)
	assert_str(String(mirror_resolution.get("replacement_item_id", ""))).is_equal(Registry.HELL_MIRROR_ITEM_ID)
	assert_str(String(hazard_resolution.get("required_item_id", ""))).is_equal(Registry.HELL_MIRROR_ITEM_ID)
	assert_str(String(hazard_resolution.get("source_event_id", ""))).is_equal("room_106_horrific_mirror")


func test_presentation_manifests_reference_registered_event_scenes() -> void:
	var directory := DirAccess.open("res://resource/anomaly_manifests")
	assert_object(directory).is_not_null()
	for file_name in directory.get_files():
		if not file_name.ends_with(".json") or file_name == "schema.json":
			continue
		var file := FileAccess.open("res://resource/anomaly_manifests/%s" % file_name, FileAccess.READ)
		assert_object(file).override_failure_message("cannot read %s" % file_name).is_not_null()
		var manifest = JSON.parse_string(file.get_as_text())
		assert_bool(manifest is Dictionary).override_failure_message("invalid JSON in %s" % file_name).is_true()
		var event_id := String(manifest.get("event_id", ""))
		var source_scene_id := String(manifest.get("source_scene_id", ""))
		assert_array(Registry.all_event_ids()).override_failure_message(
			"%s references an unknown event" % file_name
		).contains([event_id])
		assert_array(Registry.get_candidate_scene_ids(event_id)).override_failure_message(
			"%s scene %s is outside registry placement" % [file_name, source_scene_id]
		).contains([source_scene_id])


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


func _known_item_ids() -> Array:
	var inventory := InventoryModel.new()
	ItemCatalog.register_defaults(inventory)
	return inventory.item_catalog.keys()
