extends GdUnitTestSuite

const PresentationLayer := preload("res://scripts/ui/anomaly_presentation_layer.gd")


func test_baby_wallpaper_uses_generated_scene_and_restores_each_clicked_surface() -> void:
	var layer = auto_free(PresentationLayer.new())
	add_child(layer)
	layer.reload_manifests()
	layer.set_scene("laundry_room")
	layer.set_photo_rect(Rect2(20.0, 30.0, 1000.0, 700.0))

	assert_bool(layer.apply_presentation_state({
		"event_id": "laundry_baby_face_surfaces",
		"state": "visible",
		"closed_surfaces": [],
	})).is_true()
	assert_int(layer.get_child_count()).is_equal(1)

	layer.apply_presentation_state({
		"event_id": "laundry_baby_face_surfaces",
		"state": "visible",
		"closed_surfaces": ["front", "ceiling"],
	})

	assert_int(layer.get_child_count()).is_equal(3)
	var restored_surface_count := 0
	for child in layer.get_children():
		if child.has_meta("normalized_rect"):
			restored_surface_count += 1
	assert_int(restored_surface_count).is_equal(2)


func test_shower_event_selects_the_manifest_for_its_saved_room() -> void:
	var layer = auto_free(PresentationLayer.new())
	add_child(layer)
	layer.reload_manifests()
	layer.set_scene("room_107_bathroom")
	layer.set_photo_rect(Rect2(0.0, 0.0, 1000.0, 700.0))

	assert_bool(layer.apply_presentation_state({
		"event_id": "bathroom_shower_legs",
		"state": "legs",
		"scene_id": "room_107_bathroom",
		"curtain_legs_visible": true,
	})).is_true()
	assert_int(layer.get_child_count()).is_equal(1)


func test_red_washer_artifact_persists_until_the_laundry_is_discarded() -> void:
	var layer = auto_free(PresentationLayer.new())
	add_child(layer)
	layer.reload_manifests()
	layer.set_scene("laundry_room")
	layer.set_photo_rect(Rect2(0.0, 0.0, 1448.0, 1086.0))

	for state_id in ["red", "music", "ready"]:
		assert_bool(layer.apply_presentation_state({
			"event_id": "laundry_red_washer",
			"state": state_id,
			"scene_id": "laundry_room",
		})).override_failure_message("missing red washer artifact for %s" % state_id).is_true()
		assert_int(layer.get_child_count()).is_equal(1)

	assert_bool(layer.apply_presentation_state({
		"event_id": "laundry_red_washer",
		"state": "discarded",
		"scene_id": "laundry_room",
	})).is_false()
