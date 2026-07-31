class_name HotelChoiceDialogueOverlay
extends Control

signal choice_selected(choice_id: String)
signal narrative_finished

var _prompt_label: Label
var _choice_box: VBoxContainer
var _narrative_timer: Timer
var _narrative_lines: Array[String] = []
var _narrative_index := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var shade := ColorRect.new()
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.color = Color(0.0, 0.0, 0.0, 0.38)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 120)
	margin.add_theme_constant_override("margin_right", 120)
	margin.add_theme_constant_override("margin_top", 160)
	margin.add_theme_constant_override("margin_bottom", 72)
	add_child(margin)

	var alignment := VBoxContainer.new()
	alignment.alignment = BoxContainer.ALIGNMENT_END
	margin.add_child(alignment)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style())
	alignment.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)

	_prompt_label = Label.new()
	_prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_prompt_label.add_theme_font_size_override("font_size", 22)
	_prompt_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	content.add_child(_prompt_label)

	_choice_box = VBoxContainer.new()
	_choice_box.add_theme_constant_override("separation", 6)
	content.add_child(_choice_box)

	_narrative_timer = Timer.new()
	_narrative_timer.one_shot = false
	_narrative_timer.timeout.connect(_advance_narrative)
	add_child(_narrative_timer)
	visible = false


func show_prompt(prompt: String, choices: Array) -> void:
	_stop_narrative()
	_clear_choices()
	_prompt_label.text = prompt
	for choice in choices:
		var button := Button.new()
		var selected := bool(choice.get("selected", false))
		button.text = "%s%s" % ["✓ " if selected else "", String(choice.get("text", ""))]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.add_theme_font_size_override("font_size", 18)
		if selected:
			button.add_theme_color_override("font_color", Color(0.62, 0.59, 0.55))
			button.add_theme_color_override("font_hover_color", Color(0.78, 0.72, 0.65))
		button.pressed.connect(_select_choice.bind(String(choice.get("id", ""))))
		_choice_box.add_child(button)
	visible = true
	move_to_front()


func show_narrative(lines: Array[String], interval_seconds := 0.34) -> void:
	_clear_choices()
	_narrative_lines = lines.duplicate()
	_narrative_index = 0
	visible = true
	move_to_front()
	if _narrative_lines.is_empty():
		_finish_narrative()
		return
	_prompt_label.text = _narrative_lines[0]
	_narrative_timer.wait_time = maxf(interval_seconds, 0.05)
	_narrative_timer.start()


func close() -> void:
	_stop_narrative()
	_clear_choices()
	visible = false


func _select_choice(choice_id: String) -> void:
	if not choice_id.is_empty():
		choice_selected.emit(choice_id)


func _advance_narrative() -> void:
	_narrative_index += 1
	if _narrative_index >= _narrative_lines.size():
		_finish_narrative()
		return
	_prompt_label.text = _narrative_lines[_narrative_index]


func _finish_narrative() -> void:
	_stop_narrative()
	visible = false
	narrative_finished.emit()


func _stop_narrative() -> void:
	if _narrative_timer != null:
		_narrative_timer.stop()
	_narrative_lines.clear()
	_narrative_index = 0


func _clear_choices() -> void:
	if _choice_box == null:
		return
	for child in _choice_box.get_children():
		child.queue_free()


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.025, 0.03, 0.95)
	style.border_color = Color(0.42, 0.37, 0.32, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 22.0
	style.content_margin_right = 22.0
	style.content_margin_top = 18.0
	style.content_margin_bottom = 18.0
	return style
