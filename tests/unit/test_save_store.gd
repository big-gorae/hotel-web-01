extends GdUnitTestSuite

const JsonSaveStore := preload("res://scripts/systems/json_save_store.gd")
const DaySaveManager := preload("res://scripts/systems/day_save_manager.gd")

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


func _remove_test_files() -> void:
	for path in [TEST_PATH, "%s.tmp" % TEST_PATH, "%s.bak" % TEST_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
