extends GdUnitTestSuite

const HoldProgressOverlay := preload("res://scripts/ui/hold_progress_overlay.gd")


func test_show_and_hide_circular_hold() -> void:
	var overlay = auto_free(HoldProgressOverlay.new())
	add_child(overlay)

	overlay.show_hold(HoldProgressOverlay.MODE_CIRCULAR, Vector2(100.0, 120.0))

	assert_bool(overlay.is_showing_hold()).is_true()
	assert_bool(overlay.visible).is_true()

	overlay.set_progress(0.5)
	overlay.hide_hold()

	assert_bool(overlay.is_showing_hold()).is_false()
	assert_bool(overlay.visible).is_false()


func test_horizontal_hold_is_supported() -> void:
	var overlay = auto_free(HoldProgressOverlay.new())
	add_child(overlay)

	overlay.show_hold(HoldProgressOverlay.MODE_HORIZONTAL)
	overlay.set_progress(2.0)

	assert_bool(overlay.is_showing_hold()).is_true()
