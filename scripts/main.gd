extends Control

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
		"photo": "res://resource/front_desk.png",
		"intro": "The night clerk's counter is quiet. Notes, a phone, and the old monitor are ready for clues.",
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
				"id": "monitor",
				"label": "Monitor",
				"rect": Rect2(0.760, 0.300, 0.220, 0.390),
				"text": "The reservation screen is still open, but several entries are hard to read.",
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
		"photo": "res://resource/corridor.png",
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
			{
				"id": "parking_lot",
				"label": "Parking Lot",
				"rect": Rect2(0.830, 0.290, 0.165, 0.355),
				"text": "Wet pavement reflects the motel lights. A car engine ticks as it cools.",
			},
			],
		},
		"room_106_bed_bathroom_entry": {
			"title": "Room 106 - Bed And Bathroom Entry",
			"photo": "res://resource/room_106_bed_bathroom_entry.png",
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
					"text": "The curtains leave a narrow view of the parking lot lights.",
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
			"title": "Room 107 - Bed And Nightstand",
			"photo": "res://resource/room_107_bed_nightstand.png",
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
			"title": "Room 107 - Bathroom Entry",
			"photo": "res://resource/room_107_bathroom_entry.png",
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
			"title": "Room 108 - Bed And Window",
			"photo": "res://resource/room_108_bed_window.png",
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
			"title": "Room 108 - Bathroom Entry",
			"photo": "res://resource/room_108_bathroom_entry.png",
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
			"title": "Room 105 - Door And Window",
			"photo": "res://resource/room_105_door_window.png",
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
				"text": "The window faces the parking lot. The glass is cold to the touch.",
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
		"title": "Room 105 - Bathroom Entry",
		"photo": "res://resource/room_105_bathroom_entry.png",
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
			"title": "Room 105 - Bathroom",
			"photo": "res://resource/room_105_bathroom.png",
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
			"title": "Room 106 - Bathroom",
			"photo": "res://resource/room_106_bathroom.png",
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
			"title": "Room 107 - Bathroom",
			"photo": "res://resource/room_107_bathroom.png",
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
			"title": "Room 108 - Bathroom",
			"photo": "res://resource/room_108_bathroom.png",
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
			"photo": "res://resource/laundry_room.png",
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
					"id": "laundry_machines",
					"label": "Machines",
					"rect": Rect2(0.630, 0.410, 0.340, 0.370),
					"text": "The machines are silent, but one lid has been left open.",
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
			"photo": "res://resource/exterior_stairs.png",
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
				{
					"id": "parking_lot_light",
					"label": "Parking Lot",
					"rect": Rect2(0.000, 0.300, 0.250, 0.470),
					"text": "The parking lot is quiet except for the buzz of the lamp.",
				},
			],
		},
	}

var current_scene_id := START_SCENE_ID
var current_texture: Texture2D
var hotspot_buttons: Array[Button] = []
var debug_ui_enabled := false
var show_hotspots := false
var show_chat := false
var show_navigation := false
var game_brightness := DEFAULT_BRIGHTNESS
var mouse_position := Vector2.ZERO
var title_tween: Tween

var photo: TextureRect
var brightness_overlay: ColorRect
var hotspot_layer: Control
var title_panel: PanelContainer
var title_label: Label
var debug_panel: PanelContainer
var bottom_panel: PanelContainer
var message_label: Label
var navigation_panel: PanelContainer
var nav_bar: HBoxContainer
var hotspot_toggle: Button
var chat_toggle: Button
var navigation_toggle: Button
var menu_overlay: ColorRect
var brightness_slider: HSlider
var brightness_value_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	debug_ui_enabled = _is_debug_ui_enabled()
	get_tree().root.size_changed.connect(_update_layout)
	_build_ui()
	show_scene(START_SCENE_ID)


func _is_debug_ui_enabled() -> bool:
	var value := OS.get_environment(DEBUG_UI_ENV).strip_edges().to_lower()
	return DEBUG_UI_ENABLED_VALUES.has(value) or OS.has_feature("editor")


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_toggle_menu()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion:
		mouse_position = event.position
		_update_layout()


func show_scene(scene_id: String) -> void:
	if not HOTEL_SCENES.has(scene_id):
		push_warning("Unknown hotel scene: %s" % scene_id)
		return

	current_scene_id = scene_id
	var scene_data: Dictionary = HOTEL_SCENES[current_scene_id]
	current_texture = load(scene_data["photo"]) as Texture2D
	photo.texture = current_texture
	title_label.text = scene_data["title"]
	_show_title_banner()
	_set_message(scene_data["intro"])
	_build_hotspots(scene_data["hotspots"])
	_build_navigation(scene_data["exits"])
	_update_layout()


func _build_ui() -> void:
	photo = TextureRect.new()
	photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(photo)

	brightness_overlay = ColorRect.new()
	brightness_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	brightness_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(brightness_overlay)
	_apply_brightness()

	hotspot_layer = Control.new()
	hotspot_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hotspot_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(hotspot_layer)

	title_panel = PanelContainer.new()
	title_panel.position = Vector2(18.0, 18.0)
	title_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.78), Color(1.0, 1.0, 1.0, 0.10), 8))
	add_child(title_panel)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	title_panel.add_child(title_label)

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
	add_child(debug_panel)

	var corner_row := HBoxContainer.new()
	corner_row.add_theme_constant_override("separation", 8)
	debug_panel.add_child(corner_row)

	hotspot_toggle = _make_debug_button("▣", "Show click areas", _toggle_hotspots)
	corner_row.add_child(hotspot_toggle)

	chat_toggle = _make_debug_button("💬", "Hide chat panel", _toggle_chat)
	corner_row.add_child(chat_toggle)

	navigation_toggle = _make_debug_button("🧭", "Show quick travel buttons", _toggle_navigation)
	corner_row.add_child(navigation_toggle)

	bottom_panel = PanelContainer.new()
	bottom_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.82), Color(1.0, 1.0, 1.0, 0.10), 8))
	add_child(bottom_panel)

	var bottom_layout := VBoxContainer.new()
	bottom_layout.add_theme_constant_override("separation", 10)
	bottom_panel.add_child(bottom_layout)

	message_label = Label.new()
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	bottom_layout.add_child(message_label)

	navigation_panel = PanelContainer.new()
	navigation_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.82), Color(1.0, 1.0, 1.0, 0.10), 8))
	add_child(navigation_panel)

	nav_bar = HBoxContainer.new()
	nav_bar.add_theme_constant_override("separation", 8)
	navigation_panel.add_child(nav_bar)

	_position_bottom_panels()
	_apply_chat_display()
	_apply_navigation_display()
	_sync_debug_toggles()
	_build_menu()


func _build_menu() -> void:
	menu_overlay = ColorRect.new()
	menu_overlay.color = Color(0.0, 0.0, 0.0, 0.58)
	menu_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_overlay.visible = false
	menu_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_overlay.add_child(center)

	var menu_panel := PanelContainer.new()
	menu_panel.custom_minimum_size = Vector2(360.0, 0.0)
	menu_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.94), Color(1.0, 1.0, 1.0, 0.16), 12))
	center.add_child(menu_panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	menu_panel.add_child(layout)

	var title := Label.new()
	title.text = "Menu"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	layout.add_child(title)

	var continue_button := Button.new()
	continue_button.text = "Continue"
	continue_button.focus_mode = Control.FOCUS_NONE
	continue_button.pressed.connect(_hide_menu)
	layout.add_child(continue_button)

	var brightness_label := Label.new()
	brightness_label.text = "Brightness"
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
	quit_button.text = "Quit"
	quit_button.focus_mode = Control.FOCUS_NONE
	quit_button.pressed.connect(_quit_game)
	layout.add_child(quit_button)

	_update_brightness_label()


func _build_hotspots(hotspots: Array) -> void:
	for button in hotspot_buttons:
		button.queue_free()
	hotspot_buttons.clear()

	for hotspot in hotspots:
		var button := Button.new()
		button.text = hotspot["label"]
		button.tooltip_text = hotspot.get("text", hotspot["label"])
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
		button.text = exit_data["label"]
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(show_scene.bind(exit_data["target"]))
		nav_bar.add_child(button)

	_apply_navigation_display()


func _on_hotspot_pressed(hotspot: Dictionary) -> void:
	if hotspot.has("target"):
		show_scene(hotspot["target"])
		return

	_set_message(hotspot.get("text", hotspot["label"]))


func _toggle_hotspots() -> void:
	show_hotspots = not show_hotspots
	_apply_hotspot_display()


func _toggle_chat() -> void:
	show_chat = not show_chat
	_apply_chat_display()


func _toggle_navigation() -> void:
	show_navigation = not show_navigation
	_apply_navigation_display()


func _toggle_menu() -> void:
	if menu_overlay == null:
		return

	menu_overlay.visible = not menu_overlay.visible


func _hide_menu() -> void:
	if menu_overlay == null:
		return

	menu_overlay.visible = false


func _quit_game() -> void:
	get_tree().quit()


func _on_brightness_changed(value: float) -> void:
	game_brightness = value
	_apply_brightness()


func _apply_brightness() -> void:
	if brightness_overlay == null:
		return

	if game_brightness < DEFAULT_BRIGHTNESS:
		var darkness := (DEFAULT_BRIGHTNESS - game_brightness) / (DEFAULT_BRIGHTNESS - MIN_BRIGHTNESS)
		brightness_overlay.color = Color(0.0, 0.0, 0.0, darkness * 0.55)
	elif game_brightness > DEFAULT_BRIGHTNESS:
		var lightness := (game_brightness - DEFAULT_BRIGHTNESS) / (MAX_BRIGHTNESS - DEFAULT_BRIGHTNESS)
		brightness_overlay.color = Color(1.0, 1.0, 1.0, lightness * 0.28)
	else:
		brightness_overlay.color = Color(0.0, 0.0, 0.0, 0.0)

	_update_brightness_label()


func _update_brightness_label() -> void:
	if brightness_value_label == null:
		return

	brightness_value_label.text = "%d%%" % roundi(game_brightness * 100.0)


func _apply_hotspot_display() -> void:
	_sync_debug_toggles()

	for button in hotspot_buttons:
		var hotspot: Dictionary = button.get_meta("hotspot")
		if show_hotspots:
			button.text = hotspot["label"]
			button.tooltip_text = hotspot.get("text", hotspot["label"])
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


func _apply_chat_display() -> void:
	bottom_panel.visible = show_chat
	_position_bottom_panels()
	_sync_debug_toggles()


func _apply_navigation_display() -> void:
	navigation_panel.visible = show_navigation
	_position_bottom_panels()
	_sync_debug_toggles()


func _sync_debug_toggles() -> void:
	if debug_panel != null:
		debug_panel.visible = debug_ui_enabled

	if hotspot_toggle == null:
		return

	hotspot_toggle.button_pressed = show_hotspots
	hotspot_toggle.tooltip_text = "Hide click areas" if show_hotspots else "Show click areas"
	_style_debug_button(hotspot_toggle, show_hotspots)

	chat_toggle.button_pressed = show_chat
	chat_toggle.tooltip_text = "Hide chat panel" if show_chat else "Show chat panel"
	_style_debug_button(chat_toggle, show_chat)

	navigation_toggle.button_pressed = show_navigation
	navigation_toggle.tooltip_text = "Hide quick travel buttons" if show_navigation else "Show quick travel buttons"
	_style_debug_button(navigation_toggle, show_navigation)


func _position_bottom_panels() -> void:
	if bottom_panel != null:
		bottom_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		bottom_panel.offset_left = 18.0
		bottom_panel.offset_top = -150.0
		bottom_panel.offset_right = -18.0
		bottom_panel.offset_bottom = -18.0

	if navigation_panel != null:
		navigation_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		navigation_panel.offset_left = 18.0
		navigation_panel.offset_right = -18.0
		if show_chat:
			navigation_panel.offset_top = -210.0
			navigation_panel.offset_bottom = -162.0
		else:
			navigation_panel.offset_top = -66.0
			navigation_panel.offset_bottom = -18.0


func _set_message(message: String) -> void:
	message_label.text = message


func _update_layout() -> void:
	if photo == null:
		return

	var viewport_size := get_viewport_rect().size
	var offset := _get_parallax_offset(viewport_size)
	photo.position = Vector2(-PARALLAX_PADDING, -PARALLAX_PADDING) + offset
	photo.size = viewport_size + Vector2(PARALLAX_PADDING * 2.0, PARALLAX_PADDING * 2.0)
	_position_title_panel()
	_update_hotspot_layout()


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
