class_name HotelItemCatalog
extends RefCounted

const ItemDefinition := preload("res://scripts/items/item_definition.gd")
const ItemCombinationRule := preload("res://scripts/items/item_combination_rule.gd")

const INITIAL_ITEM_IDS: Array[String] = [
	"room_105_key",
	"small_flashlight",
	"guest_note",
	"cleaning_cloth",
	"small_mirror",
]


static func register_defaults(inventory_model) -> void:
	_register_item(inventory_model, "room_105_key", "Room 105 Key", "A worn brass key from the front desk drawer.", "🔑")
	_register_item(inventory_model, "small_flashlight", "Flashlight", "A compact flashlight. Useful when the power fails.", "🔦")
	_register_item(inventory_model, "guest_note", "Guest Note", "A folded note with a room number written in pencil.", "📝")
	_register_item(inventory_model, "revealed_guest_note", "Revealed Note", "The flashlight reveals faint writing under the room number: Do not return it after midnight.", "📄")
	_register_item(inventory_model, "cleaning_cloth", "Cleaning Cloth", "A rough cloth for wiping sinks, floors, and anything that should not be touched directly.", "🧽")
	_register_item(
		inventory_model,
		"small_mirror",
		"Small Mirror",
		"A small hand mirror. Its surface is unusually clear.",
		"🪞",
		true,
		"res://resource/images/items/small_mirror.png",
	)
	_register_item(
		inventory_model,
		"hell_mirror",
		"Mirror of Hell",
		"It feels wrong to keep this in your hand.",
		"🪞",
		true,
		"res://resource/images/items/hell_mirror.png",
	)
	_register_item(
		inventory_model,
		"cute_doll",
		"Cute Doll",
		"A small wooden doll found on the laundry-room table. It can be held, but only needs to be in your inventory to offer it.",
		"🪆",
		true,
	)
	_register_item(inventory_model, "collected_trash", "Collected Trash", "Loose papers and trash gathered during room work.", "🗑", false)
	inventory_model.add_combination_rule(_make_combination_rule(
		"reveal_guest_note",
		"small_flashlight",
		"guest_note",
		["revealed_guest_note"],
		false,
		true,
		"combine.reveal_guest_note",
		"The flashlight reveals hidden writing on the note.",
	))


static func reset_to_initial_items(inventory_model) -> void:
	inventory_model.reset_items(INITIAL_ITEM_IDS)


static func _register_item(
	inventory_model,
	item_id: String,
	item_name: String,
	item_description: String,
	item_icon_text: String,
	item_can_equip := true,
	item_icon_path := "",
) -> void:
	var item := ItemDefinition.new()
	item.id = item_id
	item.name_key = "item.%s.name" % item_id
	item.description_key = "item.%s.description" % item_id
	item.fallback_display_name = item_name
	item.fallback_description = item_description
	item.icon_text = item_icon_text
	item.icon_path = item_icon_path
	item.can_equip = item_can_equip
	inventory_model.register_item_definition(item)


static func _make_combination_rule(rule_id: String, item_a_id: String, item_b_id: String, result_item_ids: Array[String], consume_item_a: bool, consume_item_b: bool, message_key: String, fallback_message: String):
	var rule := ItemCombinationRule.new()
	rule.id = rule_id
	rule.item_a_id = item_a_id
	rule.item_b_id = item_b_id
	rule.result_item_ids = result_item_ids
	rule.consume_item_a = consume_item_a
	rule.consume_item_b = consume_item_b
	rule.message_key = message_key
	rule.fallback_message = fallback_message
	return rule
