extends GdUnitTestSuite

const FlagStore := preload("res://scripts/systems/flag_store.gd")
const InventoryModel := preload("res://scripts/items/inventory_model.gd")
const ItemDefinition := preload("res://scripts/items/item_definition.gd")
const TaskManager := preload("res://scripts/tasks/task_manager.gd")
const HorrorEventManager := preload("res://scripts/horror/horror_event_manager.gd")
const RuleBookManager := preload("res://scripts/rules/rule_book_manager.gd")
const InteractionActionRunner := preload("res://scripts/interactions/interaction_action_runner.gd")
const InteractionContext := preload("res://scripts/interactions/interaction_context.gd")

var flags
var inventory
var tasks
var horror
var rules
var runner


func before_test() -> void:
	flags = FlagStore.new()
	flags.set_value(InteractionActionRunner.LAUNDRY_OPEN_FLAG, true)
	inventory = InventoryModel.new()
	_register_item("cleaning_cloth", true)
	_register_item("small_mirror", true)
	_register_item("hell_mirror", true)
	_register_item("collected_trash", false)
	inventory.add_item_by_id("cleaning_cloth")
	inventory.equip_item(inventory.get_items()[0])
	tasks = TaskManager.new()
	tasks.setup_default_catalog()
	horror = HorrorEventManager.new()
	horror.setup_default_catalog()
	rules = RuleBookManager.new()
	rules.setup_default_catalog()
	runner = InteractionActionRunner.new()
	runner.setup(flags, inventory, tasks, horror, rules)


func test_toggle_laundry_legacy_action_updates_flag() -> void:
	var result = runner.execute_action("toggle_laundry_washer", _context("laundry_room"))

	assert_that(flags.get_bool(InteractionActionRunner.LAUNDRY_OPEN_FLAG, true)).is_false()
	assert_that(result.should_refresh_photo).is_true()
	assert_that(result.should_save).is_true()


func test_equipped_item_completes_item_gated_task() -> void:
	var hotspot := _task_hotspot("room_105_bathroom", "room_105_clean_sink")
	var result = runner.execute_item_on_hotspot(hotspot, _context("room_105_bathroom", "task_room_105_clean_sink", "cleaning_cloth"))

	assert_that(tasks.get_task_state("room_105_clean_sink")).is_equal("done")
	assert_that(flags.get_bool("task.room_105.sink.cleaned")).is_true()
	assert_that(result.should_refresh_hotspots).is_true()
	assert_that(result.should_save).is_true()


func test_anomaly_requires_rule_before_resolution() -> void:
	var event_id := "room_105_closet_pig_man"
	var definition = horror.get_definition(event_id)
	definition.required_rule_id = "close_open_wardrobe"
	horror.active_event_id_by_room["room_105"] = event_id
	var blocked_result = runner.execute_action("resolve_horror_event:%s" % event_id, _context("room_105_bathroom_entry"))

	assert_that(horror.resolved_event_ids.has(event_id)).is_false()
	assert_that(blocked_result.blocked_reason_key).is_equal("horror_event.%s.blocked" % event_id)

	rules.mark_rule_read("close_open_wardrobe")
	var resolved_result = runner.execute_action("resolve_horror_event:%s" % event_id, _context("room_105_bathroom_entry"))

	assert_that(horror.resolved_event_ids.has(event_id)).is_true()
	assert_that(resolved_result.should_refresh_hotspots).is_true()
	assert_that(resolved_result.should_save).is_true()


func test_item_only_execution_silently_ignores_non_item_targets() -> void:
	var hotspot := {
		"id": "ordinary_door",
		"text": "The door is locked.",
		"item_actions": [
			{
				"item_id": "cleaning_cloth",
				"actions": [{"type": "show_dialogue", "fallback_text": "Cleaned."}],
			},
		],
	}
	var result = runner.execute_item_on_hotspot(hotspot, _context("corridor", "ordinary_door", "flashlight"))

	assert_that(result.consumed).is_false()
	assert_that(result.has_dialogue()).is_false()


func test_regular_click_does_not_auto_use_equipped_item() -> void:
	var hotspot := {
		"id": "stain",
		"text": "A dark stain.",
		"item_actions": [
			{
				"item_id": "cleaning_cloth",
				"actions": [{"type": "show_dialogue", "fallback_text": "Cleaned."}],
			},
		],
	}
	var result = runner.execute_hotspot(hotspot, _context("room_105_bathroom", "stain", "cleaning_cloth"))

	assert_that(result.fallback_dialogue).is_equal("A dark stain.")


func test_replace_item_action_can_auto_equip_replacement() -> void:
	inventory.add_item_by_id("small_mirror")
	inventory.equip_item_by_id("small_mirror")

	var result = runner.execute_action({
		"type": "replace_item",
		"current_item_id": "small_mirror",
		"replacement_item_id": "hell_mirror",
		"equip_replacement": true,
	}, _context("room_106_bathroom"))

	assert_that(inventory.has_item_id("small_mirror")).is_false()
	assert_that(inventory.has_item_id("hell_mirror")).is_true()
	assert_that(inventory.equipped_item.id).is_equal("hell_mirror")
	assert_that(result.should_save).is_true()


func _register_item(item_id: String, can_equip: bool) -> void:
	var item := ItemDefinition.new()
	item.id = item_id
	item.fallback_display_name = item_id
	item.can_equip = can_equip
	inventory.register_item_definition(item)


func _task_hotspot(scene_id: String, task_id: String) -> Dictionary:
	for hotspot in tasks.get_hotspots_for_scene(scene_id):
		if String(hotspot.get("task_id", "")) == task_id:
			return hotspot
	return {}


func _context(scene_id: String, hotspot_id := "", equipped_item_id := ""):
	var context = InteractionContext.new()
	context.scene_id = scene_id
	context.hotspot_id = hotspot_id
	context.equipped_item_id = equipped_item_id
	return context
