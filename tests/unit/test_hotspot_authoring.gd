extends GdUnitTestSuite

const HotspotArea := preload("res://scripts/hotspots/hotspot_area.gd")
const InteractionActionDefinition := preload("res://scripts/interactions/interaction_action_definition.gd")
const ItemInteractionDefinition := preload("res://scripts/interactions/item_interaction_definition.gd")


func test_editor_hotspot_serializes_typed_actions() -> void:
	var hotspot = auto_free(HotspotArea.new())
	hotspot.hotspot_id = "test_sink"
	hotspot.position = Vector2(64.0, 72.0)
	hotspot.size = Vector2(128.0, 144.0)

	var dialogue := InteractionActionDefinition.new()
	dialogue.action_type = "show_dialogue"
	dialogue.text_key = "test.dialogue"
	dialogue.fallback_text = "Test"
	hotspot.actions.append(dialogue)

	var resolve := InteractionActionDefinition.new()
	resolve.action_type = "resolve_horror_event"
	resolve.event_id = "test_event"
	var item_action := ItemInteractionDefinition.new()
	item_action.item_id = "cleaning_cloth"
	item_action.actions.append(resolve)
	hotspot.item_actions.append(item_action)

	var data: Dictionary = hotspot.to_hotspot_data(Vector2(1280.0, 720.0))

	assert_that(data.get("actions", [])[0].get("text_key", "")).is_equal("test.dialogue")
	assert_that(data.get("item_actions", [])[0].get("item_id", "")).is_equal("cleaning_cloth")
	assert_that(data.get("item_actions", [])[0].get("actions", [])[0].get("event_id", "")).is_equal("test_event")
