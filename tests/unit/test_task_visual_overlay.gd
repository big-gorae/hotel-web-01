extends GdUnitTestSuite

const TaskManager := preload("res://scripts/tasks/task_manager.gd")
const TaskVisualOverlay := preload("res://scripts/ui/task_visual_overlay.gd")


func test_room_105_layers_follow_each_task_state_and_anomaly_suppression() -> void:
	var manager := TaskManager.new()
	manager.setup_default_catalog()
	var overlay = auto_free(TaskVisualOverlay.new())
	add_child(overlay)
	overlay.setup(manager)
	overlay.set_scene("room_105_door_window")
	overlay.set_photo_rect(Rect2(20.0, 30.0, 1000.0, 750.0))

	assert_bool(overlay.visible).is_true()
	assert_array(overlay.get_visible_task_ids()).contains_exactly([
		"room_105_fold_bedding",
		"room_105_collect_trash_cup",
		"room_105_collect_trash_receipt",
		"room_105_collect_trash_wrapper",
	])
	for child in overlay.get_children():
		assert_vector(child.position).is_equal(Vector2(20.0, 30.0))
		assert_vector(child.size).is_equal(Vector2(1000.0, 750.0))

	manager.complete_task("room_105_collect_trash_cup")
	assert_bool(overlay.get_visible_task_ids().has("room_105_collect_trash_cup")).is_false()

	overlay.set_active_event_id("vacant_room_blanket_child")
	assert_bool(overlay.get_visible_task_ids().has("room_105_fold_bedding")).is_false()
	assert_int(overlay.get_child_count()).is_equal(2)
