extends GdUnitTestSuite

const MoldGrowthSystem := preload("res://scripts/horror/mold_growth_system.gd")
const EyeCloseController := preload("res://scripts/systems/eye_close_controller.gd")
const EyeCloseProfile := preload("res://scripts/systems/eye_close_profile.gd")
const MoldOverlay := preload("res://scripts/ui/mold_overlay.gd")


func test_mold_uses_random_initial_delay_then_fixed_growth_interval() -> void:
	var mold = MoldGrowthSystem.new()
	mold.initial_cooldown_min = 10.0
	mold.initial_cooldown_max = 10.0
	mold.growth_interval = 2.0
	mold.setup(7)
	mold.register_room("room_105")
	mold.set_enabled(true)

	mold.advance(9.9)
	assert_that(mold.get_mold_stack("room_105")).is_equal(0)
	mold.advance(0.1)
	assert_that(mold.get_mold_stack("room_105")).is_equal(1)
	mold.advance(4.0)
	assert_that(mold.get_mold_stack("room_105")).is_equal(3)


func test_mold_remover_is_the_only_item_that_removes_two_stacks_per_use() -> void:
	var mold = MoldGrowthSystem.new()
	mold.initial_cooldown_min = 10.0
	mold.initial_cooldown_max = 10.0
	mold.setup(2)
	mold.register_room("room_105")
	mold.force_stack("room_105", 6)

	assert_that(mold.remove_mold("room_105", "cleaning_cloth")).is_false()
	assert_that(mold.get_mold_stack("room_105")).is_equal(6)
	assert_that(mold.remove_mold("room_105", "mold_remover")).is_true()
	assert_that(mold.get_mold_stack("room_105")).is_equal(4)
	assert_that(mold.remove_mold("room_105", "mold_remover")).is_true()
	assert_that(mold.get_mold_stack("room_105")).is_equal(2)
	assert_that(mold.remove_mold("room_105", "mold_remover")).is_true()
	assert_that(mold.get_mold_stack("room_105")).is_equal(0)
	mold.force_stack("room_105", 1)
	assert_that(mold.remove_mold("room_105", "mold_remover")).is_true()
	assert_that(mold.get_mold_stack("room_105")).is_equal(0)


func test_eye_close_profile_can_be_injected_and_song_uses_narrow_radius() -> void:
	var eyes = auto_free(EyeCloseController.new())
	var profile = EyeCloseProfile.new()
	profile.vision_radius = 180.0
	profile.anomaly_vision_radius = 82.0
	profile.song_vision_radius = 36.0
	profile.slit_height_scale = 0.46
	eyes.apply_profile(profile)

	eyes.set_anomaly_context(true)
	eyes.close_eyes()
	assert_that(eyes.is_closed()).is_true()
	assert_that(eyes.get_effective_vision_radius()).is_equal(82.0)
	assert_that(eyes.start_song(4.0)).is_true()
	assert_that(eyes.get_effective_vision_radius()).is_equal(36.0)

	eyes.set_debug_vision_radius(120.0)
	assert_that(eyes.get_effective_vision_radius()).is_equal(120.0)
	assert_float(eyes.get_effective_slit_height_scale()).is_equal(0.46)
	eyes.set_debug_slit_height_scale(0.58)
	assert_float(eyes.get_effective_slit_height_scale()).is_equal(0.58)
	eyes.open_eyes()
	assert_that(eyes.is_closed()).is_false()


func test_default_eye_radius_is_preserved_and_visible_area_uses_clean_squint_shader() -> void:
	var eyes = auto_free(EyeCloseController.new())
	add_child(eyes)

	assert_that(eyes.get_effective_vision_radius()).is_equal(150.0)
	assert_that(eyes._mask_material.shader.code).contains("textureLod")
	assert_that(eyes._mask_material.shader.code).not_contains("vhs_apply_signal")
	assert_that(eyes._mask_material.shader.code).contains("slit_half_width")
	assert_that(eyes._mask_material.shader.code).contains("lid_curve")
	assert_float(eyes.profile.slit_height_scale).is_equal(0.40)
	assert_that(eyes._mask_material.shader.code).contains("upper_opening")
	assert_that(eyes._mask_material.shader.code).contains("slit_height_scale")
	assert_that(eyes._mask_material.shader.code).not_contains("distance(pixel, focus_position)")
	assert_that(eyes.profile.visible_brightness).is_equal(0.36)
	assert_that(eyes._mask_material.shader.code).contains("visible_color *= visible_brightness")


func test_mold_overlay_uses_generated_texture_and_supports_six_visual_stages() -> void:
	var overlay = auto_free(MoldOverlay.new())
	overlay.set_photo_rect(Rect2(Vector2.ZERO, Vector2(1456.0, 1092.0)))
	overlay.set_stack(6)

	assert_that(overlay.MOLD_TEXTURE).is_not_null()
	assert_that(overlay.stack).is_equal(6)
	overlay.set_stack(99)
	assert_that(overlay.stack).is_equal(6)
