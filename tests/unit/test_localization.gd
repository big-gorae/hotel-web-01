extends GdUnitTestSuite

const Localization := preload("res://scripts/localization.gd")


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
