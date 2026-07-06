extends Control

const HotelLocalization = preload("res://scripts/localization.gd")
const HotelItemDefinitionScript = preload("res://scripts/items/item_definition.gd")
const HotelItemCombinationRuleScript = preload("res://scripts/items/item_combination_rule.gd")
const HotelInventoryModelScript = preload("res://scripts/items/inventory_model.gd")
const HotelInventoryScreenScript = preload("res://scripts/ui/inventory_screen.gd")
const HotelEquipmentHudScript = preload("res://scripts/ui/equipment_hud.gd")
const HotelRuleBookScreenScript = preload("res://scripts/ui/rule_book_screen.gd")
const HotelPlaybackPauseManagerScript = preload("res://scripts/systems/playback_pause_manager.gd")

const START_SCENE_ID := "front_desk"
const PARALLAX_PADDING := 48.0
const PARALLAX_STRENGTH := 18.0
const TITLE_VISIBLE_SECONDS := 2.0
const TITLE_FADE_SECONDS := 1.0
const DEBUG_UI_ENV := "HOTEL_DEBUG_UI"
const DEBUG_UI_ENABLED_VALUES := ["1", "true", "yes", "on"]
const DEFAULT_BRIGHTNESS := 1.0
const MIN_BRIGHTNESS := 0.55
const MAX_BRIGHTNESS := 1.45
const LAUNDRY_OPEN_PHOTO := "res://resource/images/laundry_room.png"
const LAUNDRY_CLOSED_PHOTO := "res://resource/images/laundry_room_washer_closed.png"
const FOOTSTEP_SOUND := "res://resource/sounds/footstep.ogg"
const FOOTSTEP_COUNT := 3
const FOOTSTEP_INTERVAL_SECONDS := 0.22
const FOOTSTEP_VOLUME_DB := -9.0
const FOOTSTEP_PITCHES := [0.94, 1.03, 0.98, 1.06]
const LOBBY_BACKGROUND_PHOTO := "res://resource/images/front_desk.png"
const LOBBY_BLUR_SHADER_CODE := "shader_type canvas_item;\nuniform float blur_size = 3.5;\nvoid fragment() {\n\tvec2 px = TEXTURE_PIXEL_SIZE * blur_size;\n\tvec4 color = texture(TEXTURE, UV) * 0.18;\n\tcolor += texture(TEXTURE, UV + vec2(px.x, 0.0)) * 0.12;\n\tcolor += texture(TEXTURE, UV - vec2(px.x, 0.0)) * 0.12;\n\tcolor += texture(TEXTURE, UV + vec2(0.0, px.y)) * 0.12;\n\tcolor += texture(TEXTURE, UV - vec2(0.0, px.y)) * 0.12;\n\tcolor += texture(TEXTURE, UV + vec2(px.x, px.y)) * 0.11;\n\tcolor += texture(TEXTURE, UV + vec2(-px.x, px.y)) * 0.11;\n\tcolor += texture(TEXTURE, UV + vec2(px.x, -px.y)) * 0.11;\n\tcolor += texture(TEXTURE, UV - vec2(px.x, px.y)) * 0.11;\n\tCOLOR = color;\n}\n"
const TOTAL_DAYS := 5
const SAVE_VERSION := 1
const SAVE_PATH := "user://hotel_save.json"

const IDLE_STYLE := {
	"bg": Color(1.0, 1.0, 1.0, 0.05),
	"border": Color(1.0, 1.0, 1.0, 0.22),
}
const HOVER_STYLE := {
	"bg": Color(1.0, 0.82, 0.28, 0.2),
	"border": Color(1.0, 0.82, 0.28, 0.9),
}
const PRESS_STYLE := {
	"bg": Color(0.25, 0.72, 1.0, 0.22),
	"border": Color(0.45, 0.82, 1.0, 0.95),
}
const HIDDEN_STYLE := {
	"bg": Color(1.0, 1.0, 1.0, 0.0),
	"border": Color(1.0, 1.0, 1.0, 0.0),
}

const HOTEL_SCENES := {
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
		"hotspots": [
			{
				"id": "front_left_edge",
				"label": "Laundry",
				"rect": Rect2(0.000, 0.000, 0.075, 1.000),
				"target": "laundry_room",
			},
			{
				"id": "front_right_edge",
				"label": "Corridor",
				"rect": Rect2(0.925, 0.000, 0.075, 1.000),
				"target": "corridor",
			},
			{
				"id": "desk_bell",
				"label": "Bell",
				"rect": Rect2(0.407, 0.407, 0.075, 0.095),
				"text": "The bell gives a thin ring that hangs in the lobby for a second.",
			},
			{
				"id": "phone",
				"label": "Phone",
				"rect": Rect2(0.020, 0.690, 0.180, 0.260),
				"text": "The desk phone still works. The last extension dialed was 105.",
			},
			{
				"id": "logbook",
				"label": "Logbook",
				"rect": Rect2(0.390, 0.745, 0.245, 0.190),
				"text": "Guest names, room numbers, and a few rushed pencil marks fill the page.",
			},
			{
				"id": "front_door",
				"label": "Exit Door",
				"rect": Rect2(0.330, 0.020, 0.235, 0.500),
				"text": "The glass door looks out toward the corridor, but this is not the way you leave the desk.",
			},
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
		"hotspots": [
			{
				"id": "corridor_left_edge",
				"label": "Front Desk",
				"rect": Rect2(0.000, 0.000, 0.075, 1.000),
				"target": "front_desk",
			},
			{
				"id": "corridor_bottom_edge",
				"label": "Stairs",
				"rect": Rect2(0.000, 0.860, 1.000, 0.140),
				"target": "exterior_stairs",
			},
			{
				"id": "room_105",
				"label": "Room 105",
				"rect": Rect2(0.080, 0.135, 0.145, 0.475),
				"target": "room_105_door_window",
			},
			{
				"id": "room_106",
				"label": "Room 106",
				"rect": Rect2(0.302, 0.155, 0.102, 0.395),
				"target": "room_106_bed_bathroom_entry",
			},
			{
				"id": "room_107",
				"label": "Room 107",
				"rect": Rect2(0.490, 0.175, 0.080, 0.330),
				"target": "room_107_bed_nightstand",
			},
			{
				"id": "room_108",
				"label": "Room 108",
				"rect": Rect2(0.630, 0.205, 0.060, 0.275),
				"target": "room_108_bed_window",
			},
			{
				"id": "walkway_lights",
				"label": "Lights",
				"rect": Rect2(0.245, 0.155, 0.085, 0.170),
				"text": "The corridor lamps flicker at uneven intervals.",
			},
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
			"hotspots": [
				{
					"id": "room_106_exit_edge",
					"label": "Corridor",
					"rect": Rect2(0.000, 0.000, 0.095, 1.000),
					"target": "corridor",
				},
				{
					"id": "room_106_bed",
					"label": "Bed",
					"rect": Rect2(0.320, 0.560, 0.680, 0.390),
					"text": "The bedspread is pulled into place, but the room still feels recently used.",
				},
				{
					"id": "room_106_window",
					"label": "Window",
					"rect": Rect2(0.425, 0.170, 0.205, 0.310),
					"text": "The curtains leave a narrow view of the outside lights.",
				},
				{
					"id": "room_106_bathroom_entry",
					"label": "Bathroom",
					"rect": Rect2(0.095, 0.150, 0.170, 0.440),
					"target": "room_106_bathroom",
				},
				{
					"id": "room_106_dresser",
					"label": "Dresser",
					"rect": Rect2(0.000, 0.500, 0.180, 0.455),
					"text": "The coffee maker and drawers are within reach of the bathroom door.",
				},
			],
		},
		"room_107_bed_nightstand": {
			"title": "Room 107",
			"photo": "res://resource/images/room_107_bed_nightstand.png",
			"intro": "Room 107 shows the nightstand, phone, and a messier bed.",
			"exits": [
				{"label": "Room 107 Bathroom Entry", "target": "room_107_bathroom_entry"},
				{"label": "Corridor", "target": "corridor"},
			],
			"hotspots": [
				{
					"id": "room_107_turn_edge",
					"label": "Turn",
					"rect": Rect2(0.900, 0.000, 0.100, 1.000),
					"target": "room_107_bathroom_entry",
				},
				{
					"id": "room_107_door",
					"label": "Door",
					"rect": Rect2(0.000, 0.000, 0.090, 1.000),
					"target": "corridor",
				},
				{
					"id": "room_107_nightstand",
					"label": "Nightstand",
					"rect": Rect2(0.750, 0.610, 0.205, 0.250),
					"text": "The room phone sits beside a loose note and a warm lamp.",
				},
				{
					"id": "room_107_window_view",
					"label": "Window",
					"rect": Rect2(0.175, 0.115, 0.245, 0.345),
					"text": "A parked car is visible through the window.",
				},
				{
					"id": "room_107_loose_papers",
					"label": "Papers",
					"rect": Rect2(0.760, 0.850, 0.135, 0.085),
					"text": "A few papers lie on the carpet near the bed.",
				},
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
			"hotspots": [
				{
					"id": "room_107_left_edge",
					"label": "Turn",
					"rect": Rect2(0.000, 0.000, 0.095, 1.000),
					"target": "room_107_bed_nightstand",
				},
				{
					"id": "room_107_bathroom_doorway",
					"label": "Bathroom",
					"rect": Rect2(0.505, 0.095, 0.210, 0.585),
					"target": "room_107_bathroom",
				},
				{
					"id": "room_107_closet_door",
					"label": "Closet",
					"rect": Rect2(0.755, 0.140, 0.165, 0.620),
					"text": "The door beside the bathroom is a closet, not the exit.",
				},
				{
					"id": "room_107_bed_side",
					"label": "Bed",
					"rect": Rect2(0.000, 0.540, 0.470, 0.350),
					"text": "The bed is half lit by the nightstand lamp.",
				},
				{
					"id": "room_107_phone",
					"label": "Phone",
					"rect": Rect2(0.285, 0.420, 0.170, 0.185),
					"text": "The phone is close enough to reach from the pillow.",
				},
			],
		},
		"room_108_bed_window": {
			"title": "Room 108",
			"photo": "res://resource/images/room_108_bed_window.png",
			"intro": "Room 108 opens on the bed, window, and desk side of the room.",
			"exits": [
				{"label": "Room 108 Bathroom Entry", "target": "room_108_bathroom_entry"},
				{"label": "Corridor", "target": "corridor"},
			],
			"hotspots": [
				{
					"id": "room_108_exit_edge",
					"label": "Corridor",
					"rect": Rect2(0.000, 0.000, 0.090, 1.000),
					"target": "corridor",
				},
				{
					"id": "room_108_right_edge",
					"label": "Turn",
					"rect": Rect2(0.905, 0.000, 0.095, 1.000),
					"target": "room_108_bathroom_entry",
				},
				{
					"id": "room_108_bed",
					"label": "Bed",
					"rect": Rect2(0.000, 0.430, 0.620, 0.430),
					"text": "The bed faces the window and catches most of the room's warm light.",
				},
				{
					"id": "room_108_window",
					"label": "Window",
					"rect": Rect2(0.555, 0.115, 0.270, 0.405),
					"text": "The opposite wing of the hotel is visible through the window.",
				},
				{
					"id": "room_108_nightstand",
					"label": "Nightstand",
					"rect": Rect2(0.335, 0.280, 0.120, 0.230),
					"text": "A lamp and a small notepad sit beside the bed.",
				},
				{
					"id": "room_108_desk",
					"label": "Desk",
					"rect": Rect2(0.865, 0.430, 0.130, 0.435),
					"text": "The desk is clear except for the coffee set.",
				},
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
			"hotspots": [
				{
					"id": "room_108_left_edge",
					"label": "Turn",
					"rect": Rect2(0.000, 0.000, 0.095, 1.000),
					"target": "room_108_bed_window",
				},
				{
					"id": "room_108_bathroom_doorway",
					"label": "Bathroom",
					"rect": Rect2(0.830, 0.000, 0.170, 0.820),
					"target": "room_108_bathroom",
				},
				{
					"id": "room_108_television",
					"label": "TV",
					"rect": Rect2(0.610, 0.150, 0.135, 0.235),
					"text": "The television is mounted high on the wall beside the bathroom entry.",
				},
				{
					"id": "room_108_dresser",
					"label": "Dresser",
					"rect": Rect2(0.660, 0.475, 0.235, 0.420),
					"text": "The dresser blocks most of the path along the right wall.",
				},
				{
					"id": "room_108_bed_side",
					"label": "Bed",
					"rect": Rect2(0.000, 0.540, 0.470, 0.350),
					"text": "The blanket is loose near the nightstand.",
				},
				{
					"id": "room_108_phone",
					"label": "Phone",
					"rect": Rect2(0.285, 0.420, 0.170, 0.185),
					"text": "The phone rests beside the lamp, pointed toward the bed.",
				},
			],
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
		"hotspots": [
			{
				"id": "room_left_edge",
				"label": "Turn",
				"rect": Rect2(0.000, 0.680, 0.105, 0.240),
				"target": "room_105_bathroom_entry",
			},
			{
				"id": "room_right_edge",
				"label": "Turn",
				"rect": Rect2(0.905, 0.000, 0.095, 1.000),
				"target": "room_105_bathroom_entry",
			},
			{
				"id": "room_door",
				"label": "Door",
				"rect": Rect2(0.000, 0.090, 0.135, 0.540),
				"target": "corridor",
			},
			{
				"id": "window",
				"label": "Window",
				"rect": Rect2(0.222, 0.147, 0.205, 0.350),
				"text": "The window faces the motel exterior. The glass is cold to the touch.",
			},
			{
				"id": "bed",
				"label": "Bed",
				"rect": Rect2(0.308, 0.465, 0.660, 0.390),
				"text": "The bedspread has been pulled tight, but one corner is slightly tucked under.",
			},
			{
				"id": "lamp",
				"label": "Lamp",
				"rect": Rect2(0.610, 0.335, 0.120, 0.230),
				"text": "The lamp is warm, making the room feel smaller than it is.",
			},
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
		"hotspots": [
			{
				"id": "bathroom_left_edge",
				"label": "Turn",
				"rect": Rect2(0.000, 0.000, 0.095, 1.000),
				"target": "room_105_door_window",
			},
			{
				"id": "bathroom_right_edge",
				"label": "Turn",
				"rect": Rect2(0.925, 0.000, 0.075, 1.000),
				"target": "room_105_door_window",
			},
			{
				"id": "bathroom_sink",
				"label": "Bathroom",
				"rect": Rect2(0.458, 0.260, 0.220, 0.325),
				"target": "room_105_bathroom",
			},
			{
				"id": "closet_door",
				"label": "Closet",
				"rect": Rect2(0.640, 0.220, 0.126, 0.500),
				"text": "The closet door is closed, but the knob is polished from frequent use.",
			},
			{
				"id": "television",
				"label": "TV",
				"rect": Rect2(0.795, 0.435, 0.170, 0.240),
				"text": "The television reflects the room back at you in a warped curve.",
			},
			{
				"id": "nightstand",
				"label": "Nightstand",
				"rect": Rect2(0.270, 0.585, 0.145, 0.170),
				"text": "A phone sits beside the bed. The room card is missing.",
			},
			],
		},
		"room_105_bathroom": {
			"title": "Room 105",
			"photo": "res://resource/images/room_105_bathroom.png",
			"intro": "The bathroom is cramped and bright. The mirror, sink, tub, and door are all close together.",
			"exits": [
				{"label": "Room 105 Bathroom Entry", "target": "room_105_bathroom_entry"},
				{"label": "Room 105", "target": "room_105_door_window"},
			],
			"hotspots": [
				{
					"id": "bathroom_door",
					"label": "Door",
					"rect": Rect2(0.835, 0.000, 0.165, 1.000),
					"target": "room_105_bathroom_entry",
				},
				{
					"id": "bathroom_mirror",
					"label": "Mirror",
					"rect": Rect2(0.000, 0.000, 0.225, 0.520),
					"text": "The mirror is worn at the edges, blurring the room behind you.",
				},
				{
					"id": "bathroom_sink",
					"label": "Sink",
					"rect": Rect2(0.000, 0.560, 0.395, 0.280),
					"text": "A small tube rests near the sink. The counter is stained from years of use.",
				},
				{
					"id": "bathroom_tub",
					"label": "Tub",
					"rect": Rect2(0.455, 0.120, 0.340, 0.760),
					"text": "The shower curtain hangs still. The tub is dry.",
				},
			],
		},
		"room_106_bathroom": {
			"title": "Room 106",
			"photo": "res://resource/images/room_106_bathroom.png",
			"intro": "Room 106 uses the shared bathroom angle for now. The mirror, sink, tub, and door are all close together.",
			"exits": [
				{"label": "Room 106", "target": "room_106_bed_bathroom_entry"},
			],
			"hotspots": [
				{
					"id": "room_106_bathroom_door",
					"label": "Door",
					"rect": Rect2(0.835, 0.000, 0.165, 1.000),
					"target": "room_106_bed_bathroom_entry",
				},
				{
					"id": "room_106_bathroom_mirror",
					"label": "Mirror",
					"rect": Rect2(0.000, 0.000, 0.225, 0.520),
					"text": "The mirror is worn at the edges, blurring the room behind you.",
				},
				{
					"id": "room_106_bathroom_sink",
					"label": "Sink",
					"rect": Rect2(0.000, 0.560, 0.395, 0.280),
					"text": "A small tube rests near the sink. The counter is stained from years of use.",
				},
				{
					"id": "room_106_bathroom_tub",
					"label": "Tub",
					"rect": Rect2(0.455, 0.120, 0.340, 0.760),
					"text": "The shower curtain hangs still. The tub is dry.",
				},
			],
		},
		"room_107_bathroom": {
			"title": "Room 107",
			"photo": "res://resource/images/room_107_bathroom.png",
			"intro": "Room 107 uses the shared bathroom angle for now. The mirror, sink, tub, and door are all close together.",
			"exits": [
				{"label": "Room 107 Bathroom Entry", "target": "room_107_bathroom_entry"},
			],
			"hotspots": [
				{
					"id": "room_107_bathroom_door",
					"label": "Door",
					"rect": Rect2(0.835, 0.000, 0.165, 1.000),
					"target": "room_107_bathroom_entry",
				},
				{
					"id": "room_107_bathroom_mirror",
					"label": "Mirror",
					"rect": Rect2(0.000, 0.000, 0.225, 0.520),
					"text": "The mirror is worn at the edges, blurring the room behind you.",
				},
				{
					"id": "room_107_bathroom_sink",
					"label": "Sink",
					"rect": Rect2(0.000, 0.560, 0.395, 0.280),
					"text": "A small tube rests near the sink. The counter is stained from years of use.",
				},
				{
					"id": "room_107_bathroom_tub",
					"label": "Tub",
					"rect": Rect2(0.455, 0.120, 0.340, 0.760),
					"text": "The shower curtain hangs still. The tub is dry.",
				},
			],
		},
		"room_108_bathroom": {
			"title": "Room 108",
			"photo": "res://resource/images/room_108_bathroom.png",
			"intro": "Room 108 uses the shared bathroom angle for now. The mirror, sink, tub, and door are all close together.",
			"exits": [
				{"label": "Room 108 Bathroom Entry", "target": "room_108_bathroom_entry"},
			],
			"hotspots": [
				{
					"id": "room_108_bathroom_door",
					"label": "Door",
					"rect": Rect2(0.835, 0.000, 0.165, 1.000),
					"target": "room_108_bathroom_entry",
				},
				{
					"id": "room_108_bathroom_mirror",
					"label": "Mirror",
					"rect": Rect2(0.000, 0.000, 0.225, 0.520),
					"text": "The mirror is worn at the edges, blurring the room behind you.",
				},
				{
					"id": "room_108_bathroom_sink",
					"label": "Sink",
					"rect": Rect2(0.000, 0.560, 0.395, 0.280),
					"text": "A small tube rests near the sink. The counter is stained from years of use.",
				},
				{
					"id": "room_108_bathroom_tub",
					"label": "Tub",
					"rect": Rect2(0.455, 0.120, 0.340, 0.760),
					"text": "The shower curtain hangs still. The tub is dry.",
				},
			],
		},
		"laundry_room": {
			"title": "Laundry Room",
			"photo": "res://resource/images/laundry_room.png",
			"intro": "The laundry room hums under fluorescent light. Machines line the walls and the exit is behind you.",
			"exits": [
				{"label": "Front Desk", "target": "front_desk"},
			],
			"hotspots": [
				{
					"id": "laundry_bottom_edge",
					"label": "Exit",
					"rect": Rect2(0.000, 0.740, 1.000, 0.135),
					"target": "front_desk",
				},
				{
					"id": "laundry_second_washer",
					"label": "Washer",
					"rect": Rect2(0.585, 0.440, 0.130, 0.335),
					"action": "toggle_laundry_washer",
				},
				{
					"id": "laundry_rules",
					"label": "Rules",
					"rect": Rect2(0.505, 0.260, 0.100, 0.150),
					"text": "Laundry rules are posted beside the window in small print.",
				},
				{
					"id": "detergent",
					"label": "Detergent",
					"rect": Rect2(0.175, 0.465, 0.185, 0.130),
					"text": "Detergent bottles sit near the sink, lined up like someone left in a hurry.",
				},
			],
		},
		"exterior_stairs": {
			"title": "Exterior Stairs",
			"photo": "res://resource/images/exterior_stairs.png",
			"intro": "The exterior stairs cut across the motel wall. Wet asphalt spreads out below.",
			"exits": [
				{"label": "Corridor", "target": "corridor"},
			],
			"hotspots": [
				{
					"id": "stairs_right_edge",
					"label": "Corridor",
					"rect": Rect2(0.900, 0.000, 0.100, 1.000),
					"target": "corridor",
				},
				{
					"id": "metal_stairs",
					"label": "Stairs",
					"rect": Rect2(0.295, 0.085, 0.440, 0.815),
					"text": "The metal stairs creak under light pressure.",
				},
			],
		},
	}

var localization := HotelLocalization.new()
var inventory_model = null
var playback_pause_manager = null
var current_scene_id := START_SCENE_ID
var current_texture: Texture2D
var hotspot_buttons: Array[Button] = []
var debug_ui_enabled := false
var show_hotspots := false
var show_persistent_dialogue := false
var show_navigation := false
var laundry_second_washer_open := true
var game_brightness := DEFAULT_BRIGHTNESS
var current_persistent_dialogue_text := ""
var mouse_position := Vector2.ZERO
var title_tween: Tween
var transient_dialogue_tween: Tween
var footstep_stream: AudioStream
var footstep_players: Array[AudioStreamPlayer] = []
var footstep_timer: Timer
var footstep_index := 0
var game_started := false
var current_day := 1
var unlocked_days: Array[int] = [1]
var day_slots: Dictionary = {}

var gameplay_layer: Control
var photo: TextureRect
var brightness_overlay: ColorRect
var hotspot_layer: Control
var title_panel: PanelContainer
var title_label: Label
var day_badge_panel: PanelContainer
var day_badge_label: Label
var debug_panel: PanelContainer
var persistent_dialogue_panel: PanelContainer
var persistent_dialogue_label: Label
var transient_dialogue_panel: PanelContainer
var transient_dialogue_label: Label
var navigation_panel: PanelContainer
var nav_bar: HBoxContainer
var debug_day_bar: HBoxContainer
var hotspot_toggle: Button
var chat_toggle: Button
var navigation_toggle: Button
var menu_overlay: ColorRect
var brightness_slider: HSlider
var brightness_value_label: Label
var inventory_tab_button: Button
var rule_book_tab_button: Button
var inventory_screen
var equipment_hud
var rule_book_screen
var lobby_overlay: Control
var lobby_continue_button: Button
var lobby_day_panel: PanelContainer
var lobby_day_grid: GridContainer
var lobby_status_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_PASS
	_hide_editor_hotspot_definitions()
	inventory_model = HotelInventoryModelScript.new()
	playback_pause_manager = HotelPlaybackPauseManagerScript.new()
	debug_ui_enabled = _is_debug_ui_enabled()
	get_tree().root.size_changed.connect(_update_layout)
	_seed_inventory()
	_load_save_data()
	_build_ui()
	_build_audio()
	_show_lobby()


func _is_debug_ui_enabled() -> bool:
	var value := OS.get_environment(DEBUG_UI_ENV).strip_edges().to_lower()
	return DEBUG_UI_ENABLED_VALUES.has(value) or OS.has_feature("editor")


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if _is_lobby_open():
			get_viewport().set_input_as_handled()
			return

		_toggle_menu()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion and not _is_menu_open():
		mouse_position = event.position
		_update_layout()


func show_scene(scene_id: String, play_transition_sound := true) -> void:
	if not HOTEL_SCENES.has(scene_id):
		push_warning("Unknown hotel scene: %s" % scene_id)
		return

	if play_transition_sound and current_scene_id != scene_id:
		_play_transition_footsteps()

	current_scene_id = scene_id
	var scene_data: Dictionary = HOTEL_SCENES[current_scene_id]
	current_texture = load(_scene_photo(scene_id, scene_data)) as Texture2D
	photo.texture = current_texture
	title_label.text = _scene_text(scene_id, scene_data, "title")
	_show_title_banner()
	_set_persistent_dialogue(_scene_text(scene_id, scene_data, "intro"))
	_build_hotspots(_scene_hotspots(scene_id, scene_data))
	_build_navigation(scene_data["exits"])
	_apply_brightness()
	_update_layout()


func _build_ui() -> void:
	gameplay_layer = Control.new()
	gameplay_layer.process_mode = Node.PROCESS_MODE_PAUSABLE
	gameplay_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	gameplay_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(gameplay_layer)

	photo = TextureRect.new()
	photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gameplay_layer.add_child(photo)

	brightness_overlay = ColorRect.new()
	brightness_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	brightness_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gameplay_layer.add_child(brightness_overlay)
	_apply_brightness()

	hotspot_layer = Control.new()
	hotspot_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hotspot_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gameplay_layer.add_child(hotspot_layer)

	title_panel = PanelContainer.new()
	title_panel.position = Vector2(18.0, 18.0)
	title_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.78), Color(1.0, 1.0, 1.0, 0.10), 8))
	gameplay_layer.add_child(title_panel)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	title_panel.add_child(title_label)

	day_badge_panel = PanelContainer.new()
	day_badge_panel.visible = false
	day_badge_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	day_badge_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.10, 0.075, 0.035, 0.78), Color(1.0, 0.72, 0.25, 0.42), 999))
	gameplay_layer.add_child(day_badge_panel)

	day_badge_label = Label.new()
	day_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_badge_label.add_theme_font_size_override("font_size", 14)
	day_badge_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.58))
	day_badge_panel.add_child(day_badge_label)

	debug_panel = PanelContainer.new()
	debug_panel.anchor_left = 1.0
	debug_panel.anchor_right = 1.0
	debug_panel.anchor_top = 0.0
	debug_panel.anchor_bottom = 0.0
	debug_panel.offset_left = -184.0
	debug_panel.offset_top = 18.0
	debug_panel.offset_right = -18.0
	debug_panel.offset_bottom = 66.0
	debug_panel.visible = debug_ui_enabled
	debug_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.78), Color(1.0, 1.0, 1.0, 0.10), 8))
	gameplay_layer.add_child(debug_panel)

	var corner_row := HBoxContainer.new()
	corner_row.add_theme_constant_override("separation", 8)
	debug_panel.add_child(corner_row)

	hotspot_toggle = _make_debug_button("▣", _ui_text("debug.hotspots.show", "Show click areas"), _toggle_hotspots)
	corner_row.add_child(hotspot_toggle)

	chat_toggle = _make_debug_button("💬", _ui_text("debug.dialogue.hide", "Hide dialogue panel"), _toggle_chat)
	corner_row.add_child(chat_toggle)

	navigation_toggle = _make_debug_button("🧭", _ui_text("debug.navigation.show", "Show quick travel buttons"), _toggle_navigation)
	corner_row.add_child(navigation_toggle)

	persistent_dialogue_panel = PanelContainer.new()
	persistent_dialogue_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	persistent_dialogue_panel.gui_input.connect(_on_persistent_dialogue_input)
	persistent_dialogue_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.82), Color(1.0, 1.0, 1.0, 0.10), 8))
	gameplay_layer.add_child(persistent_dialogue_panel)

	var bottom_layout := VBoxContainer.new()
	bottom_layout.add_theme_constant_override("separation", 10)
	persistent_dialogue_panel.add_child(bottom_layout)

	persistent_dialogue_label = Label.new()
	persistent_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	persistent_dialogue_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	persistent_dialogue_label.add_theme_font_size_override("font_size", 18)
	persistent_dialogue_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	bottom_layout.add_child(persistent_dialogue_label)

	transient_dialogue_panel = PanelContainer.new()
	transient_dialogue_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transient_dialogue_panel.visible = false
	transient_dialogue_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.78), Color(1.0, 1.0, 1.0, 0.0), 8))
	gameplay_layer.add_child(transient_dialogue_panel)

	transient_dialogue_label = Label.new()
	transient_dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transient_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	transient_dialogue_label.max_lines_visible = 2
	transient_dialogue_label.add_theme_font_size_override("font_size", 18)
	transient_dialogue_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	transient_dialogue_panel.add_child(transient_dialogue_label)

	navigation_panel = PanelContainer.new()
	navigation_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.82), Color(1.0, 1.0, 1.0, 0.10), 8))
	gameplay_layer.add_child(navigation_panel)

	var navigation_layout := VBoxContainer.new()
	navigation_layout.add_theme_constant_override("separation", 8)
	navigation_panel.add_child(navigation_layout)

	nav_bar = HBoxContainer.new()
	nav_bar.add_theme_constant_override("separation", 8)
	navigation_layout.add_child(nav_bar)

	debug_day_bar = HBoxContainer.new()
	debug_day_bar.add_theme_constant_override("separation", 8)
	navigation_layout.add_child(debug_day_bar)
	_build_debug_day_bar()

	equipment_hud = HotelEquipmentHudScript.new()
	equipment_hud.anchor_left = 0.0
	equipment_hud.anchor_right = 0.0
	equipment_hud.anchor_top = 1.0
	equipment_hud.anchor_bottom = 1.0
	equipment_hud.offset_left = 18.0
	equipment_hud.offset_top = -106.0
	equipment_hud.offset_right = 112.0
	equipment_hud.offset_bottom = -18.0
	gameplay_layer.add_child(equipment_hud)
	equipment_hud.bind_inventory(inventory_model, localization)
	equipment_hud.activated.connect(_show_menu)

	_position_bottom_panels()
	_apply_persistent_dialogue_display()
	_apply_navigation_display()
	_sync_debug_toggles()
	_build_menu()
	_build_lobby()
	_update_day_display()


func _hide_editor_hotspot_definitions() -> void:
	var definitions := get_node_or_null("HotspotDefinitions")
	if definitions is CanvasItem:
		definitions.visible = false


func _seed_inventory() -> void:
	_register_inventory_item("room_105_key", "Room 105 Key", "A worn brass key from the front desk drawer.", "🔑")
	_register_inventory_item("small_flashlight", "Flashlight", "A compact flashlight. Useful when the power fails.", "🔦")
	_register_inventory_item("guest_note", "Guest Note", "A folded note with a room number written in pencil.", "📝")
	_register_inventory_item("revealed_guest_note", "Revealed Note", "The flashlight reveals faint writing under the room number: Do not return it after midnight.", "📄")

	inventory_model.add_item_by_id("room_105_key")
	inventory_model.add_item_by_id("small_flashlight")
	inventory_model.add_item_by_id("guest_note")
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


func _register_inventory_item(item_id: String, item_name: String, item_description: String, item_icon_text: String, item_can_equip := true) -> void:
	inventory_model.register_item_definition(_make_inventory_item(item_id, item_name, item_description, item_icon_text, item_can_equip))


func _make_inventory_item(item_id: String, item_name: String, item_description: String, item_icon_text: String, item_can_equip := true):
	var item = HotelItemDefinitionScript.new()
	item.id = item_id
	item.name_key = "item.%s.name" % item_id
	item.description_key = "item.%s.description" % item_id
	item.fallback_display_name = item_name
	item.fallback_description = item_description
	item.icon_text = item_icon_text
	item.can_equip = item_can_equip
	return item


func _make_combination_rule(rule_id: String, item_a_id: String, item_b_id: String, result_item_ids: Array[String], consume_item_a := true, consume_item_b := true, message_key := "", fallback_message := ""):
	var rule = HotelItemCombinationRuleScript.new()
	rule.id = rule_id
	rule.item_a_id = item_a_id
	rule.item_b_id = item_b_id
	rule.result_item_ids = result_item_ids
	rule.consume_item_a = consume_item_a
	rule.consume_item_b = consume_item_b
	rule.message_key = message_key
	rule.fallback_message = fallback_message
	return rule


func _build_audio() -> void:
	footstep_stream = load(FOOTSTEP_SOUND) as AudioStream
	if footstep_stream == null:
		push_warning("Missing footstep sound: %s" % FOOTSTEP_SOUND)
		return

	for index in range(FOOTSTEP_COUNT):
		var player := AudioStreamPlayer.new()
		player.process_mode = Node.PROCESS_MODE_PAUSABLE
		player.stream = footstep_stream
		player.volume_db = FOOTSTEP_VOLUME_DB
		gameplay_layer.add_child(player)
		footstep_players.append(player)

	footstep_timer = Timer.new()
	footstep_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	footstep_timer.one_shot = false
	footstep_timer.wait_time = FOOTSTEP_INTERVAL_SECONDS
	footstep_timer.timeout.connect(_on_footstep_timer_timeout)
	gameplay_layer.add_child(footstep_timer)


func _build_menu() -> void:
	menu_overlay = ColorRect.new()
	menu_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_overlay.color = Color(0.0, 0.0, 0.0, 0.58)
	menu_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_overlay.visible = false
	menu_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_overlay)

	var center := CenterContainer.new()
	center.process_mode = Node.PROCESS_MODE_ALWAYS
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_overlay.add_child(center)

	var shell := HBoxContainer.new()
	shell.process_mode = Node.PROCESS_MODE_ALWAYS
	shell.add_theme_constant_override("separation", 24)
	center.add_child(shell)

	var menu_panel := PanelContainer.new()
	menu_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_panel.custom_minimum_size = Vector2(360.0, 0.0)
	menu_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.94), Color(1.0, 1.0, 1.0, 0.16), 12))
	shell.add_child(menu_panel)

	var layout := VBoxContainer.new()
	layout.process_mode = Node.PROCESS_MODE_ALWAYS
	layout.add_theme_constant_override("separation", 14)
	menu_panel.add_child(layout)

	var title := Label.new()
	title.text = _ui_text("menu.title", "Menu")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	layout.add_child(title)

	var continue_button := Button.new()
	continue_button.text = _ui_text("menu.continue", "Continue")
	continue_button.focus_mode = Control.FOCUS_NONE
	continue_button.pressed.connect(_hide_menu)
	layout.add_child(continue_button)

	var main_menu_button := Button.new()
	main_menu_button.text = _ui_text("menu.main_menu", "Main Menu")
	main_menu_button.focus_mode = Control.FOCUS_NONE
	main_menu_button.pressed.connect(_return_to_lobby)
	layout.add_child(main_menu_button)

	var brightness_label := Label.new()
	brightness_label.text = _ui_text("menu.brightness", "Brightness")
	brightness_label.add_theme_font_size_override("font_size", 16)
	brightness_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	layout.add_child(brightness_label)

	var brightness_row := HBoxContainer.new()
	brightness_row.add_theme_constant_override("separation", 10)
	layout.add_child(brightness_row)

	brightness_slider = HSlider.new()
	brightness_slider.min_value = MIN_BRIGHTNESS
	brightness_slider.max_value = MAX_BRIGHTNESS
	brightness_slider.step = 0.01
	brightness_slider.value = game_brightness
	brightness_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brightness_slider.value_changed.connect(_on_brightness_changed)
	brightness_row.add_child(brightness_slider)

	brightness_value_label = Label.new()
	brightness_value_label.custom_minimum_size = Vector2(56.0, 0.0)
	brightness_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	brightness_value_label.add_theme_font_size_override("font_size", 16)
	brightness_value_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	brightness_row.add_child(brightness_value_label)

	var quit_button := Button.new()
	quit_button.text = _ui_text("menu.quit", "Quit")
	quit_button.focus_mode = Control.FOCUS_NONE
	quit_button.pressed.connect(_quit_game)
	layout.add_child(quit_button)

	var content_shell := VBoxContainer.new()
	content_shell.process_mode = Node.PROCESS_MODE_ALWAYS
	content_shell.add_theme_constant_override("separation", 0)
	shell.add_child(content_shell)

	var tab_bar := HBoxContainer.new()
	tab_bar.process_mode = Node.PROCESS_MODE_ALWAYS
	tab_bar.add_theme_constant_override("separation", 2)
	content_shell.add_child(tab_bar)

	inventory_tab_button = Button.new()
	inventory_tab_button.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_tab_button.text = _ui_text("menu.inventory", "Inventory")
	inventory_tab_button.toggle_mode = true
	inventory_tab_button.focus_mode = Control.FOCUS_NONE
	inventory_tab_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	inventory_tab_button.pressed.connect(_show_inventory_menu_panel)
	tab_bar.add_child(inventory_tab_button)

	rule_book_tab_button = Button.new()
	rule_book_tab_button.process_mode = Node.PROCESS_MODE_ALWAYS
	rule_book_tab_button.text = _ui_text("menu.rule_book", "Rule Book")
	rule_book_tab_button.toggle_mode = true
	rule_book_tab_button.focus_mode = Control.FOCUS_NONE
	rule_book_tab_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	rule_book_tab_button.pressed.connect(_show_rule_book_menu_panel)
	tab_bar.add_child(rule_book_tab_button)

	inventory_screen = HotelInventoryScreenScript.new()
	inventory_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_screen.custom_minimum_size = Vector2(570.0, 420.0)
	inventory_screen.setup(inventory_model, localization)
	content_shell.add_child(inventory_screen)

	rule_book_screen = HotelRuleBookScreenScript.new()
	rule_book_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	rule_book_screen.custom_minimum_size = Vector2(570.0, 420.0)
	rule_book_screen.setup(localization)
	rule_book_screen.visible = false
	content_shell.add_child(rule_book_screen)

	_update_brightness_label()


func _build_lobby() -> void:
	lobby_overlay = Control.new()
	lobby_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	lobby_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	lobby_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(lobby_overlay)

	var background := TextureRect.new()
	background.process_mode = Node.PROCESS_MODE_ALWAYS
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.texture = load(LOBBY_BACKGROUND_PHOTO) as Texture2D
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.material = _make_lobby_blur_material()
	lobby_overlay.add_child(background)

	var shade := ColorRect.new()
	shade.process_mode = Node.PROCESS_MODE_ALWAYS
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.color = Color(0.0, 0.0, 0.0, 0.46)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lobby_overlay.add_child(shade)

	var center := CenterContainer.new()
	center.process_mode = Node.PROCESS_MODE_ALWAYS
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lobby_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	panel.custom_minimum_size = Vector2(460.0, 0.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.90), Color(1.0, 1.0, 1.0, 0.14), 12))
	center.add_child(panel)

	var layout := VBoxContainer.new()
	layout.process_mode = Node.PROCESS_MODE_ALWAYS
	layout.add_theme_constant_override("separation", 14)
	panel.add_child(layout)

	var title := Label.new()
	title.text = _ui_text("lobby.title", "Night Shift")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(1.0, 0.92, 0.72))
	layout.add_child(title)

	var start_button := Button.new()
	start_button.process_mode = Node.PROCESS_MODE_ALWAYS
	start_button.text = _ui_text("lobby.start_shift", "Start Shift")
	start_button.focus_mode = Control.FOCUS_NONE
	start_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	start_button.pressed.connect(_start_shift)
	layout.add_child(start_button)

	lobby_continue_button = Button.new()
	lobby_continue_button.process_mode = Node.PROCESS_MODE_ALWAYS
	lobby_continue_button.text = _ui_text("lobby.continue", "Continue")
	lobby_continue_button.focus_mode = Control.FOCUS_NONE
	lobby_continue_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	lobby_continue_button.pressed.connect(_toggle_lobby_day_panel)
	layout.add_child(lobby_continue_button)

	lobby_day_panel = PanelContainer.new()
	lobby_day_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	lobby_day_panel.visible = false
	lobby_day_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.02, 0.024, 0.028, 0.70), Color(1.0, 1.0, 1.0, 0.08), 10))
	layout.add_child(lobby_day_panel)

	var day_layout := VBoxContainer.new()
	day_layout.process_mode = Node.PROCESS_MODE_ALWAYS
	day_layout.add_theme_constant_override("separation", 10)
	lobby_day_panel.add_child(day_layout)

	var day_title := Label.new()
	day_title.text = _ui_text("lobby.choose_day", "Choose Day")
	day_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_title.add_theme_font_size_override("font_size", 16)
	day_title.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	day_layout.add_child(day_title)

	lobby_day_grid = GridContainer.new()
	lobby_day_grid.process_mode = Node.PROCESS_MODE_ALWAYS
	lobby_day_grid.columns = TOTAL_DAYS
	lobby_day_grid.add_theme_constant_override("h_separation", 8)
	day_layout.add_child(lobby_day_grid)

	var quit_button := Button.new()
	quit_button.process_mode = Node.PROCESS_MODE_ALWAYS
	quit_button.text = _ui_text("lobby.quit", "Quit")
	quit_button.focus_mode = Control.FOCUS_NONE
	quit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	quit_button.pressed.connect(_quit_game)
	layout.add_child(quit_button)

	_refresh_lobby_continue_state()


func _make_lobby_blur_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = LOBBY_BLUR_SHADER_CODE

	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("blur_size", 4.0)
	return material


func _show_lobby() -> void:
	game_started = false
	if lobby_overlay != null:
		_refresh_lobby_continue_state()
		lobby_overlay.visible = true
		lobby_overlay.move_to_front()

	_set_game_paused(true)


func _start_shift() -> void:
	day_slots.clear()
	unlocked_days = [1]
	current_day = 1
	laundry_second_washer_open = true
	game_brightness = DEFAULT_BRIGHTNESS
	_start_day(1, false, false)


func _toggle_lobby_day_panel() -> void:
	if lobby_day_panel == null or not _has_save_data():
		return

	lobby_day_panel.visible = not lobby_day_panel.visible
	_refresh_lobby_day_grid()


func _start_saved_day(day: int) -> void:
	_start_day(day, true, false)


func _start_day(day: int, use_saved_state: bool, play_transition_sound: bool) -> void:
	game_started = true
	current_day = clampi(day, 1, TOTAL_DAYS)
	_unlock_day(current_day)

	if lobby_overlay != null:
		lobby_overlay.visible = false

	_set_game_paused(false)

	var target_scene_id := START_SCENE_ID
	if use_saved_state:
		target_scene_id = _restore_day_state(current_day)
	else:
		_reset_day_runtime_state()

	show_scene(target_scene_id, play_transition_sound)
	_save_current_day()
	_update_day_display()


func _is_lobby_open() -> bool:
	return lobby_overlay != null and lobby_overlay.visible


func _load_save_data() -> void:
	unlocked_days = [1]
	day_slots.clear()
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var save_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		push_warning("Failed to open save file: %s" % SAVE_PATH)
		return

	var parsed = JSON.parse_string(save_file.get_as_text())
	if not parsed is Dictionary:
		push_warning("Ignoring invalid save file: %s" % SAVE_PATH)
		return

	var save_data: Dictionary = parsed
	unlocked_days.clear()
	for value in save_data.get("unlocked_days", [1]):
		_unlock_day(int(value))

	var saved_slots: Dictionary = save_data.get("day_slots", {})
	for key in saved_slots.keys():
		var day := clampi(int(key), 1, TOTAL_DAYS)
		var slot = saved_slots[key]
		if slot is Dictionary:
			day_slots[str(day)] = slot
			_unlock_day(day)

	if unlocked_days.is_empty():
		unlocked_days = [1]

	current_day = clampi(int(save_data.get("current_day", 1)), 1, TOTAL_DAYS)


func _save_current_day() -> void:
	_store_current_day_state()
	_write_save_data()
	_refresh_lobby_continue_state()


func _store_current_day_state() -> void:
	_unlock_day(current_day)
	day_slots[str(current_day)] = {
		"day": current_day,
		"scene_id": current_scene_id,
		"laundry_second_washer_open": laundry_second_washer_open,
		"game_brightness": game_brightness,
	}


func _write_save_data() -> void:
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		push_warning("Failed to write save file: %s" % SAVE_PATH)
		return

	save_file.store_string(JSON.stringify({
		"version": SAVE_VERSION,
		"current_day": current_day,
		"unlocked_days": unlocked_days,
		"day_slots": day_slots,
	}, "\t"))


func _restore_day_state(day: int) -> String:
	var slot: Dictionary = day_slots.get(str(day), {})
	laundry_second_washer_open = bool(slot.get("laundry_second_washer_open", true))
	game_brightness = float(slot.get("game_brightness", DEFAULT_BRIGHTNESS))
	if brightness_slider != null:
		brightness_slider.value = game_brightness

	var saved_scene_id := String(slot.get("scene_id", START_SCENE_ID))
	if not HOTEL_SCENES.has(saved_scene_id):
		return START_SCENE_ID

	return saved_scene_id


func _reset_day_runtime_state() -> void:
	laundry_second_washer_open = true
	game_brightness = DEFAULT_BRIGHTNESS
	if brightness_slider != null:
		brightness_slider.value = game_brightness


func _change_day(day: int) -> void:
	var target_day := clampi(day, 1, TOTAL_DAYS)
	if target_day == current_day:
		return

	_save_current_day()
	_start_day(target_day, _has_saved_day(target_day), false)


func _unlock_day(day: int) -> void:
	var safe_day := clampi(day, 1, TOTAL_DAYS)
	if not unlocked_days.has(safe_day):
		unlocked_days.append(safe_day)
		unlocked_days.sort()


func _has_save_data() -> bool:
	return not day_slots.is_empty()


func _has_saved_day(day: int) -> bool:
	return day_slots.has(str(clampi(day, 1, TOTAL_DAYS)))


func _day_name(day: int) -> String:
	return _ui_text("day.label", "Day %d") % day


func _refresh_lobby_continue_state() -> void:
	if lobby_continue_button == null:
		return

	var has_save := _has_save_data()
	lobby_continue_button.disabled = not has_save
	lobby_continue_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if has_save else Control.CURSOR_FORBIDDEN
	lobby_continue_button.tooltip_text = ""

	if lobby_day_panel != null and not has_save:
		lobby_day_panel.visible = false

	_refresh_lobby_day_grid()


func _refresh_lobby_day_grid() -> void:
	if lobby_day_grid == null:
		return

	for child in lobby_day_grid.get_children():
		child.queue_free()

	for day in range(1, TOTAL_DAYS + 1):
		var day_button := Button.new()
		day_button.process_mode = Node.PROCESS_MODE_ALWAYS
		day_button.custom_minimum_size = Vector2(72.0, 48.0)
		day_button.text = _day_name(day)
		day_button.focus_mode = Control.FOCUS_NONE
		day_button.disabled = not _has_saved_day(day)
		day_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not day_button.disabled else Control.CURSOR_FORBIDDEN
		day_button.tooltip_text = _ui_text("lobby.day.saved", "Start from this saved day.") if not day_button.disabled else _ui_text("lobby.day.locked", "Reach this day first.")
		day_button.pressed.connect(_start_saved_day.bind(day))
		lobby_day_grid.add_child(day_button)


func _latest_saved_day() -> int:
	var latest_day := 1
	for key in day_slots.keys():
		latest_day = max(latest_day, int(key))

	return latest_day


func _build_hotspots(hotspots: Array) -> void:
	for button in hotspot_buttons:
		button.queue_free()
	hotspot_buttons.clear()

	for hotspot in hotspots:
		var label := _hotspot_text(hotspot, "label")
		var button := Button.new()
		button.text = label
		button.tooltip_text = _hotspot_tooltip(hotspot, label)
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.set_meta("hotspot", hotspot)
		button.add_theme_font_size_override("font_size", 15)
		button.pressed.connect(_on_hotspot_pressed.bind(hotspot))
		hotspot_layer.add_child(button)
		hotspot_buttons.append(button)

	_apply_hotspot_display()


func _build_navigation(exits: Array) -> void:
	for child in nav_bar.get_children():
		child.queue_free()

	for exit_data in exits:
		var button := Button.new()
		button.text = _exit_label(exit_data)
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(_on_navigation_pressed.bind(exit_data["target"]))
		nav_bar.add_child(button)

	_apply_navigation_display()


func _build_debug_day_bar() -> void:
	if debug_day_bar == null:
		return

	for child in debug_day_bar.get_children():
		child.queue_free()

	var title := Label.new()
	title.text = _ui_text("debug.days.title", "Day")
	title.custom_minimum_size = Vector2(54.0, 0.0)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.58))
	debug_day_bar.add_child(title)

	for day in range(1, TOTAL_DAYS + 1):
		var day_button := Button.new()
		day_button.text = str(day)
		day_button.toggle_mode = true
		day_button.focus_mode = Control.FOCUS_NONE
		day_button.custom_minimum_size = Vector2(38.0, 32.0)
		day_button.tooltip_text = _ui_text("debug.days.tooltip", "Jump to this day and autosave the current day.")
		day_button.pressed.connect(_change_day.bind(day))
		debug_day_bar.add_child(day_button)

	_refresh_debug_day_buttons()


func _on_navigation_pressed(scene_id: String) -> void:
	show_scene(scene_id)


func _on_hotspot_pressed(hotspot: Dictionary) -> void:
	if hotspot.has("action"):
		_run_hotspot_action(hotspot["action"])
		return

	if hotspot.has("target"):
		show_scene(hotspot["target"])
		return

	var label := _hotspot_text(hotspot, "label")
	_show_transient_dialogue(_hotspot_tooltip(hotspot, label))


func _run_hotspot_action(action: String) -> void:
	match action:
		"toggle_laundry_washer":
			_toggle_laundry_washer()
		_:
			push_warning("Unknown hotspot action: %s" % action)


func _play_transition_footsteps() -> void:
	if footstep_stream == null or footstep_players.is_empty() or footstep_timer == null:
		return

	footstep_timer.stop()
	footstep_index = 0
	_play_next_footstep()
	if footstep_index < FOOTSTEP_COUNT:
		footstep_timer.start()


func _on_footstep_timer_timeout() -> void:
	_play_next_footstep()
	if footstep_index >= FOOTSTEP_COUNT:
		footstep_timer.stop()


func _play_next_footstep() -> void:
	var player := footstep_players[footstep_index % footstep_players.size()]
	player.pitch_scale = FOOTSTEP_PITCHES[footstep_index % FOOTSTEP_PITCHES.size()]
	player.stop()
	player.play()
	footstep_index += 1


func _toggle_laundry_washer() -> void:
	laundry_second_washer_open = not laundry_second_washer_open
	if current_scene_id == "laundry_room":
		var scene_data: Dictionary = HOTEL_SCENES[current_scene_id]
		current_texture = load(_scene_photo(current_scene_id, scene_data)) as Texture2D
		photo.texture = current_texture
		_apply_brightness()
		_update_layout()

	var state_key := "opened" if laundry_second_washer_open else "closed"
	var message := "The second washer door is open." if laundry_second_washer_open else "The second washer door is closed."
	_show_transient_dialogue(localization.translate("hotspot.laundry_room.laundry_second_washer.%s" % state_key, message))


func _toggle_hotspots() -> void:
	show_hotspots = not show_hotspots
	_apply_hotspot_display()


func _toggle_chat() -> void:
	show_persistent_dialogue = not show_persistent_dialogue
	_apply_persistent_dialogue_display()


func _toggle_navigation() -> void:
	show_navigation = not show_navigation
	_apply_navigation_display()


func _toggle_menu() -> void:
	if menu_overlay == null:
		return

	if menu_overlay.visible:
		_hide_menu()
	else:
		_show_menu()


func _show_menu() -> void:
	if menu_overlay == null:
		return
	if not game_started:
		return

	_show_inventory_menu_panel()
	menu_overlay.visible = true
	_set_game_paused(true)


func _hide_menu() -> void:
	if menu_overlay == null:
		return

	menu_overlay.visible = false
	_set_game_paused(false)


func _is_menu_open() -> bool:
	return menu_overlay != null and menu_overlay.visible


func _show_inventory_menu_panel() -> void:
	if inventory_screen != null:
		inventory_screen.visible = true

	if rule_book_screen != null:
		rule_book_screen.visible = false

	_sync_menu_tabs("inventory")


func _show_rule_book_menu_panel() -> void:
	if inventory_screen != null:
		inventory_screen.visible = false

	if rule_book_screen != null:
		rule_book_screen.visible = true
		rule_book_screen.refresh_text()

	_sync_menu_tabs("rule_book")


func _sync_menu_tabs(active_tab: String) -> void:
	if inventory_tab_button != null:
		var inventory_active := active_tab == "inventory"
		inventory_tab_button.button_pressed = inventory_active
		_style_menu_tab(inventory_tab_button, inventory_active)

	if rule_book_tab_button != null:
		var rule_book_active := active_tab == "rule_book"
		rule_book_tab_button.button_pressed = rule_book_active
		_style_menu_tab(rule_book_tab_button, rule_book_active)


func _style_menu_tab(button: Button, active: bool) -> void:
	var background := Color(0.09, 0.075, 0.045, 0.98) if active else Color(0.03, 0.035, 0.04, 0.76)
	var border := Color(1.0, 0.78, 0.32, 0.92) if active else Color(1.0, 1.0, 1.0, 0.12)
	button.custom_minimum_size = Vector2(138.0, 38.0)
	button.add_theme_stylebox_override("normal", _make_tab_style(background, border, active))
	button.add_theme_stylebox_override("hover", _make_tab_style(Color(0.15, 0.12, 0.065, 0.98), Color(1.0, 0.82, 0.28, 0.92), true))
	button.add_theme_stylebox_override("pressed", _make_tab_style(Color(0.09, 0.075, 0.045, 1.0), Color(1.0, 0.78, 0.32, 1.0), true))
	button.add_theme_color_override("font_color", Color(1.0, 0.88, 0.58) if active else Color(0.72, 0.72, 0.68))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.88, 0.58))


func _return_to_lobby() -> void:
	_save_current_day()
	if menu_overlay != null:
		menu_overlay.visible = false

	_show_lobby()


func _set_game_paused(paused: bool) -> void:
	if paused:
		playback_pause_manager.pause_tree(get_tree(), gameplay_layer)
	else:
		playback_pause_manager.resume_tree(get_tree())


func _quit_game() -> void:
	get_tree().quit()


func _on_brightness_changed(value: float) -> void:
	game_brightness = value
	_apply_brightness()


func _apply_brightness() -> void:
	if brightness_overlay == null:
		return

	var effective_brightness := game_brightness
	if effective_brightness < DEFAULT_BRIGHTNESS:
		var darkness := (DEFAULT_BRIGHTNESS - effective_brightness) / (DEFAULT_BRIGHTNESS - MIN_BRIGHTNESS)
		brightness_overlay.color = Color(0.0, 0.0, 0.0, darkness * 0.55)
	elif effective_brightness > DEFAULT_BRIGHTNESS:
		var lightness := (effective_brightness - DEFAULT_BRIGHTNESS) / (MAX_BRIGHTNESS - DEFAULT_BRIGHTNESS)
		brightness_overlay.color = Color(1.0, 1.0, 1.0, lightness * 0.28)
	else:
		brightness_overlay.color = Color(0.0, 0.0, 0.0, 0.0)

	_update_brightness_label()


func _update_brightness_label() -> void:
	if brightness_value_label == null:
		return

	brightness_value_label.text = "%d%%" % roundi(game_brightness * 100.0)


func _on_persistent_dialogue_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_hide_persistent_dialogue()


func _show_transient_dialogue(message: String) -> void:
	if transient_dialogue_panel == null:
		return

	if not show_persistent_dialogue:
		_hide_transient_dialogue()
		return

	transient_dialogue_label.text = message
	_position_transient_dialogue()
	transient_dialogue_panel.visible = true
	transient_dialogue_panel.modulate.a = 1.0

	if transient_dialogue_tween != null:
		transient_dialogue_tween.kill()

	transient_dialogue_tween = create_tween()
	transient_dialogue_tween.tween_interval(2.0)
	transient_dialogue_tween.tween_property(transient_dialogue_panel, "modulate:a", 0.0, 0.6)
	transient_dialogue_tween.finished.connect(_hide_transient_dialogue)


func _hide_transient_dialogue() -> void:
	if transient_dialogue_panel != null:
		transient_dialogue_panel.visible = false

	transient_dialogue_tween = null


func _position_transient_dialogue() -> void:
	if transient_dialogue_panel == null or transient_dialogue_label == null:
		return

	var viewport_size := get_viewport_rect().size
	var max_width := minf(720.0, viewport_size.x - 48.0)
	var estimated_width := clampf(transient_dialogue_label.text.length() * 10.0 + 48.0, 220.0, max_width)
	transient_dialogue_label.custom_minimum_size = Vector2(estimated_width, 0.0)
	transient_dialogue_panel.size = transient_dialogue_panel.get_combined_minimum_size()
	transient_dialogue_panel.position = Vector2((viewport_size.x - transient_dialogue_panel.size.x) * 0.5, viewport_size.y - 205.0)


func _scene_text(scene_id: String, scene_data: Dictionary, field: String) -> String:
	return localization.translate("scene.%s.%s" % [scene_id, field], scene_data.get(field, ""))


func _scene_photo(scene_id: String, scene_data: Dictionary) -> String:
	if scene_id == "laundry_room" and not laundry_second_washer_open:
		return localization.translate_scene_photo(scene_id, LAUNDRY_CLOSED_PHOTO, "closed")

	return localization.translate_scene_photo(scene_id, scene_data["photo"])


func _scene_hotspots(scene_id: String, scene_data: Dictionary) -> Array:
	var editor_hotspots := _editor_hotspots_for_scene(scene_id)
	if not editor_hotspots.is_empty():
		return editor_hotspots

	return scene_data["hotspots"]


func _editor_hotspots_for_scene(scene_id: String) -> Array:
	var definitions := get_node_or_null("HotspotDefinitions")
	if definitions == null:
		return []

	var scene_group := definitions.get_node_or_null(scene_id)
	if scene_group == null:
		return []

	var authoring_size := Vector2(1280.0, 720.0)
	if scene_group is Control and scene_group.size.x > 0.0 and scene_group.size.y > 0.0:
		authoring_size = scene_group.size

	var hotspots := []
	for child in scene_group.get_children():
		if child.has_method("to_hotspot_data"):
			hotspots.append(child.to_hotspot_data(authoring_size))

	return hotspots


func _hotspot_text(hotspot: Dictionary, field: String) -> String:
	var hotspot_id: String = hotspot.get("id", "unknown")
	return localization.translate("hotspot.%s.%s.%s" % [current_scene_id, hotspot_id, field], hotspot.get(field, ""))


func _hotspot_tooltip(hotspot: Dictionary, fallback: String) -> String:
	if hotspot.has("text"):
		return _hotspot_text(hotspot, "text")

	return fallback


func _exit_label(exit_data: Dictionary) -> String:
	return localization.translate("exit.%s.%s.label" % [current_scene_id, exit_data["target"]], exit_data["label"])


func _ui_text(key: String, fallback: String) -> String:
	return localization.translate("ui.%s" % key, fallback)


func _apply_hotspot_display() -> void:
	_sync_debug_toggles()

	for button in hotspot_buttons:
		var hotspot: Dictionary = button.get_meta("hotspot")
		var label := _hotspot_text(hotspot, "label")
		if show_hotspots:
			button.text = label
			button.tooltip_text = _hotspot_tooltip(hotspot, label)
			button.add_theme_stylebox_override("normal", _make_panel_style(IDLE_STYLE["bg"], IDLE_STYLE["border"], 5))
			button.add_theme_stylebox_override("hover", _make_panel_style(HOVER_STYLE["bg"], HOVER_STYLE["border"], 5))
			button.add_theme_stylebox_override("pressed", _make_panel_style(PRESS_STYLE["bg"], PRESS_STYLE["border"], 5))
			button.add_theme_color_override("font_color", Color(1.0, 0.96, 0.78))
			button.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.62))
		else:
			button.text = ""
			button.tooltip_text = ""
			button.add_theme_stylebox_override("normal", _make_panel_style(HIDDEN_STYLE["bg"], HIDDEN_STYLE["border"], 5))
			button.add_theme_stylebox_override("hover", _make_panel_style(HIDDEN_STYLE["bg"], HIDDEN_STYLE["border"], 5))
			button.add_theme_stylebox_override("pressed", _make_panel_style(HIDDEN_STYLE["bg"], HIDDEN_STYLE["border"], 5))
			button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.0))
			button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 0.0))


func _apply_persistent_dialogue_display() -> void:
	persistent_dialogue_panel.visible = show_persistent_dialogue
	if not show_persistent_dialogue:
		_hide_transient_dialogue()

	_position_bottom_panels()
	_sync_debug_toggles()


func _apply_navigation_display() -> void:
	navigation_panel.visible = show_navigation
	if debug_day_bar != null:
		debug_day_bar.visible = debug_ui_enabled and show_navigation
	_position_bottom_panels()
	_sync_debug_toggles()


func _sync_debug_toggles() -> void:
	if debug_panel != null:
		debug_panel.visible = debug_ui_enabled

	if hotspot_toggle == null:
		return

	hotspot_toggle.button_pressed = show_hotspots
	hotspot_toggle.tooltip_text = _ui_text("debug.hotspots.hide", "Hide click areas") if show_hotspots else _ui_text("debug.hotspots.show", "Show click areas")
	_style_debug_button(hotspot_toggle, show_hotspots)

	chat_toggle.button_pressed = show_persistent_dialogue
	chat_toggle.tooltip_text = _ui_text("debug.dialogue.hide", "Hide dialogue panel") if show_persistent_dialogue else _ui_text("debug.dialogue.show", "Show dialogue panel")
	_style_debug_button(chat_toggle, show_persistent_dialogue)

	navigation_toggle.button_pressed = show_navigation
	navigation_toggle.tooltip_text = _ui_text("debug.navigation.hide", "Hide quick travel buttons") if show_navigation else _ui_text("debug.navigation.show", "Show quick travel buttons")
	_style_debug_button(navigation_toggle, show_navigation)


func _position_bottom_panels() -> void:
	if persistent_dialogue_panel != null:
		persistent_dialogue_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		persistent_dialogue_panel.offset_left = 18.0
		persistent_dialogue_panel.offset_top = -150.0
		persistent_dialogue_panel.offset_right = -18.0
		persistent_dialogue_panel.offset_bottom = -18.0

	if navigation_panel != null:
		navigation_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		navigation_panel.offset_left = 18.0
		navigation_panel.offset_right = -18.0
		if show_persistent_dialogue:
			navigation_panel.offset_top = -258.0
			navigation_panel.offset_bottom = -162.0
		else:
			navigation_panel.offset_top = -114.0
			navigation_panel.offset_bottom = -18.0


func _set_persistent_dialogue(message: String) -> void:
	current_persistent_dialogue_text = message
	persistent_dialogue_label.text = current_persistent_dialogue_text
	_apply_persistent_dialogue_display()


func _hide_persistent_dialogue() -> void:
	show_persistent_dialogue = false
	_apply_persistent_dialogue_display()


func _update_layout() -> void:
	if photo == null:
		return

	var viewport_size := get_viewport_rect().size
	var offset := _get_parallax_offset(viewport_size)
	photo.position = Vector2(-PARALLAX_PADDING, -PARALLAX_PADDING) + offset
	photo.size = viewport_size + Vector2(PARALLAX_PADDING * 2.0, PARALLAX_PADDING * 2.0)
	_position_title_panel()
	_position_transient_dialogue()
	_update_hotspot_layout()
	_update_day_display()


func _update_hotspot_layout() -> void:
	if current_texture == null:
		return

	var image_rect := _get_photo_draw_rect()
	for button in hotspot_buttons:
		var hotspot: Dictionary = button.get_meta("hotspot")
		var normalized_rect: Rect2 = hotspot["rect"]
		button.position = image_rect.position + normalized_rect.position * image_rect.size
		button.size = normalized_rect.size * image_rect.size


func _get_photo_draw_rect() -> Rect2:
	var texture_size: Vector2 = current_texture.get_size()
	var scale: float = maxf(photo.size.x / texture_size.x, photo.size.y / texture_size.y)
	var draw_size: Vector2 = texture_size * scale
	var draw_position: Vector2 = photo.position + (photo.size - draw_size) * 0.5
	return Rect2(draw_position, draw_size)


func _get_parallax_offset(viewport_size: Vector2) -> Vector2:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return Vector2.ZERO

	var normalized_mouse := (mouse_position / viewport_size) - Vector2(0.5, 0.5)
	return -normalized_mouse * PARALLAX_STRENGTH


func _show_title_banner() -> void:
	_position_title_panel()

	if title_tween != null:
		title_tween.kill()

	title_panel.visible = true
	title_panel.modulate.a = 1.0
	title_tween = create_tween()
	title_tween.tween_interval(TITLE_VISIBLE_SECONDS)
	title_tween.tween_property(title_panel, "modulate:a", 0.0, TITLE_FADE_SECONDS)
	title_tween.finished.connect(_hide_title_banner)


func _hide_title_banner() -> void:
	title_panel.visible = false
	title_tween = null


func _position_title_panel() -> void:
	if title_panel == null:
		return

	title_panel.size = title_panel.get_combined_minimum_size()
	title_panel.position = Vector2(18.0, 18.0)
	if day_badge_panel != null:
		day_badge_panel.size = day_badge_panel.get_combined_minimum_size()
		day_badge_panel.position = Vector2(18.0, 64.0)


func _update_day_display() -> void:
	if day_badge_panel == null or day_badge_label == null:
		return

	day_badge_panel.visible = game_started
	day_badge_label.text = _day_name(current_day)
	day_badge_panel.size = day_badge_panel.get_combined_minimum_size()
	_refresh_debug_day_buttons()


func _refresh_debug_day_buttons() -> void:
	if debug_day_bar == null:
		return

	for child in debug_day_bar.get_children():
		if child is Button:
			var day := int(child.text)
			child.button_pressed = day == current_day
			_style_debug_button(child, day == current_day)


func _make_debug_button(icon: String, tooltip: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = icon
	button.tooltip_text = tooltip
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(40.0, 32.0)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(callback)
	return button


func _style_debug_button(button: Button, enabled: bool) -> void:
	var background := Color(0.25, 0.72, 1.0, 0.24) if enabled else Color(1.0, 1.0, 1.0, 0.05)
	var border := Color(0.45, 0.82, 1.0, 0.85) if enabled else Color(1.0, 1.0, 1.0, 0.18)
	button.add_theme_stylebox_override("normal", _make_panel_style(background, border, 6))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(1.0, 0.82, 0.28, 0.20), Color(1.0, 0.82, 0.28, 0.85), 6))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.25, 0.72, 1.0, 0.30), Color(0.45, 0.82, 1.0, 0.95), 6))
	button.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 0.72) if enabled else Color(0.95, 0.95, 0.95, 0.50))


func _make_panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style


func _make_tab_style(background: Color, border: Color, active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 9.0 if active else 7.0
	style.content_margin_bottom = 9.0 if active else 7.0
	return style
