class_name HotelInventoryItemButton
extends Button

signal item_dropped_on_item(source_item, target_item)
signal equip_requested(item)

const DRAG_KIND := "hotel_inventory_item"

var item = null
var localization = null


func setup(new_item, new_localization) -> void:
	item = new_item
	localization = new_localization
	text = "%s\n%s" % [item.icon_text, item.get_display_name(localization)]
	tooltip_text = item.get_description(localization)
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_DRAG
	custom_minimum_size = Vector2(104.0, 86.0)
	add_theme_font_size_override("font_size", 14)
	add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))


func _get_drag_data(_at_position: Vector2) -> Variant:
	if item == null:
		return null

	var preview := PanelContainer.new()
	preview.modulate.a = 0.92
	var label := Label.new()
	label.text = "%s  %s" % [item.icon_text, item.get_display_name(localization)]
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	preview.add_child(label)
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
