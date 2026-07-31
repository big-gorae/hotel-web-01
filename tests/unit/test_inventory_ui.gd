extends GdUnitTestSuite

const InventoryItemButton := preload("res://scripts/ui/inventory_item_button.gd")
const EquipmentSlot := preload("res://scripts/ui/equipment_slot.gd")
const ItemDefinition := preload("res://scripts/items/item_definition.gd")
const InventoryModel := preload("res://scripts/items/inventory_model.gd")
const ItemCatalog := preload("res://scripts/items/item_catalog.gd")


func test_right_click_and_left_double_click_request_equip() -> void:
	var button = auto_free(InventoryItemButton.new())
	add_child(button)
	var item = ItemDefinition.new()
	item.id = "test_item"
	item.fallback_display_name = "Test Item"
	button.setup(item, null)
	var requested_items := []
	button.equip_requested.connect(func(requested_item) -> void: requested_items.append(requested_item))

	var right_click := InputEventMouseButton.new()
	right_click.button_index = MOUSE_BUTTON_RIGHT
	right_click.pressed = true
	button._gui_input(right_click)

	assert_that(requested_items).contains_exactly([item])
	requested_items.clear()

	var left_double_click := InputEventMouseButton.new()
	left_double_click.button_index = MOUSE_BUTTON_LEFT
	left_double_click.double_click = true
	left_double_click.pressed = true
	button._gui_input(left_double_click)

	assert_that(requested_items).contains_exactly([item])


func test_hand_slot_is_a_compact_horizontal_card() -> void:
	var slot = auto_free(EquipmentSlot.new())
	add_child(slot)

	assert_that(slot.custom_minimum_size.x).is_greater(slot.custom_minimum_size.y)
	assert_that(slot.size_flags_vertical).is_equal(Control.SIZE_SHRINK_BEGIN)


func test_mirror_raster_icon_is_copied_and_used_by_inventory_and_hand_slot() -> void:
	var model := InventoryModel.new()
	ItemCatalog.register_defaults(model)
	var mirror = model.create_item("small_mirror")
	assert_str(String(mirror.icon_path)).is_equal("res://resource/images/items/small_mirror.png")
	assert_bool(ResourceLoader.exists(mirror.icon_path)).is_true()

	var copied_mirror = mirror.copy()
	assert_str(String(copied_mirror.icon_path)).is_equal(String(mirror.icon_path))

	var button = auto_free(InventoryItemButton.new())
	add_child(button)
	button.setup(mirror, null)
	assert_object(button.icon_texture_rect.texture).is_not_null()
	assert_bool(button.icon_texture_rect.visible).is_true()
	assert_bool(button.icon_fallback_label.visible).is_false()
	assert_str(button.name_label.text).is_equal(mirror.get_display_name(null))

	var slot = auto_free(EquipmentSlot.new())
	add_child(slot)
	slot.set_equipped_item(mirror)
	assert_bool(slot.icon_texture_rect.visible).is_true()
	assert_bool(slot.icon_label.visible).is_false()
