class_name HotelFilterSelectorPanel
extends HBoxContainer

signal preset_selected(preset_name: String)

var post_process_filter = null
var title_text := "Filter"
var button_tooltip_text := "Apply this screen filter."


func _init() -> void:
	add_theme_constant_override("separation", 8)


func setup(new_post_process_filter, new_title_text := "Filter", new_button_tooltip_text := "Apply this screen filter.") -> void:
	post_process_filter = new_post_process_filter
	title_text = new_title_text
	button_tooltip_text = new_button_tooltip_text
	rebuild()


func rebuild() -> void:
	for child in get_children():
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
		button.text = post_process_filter.get_preset_display_name(String(preset_name))
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(120.0, 32.0)
		button.tooltip_text = button_tooltip_text
		button.set_meta("filter_preset", String(preset_name))
		button.pressed.connect(_on_preset_button_pressed.bind(String(preset_name)))
		add_child(button)

	sync_selected_preset()


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


func _on_preset_button_pressed(preset_name: String) -> void:
	preset_selected.emit(preset_name)


func _style_button(button: Button, enabled: bool) -> void:
	var background := Color(0.25, 0.72, 1.0, 0.24) if enabled else Color(1.0, 1.0, 1.0, 0.05)
	var border := Color(0.45, 0.82, 1.0, 0.85) if enabled else Color(1.0, 1.0, 1.0, 0.18)
	button.add_theme_stylebox_override("normal", _make_panel_style(background, border, 6))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(1.0, 0.82, 0.28, 0.20), Color(1.0, 0.82, 0.28, 0.85), 6))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.25, 0.72, 1.0, 0.30), Color(0.45, 0.82, 1.0, 0.95), 6))
	button.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 0.72) if enabled else Color(0.95, 0.95, 0.95, 0.50))


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
