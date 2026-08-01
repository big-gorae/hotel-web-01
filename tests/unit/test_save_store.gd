extends GdUnitTestSuite

const JsonSaveStore := preload("res://scripts/systems/json_save_store.gd")
const DaySaveManager := preload("res://scripts/systems/day_save_manager.gd")
const GameMode := preload("res://scripts/systems/game_mode.gd")

const TEST_PATH := "user://hotel_json_store_test.json"


func before_test() -> void:
	_remove_test_files()


func after_test() -> void:
	_remove_test_files()


func test_atomic_json_store_replaces_file_without_temp_artifacts() -> void:
	assert_that(JsonSaveStore.write_dictionary_atomic(TEST_PATH, {"value": 1})).is_true()
	assert_that(JsonSaveStore.write_dictionary_atomic(TEST_PATH, {"value": 2})).is_true()

	assert_that(int(JsonSaveStore.load_dictionary(TEST_PATH).get("value", 0))).is_equal(2)
	assert_that(FileAccess.file_exists("%s.tmp" % TEST_PATH)).is_false()
	assert_that(FileAccess.file_exists("%s.bak" % TEST_PATH)).is_false()


func test_version_one_day_save_migrates_to_current_schema() -> void:
	var manager := DaySaveManager.new()
	var migrated: Dictionary = manager._migrate_save_data({
		"version": 1,
		"current_day": 2,
		"unlocked_days": [1, 2],
		"day_slots": {"2": {"scene_id": "corridor"}},
	})

	assert_that(migrated.get("version", 0)).is_equal(DaySaveManager.SAVE_VERSION)
	assert_that(migrated.get("day_slots", {}).has("2")).is_true()
	assert_str(String(migrated.get("game_mode", ""))).is_equal(GameMode.STORY)


func test_story_and_infinity_use_separate_save_paths_and_day_limits() -> void:
	var manager := DaySaveManager.new()
	assert_str(manager.get_save_path()).is_equal(DaySaveManager.SAVE_PATH)
	assert_int(manager.clamp_day(12)).is_equal(DaySaveManager.TOTAL_DAYS)

	manager.set_game_mode(GameMode.INFINITY, false)
	assert_str(manager.get_save_path()).is_equal(DaySaveManager.INFINITY_SAVE_PATH)
	assert_int(manager.clamp_day(12)).is_equal(12)

	manager.set_current_day(25)
	assert_int(manager.current_day).is_equal(25)


func _remove_test_files() -> void:
	for path in [TEST_PATH, "%s.tmp" % TEST_PATH, "%s.bak" % TEST_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
