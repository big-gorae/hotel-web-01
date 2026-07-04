class_name HotelLocalization
extends RefCounted

enum Language {
	ENGLISH,
	KOREAN,
	JAPANESE,
	RUSSIAN,
	CHINESE,
}

const DEFAULT_LANGUAGE := Language.ENGLISH
const SUPPORTED_LANGUAGES := [
	Language.ENGLISH,
	Language.KOREAN,
	Language.JAPANESE,
	Language.RUSSIAN,
	Language.CHINESE,
]
const LANGUAGE_CODES := {
	Language.ENGLISH: "en",
	Language.KOREAN: "ko",
	Language.JAPANESE: "ja",
	Language.RUSSIAN: "ru",
	Language.CHINESE: "zh",
}

var current_language := DEFAULT_LANGUAGE
var translations := {
	Language.ENGLISH: {
		"ui.menu.title": "Menu",
		"ui.menu.continue": "Continue",
		"ui.menu.brightness": "Brightness",
		"ui.menu.quit": "Quit",
		"ui.debug.hotspots.show": "Show click areas",
		"ui.debug.hotspots.hide": "Hide click areas",
		"ui.debug.dialogue.show": "Show dialogue panel",
		"ui.debug.dialogue.hide": "Hide dialogue panel",
		"ui.debug.navigation.show": "Show quick travel buttons",
		"ui.debug.navigation.hide": "Hide quick travel buttons",
	}
}


func set_language(language: int) -> void:
	if SUPPORTED_LANGUAGES.has(language):
		current_language = language


func get_language() -> int:
	return current_language


func get_language_code() -> String:
	return LANGUAGE_CODES.get(current_language, LANGUAGE_CODES[DEFAULT_LANGUAGE])


func get_supported_languages() -> Array:
	return SUPPORTED_LANGUAGES.duplicate()


func translate(key: String, fallback: String = "") -> String:
	var table: Dictionary = translations.get(current_language, {})
	if table.has(key):
		return table[key]

	var english_table: Dictionary = translations.get(DEFAULT_LANGUAGE, {})
	if english_table.has(key):
		return english_table[key]

	return fallback
