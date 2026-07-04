class_name HotelInventoryModel
extends RefCounted

signal items_changed
signal equipped_item_changed(item)

var items: Array = []
var equipped_item = null


func add_item(item) -> void:
	if item == null:
		return

	items.append(item)
	items_changed.emit()


func get_items() -> Array:
	return items.duplicate()


func equip_item(item) -> bool:
	if item == null or not item.can_equip or not items.has(item):
		return false

	equipped_item = item
	equipped_item_changed.emit(equipped_item)
	return true


func clear_equipped_item() -> void:
	equipped_item = null
	equipped_item_changed.emit(equipped_item)
