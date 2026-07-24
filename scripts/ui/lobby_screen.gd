class_name HotelLobbyScreen
extends Control

signal start_shift_requested
signal day_selected(day: int)
signal quit_requested

const AnomalyCollectionPanel := preload("res://scripts/ui/anomaly_collection_panel.gd")
const LOBBY_BLUR_SHADER_CODE := "shader_type canvas_item;\nuniform float blur_size = 3.5;\nvoid fragment() {\n\tvec2 px = TEXTURE_PIXEL_SIZE * blur_size;\n\tvec4 color = texture(TEXTURE, UV) * 0.18;\n\tcolor += texture(TEXTURE, UV + vec2(px.x, 0.0)) * 0.12;\n\tcolor += texture(TEXTURE, UV - vec2(px.x, 0.0)) * 0.12;\n\tcolor += texture(TEXTURE, UV + vec2(0.0, px.y)) * 0.12;\n\tcolor += texture(TEXTURE, UV - vec2(0.0, px.y)) * 0.12;\n\tcolor += texture(TEXTURE, UV + vec2(px.x, px.y)) * 0.11;\n\tcolor += texture(TEXTURE, UV + vec2(-px.x, px.y)) * 0.11;\n\tcolor += texture(TEXTURE, UV + vec2(px.x, -px.y)) * 0.11;\n\tcolor += texture(TEXTURE, UV - vec2(px.x, px.y)) * 0.11;\n\tfloat luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));\n\tcolor.rgb = mix(vec3(luma), color.rgb, 0.74);\n\tcolor.rgb = (color.rgb - 0.5) * 1.10 + 0.5 - 0.02;\n\tcolor.rgb = mix(color.rgb, color.rgb * vec3(1.0, 0.91, 0.70), 0.18);\n\tfloat dist = distance(UV, vec2(0.5));\n\tfloat vignette = smoothstep(0.35, 0.82, dist);\n\tcolor.rgb *= 1.0 - vignette * 0.22;\n\tCOLOR = vec4(clamp(color.rgb, vec3(0.0), vec3(1.0)), color.a);\n}\n"
var localization = null
var horror_event_manager = null
var day_save_manager = null
var continue_button: Button
var day_panel: PanelContainer
var day_grid: GridContainer
var horror_summary_label: Label
var anomaly_collection_panel


func setup(new_localization, new_horror_event_manager, new_day_save_manager, background_photo: String) -> void:
	localization = new_localization
	horror_event_manager = new_horror_event_manager
	day_save_manager = new_day_save_manager
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build(background_photo)
	refresh_continue_state()


func open(summary_text: String) -> void:
	refresh_continue_state()
	refresh_horror_summary(summary_text)
	visible = true
	move_to_front()


func close() -> void:
	visible = false


func toggle_day_panel() -> void:
	if not day_save_manager.has_save_data():
		return
	day_panel.visible = not day_panel.visible
	refresh_day_grid()


func refresh_continue_state() -> void:
	var has_save: bool = day_save_manager.has_save_data()
	continue_button.disabled = not has_save
	continue_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if has_save else Control.CURSOR_FORBIDDEN
	continue_button.tooltip_text = ""
	if not has_save:
		day_panel.visible = false
	refresh_day_grid()


func refresh_horror_summary(summary_text: String) -> void:
	horror_summary_label.text = summary_text
	anomaly_collection_panel.refresh()


func toggle_anomaly_collection() -> void:
	anomaly_collection_panel.refresh()
	anomaly_collection_panel.visible = not anomaly_collection_panel.visible


func hide_anomaly_collection() -> void:
	anomaly_collection_panel.visible = false


func refresh_day_grid() -> void:
	for child in day_grid.get_children():
		child.queue_free()
	for day in range(1, day_save_manager.TOTAL_DAYS + 1):
		var day_button := Button.new()
		day_button.process_mode = Node.PROCESS_MODE_ALWAYS
		day_button.custom_minimum_size = Vector2(72.0, 48.0)
		day_button.text = _day_name(day)
		day_button.focus_mode = Control.FOCUS_NONE
		day_button.disabled = not day_save_manager.has_saved_day(day)
		day_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not day_button.disabled else Control.CURSOR_FORBIDDEN
		day_button.tooltip_text = _text("lobby.day.saved", "Start from this saved day.") if not day_button.disabled else _text("lobby.day.locked", "Reach this day first.")
		day_button.pressed.connect(_on_day_selected.bind(day))
		day_grid.add_child(day_button)


func _on_day_selected(day: int) -> void:
	day_selected.emit(day)


func _build(background_photo: String) -> void:
	var background := TextureRect.new()
	background.process_mode = Node.PROCESS_MODE_ALWAYS
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.texture = load(background_photo) as Texture2D
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.material = _make_blur_material()
	add_child(background)

	var shade := ColorRect.new()
	shade.process_mode = Node.PROCESS_MODE_ALWAYS
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.color = Color(0.0, 0.0, 0.0, 0.46)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var center := CenterContainer.new()
	center.process_mode = Node.PROCESS_MODE_ALWAYS
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	panel.custom_minimum_size = Vector2(460.0, 0.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.90), Color(1.0, 1.0, 1.0, 0.14), 12))
	center.add_child(panel)

	var layout := VBoxContainer.new()
	layout.process_mode = Node.PROCESS_MODE_ALWAYS
	layout.add_theme_constant_override("separation", 14)
	panel.add_child(layout)

	var title := Label.new()
	title.text = _text("lobby.title", "Night Shift")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(1.0, 0.92, 0.72))
	layout.add_child(title)

	horror_summary_label = Label.new()
	horror_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	horror_summary_label.add_theme_font_size_override("font_size", 14)
	horror_summary_label.add_theme_color_override("font_color", Color(0.82, 0.75, 0.62))
	layout.add_child(horror_summary_label)

	layout.add_child(_make_button(_text("lobby.start_shift", "Start Shift"), func(): start_shift_requested.emit()))
	continue_button = _make_button(_text("lobby.continue", "Continue"), toggle_day_panel)
	layout.add_child(continue_button)

	day_panel = PanelContainer.new()
	day_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	day_panel.visible = false
	day_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.02, 0.024, 0.028, 0.70), Color(1.0, 1.0, 1.0, 0.08), 10))
	layout.add_child(day_panel)
	var day_layout := VBoxContainer.new()
	day_layout.process_mode = Node.PROCESS_MODE_ALWAYS
	day_layout.add_theme_constant_override("separation", 10)
	day_panel.add_child(day_layout)
	var day_title := Label.new()
	day_title.text = _text("lobby.choose_day", "Choose Day")
	day_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_title.add_theme_font_size_override("font_size", 16)
	day_title.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	day_layout.add_child(day_title)
	day_grid = GridContainer.new()
	day_grid.process_mode = Node.PROCESS_MODE_ALWAYS
	day_grid.columns = day_save_manager.TOTAL_DAYS
	day_grid.add_theme_constant_override("h_separation", 8)
	day_layout.add_child(day_grid)

	layout.add_child(_make_button(_text("lobby.anomaly_collection", "Anomaly Collection"), toggle_anomaly_collection))
	anomaly_collection_panel = AnomalyCollectionPanel.new()
	anomaly_collection_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	anomaly_collection_panel.visible = false
	anomaly_collection_panel.setup(horror_event_manager, localization)
	anomaly_collection_panel.close_requested.connect(hide_anomaly_collection)
	layout.add_child(anomaly_collection_panel)
	layout.add_child(_make_button(_text("lobby.quit", "Quit"), func(): quit_requested.emit()))


func _make_button(text_value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.text = text_value
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(callback)
	return button


func _day_name(day: int) -> String:
	return _text("day.label", "Day %d") % day


func _text(key: String, fallback: String) -> String:
	return localization.translate("ui.%s" % key, fallback) if localization != null else fallback


func _make_blur_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = LOBBY_BLUR_SHADER_CODE
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("blur_size", 4.0)
	return material


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
