extends GdUnitTestSuite

const HazardController := preload("res://scripts/horror/equipped_item_hazard_controller.gd")
const InventoryModel := preload("res://scripts/items/inventory_model.gd")
const ItemCatalog := preload("res://scripts/items/item_catalog.gd")


func test_hell_mirror_only_advances_while_equipped() -> void:
	var inventory := InventoryModel.new()
	ItemCatalog.register_defaults(inventory)
	inventory.add_item_by_id("hell_mirror")
	var controller := HazardController.new()
	controller.bind_inventory(inventory)
	controller.set_lethal_outcomes_enabled(false)

	controller.advance(5.0)
	assert_float(controller.get_progress()).is_equal(0.0)

	inventory.equip_item_by_id("hell_mirror")
	controller.advance(6.0)
	assert_float(controller.get_progress()).is_equal_approx(0.5, 0.001)

	inventory.clear_equipped_item()
	assert_float(controller.get_progress()).is_equal(0.0)


func test_hell_mirror_requests_death_at_limit() -> void:
	var inventory := InventoryModel.new()
	ItemCatalog.register_defaults(inventory)
	inventory.add_item_by_id("hell_mirror")
	inventory.equip_item_by_id("hell_mirror")
	var controller := HazardController.new()
	controller.fatal_hold_seconds = 2.0
	controller.bind_inventory(inventory)
	var deaths: Array[String] = []
	controller.death_requested.connect(func(item_id: String): deaths.append(item_id))

	controller.advance(2.0)

	assert_array(deaths).contains_exactly(["hell_mirror"])
