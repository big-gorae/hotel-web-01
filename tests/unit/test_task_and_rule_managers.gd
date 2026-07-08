extends GdUnitTestSuite

const TaskManager := preload("res://scripts/tasks/task_manager.gd")
const RuleBookManager := preload("res://scripts/rules/rule_book_manager.gd")


func test_task_manager_exports_and_imports_completed_tasks() -> void:
	var manager := TaskManager.new()
	manager.setup_default_catalog()

	assert_that(manager.complete_task("room_105_fold_bedding")).is_true()
	assert_that(manager.get_task_state("room_105_fold_bedding")).is_equal("done")

	var restored := TaskManager.new()
	restored.setup_default_catalog()
	restored.import_state(manager.export_state())

	assert_that(restored.get_task_state("room_105_fold_bedding")).is_equal("done")


func test_rule_book_manager_tracks_read_rules() -> void:
	var manager := RuleBookManager.new()
	manager.setup_default_catalog()

	assert_that(manager.get_visible_rules().size()).is_equal(7)
	assert_that(manager.has_read_rule("keep_washer_closed_after_11")).is_false()

	manager.mark_all_visible_read()

	assert_that(manager.has_read_rule("keep_washer_closed_after_11")).is_true()
	assert_that(manager.export_state().get("read_rule_ids", []).has("compare_corridor_room_numbers")).is_true()
