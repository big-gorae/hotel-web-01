class_name HotelAnomalyContentCatalog
extends RefCounted

const TYPE_PHENOMENON := "phenomenon"
const TYPE_ENTITY := "entity"

const TREATMENT_HOLD := "hold"
const TREATMENT_ITEM_HOLD := "item_hold"
const TREATMENT_BELL_SEQUENCE := "bell_sequence"
const TREATMENT_SURFACE_SEQUENCE := "surface_sequence"
const TREATMENT_TV_HOLD := "tv_hold"
const TREATMENT_CURTAIN_CYCLE := "curtain_cycle"
const TREATMENT_MIRROR_TRANSFER := "mirror_transfer"
const TREATMENT_SHADOW_ESCAPE := "shadow_escape"
const TREATMENT_UNRESOLVED := "unresolved"

# Keep the unfinished Day 3 encounter out of Story and Infinity schedules while
# retaining an explicit debug preview for visual, hotspot, and fatal-flow QA.
# The separate Day 7 room_109_day7_passage event is not controlled by this flag.
const ROOM_109_INITIAL_ENCOUNTER_DEBUG_ENABLED := true

# The authored story route is intentionally edited here as a plain Day table.
# Events not listed here remain available in Infinity mode.
const STORY_EVENT_BY_DAY := {
	2: "corridor_red_room_light",
	3: "room_107_hanging_girl",
	4: "hotel_following_shadow",
	5: "room_108_entrails_bathtub",
	6: "room_106_horrific_mirror",
}


static func build_definitions() -> Dictionary:
	var definitions := {}
	for definition in [
		_phenomenon("front_monitor_ghost", 3, "front_desk", Rect2(0.775, 0.265, 0.220, 0.405), TREATMENT_HOLD, 2.2),
		_phenomenon("front_glass_face", 3, "front_desk", Rect2(0.485, 0.145, 0.095, 0.365), TREATMENT_BELL_SEQUENCE, 0.0),
		_phenomenon("front_die_sign", 3, "front_desk", Rect2(0.000, 0.520, 0.150, 0.190), TREATMENT_HOLD, 2.6),
		_phenomenon("corridor_red_room_light", 2, "corridor", Rect2(0.235, 0.145, 0.075, 0.150), TREATMENT_HOLD, 1.6),
		_item_phenomenon("corridor_blood_puddle", 2, "corridor", Rect2(0.315, 0.705, 0.155, 0.165), "cleaning_cloth", 2.8),
		_phenomenon("laundry_baby_face_surfaces", 3, "laundry_room", Rect2(0.0, 0.0, 1.0, 1.0), TREATMENT_SURFACE_SEQUENCE, 0.0),
		_phenomenon("room_107_human_skin_towel", 3, "room_107_bathroom", Rect2(0.790, 0.245, 0.135, 0.540), TREATMENT_HOLD, 3.0),
		_phenomenon("stairs_hell_arrow", 2, "exterior_stairs", Rect2(0.300, 0.430, 0.120, 0.250), TREATMENT_HOLD, 2.4),
		_phenomenon("room_105_grotesque_portrait", 3, "room_105_bathroom_entry", Rect2(0.000, 0.145, 0.185, 0.300), TREATMENT_HOLD, 2.5),
		_phenomenon("room_108_tv_ghost", 2, "room_105_bathroom_entry", Rect2(0.785, 0.470, 0.210, 0.285), TREATMENT_TV_HOLD, 3.2),
		_phenomenon("bathroom_shower_legs", 2, "room_105_bathroom", Rect2(0.405, 0.155, 0.345, 0.655), TREATMENT_CURTAIN_CYCLE, 0.0),
		_phenomenon("room_107_empty_hanging_rope", 3, "room_107_bed_nightstand", Rect2(0.355, 0.045, 0.215, 0.620), TREATMENT_HOLD, 3.4),
		_item_phenomenon("room_105_bloody_handprint_mirror", 3, "room_105_bathroom", Rect2(0.000, 0.000, 0.245, 0.500), "cleaning_cloth", 3.0),
		_item_phenomenon("room_106_horrific_mirror", 2, "room_106_bathroom", Rect2(0.000, 0.000, 0.245, 0.500), "small_mirror", 3.7, TREATMENT_MIRROR_TRANSFER),
		_phenomenon("room_108_entrails_bathtub", 3, "room_108_bathroom", Rect2(0.405, 0.455, 0.410, 0.390), TREATMENT_HOLD, 4.2),
	]:
		definitions[String(definition["id"])] = definition

	for definition in [
		_entity("room_109_open_door", 3, "corridor", 42.0),
		_entity("hotel_following_shadow", 3, "", 42.0, TREATMENT_SHADOW_ESCAPE),
		_entity("room_107_hanging_girl", 3, "room_107_bed_nightstand", 48.0),
	]:
		definitions[String(definition["id"])] = definition
	return definitions


static func production_event_ids() -> Array[String]:
	return [
		"corridor_red_room_light",
		"corridor_blood_puddle",
		"stairs_hell_arrow",
		"room_108_tv_ghost",
		"bathroom_shower_legs",
		"room_106_horrific_mirror",
		"front_monitor_ghost",
		"front_glass_face",
		"front_die_sign",
		"laundry_baby_face_surfaces",
		"room_107_human_skin_towel",
		"room_105_grotesque_portrait",
		"room_107_empty_hanging_rope",
		"room_105_bloody_handprint_mirror",
		"room_108_entrails_bathtub",
		"room_107_hanging_girl",
		"hotel_following_shadow",
	]


static func story_event_for_day(day: int) -> String:
	return String(STORY_EVENT_BY_DAY.get(maxi(day, 1), ""))


static func debug_event_ids() -> Array[String]:
	var ids := production_event_ids()
	if ROOM_109_INITIAL_ENCOUNTER_DEBUG_ENABLED:
		ids.append("room_109_open_door")
	return ids


static func is_event_enabled(event_id: String) -> bool:
	if event_id == "room_109_open_door":
		return ROOM_109_INITIAL_ENCOUNTER_DEBUG_ENABLED
	return true


static func surface_rects() -> Dictionary:
	return {
		"floor": Rect2(0.0, 0.67, 1.0, 0.33),
		"ceiling": Rect2(0.0, 0.0, 1.0, 0.17),
		"left": Rect2(0.0, 0.15, 0.25, 0.55),
		"front": Rect2(0.25, 0.15, 0.50, 0.55),
		"right": Rect2(0.75, 0.15, 0.25, 0.55),
	}


static func _phenomenon(event_id: String, min_day: int, scene_id: String, rect: Rect2, treatment: String, hold_seconds: float) -> Dictionary:
	return {
		"id": event_id,
		"type": TYPE_PHENOMENON,
		"min_day": min_day,
		"scene_id": scene_id,
		"rect": rect,
		"treatment": treatment,
		"hold_seconds": hold_seconds,
		"required_item_id": "",
		"fatal_seconds": 0.0,
	}


static func _item_phenomenon(event_id: String, min_day: int, scene_id: String, rect: Rect2, item_id: String, hold_seconds: float, treatment := TREATMENT_ITEM_HOLD) -> Dictionary:
	var definition := _phenomenon(event_id, min_day, scene_id, rect, treatment, hold_seconds)
	definition["required_item_id"] = item_id
	return definition


static func _entity(event_id: String, min_day: int, scene_id: String, fatal_seconds: float, treatment := TREATMENT_UNRESOLVED) -> Dictionary:
	return {
		"id": event_id,
		"type": TYPE_ENTITY,
		"min_day": min_day,
		"scene_id": scene_id,
		"rect": Rect2(),
		"treatment": treatment,
		"hold_seconds": 0.0,
		"required_item_id": "",
		"fatal_seconds": fatal_seconds,
	}
