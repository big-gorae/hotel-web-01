class_name HotelAnomalyContentCatalog
extends RefCounted

const AnomalyRegistry := preload("res://scripts/horror/anomaly_registry.gd")

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

static func build_definitions() -> Dictionary:
	var definitions := {}
	for event_id in AnomalyRegistry.content_event_ids(true):
		var metadata: Dictionary = AnomalyRegistry.get_definition(event_id)
		var schedule: Dictionary = metadata.get("schedule", {})
		var placement: Dictionary = metadata.get("placement", {})
		var lifecycle: Dictionary = metadata.get("lifecycle", {})
		var resolution: Dictionary = metadata.get("resolution", {})
		var presentation: Dictionary = metadata.get("presentation", {})
		definitions[event_id] = {
			"id": event_id,
			"type": String(metadata.get("kind", "")),
			"min_day": int(schedule.get("legacy_min_day", 1)),
			"scene_id": String(placement.get("default_scene_id", "")),
			"rect": presentation.get("hotspot_rect", Rect2()),
			"treatment": String(resolution.get(
				"content_runtime_treatment",
				resolution.get("treatment", TREATMENT_UNRESOLVED),
			)),
			"hold_seconds": float(resolution.get("hold_seconds", 0.0)),
			"required_item_id": String(resolution.get("required_item_id", "")),
			"fatal_seconds": float(lifecycle.get("fatal_seconds", 0.0)),
		}
	return definitions


static func production_event_ids() -> Array[String]:
	return AnomalyRegistry.production_event_ids()


static func story_event_for_day(day: int) -> String:
	return AnomalyRegistry.story_event_for_day(AnomalyRegistry.CHANNEL_PRODUCTION, day)


static func debug_event_ids() -> Array[String]:
	return AnomalyRegistry.content_event_ids(true)


static func is_event_enabled(event_id: String) -> bool:
	var definition := AnomalyRegistry.get_definition(event_id)
	if definition.is_empty():
		return false
	if bool(definition.get("schedule", {}).get("debug_only", false)):
		return ROOM_109_INITIAL_ENCOUNTER_DEBUG_ENABLED
	return String(definition.get("runtime_owner", "")) == AnomalyRegistry.OWNER_CONTENT_RUNTIME


static func surface_rects() -> Dictionary:
	return {
		"floor": Rect2(0.0, 0.67, 1.0, 0.33),
		"ceiling": Rect2(0.0, 0.0, 1.0, 0.17),
		"left": Rect2(0.0, 0.15, 0.25, 0.55),
		"front": Rect2(0.25, 0.15, 0.50, 0.55),
		"right": Rect2(0.75, 0.15, 0.25, 0.55),
	}
