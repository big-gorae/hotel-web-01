class_name HotelInventoryScreen
extends HBoxContainer

const InventoryItemButton := preload("res://scripts/ui/inventory_item_button.gd")
const EquipmentSlot := preload("res://scripts/ui/equipment_slot.gd")

var inventory_model = null
var localization = null
var items_grid: GridContainer
var empty_label: Label
var combination_feedback_label: Label
var hand_slot = null


func setup(model, new_localization) -> void:
	inventory_model = model
	localization = new_localization
	_build()
	inventory_model.items_changed.connect(_refresh_items)
	inventory_model.equipped_item_changed.connect(_on_equipped_item_changed)
	inventory_model.combination_succeeded.connect(_on_combination_succeeded)
	inventory_model.combination_failed.connect(_on_combination_failed)
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
	title.text = _text("inventory.title", "Inventory")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	inventory_layout.add_child(title)

	var hint := Label.new()
	hint.text = _text("inventory.hint", "Equip by dragging, double-clicking, or right-clicking. Drop one item onto another to combine them.")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	empty_label.text = _text("inventory.empty", "No items yet.")
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.add_theme_font_size_override("font_size", 16)
	empty_label.add_theme_color_override("font_color", Color(0.72, 0.72, 0.68))
	inventory_layout.add_child(empty_label)

	combination_feedback_label = Label.new()
	combination_feedback_label.text = ""
	combination_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combination_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	combination_feedback_label.add_theme_font_size_override("font_size", 14)
	combination_feedback_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.28))
	inventory_layout.add_child(combination_feedback_label)

	hand_slot = EquipmentSlot.new()
	hand_slot.setup(localization)
	hand_slot.item_dropped.connect(_on_hand_item_dropped)
	add_child(hand_slot)


func _refresh_items() -> void:
	for child in items_grid.get_children():
		child.queue_free()

	var items: Array = inventory_model.get_items()
	empty_label.visible = items.is_empty()
	for item in items:
		var button = InventoryItemButton.new()
		button.setup(item, localization)
		button.equip_requested.connect(_on_equip_requested)
		button.item_dropped_on_item.connect(_on_item_dropped_on_item)
		items_grid.add_child(button)


func _on_hand_item_dropped(item) -> void:
	inventory_model.equip_item(item)


func _on_equip_requested(item) -> void:
	inventory_model.equip_item(item)


func _on_item_dropped_on_item(source_item, target_item) -> void:
	inventory_model.combine_items(source_item, target_item)


func _on_equipped_item_changed(item) -> void:
	if hand_slot != null:
		hand_slot.set_equipped_item(item)


func _set_combination_feedback(message: String) -> void:
	if combination_feedback_label != null:
		combination_feedback_label.text = message


func _on_combination_succeeded(rule) -> void:
	_set_combination_feedback(localization.translate(rule.message_key, rule.fallback_message))


func _on_combination_failed(_source_item, _target_item) -> void:
	_set_combination_feedback(_text("inventory.combine.no_match", "Those items do not fit together."))


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


func _text(key: String, fallback: String) -> String:
	if localization == null:
		return fallback

	return localization.translate("ui.%s" % key, fallback)
