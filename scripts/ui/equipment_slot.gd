class_name HotelEquipmentSlot
extends PanelContainer

signal item_dropped(item)

const DRAG_KIND := "hotel_inventory_item"

var icon_label: Label
var name_label: Label
var localization = null


func setup(new_localization) -> void:
	localization = new_localization
	if name_label != null:
		name_label.text = _text("inventory.hand.empty", "Drag item here")


func _ready() -> void:
	custom_minimum_size = Vector2(150.0, 190.0)
	add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.88), Color(1.0, 0.82, 0.28, 0.35), 12))

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 10)
	add_child(layout)

	var title := Label.new()
	title.text = _text("inventory.hand.title", "Hand")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	layout.add_child(title)

	icon_label = Label.new()
	icon_label.text = "✋"
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 52)
	icon_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42))
	layout.add_child(icon_label)

	name_label = Label.new()
	name_label.text = _text("inventory.hand.empty", "Drag item here")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(0.82, 0.82, 0.78))
	layout.add_child(name_label)


func set_equipped_item(item) -> void:
	if icon_label == null or name_label == null:
		return

	if item == null:
		icon_label.text = "✋"
		name_label.text = _text("inventory.hand.empty", "Drag item here")
	else:
		icon_label.text = item.icon_text
		name_label.text = item.get_display_name(localization)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.get("kind", "") == DRAG_KIND and data.get("item") != null


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	item_dropped.emit(data["item"])


func _make_panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style


func _text(key: String, fallback: String) -> String:
	if localization == null:
		return fallback

	return localization.translate("ui.%s" % key, fallback)
