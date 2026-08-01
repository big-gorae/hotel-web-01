extends GdUnitTestSuite

const HorrorEventManager := preload("res://scripts/horror/horror_event_manager.gd")
const JumpscareController := preload("res://scripts/horror/jumpscare_controller.gd")
const JumpscareLab := preload("res://scripts/ui/jumpscare_lab.gd")


func test_lab_loads_fake_mother_defaults_and_builds_an_isolated_preview() -> void:
	var manager := HorrorEventManager.new()
	manager.setup_default_catalog()
	var controller = auto_free(JumpscareController.new())
	add_child(controller)
	var lab = auto_free(JumpscareLab.new())
	add_child(lab)
	lab.setup(manager, controller)

	assert_bool(lab.select_event_by_id("room_106_abandoned_child")).is_true()
	assert_int(lab.fit_selector.get_selected_id()).is_equal(1)
	assert_float(lab.get_control_value("jumpscare_hold_seconds")).is_equal_approx(0.25, 0.001)
	assert_float(lab.get_control_value("jumpscare_initial_zoom")).is_equal_approx(1.02, 0.001)

	lab.set_control_value("jumpscare_hold_seconds", 0.22)
	lab.set_control_value("jumpscare_initial_zoom", 1.14)
	lab.set_control_value("jumpscare_lunge_seconds", 0.27)
	lab.set_control_value("jumpscare_lunge_zoom", 2.7)
	lab.set_control_value("jumpscare_focus_y", 0.31)
	var preview = lab.build_preview_definition()

	assert_float(preview.jumpscare_hold_seconds).is_equal_approx(0.22, 0.001)
	assert_float(preview.jumpscare_initial_zoom).is_equal_approx(1.14, 0.001)
	assert_float(preview.jumpscare_lunge_seconds).is_equal_approx(0.27, 0.001)
	assert_float(preview.jumpscare_lunge_zoom).is_equal_approx(2.7, 0.001)
	assert_float(preview.jumpscare_focus_point.y).is_equal_approx(0.31, 0.001)
	assert_float(manager.get_definition("room_106_abandoned_child").jumpscare_hold_seconds).is_equal_approx(0.25, 0.001)


func test_lab_preview_uses_the_controller_without_triggering_game_over_state() -> void:
	var manager := HorrorEventManager.new()
	manager.setup_default_catalog()
	var controller = auto_free(JumpscareController.new())
	add_child(controller)
	var lab = auto_free(JumpscareLab.new())
	add_child(lab)
	lab.setup(manager, controller)
	lab.select_event_by_id("room_105_closet_woman")

	assert_bool(lab.preview_selected()).is_true()
	assert_bool(controller.active).is_true()
	assert_bool(manager.is_jumpscare_active()).is_false()
	controller.stop()
