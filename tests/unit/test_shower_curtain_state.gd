extends GdUnitTestSuite

const FlagStore := preload("res://scripts/systems/flag_store.gd")
const HotelSceneCatalog := preload("res://scripts/scenes/hotel_scene_catalog.gd")
const ShowerCurtainState := preload("res://scripts/interactions/shower_curtain_state.gd")


func test_each_bathroom_has_an_independent_curtain_state_and_photo() -> void:
	var flags := FlagStore.new()
	var curtains := ShowerCurtainState.new()
	curtains.setup(flags)

	for room_number in [105, 106, 107, 108]:
		var scene_id := "room_%d_bathroom" % room_number
		var scene_data: Dictionary = HotelSceneCatalog.get_scene(scene_id)
		assert_that(curtains.supports_scene(scene_data)).is_true()
		assert_that(FileAccess.file_exists(String(scene_data.get("curtain_closed_photo", "")))).is_true()
		assert_that(curtains.is_closed(scene_id)).is_false()

	assert_that(curtains.toggle("room_105_bathroom")).is_true()
	assert_that(curtains.is_closed("room_105_bathroom")).is_true()
	assert_that(curtains.is_closed("room_106_bathroom")).is_false()
	var closed_photo := curtains.photo_path("room_105_bathroom", HotelSceneCatalog.get_scene("room_105_bathroom"))
	assert_that(closed_photo.ends_with("_curtain_closed.png")).is_true()


func test_closed_curtain_uses_the_larger_click_area() -> void:
	var flags := FlagStore.new()
	var curtains := ShowerCurtainState.new()
	curtains.setup(flags)

	var open_hotspot: Dictionary = curtains.make_hotspot("room_108_bathroom")
	curtains.toggle("room_108_bathroom")
	var closed_hotspot: Dictionary = curtains.make_hotspot("room_108_bathroom")
	var open_rect: Rect2 = open_hotspot.get("rect")
	var closed_rect: Rect2 = closed_hotspot.get("rect")

	assert_that(open_hotspot.get("id", "")).is_equal(ShowerCurtainState.HOTSPOT_ID)
	assert_that(open_rect.size.x).is_less(closed_rect.size.x)
	assert_that(open_rect.position).is_equal(closed_rect.position)


func test_explicit_preview_state_builds_matching_click_area_without_changing_saved_state() -> void:
	var flags := FlagStore.new()
	var curtains := ShowerCurtainState.new()
	curtains.setup(flags)

	var preview_hotspot: Dictionary = curtains.make_hotspot_for_state(true)
	var preview_rect: Rect2 = preview_hotspot.get("rect")

	assert_that(preview_rect).is_equal(ShowerCurtainState.CLOSED_CLICK_RECT)
	assert_that(curtains.is_closed("room_105_bathroom")).is_false()
