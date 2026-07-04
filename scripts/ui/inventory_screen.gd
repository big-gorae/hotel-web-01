class_name HotelInventoryScreen
extends HBoxContainer

const InventoryItemButton := preload("res://scripts/ui/inventory_item_button.gd")
const EquipmentSlot := preload("res://scripts/ui/equipment_slot.gd")

var inventory_model = null
var items_grid: GridContainer
var empty_label: Label
var hand_slot = null


func setup(model) -> void:
	inventory_model = model
	_build()
	inventory_model.items_changed.connect(_refresh_items)
	inventory_model.equipped_item_changed.connect(_on_equipped_item_changed)
	_refresh_items()
	_on_equipped_item_changed(inventory_model.equipped_item)


func _build() -> void:
	for child in get_children():
		child.queue_free()

	add_theme_constant_override("separation", 18)
	alignment = BoxContainer.ALIGNMENT_CENTER

	var inventory_panel := PanelContainer.new()
	inventory_panel.custom_minimum_size = Vector2(390.0, 420.0)
	inventory_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.92), Color(1.0, 1.0, 1.0, 0.14), 12))
	add_child(inventory_panel)

	var inventory_layout := VBoxContainer.new()
	inventory_layout.add_theme_constant_override("separation", 12)
	inventory_panel.add_child(inventory_layout)

	var title := Label.new()
	title.text = "Inventory"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	inventory_layout.add_child(title)

	var hint := Label.new()
	hint.text = "Drag an item to Hand to equip it."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.72, 0.72, 0.68))
	inventory_layout.add_child(hint)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_layout.add_child(scroll)

	items_grid = GridContainer.new()
	items_grid.columns = 3
	items_grid.add_theme_constant_override("h_separation", 10)
	items_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(items_grid)

	empty_label = Label.new()
	empty_label.text = "No items yet."
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.add_theme_font_size_override("font_size", 16)
	empty_label.add_theme_color_override("font_color", Color(0.72, 0.72, 0.68))
	inventory_layout.add_child(empty_label)

	hand_slot = EquipmentSlot.new()
	hand_slot.item_dropped.connect(_on_hand_item_dropped)
	add_child(hand_slot)


func _refresh_items() -> void:
	for child in items_grid.get_children():
		child.queue_free()

	var items: Array = inventory_model.get_items()
	empty_label.visible = items.is_empty()
	for item in items:
		var button = InventoryItemButton.new()
		button.setup(item)
		items_grid.add_child(button)


func _on_hand_item_dropped(item) -> void:
	inventory_model.equip_item(item)


func _on_equipped_item_changed(item) -> void:
	if hand_slot != null:
		hand_slot.set_equipped_item(item)


func _make_panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	return style
