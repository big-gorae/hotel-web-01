class_name HotelAnomalyRegistry
extends RefCounted

## Canonical semantic metadata for every authored anomaly, entity, and derived
## anomaly hazard. Runtime state (selected scene, timers, active state) belongs
## to the owning system and must never be written back into this registry.

const SCHEMA_VERSION := 1

const KIND_ENTITY := "entity"
const KIND_PHENOMENON := "phenomenon"
const KIND_DERIVED_HAZARD := "derived_hazard"

const OWNER_CONTENT_RUNTIME := "content_runtime"
const OWNER_NIGHT_DIRECTOR := "night_director"
const OWNER_CLOSET_SYSTEM := "closet_system"
const OWNER_ITEM_HAZARD := "item_hazard"

const CHANNEL_PRODUCTION := "production"
const CHANNEL_PRIMARY_ENTITY := "primary_entity"
const CHANNEL_DERIVED := "derived"

const SELECTION_FIXED := "fixed"
const SELECTION_RANDOM_ONCE_AT_ARM := "random_once_at_arm"
const SELECTION_GLOBAL := "global"
const SELECTION_DERIVED := "derived"

const VISIBILITY_OFFSCREEN_ONLY := "offscreen_only"
const VISIBILITY_GLOBAL_INVISIBLE := "global_invisible"
const VISIBILITY_AUTHORED_ON_ENTRY := "authored_on_entry"
const VISIBILITY_DERIVED := "derived"

const ACTIVATION_SLOT_PRIMARY := "anomaly_primary"
const SELECTED_SCENE_TOKEN := "$selected"
const HANGING_GIRL_DOLL_ITEM_ID := "cute_doll"
const SMALL_MIRROR_ITEM_ID := "small_mirror"
const HELL_MIRROR_ITEM_ID := "hell_mirror"
const RESOLUTION_ITEM_REFERENCE_KEYS: Array[String] = [
	"required_item_id",
	"replacement_item_id",
	"pickup_item_id",
	"consumed_item_id",
]

# These arrays preserve the authored seeded-random order while keeping schedule
# ownership in this single registry.
const PRODUCTION_INFINITY_ORDER: Array[String] = [
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
const PRIMARY_INFINITY_ORDER: Array[String] = [
	"room_105_closet_pig_man",
	"room_108_light_repair_call",
	"laundry_red_washer",
	"room_106_abandoned_child",
	"vacant_room_blanket_child",
]
const ENTITY_PRESENTATION := {
	"room_105_closet_pig_man": {"room_id": "room_105", "scene_ids": ["room_105_door_window", "room_105_bathroom_entry"]},
	"room_106_abandoned_child": {"room_id": "room_106", "scene_ids": ["room_106_bathroom"]},
	"room_108_light_repair_call": {"room_id": "room_108", "scene_ids": ["front_desk", "room_108_bed_window"]},
	"room_109_open_door": {"room_id": "room_109", "scene_ids": ["corridor"]},
	"laundry_red_washer": {"room_id": "laundry_room", "scene_ids": ["laundry_room"]},
	"vacant_room_blanket_child": {
		"room_id": "hotel",
		"scene_ids": ["room_105_door_window", "room_106_bed_bathroom_entry", "room_107_bed_nightstand", "room_108_bed_window"],
	},
	"room_109_day7_passage": {"room_id": "corridor", "scene_ids": ["corridor"]},
	"hotel_following_shadow": {"room_id": "hotel", "scene_ids": []},
	"room_107_hanging_girl": {"room_id": "room_107", "scene_ids": ["room_107_bed_nightstand"]},
	"hell_mirror": {"room_id": "hotel", "scene_ids": []},
}

const DIRECT_KINDS: Array[String] = [KIND_ENTITY, KIND_PHENOMENON]
const VALID_OWNERS: Array[String] = [
	OWNER_CONTENT_RUNTIME,
	OWNER_NIGHT_DIRECTOR,
	OWNER_CLOSET_SYSTEM,
	OWNER_ITEM_HAZARD,
]
const VALID_CHANNELS: Array[String] = [
	CHANNEL_PRODUCTION,
	CHANNEL_PRIMARY_ENTITY,
	CHANNEL_DERIVED,
]
const VALID_SELECTION_POLICIES: Array[String] = [
	SELECTION_FIXED,
	SELECTION_RANDOM_ONCE_AT_ARM,
	SELECTION_GLOBAL,
	SELECTION_DERIVED,
]
const VALID_VISIBILITY_POLICIES: Array[String] = [
	VISIBILITY_OFFSCREEN_ONLY,
	VISIBILITY_GLOBAL_INVISIBLE,
	VISIBILITY_AUTHORED_ON_ENTRY,
	VISIBILITY_DERIVED,
]

static var _definition_cache: Dictionary = {}


static func build_definitions() -> Dictionary:
	return _definitions().duplicate(true)


static func _definitions() -> Dictionary:
	if not _definition_cache.is_empty():
		return _definition_cache
	var definitions := {}
	for definition in [
		# Production phenomena.
		_content_event("front_monitor_ghost", KIND_PHENOMENON, 3, [], ["front_desk"], "hold", 2.2, Rect2(0.775, 0.265, 0.220, 0.405)),
		_content_event("front_glass_face", KIND_PHENOMENON, 3, [], ["front_desk"], "bell_sequence", 0.0, Rect2(0.485, 0.145, 0.095, 0.365)),
		_content_event("front_die_sign", KIND_PHENOMENON, 3, [], ["front_desk"], "hold", 2.6, Rect2(0.000, 0.520, 0.150, 0.190)),
		_content_event("corridor_red_room_light", KIND_PHENOMENON, 2, [2], ["corridor"], "hold", 1.6, Rect2(0.235, 0.145, 0.075, 0.150)),
		_content_event("corridor_blood_puddle", KIND_PHENOMENON, 2, [], ["corridor"], "item_hold", 2.8, Rect2(0.315, 0.705, 0.155, 0.165), "cleaning_cloth"),
		_content_event("laundry_baby_face_surfaces", KIND_PHENOMENON, 3, [], ["laundry_room"], "surface_sequence", 0.0, Rect2(0.0, 0.0, 1.0, 1.0)),
		_content_event("room_107_human_skin_towel", KIND_PHENOMENON, 3, [], ["room_107_bathroom"], "hold", 3.0, Rect2(0.790, 0.245, 0.135, 0.540)),
		_content_event("stairs_hell_arrow", KIND_PHENOMENON, 2, [], ["exterior_stairs"], "hold", 2.4, Rect2(0.300, 0.430, 0.120, 0.250)),
		_content_event("room_105_grotesque_portrait", KIND_PHENOMENON, 3, [], ["room_105_bathroom_entry"], "hold", 2.5, Rect2(0.000, 0.145, 0.185, 0.300)),
		_content_event(
			"room_108_tv_ghost",
			KIND_PHENOMENON,
			2,
			[],
			["room_105_bathroom_entry"],
			"tv_hold",
			3.2,
			Rect2(0.785, 0.470, 0.210, 0.285),
			"",
			0.0,
			{
				"id_location_mismatch_allowed": true,
				"mismatch_reason": "Legacy save-compatible event id after the TV moved to Room 105.",
			},
		),
		_content_event(
			"bathroom_shower_legs",
			KIND_PHENOMENON,
			2,
			[],
			[
				"room_105_bathroom",
				"room_106_bathroom",
				"room_107_bathroom",
				"room_108_bathroom",
			],
			"curtain_cycle",
			0.0,
			Rect2(0.405, 0.155, 0.345, 0.655),
			"",
			0.0,
			{},
			SELECTION_RANDOM_ONCE_AT_ARM,
		),
		_content_event("room_107_empty_hanging_rope", KIND_PHENOMENON, 3, [], ["room_107_bed_nightstand"], "hold", 3.4, Rect2(0.355, 0.045, 0.215, 0.620)),
		_content_event("room_105_bloody_handprint_mirror", KIND_PHENOMENON, 3, [], ["room_105_bathroom"], "item_hold", 3.0, Rect2(0.000, 0.000, 0.245, 0.500), "cleaning_cloth"),
		_with_resolution(
			_content_event("room_106_horrific_mirror", KIND_PHENOMENON, 2, [6], ["room_106_bathroom"], "mirror_transfer", 3.7, Rect2(0.000, 0.000, 0.245, 0.500), SMALL_MIRROR_ITEM_ID),
			{"replacement_item_id": HELL_MIRROR_ITEM_ID},
		),
		_content_event("room_108_entrails_bathtub", KIND_PHENOMENON, 3, [5], ["room_108_bathroom"], "hold", 4.2, Rect2(0.405, 0.455, 0.410, 0.390)),

		# Production entities.
		_content_event(
			"room_109_open_door",
			KIND_ENTITY,
			3,
			[],
			["corridor"],
			"unresolved",
			0.0,
			Rect2(),
			"",
			42.0,
			{"preview_enabled": true},
			SELECTION_FIXED,
			false,
			true,
		),
		_content_event(
			"hotel_following_shadow",
			KIND_ENTITY,
			3,
			[4],
			[],
			"shadow_escape",
			0.0,
			Rect2(),
			"",
			42.0,
			{
				"visibility_exception_reason": "The attached shadow is intentionally invisible until its fatal state.",
			},
			SELECTION_GLOBAL,
			true,
			false,
			VISIBILITY_GLOBAL_INVISIBLE,
			["hotel:global", "audio:footsteps", "prop:front_bell"],
		),
		_with_resolution(
			_content_event(
				"room_107_hanging_girl",
				KIND_ENTITY,
				3,
				[3],
				["room_107_bed_nightstand"],
				"hanging_girl_choice",
				0.0,
				Rect2(),
				HANGING_GIRL_DOLL_ITEM_ID,
				48.0,
				{},
				SELECTION_FIXED,
				true,
				false,
				VISIBILITY_OFFSCREEN_ONLY,
				["scene:room_107_bed_nightstand", "prop:laundry_table"],
				["room_107_bed_nightstand", "laundry_room"],
				["room_107_bed_nightstand", "laundry_room"],
				"unresolved",
			),
			{
				"pickup_item_id": HANGING_GIRL_DOLL_ITEM_ID,
				"consumed_item_id": HANGING_GIRL_DOLL_ITEM_ID,
			},
		),

		# Primary night entities.
		_primary_event(
			"room_105_closet_pig_man",
			OWNER_CLOSET_SYSTEM,
			[2],
			true,
			["room_105_bathroom_entry"],
			"wardrobe_hold",
			{
				"initial_wait_min_seconds": 90.0,
				"initial_wait_max_seconds": 180.0,
				"door_open_seconds": 30.0,
				"emerging_seconds": 40.0,
				"hold_seconds": 5.0,
				"squeal_interval_seconds": 30.0,
				"squeal_jitter_seconds": 10.0,
			},
		),
		_primary_event(
			"room_106_abandoned_child",
			OWNER_NIGHT_DIRECTOR,
			[6],
			true,
			["room_106_bathroom"],
			"eye_close_song",
			{"appearance_delay_seconds": 7.0, "response_seconds": 6.0, "song_seconds": 6.5},
		),
		_primary_event(
			"room_108_light_repair_call",
			OWNER_NIGHT_DIRECTOR,
			[4],
			true,
			["front_desk"],
			"answer_then_avoid_room",
			{
				"maximum_bells": 13,
				"initial_delay_seconds": 24.0,
				"repeat_delay_seconds": 58.0,
				"bell_interval_seconds": 1.15,
				"death_delay_seconds": 2.4,
				"forbidden_seconds": 18.0,
				"affected_scene_prefixes": ["room_108"],
			},
			["prop:front_phone", "room:room_108"],
			["front_desk"],
			["front_desk"],
		),
		_primary_event(
			"laundry_red_washer",
			OWNER_NIGHT_DIRECTOR,
			[5],
			true,
			["laundry_room"],
			"washer_hold_then_eye_close",
			{
				"hold_seconds": 1.5,
				"music_seconds": 7.0,
				"eye_close_grace_seconds": 1.5,
				"neglect_seconds": 30.0,
			},
			["scene:laundry_room", "prop:laundry_washer_1", "audio:laundry"],
		),
		_primary_event(
			"vacant_room_blanket_child",
			OWNER_NIGHT_DIRECTOR,
			[],
			true,
			[
				"room_105_door_window",
				"room_106_bed_bathroom_entry",
				"room_107_bed_nightstand",
				"room_108_bed_window",
			],
			"eye_close_wait",
			{
				"response_seconds": 18.0,
				"eye_close_seconds": 6.0,
				"death_delay_seconds": 1.4,
				"default_scene_id": "room_108_bed_window",
			},
			["scene:$selected"],
			[SELECTED_SCENE_TOKEN],
			[SELECTED_SCENE_TOKEN],
			SELECTION_FIXED,
			"room_108_bed_window",
			["vacant_room_child_under_blanket"],
		),
		_primary_event(
			"room_109_day7_passage",
			OWNER_NIGHT_DIRECTOR,
			[7],
			false,
			["corridor"],
			"do_not_turn",
			{"wait_seconds": 3.0, "footstep_seconds": 6.0},
			["scene:corridor", "audio:corridor_footsteps"],
			["corridor"],
			[],
			SELECTION_FIXED,
			"corridor",
			[],
			VISIBILITY_AUTHORED_ON_ENTRY,
			"The player's corridor entry is the authored trigger; no object materializes in view.",
		),

		# Derived hazard produced by the horrific mirror resolution.
		_derived_hazard(),
	]:
		definitions[String(definition["id"])] = definition
	for event_id in definitions:
		var presentation: Dictionary = definitions[event_id]["presentation"]
		if ENTITY_PRESENTATION.has(event_id):
			var override: Dictionary = ENTITY_PRESENTATION[event_id]
			presentation["room_id"] = String(override.get("room_id", "hotel"))
			presentation["game_over_scene_ids"] = _string_array(override.get("scene_ids", []))
		else:
			var default_scene_id := String(definitions[event_id]["placement"].get("default_scene_id", ""))
			presentation["room_id"] = _room_id_from_scene(default_scene_id)
			presentation["game_over_scene_ids"] = [default_scene_id] if not default_scene_id.is_empty() else []
	_definition_cache = definitions
	return _definition_cache


static func all_event_ids() -> Array[String]:
	var ids := _string_array(_definitions().keys())
	ids.sort()
	return ids


static func direct_event_ids() -> Array[String]:
	var ids: Array[String] = []
	for event_id in all_event_ids():
		if String(get_definition(event_id).get("kind", "")) in DIRECT_KINDS:
			ids.append(event_id)
	return ids


static func content_event_ids(include_debug_only := true) -> Array[String]:
	var ids := production_event_ids()
	if not include_debug_only:
		return ids
	for event_id in _definitions():
		var definition: Dictionary = _definitions()[event_id]
		if (
			String(definition.get("runtime_owner", "")) == OWNER_CONTENT_RUNTIME
			and bool(definition.get("schedule", {}).get("debug_only", false))
			and not ids.has(event_id)
		):
			ids.append(event_id)
	return ids


static func production_event_ids() -> Array[String]:
	var ids: Array[String] = []
	for event_id in PRODUCTION_INFINITY_ORDER:
		var schedule: Dictionary = get_definition(event_id).get("schedule", {})
		if String(schedule.get("channel", "")) == CHANNEL_PRODUCTION and bool(schedule.get("infinity_enabled", false)):
			ids.append(event_id)
	return ids


static func primary_infinity_event_ids() -> Array[String]:
	var ids: Array[String] = []
	for event_id in PRIMARY_INFINITY_ORDER:
		var schedule: Dictionary = get_definition(event_id).get("schedule", {})
		if String(schedule.get("channel", "")) == CHANNEL_PRIMARY_ENTITY and bool(schedule.get("infinity_enabled", false)):
			ids.append(event_id)
	return ids


static func story_event_for_day(channel: String, day: int) -> String:
	var safe_day := maxi(day, 1)
	for event_id in all_event_ids():
		var schedule: Dictionary = get_definition(event_id).get("schedule", {})
		if String(schedule.get("channel", "")) != channel:
			continue
		if safe_day in schedule.get("story_days", []):
			return event_id
	return ""


static func get_definition(event_id: String) -> Dictionary:
	return _definitions().get(event_id, {}).duplicate(true)


static func get_candidate_scene_ids(event_id: String) -> Array[String]:
	return _string_array(_definitions().get(event_id, {}).get("placement", {}).get("candidate_scene_ids", []))


static func get_default_scene_id(event_id: String) -> String:
	return String(_definitions().get(event_id, {}).get("placement", {}).get("default_scene_id", ""))


static func get_selection_policy(event_id: String) -> String:
	return String(_definitions().get(event_id, {}).get("placement", {}).get("selection_policy", ""))


static func get_visibility_policy(event_id: String) -> String:
	return String(_definitions().get(event_id, {}).get("activation", {}).get("visibility_policy", ""))


static func materialization_scene_ids(event_id: String, selected_scene_id := "") -> Array[String]:
	var placement: Dictionary = _definitions().get(event_id, {}).get("placement", {})
	return _resolve_scene_tokens(
		placement.get("materialization_scene_ids", []),
		_selected_scene_or_default(event_id, selected_scene_id),
	)


static func observation_guard_scene_ids(event_id: String, selected_scene_id := "") -> Array[String]:
	var placement: Dictionary = _definitions().get(event_id, {}).get("placement", {})
	return _resolve_scene_tokens(
		placement.get("observation_guard_scene_ids", []),
		_selected_scene_or_default(event_id, selected_scene_id),
	)


static func conflict_tags(event_id: String, selected_scene_id := "") -> Array[String]:
	var definition: Dictionary = _definitions().get(event_id, {})
	var tags := _string_array(definition.get("activation", {}).get("exclusive_slots", []))
	var selected := _selected_scene_or_default(event_id, selected_scene_id)
	for scene_id in observation_guard_scene_ids(event_id, selected):
		var scene_tag := "scene:%s" % scene_id
		if not tags.has(scene_tag):
			tags.append(scene_tag)
	for raw_scope in definition.get("occupancy", {}).get("scope_ids", []):
		var scope := String(raw_scope).replace(SELECTED_SCENE_TOKEN, selected)
		if not scope.is_empty() and not tags.has(scope):
			tags.append(scope)
	return tags


static func validate_all(known_scene_ids: Array = [], known_item_ids: Array = []) -> Array[String]:
	var errors: Array[String] = []
	var definitions := _definitions()
	if definitions.size() != 25:
		errors.append("registry must contain exactly 25 authored definitions")
	var alias_owners := {}
	var story_owners := {}
	for event_id in definitions:
		var canonical_id := String(event_id)
		var definition: Dictionary = definitions[event_id]
		_validate_definition(canonical_id, definition, known_scene_ids, errors)
		for raw_alias in definition.get("aliases", []):
			var alias := String(raw_alias)
			if alias.is_empty():
				errors.append("%s: alias must not be empty" % canonical_id)
			elif definitions.has(alias):
				errors.append("%s: alias %s collides with a canonical id" % [canonical_id, alias])
			elif alias_owners.has(alias):
				errors.append("%s: alias %s is already owned by %s" % [canonical_id, alias, alias_owners[alias]])
			else:
				alias_owners[alias] = canonical_id
		var schedule: Dictionary = definition.get("schedule", {})
		var channel := String(schedule.get("channel", ""))
		for raw_day in schedule.get("story_days", []):
			var day := int(raw_day)
			if day < 1:
				errors.append("%s: story day must be positive" % canonical_id)
				continue
			var story_key := "%s:%d" % [channel, day]
			if story_owners.has(story_key):
				errors.append("%s: story slot %s is already owned by %s" % [canonical_id, story_key, story_owners[story_key]])
			else:
				story_owners[story_key] = canonical_id
		var resolution: Dictionary = definition.get("resolution", {})
		for item_key in RESOLUTION_ITEM_REFERENCE_KEYS:
			var item_id := String(resolution.get(item_key, ""))
			if not item_id.is_empty() and not known_item_ids.is_empty() and not known_item_ids.has(item_id):
				errors.append("%s: %s references unknown item %s" % [canonical_id, item_key, item_id])
		var source_event_id := String(resolution.get("source_event_id", ""))
		if not source_event_id.is_empty() and not definitions.has(source_event_id):
			errors.append("%s: source event %s is not registered" % [canonical_id, source_event_id])
	_validate_infinity_order(PRODUCTION_INFINITY_ORDER, CHANNEL_PRODUCTION, definitions, errors)
	_validate_infinity_order(PRIMARY_INFINITY_ORDER, CHANNEL_PRIMARY_ENTITY, definitions, errors)
	return errors


static func _validate_definition(event_id: String, definition: Dictionary, known_scene_ids: Array, errors: Array[String]) -> void:
	if String(definition.get("id", "")) != event_id:
		errors.append("%s: dictionary key and id differ" % event_id)
	if int(definition.get("schema_version", 0)) != SCHEMA_VERSION:
		errors.append("%s: unsupported schema version" % event_id)
	var kind := String(definition.get("kind", ""))
	if kind not in [KIND_ENTITY, KIND_PHENOMENON, KIND_DERIVED_HAZARD]:
		errors.append("%s: invalid kind" % event_id)
	if String(definition.get("runtime_owner", "")) not in VALID_OWNERS:
		errors.append("%s: invalid runtime owner" % event_id)

	var schedule: Dictionary = definition.get("schedule", {})
	if String(schedule.get("channel", "")) not in VALID_CHANNELS:
		errors.append("%s: invalid schedule channel" % event_id)

	var placement: Dictionary = definition.get("placement", {})
	var selection_policy := String(placement.get("selection_policy", ""))
	if selection_policy not in VALID_SELECTION_POLICIES:
		errors.append("%s: invalid placement selection policy" % event_id)
	var candidates := _string_array(placement.get("candidate_scene_ids", []))
	var default_scene := String(placement.get("default_scene_id", ""))
	if selection_policy in [SELECTION_FIXED, SELECTION_RANDOM_ONCE_AT_ARM]:
		if candidates.is_empty():
			errors.append("%s: selectable anomaly has no candidate scenes" % event_id)
		elif not candidates.has(default_scene):
			errors.append("%s: default scene is not a candidate" % event_id)
	if selection_policy == SELECTION_RANDOM_ONCE_AT_ARM and candidates.size() < 2:
		errors.append("%s: random placement needs at least two candidate scenes" % event_id)
	if selection_policy in [SELECTION_GLOBAL, SELECTION_DERIVED] and (not candidates.is_empty() or not default_scene.is_empty()):
		errors.append("%s: global or derived placement must not declare a concrete scene" % event_id)
	for scene_id in candidates:
		if not known_scene_ids.is_empty() and not known_scene_ids.has(scene_id):
			errors.append("%s: unknown candidate scene %s" % [event_id, scene_id])

	var activation: Dictionary = definition.get("activation", {})
	var visibility_policy := String(activation.get("visibility_policy", ""))
	if visibility_policy not in VALID_VISIBILITY_POLICIES:
		errors.append("%s: invalid visibility policy" % event_id)
	var slots := _string_array(activation.get("exclusive_slots", []))
	if kind in DIRECT_KINDS and not slots.has(ACTIVATION_SLOT_PRIMARY):
		errors.append("%s: direct anomaly is missing the primary activation slot" % event_id)

	var selections := candidates.duplicate()
	if selections.is_empty():
		selections.append(default_scene)
	for selected_scene in selections:
		var materialization := materialization_scene_ids(event_id, selected_scene)
		var guards := observation_guard_scene_ids(event_id, selected_scene)
		for scene_id in materialization:
			if not known_scene_ids.is_empty() and not known_scene_ids.has(scene_id):
				errors.append("%s: unknown materialization scene %s" % [event_id, scene_id])
		for scene_id in guards:
			if not known_scene_ids.is_empty() and not known_scene_ids.has(scene_id):
				errors.append("%s: unknown observation guard scene %s" % [event_id, scene_id])
		if visibility_policy == VISIBILITY_OFFSCREEN_ONLY:
			if materialization.is_empty():
				errors.append("%s: visible offscreen anomaly has no materialization scenes" % event_id)
			for scene_id in materialization:
				if not guards.has(scene_id):
					errors.append("%s: materialization scene %s is not observation-guarded" % [event_id, scene_id])
	if visibility_policy in [VISIBILITY_GLOBAL_INVISIBLE, VISIBILITY_AUTHORED_ON_ENTRY]:
		if String(definition.get("debug", {}).get("visibility_exception_reason", "")).is_empty():
			errors.append("%s: visibility exception has no reason" % event_id)

	for required_section in ["occupancy", "lifecycle", "resolution", "persistence", "presentation", "debug"]:
		if not definition.has(required_section) or not definition[required_section] is Dictionary:
			errors.append("%s: missing %s metadata" % [event_id, required_section])
	var collection_kind := String(definition.get("presentation", {}).get("collection_kind", ""))
	if collection_kind not in [KIND_ENTITY, KIND_PHENOMENON]:
		errors.append("%s: invalid collection kind" % event_id)


static func _validate_infinity_order(
	ordered_event_ids: Array[String],
	channel: String,
	definitions: Dictionary,
	errors: Array[String],
) -> void:
	var seen := {}
	for event_id in ordered_event_ids:
		if seen.has(event_id):
			errors.append("%s infinity order contains duplicate %s" % [channel, event_id])
			continue
		seen[event_id] = true
		if not definitions.has(event_id):
			errors.append("%s infinity order references unknown event %s" % [channel, event_id])
			continue
		var schedule: Dictionary = definitions[event_id].get("schedule", {})
		if String(schedule.get("channel", "")) != channel or not bool(schedule.get("infinity_enabled", false)):
			errors.append("%s: event is in the wrong infinity order" % event_id)
	for event_id in definitions:
		var schedule: Dictionary = definitions[event_id].get("schedule", {})
		if String(schedule.get("channel", "")) != channel or not bool(schedule.get("infinity_enabled", false)):
			continue
		if not seen.has(event_id):
			errors.append("%s: infinity-enabled event is missing from its ordered pool" % event_id)


static func _content_event(
	event_id: String,
	kind: String,
	legacy_min_day: int,
	story_days: Array,
	candidate_scene_ids: Array,
	treatment: String,
	hold_seconds: float,
	hotspot_rect: Rect2,
	required_item_id := "",
	fatal_seconds := 0.0,
	debug: Dictionary = {},
	selection_policy := SELECTION_FIXED,
	infinity_enabled := true,
	debug_only := false,
	visibility_policy := VISIBILITY_OFFSCREEN_ONLY,
	custom_scopes: Array = [],
	materialization_scene_ids: Array = [],
	observation_guard_scene_ids: Array = [],
	content_runtime_treatment := "",
) -> Dictionary:
	var selected_scenes := _string_array(candidate_scene_ids)
	var default_scene_id := selected_scenes[0] if not selected_scenes.is_empty() else ""
	var materialization := _string_array(materialization_scene_ids)
	if materialization.is_empty() and not default_scene_id.is_empty():
		materialization = [SELECTED_SCENE_TOKEN]
	var guards := _string_array(observation_guard_scene_ids)
	if guards.is_empty() and visibility_policy == VISIBILITY_OFFSCREEN_ONLY:
		guards = materialization.duplicate()
	var scopes := _string_array(custom_scopes)
	if scopes.is_empty() and not default_scene_id.is_empty():
		scopes = ["scene:%s" % SELECTED_SCENE_TOKEN]
	return _definition(
		event_id,
		kind,
		OWNER_CONTENT_RUNTIME,
		CHANNEL_PRODUCTION,
		story_days,
		infinity_enabled,
		selected_scenes,
		selection_policy,
		default_scene_id,
		materialization,
		guards,
		visibility_policy,
		scopes,
		{
			"state_machine_id": treatment,
			"fatal_policy": "global_timeout" if fatal_seconds > 0.0 else "none",
			"fatal_seconds": fatal_seconds,
		},
		{
			"treatment": treatment,
			"content_runtime_treatment": content_runtime_treatment if not content_runtime_treatment.is_empty() else treatment,
			"hold_seconds": hold_seconds,
			"required_item_id": required_item_id,
		},
		debug,
		{
			"legacy_min_day": legacy_min_day,
			"hotspot_rect": hotspot_rect,
			"debug_only": debug_only,
		},
	)


static func _primary_event(
	event_id: String,
	owner: String,
	story_days: Array,
	infinity_enabled: bool,
	candidate_scene_ids: Array,
	treatment: String,
	tuning: Dictionary,
	custom_scopes: Array = [],
	materialization_scene_ids: Array = [],
	observation_guard_scene_ids: Array = [],
	selection_policy := SELECTION_FIXED,
	default_scene_id := "",
	aliases: Array = [],
	visibility_policy := VISIBILITY_OFFSCREEN_ONLY,
	visibility_exception_reason := "",
) -> Dictionary:
	var candidates := _string_array(candidate_scene_ids)
	var selected_default := default_scene_id
	if selected_default.is_empty() and not candidates.is_empty():
		selected_default = candidates[0]
	var materialization := _string_array(materialization_scene_ids)
	if materialization.is_empty() and not selected_default.is_empty():
		materialization = [SELECTED_SCENE_TOKEN]
	var guards := _string_array(observation_guard_scene_ids)
	if guards.is_empty() and visibility_policy == VISIBILITY_OFFSCREEN_ONLY:
		guards = materialization.duplicate()
	var scopes := _string_array(custom_scopes)
	if scopes.is_empty() and not selected_default.is_empty():
		scopes = ["scene:%s" % SELECTED_SCENE_TOKEN]
	return _definition(
		event_id,
		KIND_ENTITY,
		owner,
		CHANNEL_PRIMARY_ENTITY,
		story_days,
		infinity_enabled,
		candidates,
		selection_policy,
		selected_default,
		materialization,
		guards,
		visibility_policy,
		scopes,
		{
			"state_machine_id": treatment,
			"fatal_policy": "owner_defined",
			"fatal_seconds": float(tuning.get("response_seconds", tuning.get("neglect_seconds", 0.0))),
		},
		{"treatment": treatment, "tuning": tuning.duplicate(true)},
		{"visibility_exception_reason": visibility_exception_reason},
		{"aliases": aliases.duplicate()},
	)


static func _derived_hazard() -> Dictionary:
	return _definition(
		HELL_MIRROR_ITEM_ID,
		KIND_DERIVED_HAZARD,
		OWNER_ITEM_HAZARD,
		CHANNEL_DERIVED,
		[],
		false,
		[],
		SELECTION_DERIVED,
		"",
		[],
		[],
		VISIBILITY_DERIVED,
		["inventory:hand", "prop:laundry_washer_2"],
		{"state_machine_id": "equipped_item_hazard", "fatal_policy": "equipped_timeout", "fatal_seconds": 12.0},
		{
			"treatment": "destroy_in_idle_laundry_washer",
			"source_event_id": "room_106_horrific_mirror",
			"required_item_id": HELL_MIRROR_ITEM_ID,
		},
		{},
	)


static func _definition(
	event_id: String,
	kind: String,
	owner: String,
	channel: String,
	story_days: Array,
	infinity_enabled: bool,
	candidate_scene_ids: Array[String],
	selection_policy: String,
	default_scene_id: String,
	materialization_scene_ids: Array[String],
	observation_guard_scene_ids: Array[String],
	visibility_policy: String,
	scope_ids: Array[String],
	lifecycle: Dictionary,
	resolution: Dictionary,
	debug: Dictionary,
	extra: Dictionary = {},
) -> Dictionary:
	var direct := kind in DIRECT_KINDS
	var result := {
		"schema_version": SCHEMA_VERSION,
		"id": event_id,
		"aliases": _string_array(extra.get("aliases", [])),
		"kind": kind,
		"runtime_owner": owner,
		"schedule": {
			"channel": channel,
			"story_days": story_days.duplicate(),
			"infinity_enabled": infinity_enabled,
			"infinity_min_night": 1,
			"weight": 1.0,
			"debug_only": bool(extra.get("debug_only", false)),
			"legacy_min_day": int(extra.get("legacy_min_day", 1)),
		},
		"placement": {
			"candidate_scene_ids": candidate_scene_ids.duplicate(),
			"selection_policy": selection_policy,
			"default_scene_id": default_scene_id,
			"materialization_scene_ids": materialization_scene_ids.duplicate(),
			"observation_guard_scene_ids": observation_guard_scene_ids.duplicate(),
		},
		"activation": {
			"trigger": "derived" if channel == CHANNEL_DERIVED else ("scene_entry" if visibility_policy == VISIBILITY_AUTHORED_ON_ENTRY else "scheduled"),
			"visibility_policy": visibility_policy,
			"exclusive_slots": [ACTIVATION_SLOT_PRIMARY] if direct else [],
			"recheck_on": ["timer_elapsed", "scene_changed", "slot_released"] if direct else [],
		},
		"occupancy": {"scope_ids": scope_ids.duplicate()},
		"lifecycle": lifecycle.duplicate(true),
		"resolution": resolution.duplicate(true),
		"persistence": {
			"save_status": true,
			"save_selected_scene": selection_policy == SELECTION_RANDOM_ONCE_AT_ARM,
			"save_timers": true,
			"save_rng_result": selection_policy == SELECTION_RANDOM_ONCE_AT_ARM,
		},
		"presentation": {
			"hotspot_rect": extra.get("hotspot_rect", Rect2()),
			"collection_kind": KIND_PHENOMENON if kind == KIND_DERIVED_HAZARD else kind,
			"collection_title_key": "anomaly_collection.event.%s.title" % event_id,
			"collection_body_key": "anomaly_collection.event.%s.body" % event_id,
			"game_over_event_id": event_id,
		},
		"debug": debug.duplicate(true),
	}
	return result


static func _with_resolution(definition: Dictionary, extra: Dictionary) -> Dictionary:
	var resolution: Dictionary = definition.get("resolution", {})
	resolution.merge(extra, true)
	return definition


static func _selected_scene_or_default(event_id: String, selected_scene_id: String) -> String:
	if not selected_scene_id.is_empty():
		return selected_scene_id
	return get_default_scene_id(event_id)


static func _resolve_scene_tokens(raw_scene_ids, selected_scene_id: String) -> Array[String]:
	var scene_ids: Array[String] = []
	for raw_scene_id in raw_scene_ids:
		var scene_id := String(raw_scene_id)
		if scene_id == SELECTED_SCENE_TOKEN:
			scene_id = selected_scene_id
		if not scene_id.is_empty() and not scene_ids.has(scene_id):
			scene_ids.append(scene_id)
	return scene_ids


static func _string_array(raw_values) -> Array[String]:
	var values: Array[String] = []
	for raw_value in raw_values:
		values.append(String(raw_value))
	return values


static func _room_id_from_scene(scene_id: String) -> String:
	if scene_id.begins_with("room_"):
		return "%s_%s" % [scene_id.get_slice("_", 0), scene_id.get_slice("_", 1)]
	if scene_id in ["front_desk", "corridor", "laundry_room", "exterior_stairs"]:
		return scene_id
	return "hotel"
