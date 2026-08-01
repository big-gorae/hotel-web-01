class_name HotelFilterSelectorPanel
extends HBoxContainer

signal preset_selected(preset_name: String)

var post_process_filter = null
var localization = null
var title_text := "Filter"
var button_tooltip_text := "Apply this screen filter."
var intensity_text := "Intensity"
var intensity_tooltip_text := "Filter intensity"
var intensity_slider: HSlider
var intensity_value_label: Label


func _init() -> void:
	add_theme_constant_override("separation", 8)


func setup(new_post_process_filter, new_title_text := "Filter", new_button_tooltip_text := "Apply this screen filter.", new_intensity_text := "Intensity", new_intensity_tooltip_text := "Filter intensity", new_localization = null) -> void:
	post_process_filter = new_post_process_filter
	localization = new_localization
	title_text = new_title_text
	button_tooltip_text = new_button_tooltip_text
	intensity_text = new_intensity_text
	intensity_tooltip_text = new_intensity_tooltip_text
	rebuild()


func rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	if post_process_filter == null:
		return

	var title := Label.new()
	title.text = title_text
	title.custom_minimum_size = Vector2(54.0, 0.0)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.58))
	add_child(title)

	for preset_name in post_process_filter.get_available_presets():
		var button := Button.new()
		var preset_id := String(preset_name)
		var fallback_name: String = post_process_filter.get_preset_display_name(preset_id)
		button.text = _text("debug.filters.preset.%s" % preset_id, fallback_name)
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(120.0, 32.0)
		button.tooltip_text = button_tooltip_text
		button.set_meta("filter_preset", String(preset_name))
		button.pressed.connect(_on_preset_button_pressed.bind(String(preset_name)))
		add_child(button)

	var intensity_label := Label.new()
	intensity_label.text = intensity_text
	intensity_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	intensity_label.add_theme_font_size_override("font_size", 14)
	intensity_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.58))
	add_child(intensity_label)

	intensity_slider = HSlider.new()
	intensity_slider.min_value = post_process_filter.MIN_INTENSITY
	intensity_slider.max_value = post_process_filter.MAX_INTENSITY
	intensity_slider.step = 0.05
	intensity_slider.custom_minimum_size = Vector2(170.0, 32.0)
	intensity_slider.focus_mode = Control.FOCUS_NONE
	intensity_slider.tooltip_text = intensity_tooltip_text
	intensity_slider.value_changed.connect(_on_intensity_slider_changed)
	add_child(intensity_slider)

	intensity_value_label = Label.new()
	intensity_value_label.custom_minimum_size = Vector2(52.0, 0.0)
	intensity_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	intensity_value_label.add_theme_font_size_override("font_size", 14)
	intensity_value_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	add_child(intensity_value_label)

	sync_selected_preset()
	sync_filter_intensity()


func sync_selected_preset() -> void:
	if post_process_filter == null:
		return

	for child in get_children():
		if child is Button:
			var preset_name := String(child.get_meta("filter_preset", ""))
			var is_current: bool = preset_name == post_process_filter.current_preset
			child.button_pressed = is_current
			_style_button(child, is_current)


func get_filter_button_count() -> int:
	var count := 0
	for child in get_children():
		if child is Button:
			count += 1
	return count


func sync_filter_intensity() -> void:
	if post_process_filter == null or intensity_slider == null or intensity_value_label == null:
		return

	var intensity: float = post_process_filter.get_filter_intensity()
	intensity_slider.set_value_no_signal(intensity)
	intensity_value_label.text = "%d%%" % int(roundf(intensity * 100.0))


func get_filter_intensity_value() -> float:
	if intensity_slider == null:
		return 0.0

	return float(intensity_slider.value)


func _on_preset_button_pressed(preset_name: String) -> void:
	preset_selected.emit(preset_name)


func _on_intensity_slider_changed(value: float) -> void:
	if post_process_filter != null:
		post_process_filter.set_filter_intensity(value)
	sync_filter_intensity()


func _style_button(button: Button, enabled: bool) -> void:
	var background := Color(0.25, 0.72, 1.0, 0.24) if enabled else Color(1.0, 1.0, 1.0, 0.05)
	var border := Color(0.45, 0.82, 1.0, 0.85) if enabled else Color(1.0, 1.0, 1.0, 0.18)
	button.add_theme_stylebox_override("normal", _make_panel_style(background, border, 6))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(1.0, 0.82, 0.28, 0.20), Color(1.0, 0.82, 0.28, 0.85), 6))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.25, 0.72, 1.0, 0.30), Color(0.45, 0.82, 1.0, 0.95), 6))
	button.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 0.72) if enabled else Color(0.95, 0.95, 0.95, 0.50))


func _text(key: String, fallback: String) -> String:
	if localization == null:
		return fallback
	return localization.translate("ui.%s" % key, fallback)


func _make_panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style
