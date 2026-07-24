extends GdUnitTestSuite

const InventoryItemButton := preload("res://scripts/ui/inventory_item_button.gd")
const EquipmentSlot := preload("res://scripts/ui/equipment_slot.gd")
const ItemDefinition := preload("res://scripts/items/item_definition.gd")


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
