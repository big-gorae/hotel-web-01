class_name HotelItemDefinition
extends RefCounted

var id := ""
var name_key := ""
var description_key := ""
var fallback_display_name := ""
var fallback_description := ""
var icon_text := "□"
var can_equip := true


func copy():
	var item = get_script().new()
	item.id = id
	item.name_key = name_key
	item.description_key = description_key
	item.fallback_display_name = fallback_display_name
	item.fallback_description = fallback_description
	item.icon_text = icon_text
	item.can_equip = can_equip
	return item


func get_display_name(localization) -> String:
	if localization != null and localization.has_method("translate_item_name"):
		return localization.translate_item_name(id, fallback_display_name)

	return fallback_display_name


func get_description(localization) -> String:
	if localization != null and localization.has_method("translate_item_description"):
		return localization.translate_item_description(id, fallback_description)

	return fallback_description
