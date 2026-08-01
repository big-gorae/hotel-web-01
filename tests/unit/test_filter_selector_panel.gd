extends GdUnitTestSuite

const PostProcessFilter := preload("res://scripts/systems/post_process_filter.gd")
const FilterSelectorPanel := preload("res://scripts/ui/filter_selector_panel.gd")
const Localization := preload("res://scripts/localization.gd")


func test_filter_selector_builds_buttons_from_filter_presets() -> void:
	var post_process_filter = auto_free(PostProcessFilter.new())
	var selector = auto_free(FilterSelectorPanel.new())

	selector.setup(post_process_filter)

	assert_that(selector.get_filter_button_count()).is_equal(3)
	assert_that(selector.intensity_slider).is_not_null()


func test_filter_selector_syncs_current_preset() -> void:
	var post_process_filter = auto_free(PostProcessFilter.new())
	var selector = auto_free(FilterSelectorPanel.new())
	selector.setup(post_process_filter)

	post_process_filter.apply_preset(PostProcessFilter.PRESET_SUBTLE_GRAIN)
	selector.sync_selected_preset()

	var selected_button: Button = _find_selected_filter_button(selector)
	assert_that(selected_button).is_not_null()
	assert_that(String(selected_button.get_meta("filter_preset", ""))).is_equal(PostProcessFilter.PRESET_SUBTLE_GRAIN)


func test_filter_selector_localizes_every_preset_in_korean_and_english() -> void:
	var post_process_filter = auto_free(PostProcessFilter.new())
	var selector = auto_free(FilterSelectorPanel.new())
	var localization := Localization.new()

	localization.set_language(Localization.Language.ENGLISH)
	selector.setup(post_process_filter, "Filter", "Apply", "Intensity", "Intensity", localization)
	assert_str(_find_filter_button(selector, PostProcessFilter.PRESET_NONE).text).is_equal("No filter")
	assert_str(_find_filter_button(selector, PostProcessFilter.PRESET_SUBTLE_GRAIN).text).is_equal("CRT static")

	localization.set_language(Localization.Language.KOREAN)
	selector.rebuild()
	assert_str(_find_filter_button(selector, PostProcessFilter.PRESET_NONE).text).is_equal("필터 없음")
	assert_str(_find_filter_button(selector, PostProcessFilter.PRESET_SUBTLE_GRAIN).text).is_equal("브라운관 지지직")


func test_filter_selector_emits_selected_preset() -> void:
	var post_process_filter = auto_free(PostProcessFilter.new())
	var selector = auto_free(FilterSelectorPanel.new())
	var selected_presets := []
	selector.preset_selected.connect(func(preset_name: String) -> void: selected_presets.append(preset_name))
	selector.setup(post_process_filter)

	selector._on_preset_button_pressed(PostProcessFilter.PRESET_NONE)

	assert_that(selected_presets).is_equal([PostProcessFilter.PRESET_NONE])


func test_filter_selector_updates_bound_filter_intensity() -> void:
	var post_process_filter = auto_free(PostProcessFilter.new())
	var selector = auto_free(FilterSelectorPanel.new())
	selector.setup(post_process_filter)

	selector._on_intensity_slider_changed(1.65)

	assert_that(post_process_filter.get_filter_intensity()).is_equal(1.65)
	assert_that(selector.get_filter_intensity_value()).is_equal(1.65)
	assert_that(selector.intensity_value_label.text).is_equal("165%")


func _find_selected_filter_button(selector) -> Button:
	for child in selector.get_children():
		if child is Button and child.button_pressed:
			return child
	return null


func _find_filter_button(selector, preset_name: String) -> Button:
	for child in selector.get_children():
		if child is Button and String(child.get_meta("filter_preset", "")) == preset_name:
			return child
	return null
