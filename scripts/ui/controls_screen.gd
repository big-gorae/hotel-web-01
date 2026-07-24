class_name HotelControlsScreen
extends PanelContainer

var localization = null


func setup(new_localization) -> void:
	localization = new_localization
	_build()


func _build() -> void:
	custom_minimum_size = Vector2(570.0, 420.0)
	add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.94), Color(1.0, 0.82, 0.28, 0.20), 12))
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	add_child(layout)

	var title := Label.new()
	title.text = _text("controls.title", "Controls")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42))
	layout.add_child(title)

	_add_control_row(layout, "E", _text("controls.close_eyes", "Close or open your eyes"))
	_add_control_row(layout, "F", _text("controls.use_item", "Use the item equipped in Hand"))
	_add_control_row(layout, _text("controls.mouse", "Mouse"), _text("controls.interact", "Aim at and interact with objects"))
	_add_control_row(layout, _text("controls.drag", "Drag"), _text("controls.equip", "Move an inventory item into Hand"))
	_add_control_row(layout, "Esc", _text("controls.pause", "Open or close this menu"))

	var hint := Label.new()
	hint.text = _text("controls.eye_hint", "With your eyes closed, only the area beneath the cursor remains visible.")
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.72, 0.72, 0.68))
	layout.add_child(hint)


func _add_control_row(parent: VBoxContainer, key_text: String, description: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	parent.add_child(row)
	var key_label := Label.new()
	key_label.text = key_text
	key_label.custom_minimum_size = Vector2(96.0, 38.0)
	key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	key_label.add_theme_font_size_override("font_size", 18)
	key_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.34))
	row.add_child(key_label)
	var description_label := Label.new()
	description_label.text = description
	description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	description_label.add_theme_font_size_override("font_size", 16)
	description_label.add_theme_color_override("font_color", Color(0.94, 0.92, 0.86))
	row.add_child(description_label)


func _text(key: String, fallback: String) -> String:
	return localization.translate("ui.%s" % key, fallback) if localization != null else fallback


func _make_panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 24.0
	style.content_margin_right = 24.0
	style.content_margin_top = 20.0
	style.content_margin_bottom = 20.0
	return style
