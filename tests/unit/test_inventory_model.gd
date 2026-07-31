extends GdUnitTestSuite

const InventoryModel := preload("res://scripts/items/inventory_model.gd")
const ItemDefinition := preload("res://scripts/items/item_definition.gd")


func test_replace_item_preserves_slot_and_equipped_state() -> void:
	var inventory = InventoryModel.new()
	_register(inventory, "small_mirror")
	_register(inventory, "hell_mirror")
	_register(inventory, "cleaning_cloth")
	inventory.add_item_by_id("cleaning_cloth")
	inventory.add_item_by_id("small_mirror")
	inventory.equip_item_by_id("small_mirror")

	assert_that(inventory.replace_item_by_id("small_mirror", "hell_mirror", true)).is_true()
	assert_that(inventory.get_items().map(func(item): return item.id)).contains_exactly(["cleaning_cloth", "hell_mirror"])
	assert_that(inventory.equipped_item.id).is_equal("hell_mirror")


func test_replace_item_rejects_unknown_ids_without_mutating_inventory() -> void:
	var inventory = InventoryModel.new()
	_register(inventory, "small_mirror")
	inventory.add_item_by_id("small_mirror")

	assert_that(inventory.replace_item_by_id("small_mirror", "missing_item", true)).is_false()
	assert_that(inventory.get_items().map(func(item): return item.id)).contains_exactly(["small_mirror"])


func test_remove_item_clears_equipped_state() -> void:
	var inventory = InventoryModel.new()
	_register(inventory, "cute_doll")
	inventory.add_item_by_id("cute_doll")
	inventory.equip_item_by_id("cute_doll")

	assert_that(inventory.remove_item_by_id("cute_doll")).is_true()
	assert_that(inventory.has_item_id("cute_doll")).is_false()
	assert_that(inventory.equipped_item).is_null()
	assert_that(inventory.remove_item_by_id("cute_doll")).is_false()


func _register(inventory, item_id: String) -> void:
	var item := ItemDefinition.new()
	item.id = item_id
	item.fallback_display_name = item_id
	inventory.register_item_definition(item)
