class_name HotelSceneCatalog
extends RefCounted

const SCENES := {
	"front_desk": {
		"title": "Front Desk",
		"photo": "res://resource/images/front_desk.png",
		"intro": "The night clerk's counter is quiet. Notes, a phone, and the logbook are ready for clues.",
		"exits": [
			{"label": "Corridor", "target": "corridor"},
			{"label": "Laundry Room", "target": "laundry_room"},
			{"label": "Room 105", "target": "room_105_door_window"},
			{"label": "Room 106", "target": "room_106_bed_bathroom_entry"},
			{"label": "Room 107", "target": "room_107_bed_nightstand"},
			{"label": "Room 108", "target": "room_108_bed_window"},
		],
	},
	"corridor": {
		"title": "Corridor",
		"photo": "res://resource/images/corridor.png",
		"intro": "The outside corridor is damp and dim. Each numbered door could hide a different lead.",
		"exits": [
			{"label": "Front Desk", "target": "front_desk"},
			{"label": "Exterior Stairs", "target": "exterior_stairs"},
			{"label": "Room 105", "target": "room_105_door_window"},
			{"label": "Room 106", "target": "room_106_bed_bathroom_entry"},
			{"label": "Room 107", "target": "room_107_bed_nightstand"},
			{"label": "Room 108", "target": "room_108_bed_window"},
		],
	},
	"laundry_room": {
		"title": "Laundry Room",
		"photo": "res://resource/images/laundry_room.png",
		"photo_variants": [
			"res://resource/images/laundry_room.png",
			"res://resource/images/laundry_room_washer_closed.png",
		],
		"intro": "The laundry room hums under fluorescent light. Machines line the walls and the exit is behind you.",
		"exits": [{"label": "Front Desk", "target": "front_desk"}],
	},
	"exterior_stairs": {
		"title": "Exterior Stairs",
		"photo": "res://resource/images/exterior_stairs.png",
		"intro": "The exterior stairs cut across the motel wall. Wet asphalt spreads out below.",
		"exits": [{"label": "Corridor", "target": "corridor"}],
	},
	"room_105_door_window": {
		"title": "Room 105",
		"photo": "res://resource/images/room_105_door_window.png",
		"intro": "A modest room with the curtains half closed. The bed, window, and door are the main points of interest.",
		"exits": [
			{"label": "Corridor", "target": "corridor"},
			{"label": "Room 105 Bathroom Entry", "target": "room_105_bathroom_entry"},
			{"label": "Front Desk", "target": "front_desk"},
		],
	},
	"room_105_bathroom_entry": {
		"title": "Room 105",
		"photo": "res://resource/images/room_105_bathroom_entry.png",
		"intro": "From this angle the bathroom, closet door, television, and bed are all within reach.",
		"exits": [
			{"label": "Room 105", "target": "room_105_door_window"},
			{"label": "Room 105 Bathroom", "target": "room_105_bathroom"},
			{"label": "Corridor", "target": "corridor"},
		],
	},
	"room_105_bathroom": {
		"title": "Room 105",
		"photo": "res://resource/images/room_105_bathroom.png",
		"curtain_closed_photo": "res://resource/images/room_105_bathroom_curtain_closed.png",
		"intro": "The bathroom is cramped and bright. The mirror, sink, tub, and door are all close together.",
		"exits": [
			{"label": "Room 105 Bathroom Entry", "target": "room_105_bathroom_entry"},
			{"label": "Room 105", "target": "room_105_door_window"},
		],
	},
	"room_106_bed_bathroom_entry": {
		"title": "Room 106",
		"photo": "res://resource/images/room_106_bed_bathroom_entry.png",
		"intro": "Room 106 has a clear view of the bed, window, bathroom entry, and dresser.",
		"exits": [
			{"label": "Room 106 Bathroom", "target": "room_106_bathroom"},
			{"label": "Corridor", "target": "corridor"},
		],
	},
	"room_106_bathroom": {
		"title": "Room 106",
		"photo": "res://resource/images/room_106_bathroom.png",
		"curtain_closed_photo": "res://resource/images/room_106_bathroom_curtain_closed.png",
		"intro": "Room 106 uses the shared bathroom angle for now. The mirror, sink, tub, and door are all close together.",
		"exits": [{"label": "Room 106", "target": "room_106_bed_bathroom_entry"}],
	},
	"room_107_bed_nightstand": {
		"title": "Room 107",
		"photo": "res://resource/images/room_107_bed_nightstand.png",
		"intro": "Room 107 shows the nightstand, phone, and a messier bed.",
		"exits": [
			{"label": "Room 107 Bathroom Entry", "target": "room_107_bathroom_entry"},
			{"label": "Corridor", "target": "corridor"},
		],
	},
	"room_107_bathroom_entry": {
		"title": "Room 107",
		"photo": "res://resource/images/room_107_bathroom_entry.png",
		"intro": "Room 107's second angle shows the bathroom entry and the closet door.",
		"exits": [
			{"label": "Room 107", "target": "room_107_bed_nightstand"},
			{"label": "Room 107 Bathroom", "target": "room_107_bathroom"},
			{"label": "Corridor", "target": "corridor"},
		],
	},
	"room_107_bathroom": {
		"title": "Room 107",
		"photo": "res://resource/images/room_107_bathroom.png",
		"curtain_closed_photo": "res://resource/images/room_107_bathroom_curtain_closed.png",
		"intro": "Room 107 uses the shared bathroom angle for now. The mirror, sink, tub, and door are all close together.",
		"exits": [{"label": "Room 107 Bathroom Entry", "target": "room_107_bathroom_entry"}],
	},
	"room_108_bed_window": {
		"title": "Room 108",
		"photo": "res://resource/images/room_108_bed_window.png",
		"intro": "Room 108 opens on the bed, window, and desk side of the room.",
		"exits": [
			{"label": "Room 108 Bathroom Entry", "target": "room_108_bathroom_entry"},
			{"label": "Corridor", "target": "corridor"},
		],
	},
	"room_108_bathroom_entry": {
		"title": "Room 108",
		"photo": "res://resource/images/room_108_bathroom_entry.png",
		"intro": "From this angle, the bathroom entry, dresser, television, and bed are all visible.",
		"exits": [
			{"label": "Room 108", "target": "room_108_bed_window"},
			{"label": "Room 108 Bathroom", "target": "room_108_bathroom"},
			{"label": "Corridor", "target": "corridor"},
		],
	},
	"room_108_bathroom": {
		"title": "Room 108",
		"photo": "res://resource/images/room_108_bathroom.png",
		"curtain_closed_photo": "res://resource/images/room_108_bathroom_curtain_closed.png",
		"intro": "Room 108 uses the shared bathroom angle for now. The mirror, sink, tub, and door are all close together.",
		"exits": [{"label": "Room 108 Bathroom Entry", "target": "room_108_bathroom_entry"}],
	},
}


static func has_scene(scene_id: String) -> bool:
	return SCENES.has(scene_id)


static func get_scene(scene_id: String) -> Dictionary:
	return SCENES.get(scene_id, {}).duplicate(true)


static func get_scene_ids() -> Array:
	return SCENES.keys()
