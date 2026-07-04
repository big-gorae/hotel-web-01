class_name HotelItemDefinition
extends RefCounted

var id := ""
var name_key := ""
var description_key := ""
var fallback_display_name := ""
var fallback_description := ""
var icon_text := "□"
var can_equip := true


func get_display_name(localization) -> String:
	if localization != null and localization.has_method("translate_item_name"):
		return localization.translate_item_name(id, fallback_display_name)

	return fallback_display_name


func get_description(localization) -> String:
	if localization != null and localization.has_method("translate_item_description"):
		return localization.translate_item_description(id, fallback_description)

	return fallback_description
