extends GdUnitTestSuite

const HoldController := preload("res://scripts/interactions/hold_interaction_controller.gd")


func test_reset_policy_clears_progress_when_released() -> void:
	var controller = HoldController.new()
	controller.begin("monitor", 2.0)
	controller.advance(1.0)
	assert_float(controller.get_progress()).is_equal_approx(0.5, 0.001)

	controller.set_held(false)
	assert_float(controller.get_progress()).is_equal_approx(0.0, 0.001)


func test_pause_policy_keeps_progress_when_released() -> void:
	var controller = HoldController.new()
	controller.begin("song", 2.0, HoldController.INTERRUPT_PAUSE)
	controller.advance(1.0)
	controller.set_held(false)
	controller.advance(1.0)
	assert_float(controller.get_progress()).is_equal_approx(0.5, 0.001)

	controller.set_held(true)
	controller.advance(1.0)
	assert_that(controller.is_active()).is_false()


func test_beginning_new_hold_cancels_previous_hold() -> void:
	var controller = HoldController.new()
	var cancelled_ids := []
	controller.hold_cancelled.connect(func(hold_id: String) -> void: cancelled_ids.append(hold_id))
	controller.begin("first", 3.0)
	controller.begin("second", 3.0)

	assert_that(cancelled_ids).contains_exactly(["first"])
	assert_that(controller.active_hold_id).is_equal("second")
