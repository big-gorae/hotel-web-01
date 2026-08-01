class_name HotelJumpscareLab
extends Control

signal preview_requested(event_id: String)

const FIT_COVER := "cover"
const FIT_CONTAIN := "contain"
const TUNABLE_FIELDS := [
	{
		"key": "jumpscare_hold_seconds",
		"label": "Lunge delay",
		"min": 0.0,
		"max": 1.2,
		"step": 0.01,
		"suffix": " s",
		"hint": "Time from first appearance until the lunge starts",
	},
	{
		"key": "jumpscare_initial_zoom",
		"label": "Initial scale",
		"min": 0.5,
		"max": 1.8,
		"step": 0.01,
		"suffix": "×",
		"hint": "Size of the source image when it first appears",
	},
	{
		"key": "jumpscare_lunge_seconds",
		"label": "Lunge duration",
		"min": 0.05,
		"max": 1.0,
		"step": 0.01,
		"suffix": " s",
		"hint": "Time required to reach the final scale",
	},
	{
		"key": "jumpscare_lunge_zoom",
		"label": "Lunge scale",
		"min": 1.1,
		"max": 4.0,
		"step": 0.05,
		"suffix": "×",
		"hint": "Scale at the end of the lunge",
	},
	{
		"key": "jumpscare_duration",
		"label": "Total duration",
		"min": 0.5,
		"max": 4.0,
		"step": 0.05,
		"suffix": " s",
		"hint": "Time from first appearance until the preview ends",
	},
	{
		"key": "jumpscare_focus_x",
		"label": "Focus X",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"suffix": "",
		"hint": "0 is left; 1 is right",
	},
	{
		"key": "jumpscare_focus_y",
		"label": "Focus Y",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"suffix": "",
		"hint": "0 is top; 1 is bottom",
	},
	{
		"key": "jumpscare_initial_shake",
		"label": "Initial shake",
		"min": 0.0,
		"max": 24.0,
		"step": 0.5,
		"suffix": " px",
		"hint": "Screen shake on the first frame",
	},
	{
		"key": "jumpscare_lunge_shake",
		"label": "Lunge shake",
		"min": 0.0,
		"max": 32.0,
		"step": 0.5,
		"suffix": " px",
		"hint": "Screen shake at the lunge",
	},
	{
		"key": "jumpscare_audio_volume_db",
		"label": "Impact volume",
		"min": -30.0,
		"max": 0.0,
		"step": 0.5,
		"suffix": " dB",
		"hint": "Preview volume",
	},
]

var horror_event_manager
var jumpscare_controller
var localization
var selected_definition

var event_selector: OptionButton
var fit_selector: OptionButton
var controls: Dictionary = {}
var preview_button: Button
var reset_button: Button
var close_button: Button
var status_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	visible = false


func setup(new_event_manager, new_jumpscare_controller, new_localization = null) -> void:
	horror_event_manager = new_event_manager
	jumpscare_controller = new_jumpscare_controller
	if localization != null and localization.language_changed.is_connected(_on_language_changed):
		localization.language_changed.disconnect(_on_language_changed)
	localization = new_localization
	if localization != null and not localization.language_changed.is_connected(_on_language_changed):
		localization.language_changed.connect(_on_language_changed)
	_rebuild_ui()


func open_lab(event_id := "room_106_abandoned_child") -> void:
	if event_selector.item_count <= 0:
		_populate_events()
	select_event_by_id(event_id)
	visible = true
	move_to_front()


func close_lab() -> void:
	visible = false


func select_event_by_id(event_id: String) -> bool:
	for index in event_selector.item_count:
		if String(event_selector.get_item_metadata(index)) == event_id:
			event_selector.select(index)
			_on_event_selected(index)
			return true
	if event_selector.item_count > 0:
		event_selector.select(0)
		_on_event_selected(0)
	return false


func set_control_value(key: String, value: float) -> void:
	var spin := controls.get(key) as SpinBox
	if spin != null:
		spin.value = value


func get_control_value(key: String) -> float:
	var spin := controls.get(key) as SpinBox
	return float(spin.value) if spin != null else 0.0


func build_preview_definition():
	if selected_definition == null:
		return null
	var preview = selected_definition.copy()
	preview.jumpscare_outcome = "continue"
	preview.jumpscare_fit_mode = (
		FIT_CONTAIN
		if fit_selector.get_selected_id() == 1
		else FIT_COVER
	)
	preview.jumpscare_hold_seconds = get_control_value("jumpscare_hold_seconds")
	preview.jumpscare_initial_zoom = get_control_value("jumpscare_initial_zoom")
	preview.jumpscare_lunge_seconds = get_control_value("jumpscare_lunge_seconds")
	preview.jumpscare_lunge_zoom = get_control_value("jumpscare_lunge_zoom")
	preview.jumpscare_duration = maxf(
		get_control_value("jumpscare_duration"),
		preview.jumpscare_hold_seconds + preview.jumpscare_lunge_seconds + 0.2
	)
	preview.jumpscare_focus_point = Vector2(
		get_control_value("jumpscare_focus_x"),
		get_control_value("jumpscare_focus_y")
	)
	preview.jumpscare_initial_shake = get_control_value("jumpscare_initial_shake")
	preview.jumpscare_lunge_shake = get_control_value("jumpscare_lunge_shake")
	preview.jumpscare_audio_volume_db = get_control_value("jumpscare_audio_volume_db")
	return preview


func preview_selected() -> bool:
	if jumpscare_controller == null:
		return false
	var preview = build_preview_definition()
	if preview == null:
		return false
	jumpscare_controller.play(preview, localization)
	preview_requested.emit(String(preview.id))
	status_label.text = _text("status.playing", "%s preview playing · deaths/saves unaffected") % _event_label(preview)
	return true


func _rebuild_ui() -> void:
	var selected_event_id := ""
	if event_selector != null and event_selector.selected >= 0 and event_selector.selected < event_selector.item_count:
		selected_event_id = String(event_selector.get_item_metadata(event_selector.selected))
	for child in get_children():
		remove_child(child)
		child.queue_free()
	controls.clear()
	event_selector = null
	fit_selector = null
	preview_button = null
	reset_button = null
	close_button = null
	status_label = null
	_build_ui()
	_populate_events()
	if not selected_event_id.is_empty():
		select_event_by_id(selected_event_id)


func _build_ui() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.78)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(880.0, 650.0)
	panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color(0.025, 0.028, 0.035, 0.98), Color(0.85, 0.18, 0.14, 0.72), 12)
	)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var title_row := HBoxContainer.new()
	layout.add_child(title_row)
	var title := Label.new()
	title.text = "⚡ %s" % _text("title", "Jumpscare Lab")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1.0, 0.83, 0.55))
	title_row.add_child(title)
	close_button = Button.new()
	close_button.text = _text("close", "Close")
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(close_lab)
	title_row.add_child(close_button)

	var intro := Label.new()
	intro.text = _text("intro", "Adjust the values and preview the result. Changes are used only in this lab and are not saved to game data.")
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_theme_color_override("font_color", Color(0.78, 0.80, 0.84))
	layout.add_child(intro)

	var source_grid := GridContainer.new()
	source_grid.columns = 2
	source_grid.add_theme_constant_override("h_separation", 14)
	source_grid.add_theme_constant_override("v_separation", 8)
	layout.add_child(source_grid)
	source_grid.add_child(_make_label(_text("entity", "Entity")))
	event_selector = OptionButton.new()
	event_selector.custom_minimum_size = Vector2(460.0, 34.0)
	event_selector.focus_mode = Control.FOCUS_NONE
	event_selector.item_selected.connect(_on_event_selected)
	source_grid.add_child(event_selector)
	source_grid.add_child(_make_label(_text("source_fit", "Source fit")))
	fit_selector = OptionButton.new()
	fit_selector.custom_minimum_size = Vector2(240.0, 34.0)
	fit_selector.focus_mode = Control.FOCUS_NONE
	fit_selector.add_item(_text("fit.cover", "Fill screen · Cover"), 0)
	fit_selector.add_item(_text("fit.contain", "Original ratio · Contain"), 1)
	source_grid.add_child(fit_selector)

	var separator := HSeparator.new()
	layout.add_child(separator)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 7)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(grid)
	for field in TUNABLE_FIELDS:
		var field_key := String(field["key"])
		grid.add_child(_make_label(_text("field.%s.label" % field_key, String(field["label"]))))
		var spin := SpinBox.new()
		spin.min_value = float(field["min"])
		spin.max_value = float(field["max"])
		spin.step = float(field["step"])
		spin.suffix = _field_suffix(field_key, String(field["suffix"]))
		spin.allow_greater = false
		spin.allow_lesser = false
		spin.custom_minimum_size = Vector2(185.0, 32.0)
		spin.update_on_text_changed = true
		controls[String(field["key"])] = spin
		grid.add_child(spin)
		var hint := _make_label(_text("field.%s.hint" % field_key, String(field["hint"])))
		hint.add_theme_color_override("font_color", Color(0.60, 0.64, 0.70))
		grid.add_child(hint)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 10)
	layout.add_child(action_row)
	preview_button = Button.new()
	preview_button.text = "▶ %s" % _text("preview", "Preview current values")
	preview_button.custom_minimum_size = Vector2(250.0, 42.0)
	preview_button.focus_mode = Control.FOCUS_NONE
	preview_button.pressed.connect(preview_selected)
	action_row.add_child(preview_button)
	reset_button = Button.new()
	reset_button.text = "↺ %s" % _text("reset", "Entity defaults")
	reset_button.custom_minimum_size = Vector2(190.0, 42.0)
	reset_button.focus_mode = Control.FOCUS_NONE
	reset_button.pressed.connect(_load_selected_definition)
	action_row.add_child(reset_button)
	status_label = Label.new()
	status_label.text = _text("status.safe", "Previews do not change death state or saves.")
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_label.add_theme_color_override("font_color", Color(0.72, 0.84, 0.74))
	action_row.add_child(status_label)


func _populate_events() -> void:
	event_selector.clear()
	if horror_event_manager == null:
		return
	var event_ids: Array[String] = []
	for event_id in horror_event_manager.definitions_by_id:
		var definition = horror_event_manager.get_definition(String(event_id))
		if definition != null and not String(definition.jumpscare_image_path).is_empty():
			event_ids.append(String(event_id))
	event_ids.sort()
	for event_id in event_ids:
		var definition = horror_event_manager.get_definition(event_id)
		var label := "%s · %s" % [_event_label(definition), event_id]
		event_selector.add_item(label)
		event_selector.set_item_metadata(event_selector.item_count - 1, event_id)
	if event_selector.item_count > 0:
		event_selector.select(0)
		_on_event_selected(0)


func _on_event_selected(index: int) -> void:
	if horror_event_manager == null or index < 0 or index >= event_selector.item_count:
		return
	var event_id := String(event_selector.get_item_metadata(index))
	selected_definition = horror_event_manager.get_definition(event_id)
	_load_selected_definition()


func _load_selected_definition() -> void:
	if selected_definition == null:
		return
	fit_selector.select(1 if String(selected_definition.jumpscare_fit_mode) == FIT_CONTAIN else 0)
	set_control_value("jumpscare_hold_seconds", float(selected_definition.jumpscare_hold_seconds))
	set_control_value("jumpscare_initial_zoom", float(selected_definition.jumpscare_initial_zoom))
	set_control_value("jumpscare_lunge_seconds", float(selected_definition.jumpscare_lunge_seconds))
	set_control_value("jumpscare_lunge_zoom", float(selected_definition.jumpscare_lunge_zoom))
	set_control_value("jumpscare_duration", float(selected_definition.jumpscare_duration))
	set_control_value("jumpscare_focus_x", float(selected_definition.jumpscare_focus_point.x))
	set_control_value("jumpscare_focus_y", float(selected_definition.jumpscare_focus_point.y))
	set_control_value("jumpscare_initial_shake", float(selected_definition.jumpscare_initial_shake))
	set_control_value("jumpscare_lunge_shake", float(selected_definition.jumpscare_lunge_shake))
	set_control_value("jumpscare_audio_volume_db", float(selected_definition.jumpscare_audio_volume_db))
	status_label.text = _text("status.loaded", "%s defaults loaded") % _event_label(selected_definition)


func _event_label(definition) -> String:
	var fallback := String(definition.fallback_title)
	if localization == null:
		return fallback
	return localization.translate(String(definition.title_key), fallback)


func _field_suffix(field_key: String, fallback: String) -> String:
	if field_key in ["jumpscare_hold_seconds", "jumpscare_lunge_seconds", "jumpscare_duration"]:
		return _text("suffix.seconds", " s")
	if field_key in ["jumpscare_initial_zoom", "jumpscare_lunge_zoom"]:
		return _text("suffix.times", "×")
	if field_key in ["jumpscare_initial_shake", "jumpscare_lunge_shake"]:
		return _text("suffix.pixels", " px")
	if field_key == "jumpscare_audio_volume_db":
		return _text("suffix.decibels", " dB")
	return fallback


func _text(key: String, fallback: String) -> String:
	if localization == null:
		return fallback
	return localization.translate("ui.debug.jumpscare_lab.%s" % key, fallback)


func _on_language_changed(_language: int) -> void:
	_rebuild_ui()


func _make_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.90, 0.90, 0.92))
	return label


func _make_panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	return style
