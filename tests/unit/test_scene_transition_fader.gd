extends GdUnitTestSuite

const SceneTransitionFader := preload("res://scripts/ui/scene_transition_fader.gd")


func test_anomaly_transition_changes_state_only_after_screen_is_black() -> void:
	var fader = auto_free(SceneTransitionFader.new())
	add_child(fader)
	fader.set_anomaly_fade_seconds(0.05)
	fader.anomaly_hold_seconds = 0.01
	var callback_state := {"alpha": -1.0}

	fader.play_anomaly_resolution(func(): callback_state["alpha"] = fader.color.a)

	assert_bool(fader.is_transitioning()).is_true()
	assert_bool(fader.visible).is_true()
	assert_int(fader.mouse_filter).is_equal(Control.MOUSE_FILTER_STOP)
	await get_tree().create_timer(0.075, true, false, true).timeout
	assert_float(float(callback_state["alpha"])).is_equal_approx(1.0, 0.001)
	await get_tree().create_timer(0.08, true, false, true).timeout
	assert_bool(fader.is_transitioning()).is_false()
	assert_bool(fader.visible).is_false()
	assert_int(fader.mouse_filter).is_equal(Control.MOUSE_FILTER_IGNORE)


func test_default_anomaly_transition_keeps_total_timing_with_a_shorter_hold() -> void:
	var fader = auto_free(SceneTransitionFader.new())

	assert_int(fader.process_mode).is_equal(Node.PROCESS_MODE_ALWAYS)
	assert_float(fader.anomaly_fade_out_seconds).is_equal(0.49)
	assert_float(fader.anomaly_hold_seconds).is_equal(0.02)
	assert_float(fader.anomaly_fade_in_seconds).is_equal(0.56)
	assert_float(
		fader.anomaly_fade_out_seconds
		+ fader.anomaly_hold_seconds
		+ fader.anomaly_fade_in_seconds
	).is_equal_approx(1.07, 0.001)


func test_anomaly_fade_uses_smooth_perceptual_alpha() -> void:
	var fader = auto_free(SceneTransitionFader.new())

	fader._set_perceptual_darkness(0.0)
	assert_float(fader.color.a).is_equal(0.0)
	fader._set_perceptual_darkness(0.5)
	assert_float(fader.color.a).is_equal_approx(0.7824, 0.0001)
	fader._set_perceptual_darkness(1.0)
	assert_float(fader.color.a).is_equal(1.0)


func test_anomaly_transition_accepts_zero_fade_seconds() -> void:
	var fader = auto_free(SceneTransitionFader.new())

	fader.set_anomaly_fade_seconds(0.0)

	assert_float(fader.anomaly_fade_out_seconds).is_equal(0.0)
	assert_float(fader.anomaly_fade_in_seconds).is_equal(0.0)
