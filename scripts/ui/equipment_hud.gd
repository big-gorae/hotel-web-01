class_name HotelEquipmentHud
extends PanelContainer

signal activated

var icon_label: Label
var icon_texture_rect: TextureRect
var name_label: Label
var localization = null


func _ready() -> void:
	custom_minimum_size = Vector2(88.0, 88.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = _text("equipment.tooltip", "Open inventory")
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

	icon_texture_rect = TextureRect.new()
	icon_texture_rect.custom_minimum_size = Vector2(48.0, 48.0)
	icon_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_texture_rect.visible = false
	layout.add_child(icon_texture_rect)

	name_label = Label.new()
	name_label.text = _text("equipment.empty", "Empty")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color(0.82, 0.82, 0.78))
	layout.add_child(name_label)


func bind_inventory(model, new_localization) -> void:
	localization = new_localization
	tooltip_text = _text("equipment.tooltip", "Open inventory")
	model.equipped_item_changed.connect(set_equipped_item)
	set_equipped_item(model.equipped_item)


func set_equipped_item(item) -> void:
	if icon_label == null or name_label == null:
		return

	if item == null:
		icon_texture_rect.texture = null
		icon_texture_rect.visible = false
		icon_label.visible = true
		icon_label.text = "✋"
		name_label.text = _text("equipment.empty", "Empty")
	else:
		var item_icon := _load_item_icon(item)
		icon_texture_rect.texture = item_icon
		icon_texture_rect.visible = item_icon != null
		icon_label.visible = item_icon == null
		icon_label.text = item.icon_text
		name_label.text = item.get_display_name(localization)


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


func _text(key: String, fallback: String) -> String:
	if localization == null:
		return fallback

	return localization.translate("ui.%s" % key, fallback)


func _load_item_icon(item) -> Texture2D:
	var icon_path := String(item.icon_path)
	if icon_path.is_empty() or not ResourceLoader.exists(icon_path):
		return null
	return load(icon_path) as Texture2D
