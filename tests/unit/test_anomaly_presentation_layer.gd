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
