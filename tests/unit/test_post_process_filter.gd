extends GdUnitTestSuite

const PostProcessFilter := preload("res://scripts/systems/post_process_filter.gd")


func test_filter_presets_are_available_in_debug_order() -> void:
	var post_process_filter = auto_free(PostProcessFilter.new())

	assert_that(post_process_filter.get_available_presets()).is_equal([
		PostProcessFilter.PRESET_NONE,
		PostProcessFilter.PRESET_DREARY_1,
		PostProcessFilter.PRESET_SUBTLE_GRAIN,
	])
	assert_that(post_process_filter.get_preset_display_name(PostProcessFilter.PRESET_NONE)).is_equal("필터 없음")
	assert_that(post_process_filter.get_preset_display_name(PostProcessFilter.PRESET_SUBTLE_GRAIN)).is_equal("자글자글 필터")


func test_filter_visibility_follows_selected_preset() -> void:
	var post_process_filter = auto_free(PostProcessFilter.new())

	post_process_filter.apply_preset(PostProcessFilter.PRESET_SUBTLE_GRAIN)
	assert_that(post_process_filter.current_preset).is_equal(PostProcessFilter.PRESET_SUBTLE_GRAIN)
	assert_that(post_process_filter.visible).is_true()

	post_process_filter.clear_filter()
	assert_that(post_process_filter.current_preset).is_equal(PostProcessFilter.PRESET_NONE)
	assert_that(post_process_filter.visible).is_false()
