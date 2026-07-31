class_name HotelInventoryItemButton
extends Button

signal item_dropped_on_item(source_item, target_item)
signal equip_requested(item)

const DRAG_KIND := "hotel_inventory_item"

var item = null
var localization = null
var icon_texture_rect: TextureRect
var icon_fallback_label: Label
var name_label: Label


func setup(new_item, new_localization) -> void:
	item = new_item
	localization = new_localization
	_build_visuals()
	var item_icon := _load_item_icon(item)
	icon_texture_rect.texture = item_icon
	icon_texture_rect.visible = item_icon != null
	icon_fallback_label.text = item.icon_text
	icon_fallback_label.visible = item_icon == null
	name_label.text = item.get_display_name(localization)
	tooltip_text = item.get_description(localization)
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_DRAG
	custom_minimum_size = Vector2(104.0, 100.0)


func _build_visuals() -> void:
	if name_label != null:
		return

	text = ""
	var content := VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 6.0
	content.offset_top = 5.0
	content.offset_right = -6.0
	content.offset_bottom = -5.0
	content.add_theme_constant_override("separation", 2)
	add_child(content)

	var icon_center := CenterContainer.new()
	icon_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_center.custom_minimum_size = Vector2(0.0, 56.0)
	icon_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(icon_center)

	icon_texture_rect = TextureRect.new()
	icon_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_texture_rect.custom_minimum_size = Vector2(52.0, 52.0)
	icon_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_center.add_child(icon_texture_rect)

	icon_fallback_label = Label.new()
	icon_fallback_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_fallback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_fallback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_fallback_label.add_theme_font_size_override("font_size", 30)
	icon_center.add_child(icon_fallback_label)

	name_label = Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.custom_minimum_size = Vector2(0.0, 30.0)
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	content.add_child(name_label)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if item == null:
		return null

	var preview := PanelContainer.new()
	preview.modulate.a = 0.92
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	preview.add_child(row)
	var item_icon := _load_item_icon(item)
	if item_icon != null:
		var texture_rect := TextureRect.new()
		texture_rect.texture = item_icon
		texture_rect.custom_minimum_size = Vector2(42.0, 42.0)
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(texture_rect)
	var label := Label.new()
	label.text = item.get_display_name(localization) if item_icon != null else "%s  %s" % [item.icon_text, item.get_display_name(localization)]
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	row.add_child(label)
	set_drag_preview(preview)
	return {
		"kind": DRAG_KIND,
		"item": item,
	}


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or not event.pressed or item == null:
		return
	var mouse_event := event as InputEventMouseButton
	var left_double_click: bool = mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.double_click
	var right_click: bool = mouse_event.button_index == MOUSE_BUTTON_RIGHT
	if left_double_click or right_click:
		equip_requested.emit(item)
		accept_event()


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.get("kind", "") == DRAG_KIND and data.get("item") != null and data.get("item") != item


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	item_dropped_on_item.emit(data["item"], item)


func _load_item_icon(target_item) -> Texture2D:
	if target_item == null:
		return null
	var icon_path := String(target_item.icon_path)
	if icon_path.is_empty() or not ResourceLoader.exists(icon_path):
		return null
	return load(icon_path) as Texture2D
