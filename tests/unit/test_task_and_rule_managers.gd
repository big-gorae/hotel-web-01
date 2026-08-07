extends GdUnitTestSuite

const TaskManager := preload("res://scripts/tasks/task_manager.gd")
const RuleBookManager := preload("res://scripts/rules/rule_book_manager.gd")
const RuleBookPageCatalog := preload("res://scripts/rules/rule_book_page_catalog.gd")


func test_task_manager_exports_and_imports_completed_tasks() -> void:
	var manager := TaskManager.new()
	manager.setup_default_catalog()

	assert_that(manager.complete_task("room_105_fold_bedding")).is_true()
	assert_that(manager.get_task_state("room_105_fold_bedding")).is_equal("done")

	var restored := TaskManager.new()
	restored.setup_default_catalog()
	restored.import_state(manager.export_state())

	assert_that(restored.get_task_state("room_105_fold_bedding")).is_equal("done")


func test_room_105_visual_tasks_expose_hold_durations_and_independent_trash_hotspots() -> void:
	var manager := TaskManager.new()
	manager.setup_default_catalog()
	var hotspots := manager.get_hotspots_for_scene("room_105_door_window")
	var task_ids: Array = hotspots.map(func(hotspot) -> String: return String(hotspot.get("task_id", "")))

	assert_array(task_ids).contains_exactly([
		"room_105_fold_bedding",
		"room_105_collect_trash_cup",
		"room_105_collect_trash_receipt",
		"room_105_collect_trash_wrapper",
	])
	for hotspot in hotspots:
		assert_float(float(hotspot.get("task_hold_seconds", 0.0))).is_greater(0.0)

	assert_that(manager.complete_task("room_105_collect_trash_cup")).is_true()
	assert_int(manager.get_hotspots_for_scene("room_105_door_window").size()).is_equal(3)


func test_rule_book_manager_tracks_read_rules() -> void:
	var manager := RuleBookManager.new()
	manager.setup_default_catalog()

	assert_that(manager.get_visible_rules().size()).is_equal(3)
	assert_that(manager.has_read_rule("make_vacant_beds")).is_false()

	manager.mark_all_visible_read()

	assert_that(manager.has_read_rule("make_vacant_beds")).is_true()
	assert_that(manager.has_read_rule("close_open_wardrobe")).is_false()

	manager.set_current_day(3)
	assert_that(manager.get_visible_rules().size()).is_equal(10)
	var day_three_orders: Array = manager.get_rules_for_day(3).map(
		func(definition) -> int: return int(definition.order)
	)
	assert_that(day_three_orders).contains_exactly([5, 6, 9, 10, 17, 18])
	manager.mark_all_visible_read()
	assert_that(manager.has_read_rule("close_open_wardrobe")).is_true()
	assert_that(manager.export_state().get("read_rule_ids", []).has("enter_open_room_109")).is_true()
	assert_that(manager.export_state().get("read_rule_ids", []).has("sister_bloodied_false_rule_warning")).is_true()

	manager.set_current_day(7)
	assert_that(manager.get_visible_rules().size()).is_equal(16)


func test_rule_book_pages_only_contain_rules_added_that_day() -> void:
	var manager := RuleBookManager.new()
	manager.setup_default_catalog()
	manager.set_current_day(7)

	var expected_counts := [3, 1, 6, 1, 1, 1, 3]
	for day in range(1, 8):
		assert_that(manager.get_rules_for_day(day).size()).is_equal(expected_counts[day - 1])
		for definition in manager.get_rules_for_day(day):
			assert_that(definition.unlock_day).is_equal(day)

	manager.mark_day_read(3)
	assert_that(manager.has_read_rule("ignore_room_108_light_repair")).is_true()
	assert_that(manager.has_read_rule("enter_open_room_109")).is_true()
	assert_that(manager.has_read_rule("ignore_sister_warning")).is_true()
	assert_that(manager.has_read_rule("ring_bell_and_run_from_follower")).is_true()
	assert_that(manager.has_read_rule("answer_before_thirteenth_ring")).is_false()


func test_rule_book_page_images_prefer_locale_then_shared_fallback() -> void:
	var candidates := RuleBookPageCatalog.get_candidate_paths(3, "ko")

	assert_that(candidates[0]).is_equal("res://resource/images/rule_book/ko/day_03.png")
	assert_that(candidates[4]).is_equal("res://resource/images/rule_book/day_03.png")
	assert_that(candidates.size()).is_equal(8)
	assert_that(RuleBookPageCatalog.resolve_page_image_path(3, "ko")).is_empty()


func test_rule_book_text_pages_use_the_selected_notebook_background() -> void:
	var background_path := RuleBookPageCatalog.get_text_background_path()

	assert_that(background_path).is_equal("res://resource/images/rule_book/notebook_background.png")
	assert_that(ResourceLoader.exists(background_path, "Texture2D")).is_true()
