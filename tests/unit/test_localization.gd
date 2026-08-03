extends GdUnitTestSuite

const Localization := preload("res://scripts/localization.gd")
const HorrorCatalog := preload("res://scripts/horror/horror_catalog.gd")
const SceneCatalog := preload("res://scripts/scenes/hotel_scene_catalog.gd")
const ItemCatalog := preload("res://scripts/items/item_catalog.gd")
const InventoryModel := preload("res://scripts/items/inventory_model.gd")
const TaskCatalog := preload("res://scripts/tasks/task_catalog.gd")
const RuleBookCatalog := preload("res://scripts/rules/rule_book_catalog.gd")
const StoryDeliveryManager := preload("res://scripts/story/story_delivery_manager.gd")
const UI_FONT_PATH := "res://resource/fonts/NanumGothic-Regular.ttf"


func test_default_language_is_korean() -> void:
	var localization := Localization.new()

	assert_int(localization.get_language()).is_equal(Localization.Language.KOREAN)
	assert_str(localization.get_language_code()).is_equal("ko")


func test_default_ui_font_is_bundled_and_contains_korean_glyphs() -> void:
	assert_str(String(ProjectSettings.get_setting("gui/theme/custom_font", ""))).is_equal(UI_FONT_PATH)
	var ui_font: Font = load(UI_FONT_PATH)

	assert_object(ui_font).is_not_null()
	for character in ["한", "글", "죽", "어"]:
		assert_bool(ui_font.has_char(character.unicode_at(0))).override_failure_message(
			"Bundled UI font is missing Korean glyph: %s" % character
		).is_true()


func test_red_washer_rule_matches_the_current_ritual_in_korean_and_english() -> void:
	var localization := Localization.new()

	assert_str(String(localization.translations[Localization.Language.KOREAN]["ui.rule_book.rule.8"])).is_equal(
		"세탁기 안에 이상한 것이 보이면 세탁을 종료하시오. 세탁 종료 노래가 나오는 동안 눈을 감고, 세탁실에 숨어 있으시오"
	)
	assert_str(String(localization.translations[Localization.Language.ENGLISH]["ui.rule_book.rule.8"])).is_equal(
		"If you see something strange inside a washer, stop the wash. While the completion song plays, close your eyes and hide in the laundry room."
	)
	assert_bool(localization.translations[Localization.Language.KOREAN].has("ui.rule_book.rule.9")).is_false()
	assert_bool(localization.translations[Localization.Language.ENGLISH].has("ui.rule_book.rule.10")).is_false()


func test_english_and_korean_have_identical_key_coverage() -> void:
	var localization := Localization.new()
	var english_keys: Array = localization.translations[Localization.Language.ENGLISH].keys()
	var korean_keys: Array = localization.translations[Localization.Language.KOREAN].keys()
	english_keys.sort()
	korean_keys.sort()

	assert_array(korean_keys).contains_exactly(english_keys)
	for key in english_keys:
		assert_str(String(localization.translations[Localization.Language.ENGLISH][key])).override_failure_message(
			"Empty English localization: %s" % key
		).is_not_empty()
		assert_str(String(localization.translations[Localization.Language.KOREAN][key])).override_failure_message(
			"Empty Korean localization: %s" % key
		).is_not_empty()


func test_every_game_over_title_and_description_exists_in_korean_and_english() -> void:
	var localization := Localization.new()
	var english: Dictionary = localization.translations[Localization.Language.ENGLISH]
	var korean: Dictionary = localization.translations[Localization.Language.KOREAN]

	for definition in HorrorCatalog.build_definitions():
		if String(definition.jumpscare_outcome) != "game_over":
			continue
		for key in [String(definition.title_key), String(definition.description_key)]:
			assert_bool(english.has(key)).override_failure_message(
				"Missing English game-over localization: %s" % key
			).is_true()
			assert_bool(korean.has(key)).override_failure_message(
				"Missing Korean game-over localization: %s" % key
			).is_true()


func test_every_scene_exit_and_authored_hotspot_has_explicit_korean_and_english_copy() -> void:
	var localization := Localization.new()
	var english: Dictionary = localization.translations[Localization.Language.ENGLISH]
	var korean: Dictionary = localization.translations[Localization.Language.KOREAN]
	for scene_id in SceneCatalog.SCENES:
		var scene: Dictionary = SceneCatalog.SCENES[scene_id]
		_assert_copy(english, korean, "scene.%s.title" % scene_id, String(scene.get("title", "")))
		_assert_copy(english, korean, "scene.%s.intro" % scene_id, String(scene.get("intro", "")))
		for exit_data in scene.get("exits", []):
			var key := "exit.%s.%s.label" % [scene_id, String(exit_data.get("target", ""))]
			_assert_copy(english, korean, key, String(exit_data.get("label", "")))

	var main_scene = auto_free(load("res://scenes/main.tscn").instantiate())
	var definitions = main_scene.get_node("HotspotDefinitions")
	for scene_group in definitions.get_children():
		for node in scene_group.get_children():
			if not node.has_method("to_hotspot_data"):
				continue
			var hotspot: Dictionary = node.to_hotspot_data(scene_group.size)
			var prefix := "hotspot.%s.%s" % [String(scene_group.name), String(hotspot.get("id", ""))]
			_assert_copy(english, korean, "%s.label" % prefix, String(hotspot.get("label", "")))
			if hotspot.has("text"):
				_assert_copy(english, korean, "%s.text" % prefix, String(hotspot.get("text", "")))


func test_runtime_only_hotspots_have_explicit_korean_and_english_copy() -> void:
	var localization := Localization.new()
	var english: Dictionary = localization.translations[Localization.Language.ENGLISH]
	var korean: Dictionary = localization.translations[Localization.Language.KOREAN]
	for key in [
		"hotspot.corridor.room_109_open_door.label",
		"hotspot.corridor.room_109_open_door.text",
		"hotspot.laundry_room.anomaly_pickup:hanging_girl_doll.label",
		"hotspot.room_107_bed_nightstand.anomaly_choice:hanging_girl.label",
		"hotspot.room_105_bathroom_entry.closet_pig_hold:wardrobe.label",
		"hotspot.room_105_bathroom_entry.closet_pig_hold:wardrobe.text",
		"hotspot.common.shower_curtain.label",
		"hotspot.common.shower_curtain.open",
		"hotspot.common.shower_curtain.close",
	]:
		_assert_copy(english, korean, key, String(english.get(key, "")))


func test_every_catalog_player_copy_has_explicit_korean_and_english_text() -> void:
	var localization := Localization.new()
	var english: Dictionary = localization.translations[Localization.Language.ENGLISH]
	var korean: Dictionary = localization.translations[Localization.Language.KOREAN]

	var inventory := InventoryModel.new()
	ItemCatalog.register_defaults(inventory)
	for item in inventory.item_catalog.values():
		_assert_nonempty_copy(english, korean, String(item.name_key))
		_assert_nonempty_copy(english, korean, String(item.description_key))
	for rule in inventory.combination_rules:
		_assert_nonempty_copy(english, korean, String(rule.message_key))

	for task in TaskCatalog.build_definitions():
		for key in [task.label_key, task.text_key, task.done_text_key]:
			_assert_nonempty_copy(english, korean, String(key))
		if not String(task.blocked_text_key).is_empty():
			_assert_nonempty_copy(english, korean, String(task.blocked_text_key))

	for rule in RuleBookCatalog.build_definitions():
		_assert_nonempty_copy(english, korean, String(rule.text_key))
	for beats in StoryDeliveryManager.DAY_BEATS.values():
		for beat in beats:
			_assert_nonempty_copy(english, korean, String(beat.get("content_key", "")))

	for definition in HorrorCatalog.build_definitions():
		_assert_nonempty_copy(english, korean, String(definition.collection_title_key))
		_assert_nonempty_copy(english, korean, String(definition.collection_body_key))


func _assert_copy(english: Dictionary, korean: Dictionary, key: String, expected_english: String) -> void:
	assert_bool(english.has(key)).override_failure_message("Missing English localization: %s" % key).is_true()
	assert_bool(korean.has(key)).override_failure_message("Missing Korean localization: %s" % key).is_true()
	assert_str(String(english.get(key, ""))).override_failure_message("Stale English localization: %s" % key).is_equal(expected_english)
	assert_str(String(korean.get(key, ""))).override_failure_message("Empty Korean localization: %s" % key).is_not_empty()


func _assert_nonempty_copy(english: Dictionary, korean: Dictionary, key: String) -> void:
	assert_str(key).override_failure_message("Empty localization key in catalog").is_not_empty()
	assert_bool(english.has(key)).override_failure_message("Missing English localization: %s" % key).is_true()
	assert_bool(korean.has(key)).override_failure_message("Missing Korean localization: %s" % key).is_true()
	assert_str(String(english.get(key, ""))).override_failure_message("Empty English localization: %s" % key).is_not_empty()
	assert_str(String(korean.get(key, ""))).override_failure_message("Empty Korean localization: %s" % key).is_not_empty()
