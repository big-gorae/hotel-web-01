class_name HotelInventoryItemButton
extends Button

const DRAG_KIND := "hotel_inventory_item"

var item = null


func setup(new_item) -> void:
	item = new_item
	text = "%s\n%s" % [item.icon_text, item.display_name]
	tooltip_text = item.description
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
	label.text = "%s  %s" % [item.icon_text, item.display_name]
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	preview.add_child(label)
	set_drag_preview(preview)
	return {
		"kind": DRAG_KIND,
		"item": item,
	}
