class_name HotelInteractionContext
extends RefCounted

var scene_id := ""
var room_id := ""
var hotspot_id := ""
var equipped_item_id := ""
var day := 1
var horror_event_id := ""


func copy():
	var context = get_script().new()
	context.scene_id = scene_id
	context.room_id = room_id
	context.hotspot_id = hotspot_id
	context.equipped_item_id = equipped_item_id
	context.day = day
	context.horror_event_id = horror_event_id
	return context
