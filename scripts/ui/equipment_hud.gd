class_name HotelEquipmentHud
extends PanelContainer

signal activated

var icon_label: Label
var name_label: Label


func _ready() -> void:
	custom_minimum_size = Vector2(88.0, 88.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "Open inventory"
	add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.72), Color(1.0, 1.0, 1.0, 0.14), 8))

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 2)
	add_child(layout)

	icon_label = Label.new()
	icon_label.text = "✋"
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 32)
	icon_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42))
	layout.add_child(icon_label)

	name_label = Label.new()
	name_label.text = "Empty"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color(0.82, 0.82, 0.78))
	layout.add_child(name_label)


func bind_inventory(model) -> void:
	model.equipped_item_changed.connect(set_equipped_item)
	set_equipped_item(model.equipped_item)


func set_equipped_item(item) -> void:
	if icon_label == null or name_label == null:
		return

	if item == null:
		icon_label.text = "✋"
		name_label.text = "Empty"
	else:
		icon_label.text = item.icon_text
		name_label.text = item.display_name


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		activated.emit()
		accept_event()


func _make_panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style
