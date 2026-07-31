extends GdUnitTestSuite

const AnomalyVisualOverlay := preload("res://scripts/ui/anomaly_visual_overlay.gd")


func test_shadow_flicker_only_animates_after_bell_distress() -> void:
	var overlay = auto_free(AnomalyVisualOverlay.new())
	add_child(overlay)
	overlay.set_scene("front_desk")
	overlay.set_photo_rect(Rect2(0.0, 0.0, 1280.0, 720.0))

	overlay.apply_presentation_state({
		"event_id": "hotel_following_shadow",
		"state": "attached",
		"scene_id": "",
	})
	overlay._process(0.20)
	assert_float(overlay.get_shadow_flicker_alpha()).is_equal(0.0)

	overlay.apply_presentation_state({
		"event_id": "hotel_following_shadow",
		"state": "bell_distressed",
		"scene_id": "",
	})
	overlay._process(0.08)
	assert_float(overlay.get_shadow_flicker_alpha()).is_greater(0.0)

	overlay.apply_presentation_state({})
	assert_float(overlay.get_shadow_flicker_alpha()).is_equal(0.0)


func test_hanging_girl_angry_eyes_remain_visible_over_full_scene_artifact() -> void:
	var overlay = auto_free(AnomalyVisualOverlay.new())
	add_child(overlay)
	overlay.set_scene("room_107_bed_nightstand")
	overlay.set_photo_rect(Rect2(0.0, 0.0, 1448.0, 1086.0))
	overlay.apply_presentation_state({
		"event_id": "room_107_hanging_girl",
		"state": "hostile",
		"scene_id": "room_107_bed_nightstand",
	})
	overlay.set_suppressed(true)

	assert_bool(overlay.visible).is_true()

	overlay.apply_presentation_state({
		"event_id": "room_107_hanging_girl",
		"state": "visible",
		"scene_id": "room_107_bed_nightstand",
	})
	assert_bool(overlay.visible).is_false()
