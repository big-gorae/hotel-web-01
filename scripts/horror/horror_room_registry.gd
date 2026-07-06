class_name HotelHorrorRoomRegistry
extends RefCounted

const ROOM_GROUPS := {
	"front_desk": {
		"display_name": "Front Desk",
		"scene_ids": ["front_desk"],
	},
	"corridor": {
		"display_name": "Corridor",
		"scene_ids": ["corridor"],
	},
	"laundry_room": {
		"display_name": "Laundry Room",
		"scene_ids": ["laundry_room"],
	},
	"exterior_stairs": {
		"display_name": "Exterior Stairs",
		"scene_ids": ["exterior_stairs"],
	},
	"room_105": {
		"display_name": "Room 105",
		"scene_ids": ["room_105_door_window", "room_105_bathroom_entry", "room_105_bathroom"],
	},
	"room_106": {
		"display_name": "Room 106",
		"scene_ids": ["room_106_bed_bathroom_entry", "room_106_bathroom"],
	},
	"room_107": {
		"display_name": "Room 107",
		"scene_ids": ["room_107_bed_nightstand", "room_107_bathroom_entry", "room_107_bathroom"],
	},
	"room_108": {
		"display_name": "Room 108",
		"scene_ids": ["room_108_bed_window", "room_108_bathroom_entry", "room_108_bathroom"],
	},
}

var scene_to_room_id: Dictionary = {}


func _init() -> void:
	for room_id in ROOM_GROUPS.keys():
		for scene_id in ROOM_GROUPS[room_id]["scene_ids"]:
			scene_to_room_id[scene_id] = room_id


func get_room_id(scene_id: String) -> String:
	return scene_to_room_id.get(scene_id, scene_id)


func get_room_scene_ids(room_id: String) -> Array:
	var room_data: Dictionary = ROOM_GROUPS.get(room_id, {})
	return room_data.get("scene_ids", []).duplicate()


func get_room_display_name(room_id: String) -> String:
	var room_data: Dictionary = ROOM_GROUPS.get(room_id, {})
	return room_data.get("display_name", room_id)


func are_same_room(scene_a_id: String, scene_b_id: String) -> bool:
	return get_room_id(scene_a_id) == get_room_id(scene_b_id)
