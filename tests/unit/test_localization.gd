extends GdUnitTestSuite

const Localization := preload("res://scripts/localization.gd")
const HorrorCatalog := preload("res://scripts/horror/horror_catalog.gd")


func test_default_language_is_korean() -> void:
	var localization := Localization.new()

	assert_int(localization.get_language()).is_equal(Localization.Language.KOREAN)
	assert_str(localization.get_language_code()).is_equal("ko")


func test_english_and_korean_have_identical_key_coverage() -> void:
	var localization := Localization.new()
	var english_keys: Array = localization.translations[Localization.Language.ENGLISH].keys()
	var korean_keys: Array = localization.translations[Localization.Language.KOREAN].keys()
	english_keys.sort()
	korean_keys.sort()

	assert_array(korean_keys).contains_exactly(english_keys)


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
