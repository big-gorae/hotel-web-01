class_name HotelEquipmentSlot
extends PanelContainer

signal item_dropped(item)

const DRAG_KIND := "hotel_inventory_item"

var icon_label: Label
var name_label: Label
var status_label: Label
var use_hint_label: Label
var localization = null


func setup(new_localization) -> void:
	localization = new_localization
	if name_label != null:
		set_equipped_item(null)


func _ready() -> void:
	custom_minimum_size = Vector2(230.0, 154.0)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_apply_panel_style(false)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 8)
	add_child(layout)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	layout.add_child(header)

	var title := Label.new()
	title.text = _text("inventory.hand.title", "HAND")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 17)
	title.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	header.add_child(title)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_label.add_theme_font_size_override("font_size", 12)
	header.add_child(status_label)

	var item_row := HBoxContainer.new()
	item_row.alignment = BoxContainer.ALIGNMENT_CENTER
	item_row.add_theme_constant_override("separation", 12)
	layout.add_child(item_row)

	icon_label = Label.new()
	icon_label.text = "✋"
	icon_label.custom_minimum_size = Vector2(68.0, 68.0)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 48)
	icon_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42))
	item_row.add_child(icon_label)

	var item_details := VBoxContainer.new()
	item_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_details.alignment = BoxContainer.ALIGNMENT_CENTER
	item_details.add_theme_constant_override("separation", 5)
	item_row.add_child(item_details)

	name_label = Label.new()
	name_label.text = _text("inventory.hand.empty", "Nothing equipped")
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(0.94, 0.91, 0.84))
	item_details.add_child(name_label)

	use_hint_label = Label.new()
	use_hint_label.text = _text("inventory.hand.empty_hint", "Drop or select an item")
	use_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	use_hint_label.add_theme_font_size_override("font_size", 12)
	use_hint_label.add_theme_color_override("font_color", Color(0.68, 0.68, 0.64))
	item_details.add_child(use_hint_label)
	set_equipped_item(null)


func set_equipped_item(item) -> void:
	if icon_label == null or name_label == null or status_label == null or use_hint_label == null:
		return

	if item == null:
		icon_label.text = "✋"
		name_label.text = _text("inventory.hand.empty", "Nothing equipped")
		status_label.text = _text("inventory.hand.status.empty", "○ EMPTY")
		status_label.add_theme_color_override("font_color", Color(0.58, 0.58, 0.56))
		use_hint_label.text = _text("inventory.hand.empty_hint", "Drop or select an item")
		_apply_panel_style(false)
	else:
		icon_label.text = item.icon_text
		name_label.text = item.get_display_name(localization)
		status_label.text = _text("inventory.hand.status.equipped", "● EQUIPPED")
		status_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.28))
		use_hint_label.text = _text("inventory.hand.use_hint", "Press F to use")
		_apply_panel_style(true)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.get("kind", "") == DRAG_KIND and data.get("item") != null


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	item_dropped.emit(data["item"])


func _apply_panel_style(equipped: bool) -> void:
	var background := Color(0.075, 0.060, 0.028, 0.94) if equipped else Color(0.03, 0.035, 0.04, 0.90)
	var border := Color(1.0, 0.82, 0.28, 0.78) if equipped else Color(1.0, 1.0, 1.0, 0.18)
	add_theme_stylebox_override("panel", _make_panel_style(background, border, 12))


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
