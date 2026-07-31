class_name HotelHorrorEventManager
extends RefCounted

signal anomaly_spawned(definition)
signal event_seen(definition)
signal event_resolved(definition)
signal jumpscare_started(definition)
signal jumpscare_finished(definition, outcome: String)

const HorrorEventDefinition := preload("res://scripts/horror/horror_event_definition.gd")
const HorrorRoomRegistry := preload("res://scripts/horror/horror_room_registry.gd")
const HorrorCatalog := preload("res://scripts/horror/horror_catalog.gd")

var room_registry = HorrorRoomRegistry.new()
var rng := RandomNumberGenerator.new()
var flag_store = null
var definitions_by_id: Dictionary = {}
var active_event_id_by_room: Dictionary = {}
var discovered_event_ids: Array[String] = []
var discovered_kind_counts: Dictionary = {}
var seen_scene_seconds: Dictionary = {}
var resolved_event_ids: Array[String] = []
var collection_event_ids: Array[String] = []
var collection_kind_counts: Dictionary = {}
var collection_resolved_event_ids: Array[String] = []
var active_jumpscare_id := ""
var jumpscares_enabled := true
var random_spawning_enabled := true


func setup_default_catalog(new_flag_store = null) -> void:
	flag_store = new_flag_store
	definitions_by_id.clear()
	for definition in HorrorCatalog.build_definitions():
		register_definition(definition)


func set_jumpscares_enabled(value: bool) -> void:
	jumpscares_enabled = value
	if not jumpscares_enabled:
		active_jumpscare_id = ""


func set_random_spawning_enabled(value: bool) -> void:
	random_spawning_enabled = value


func start_new_run() -> void:
	rng.randomize()
	for event_id in active_event_id_by_room.values():
		_set_definition_flag(definitions_by_id.get(String(event_id)), false)
	if not active_jumpscare_id.is_empty():
		_set_definition_flag(definitions_by_id.get(active_jumpscare_id), false)
	active_event_id_by_room.clear()
	discovered_event_ids.clear()
	discovered_kind_counts.clear()
	seen_scene_seconds.clear()
	resolved_event_ids.clear()
	active_jumpscare_id = ""


func register_definition(definition) -> void:
	if definition == null or definition.id.is_empty():
		return

	definitions_by_id[definition.id] = definition.copy()


func get_definition(event_id: String):
	return definitions_by_id.get(event_id)


func enter_scene(scene_id: String) -> void:
	if is_jumpscare_active():
		return

	_try_spawn_random_anomaly(scene_id)
	_mark_active_events_seen_in_scene(scene_id, 0.0)


func tick_scene_view(scene_id: String, delta: float) -> void:
	if is_jumpscare_active():
		return

	for definition in _active_definitions_for_scene(scene_id):
		if discovered_event_ids.has(definition.id):
			continue

		var view_key := "%s:%s" % [definition.id, scene_id]
		var seconds := float(seen_scene_seconds.get(view_key, 0.0)) + delta
		seen_scene_seconds[view_key] = seconds
		if seconds >= definition.view_seconds_to_discover:
			mark_event_seen(definition.id)


func get_revealed_hotspots(scene_id: String) -> Array:
	var revealed_hotspots := []
	for definition in _active_definitions_for_scene(scene_id):
		if definition.event_type != HorrorEventDefinition.TYPE_ANOMALY:
			continue

		for hotspot in definition.reveal_hotspots:
			revealed_hotspots.append(hotspot.duplicate(true))

	return revealed_hotspots


func trigger_jumpscare(event_id: String) -> bool:
	if not jumpscares_enabled or not definitions_by_id.has(event_id) or is_jumpscare_active():
		return false

	var definition = definitions_by_id[event_id]
	if definition.event_type != HorrorEventDefinition.TYPE_JUMPSCARE:
		return false

	active_jumpscare_id = event_id
	_set_definition_flag(definition, true)
	mark_event_seen(event_id)
	jumpscare_started.emit(definition)
	return true


func finish_jumpscare() -> void:
	if active_jumpscare_id.is_empty():
		return

	var definition = definitions_by_id.get(active_jumpscare_id)
	active_jumpscare_id = ""
	if definition != null:
		_set_definition_flag(definition, false)
		jumpscare_finished.emit(definition, definition.jumpscare_outcome)


func is_jumpscare_active() -> bool:
	return jumpscares_enabled and not active_jumpscare_id.is_empty()


func mark_event_seen(event_id: String) -> void:
	if not definitions_by_id.has(event_id) or discovered_event_ids.has(event_id):
		return

	var definition = definitions_by_id[event_id]
	discovered_event_ids.append(event_id)
	var kind := String(definition.discovery_kind)
	if not kind.is_empty():
		discovered_kind_counts[kind] = int(discovered_kind_counts.get(kind, 0)) + 1
	_record_collection_event(event_id)

	event_seen.emit(definition)


func resolve_event(event_id: String) -> void:
	if not definitions_by_id.has(event_id) or resolved_event_ids.has(event_id):
		return

	mark_event_seen(event_id)
	var definition = definitions_by_id[event_id]
	resolved_event_ids.append(event_id)
	if not collection_resolved_event_ids.has(event_id):
		collection_resolved_event_ids.append(event_id)
	if active_event_id_by_room.get(definition.room_id, "") == event_id:
		active_event_id_by_room.erase(definition.room_id)
	_set_definition_flag(definition, false)

	event_resolved.emit(definition)


func get_discovered_count() -> int:
	return collection_event_ids.size()


func get_discovered_kind_counts() -> Dictionary:
	return collection_kind_counts.duplicate(true)


func get_discovered_entries() -> Array:
	var entries := []
	for event_id in collection_event_ids:
		if not definitions_by_id.has(event_id):
			continue

		var definition = definitions_by_id[event_id]
		entries.append({
			"id": definition.id,
			"event_type": definition.event_type,
			"discovery_kind": definition.discovery_kind,
			"room_id": definition.room_id,
			"room_name": room_registry.get_room_display_name(definition.room_id),
			"title_key": "horror_event.%s.title" % definition.id,
			"description_key": "horror_event.%s.description" % definition.id,
			"fallback_title": definition.fallback_title,
			"fallback_description": definition.fallback_description,
			"resolved": collection_resolved_event_ids.has(definition.id),
		})

	return entries


func export_state() -> Dictionary:
	return {
		"active_event_id_by_room": active_event_id_by_room.duplicate(true),
		"discovered_event_ids": discovered_event_ids.duplicate(),
		"discovered_kind_counts": discovered_kind_counts.duplicate(true),
		"seen_scene_seconds": seen_scene_seconds.duplicate(true),
		"resolved_event_ids": resolved_event_ids.duplicate(),
	}


func import_state(state: Dictionary) -> void:
	active_event_id_by_room = state.get("active_event_id_by_room", {}).duplicate(true)
	discovered_kind_counts = state.get("discovered_kind_counts", {}).duplicate(true)
	seen_scene_seconds = state.get("seen_scene_seconds", {}).duplicate(true)
	discovered_event_ids.clear()
	for event_id in state.get("discovered_event_ids", []):
		var safe_event_id := String(event_id)
		if definitions_by_id.has(safe_event_id) and not discovered_event_ids.has(safe_event_id):
			discovered_event_ids.append(safe_event_id)
			_record_collection_event(safe_event_id)

	resolved_event_ids.clear()
	for event_id in state.get("resolved_event_ids", []):
		var safe_event_id := String(event_id)
		if definitions_by_id.has(safe_event_id) and not resolved_event_ids.has(safe_event_id):
			resolved_event_ids.append(safe_event_id)
			_record_collection_event(safe_event_id)
			if not collection_resolved_event_ids.has(safe_event_id):
				collection_resolved_event_ids.append(safe_event_id)

	active_jumpscare_id = ""
	_sync_active_flags()


func export_collection_state() -> Dictionary:
	return {
		"discovered_event_ids": collection_event_ids.duplicate(),
		"discovered_kind_counts": collection_kind_counts.duplicate(true),
		"resolved_event_ids": collection_resolved_event_ids.duplicate(),
	}


func import_collection_state(state: Dictionary) -> void:
	collection_event_ids.clear()
	for event_id in state.get("discovered_event_ids", []):
		var safe_event_id := String(event_id)
		if definitions_by_id.has(safe_event_id) and not collection_event_ids.has(safe_event_id):
			collection_event_ids.append(safe_event_id)

	collection_kind_counts.clear()
	for event_id in collection_event_ids:
		var definition = definitions_by_id[event_id]
		var kind := String(definition.discovery_kind)
		if not kind.is_empty():
			collection_kind_counts[kind] = int(collection_kind_counts.get(kind, 0)) + 1

	collection_resolved_event_ids.clear()
	for event_id in state.get("resolved_event_ids", []):
		var safe_event_id := String(event_id)
		if collection_event_ids.has(safe_event_id) and not collection_resolved_event_ids.has(safe_event_id):
			collection_resolved_event_ids.append(safe_event_id)


func _try_spawn_random_anomaly(scene_id: String) -> void:
	if not random_spawning_enabled:
		return
	var room_id := room_registry.get_room_id(scene_id)
	if active_event_id_by_room.has(room_id):
		return

	var candidates := []
	for definition in definitions_by_id.values():
		if not definition.enabled:
			continue
		if definition.event_type != HorrorEventDefinition.TYPE_ANOMALY:
			continue
		if definition.room_id != room_id:
			continue
		if resolved_event_ids.has(definition.id) or discovered_event_ids.has(definition.id):
			continue
		if definition.spawn_chance <= 0.0:
			continue
		candidates.append(definition)

	candidates.sort_custom(func(left, right): return left.id < right.id)
	var successful_candidates := []
	for definition in candidates:
		if rng.randf() <= definition.spawn_chance:
			successful_candidates.append(definition)

	var selected_definition = _choose_weighted(successful_candidates)
	if selected_definition != null:
		active_event_id_by_room[room_id] = selected_definition.id
		_set_definition_flag(selected_definition, true)
		anomaly_spawned.emit(selected_definition)


func _active_definitions_for_scene(scene_id: String) -> Array:
	var result := []
	var room_id := room_registry.get_room_id(scene_id)
	var event_id := String(active_event_id_by_room.get(room_id, ""))
	if event_id.is_empty() or not definitions_by_id.has(event_id):
		return result

	var definition = definitions_by_id[event_id]
	if definition.applies_to_scene(scene_id) and _is_definition_flag_enabled(definition):
		result.append(definition)

	return result


func _mark_active_events_seen_in_scene(scene_id: String, seconds: float) -> void:
	for definition in _active_definitions_for_scene(scene_id):
		var view_key := "%s:%s" % [definition.id, scene_id]
		seen_scene_seconds[view_key] = maxf(float(seen_scene_seconds.get(view_key, 0.0)), seconds)


func _choose_weighted(candidates: Array):
	if candidates.is_empty():
		return null

	var total_weight := 0.0
	for definition in candidates:
		total_weight += maxf(float(definition.random_weight), 0.0)
	if total_weight <= 0.0:
		return candidates[0]

	var roll := rng.randf_range(0.0, total_weight)
	for definition in candidates:
		roll -= maxf(float(definition.random_weight), 0.0)
		if roll <= 0.0:
			return definition

	return candidates.back()


func _record_collection_event(event_id: String) -> void:
	if not definitions_by_id.has(event_id) or collection_event_ids.has(event_id):
		return

	collection_event_ids.append(event_id)
	var definition = definitions_by_id[event_id]
	var kind := String(definition.discovery_kind)
	if not kind.is_empty():
		collection_kind_counts[kind] = int(collection_kind_counts.get(kind, 0)) + 1


func _set_definition_flag(definition, visible: bool) -> void:
	if flag_store == null or definition == null or String(definition.flag_id).is_empty():
		return

	flag_store.set_value(String(definition.flag_id), visible)


func _is_definition_flag_enabled(definition) -> bool:
	if definition == null or String(definition.flag_id).is_empty() or flag_store == null:
		return true

	return flag_store.get_bool(String(definition.flag_id), false)


func _sync_active_flags() -> void:
	if flag_store == null:
		return

	for definition in definitions_by_id.values():
		if not String(definition.flag_id).is_empty():
			flag_store.set_value(String(definition.flag_id), false)

	for event_id in active_event_id_by_room.values():
		var definition = definitions_by_id.get(String(event_id))
		if definition != null:
			_set_definition_flag(definition, true)
