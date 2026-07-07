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
var definitions_by_id: Dictionary = {}
var active_event_id_by_room: Dictionary = {}
var discovered_event_ids: Array[String] = []
var discovered_kind_counts: Dictionary = {}
var seen_scene_seconds: Dictionary = {}
var resolved_event_ids: Array[String] = []
var active_jumpscare_id := ""


func setup_default_catalog() -> void:
	definitions_by_id.clear()
	for definition in HorrorCatalog.build_definitions():
		register_definition(definition)


func start_new_run() -> void:
	rng.randomize()
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
	if not definitions_by_id.has(event_id) or is_jumpscare_active():
		return false

	var definition = definitions_by_id[event_id]
	if definition.event_type != HorrorEventDefinition.TYPE_JUMPSCARE:
		return false

	active_jumpscare_id = event_id
	mark_event_seen(event_id)
	jumpscare_started.emit(definition)
	return true


func finish_jumpscare() -> void:
	if active_jumpscare_id.is_empty():
		return

	var definition = definitions_by_id.get(active_jumpscare_id)
	active_jumpscare_id = ""
	if definition != null:
		jumpscare_finished.emit(definition, definition.jumpscare_outcome)


func is_jumpscare_active() -> bool:
	return not active_jumpscare_id.is_empty()


func mark_event_seen(event_id: String) -> void:
	if not definitions_by_id.has(event_id) or discovered_event_ids.has(event_id):
		return

	var definition = definitions_by_id[event_id]
	discovered_event_ids.append(event_id)
	var kind := String(definition.discovery_kind)
	if not kind.is_empty():
		discovered_kind_counts[kind] = int(discovered_kind_counts.get(kind, 0)) + 1

	event_seen.emit(definition)


func resolve_event(event_id: String) -> void:
	if not definitions_by_id.has(event_id) or resolved_event_ids.has(event_id):
		return

	var definition = definitions_by_id[event_id]
	resolved_event_ids.append(event_id)
	if active_event_id_by_room.get(definition.room_id, "") == event_id:
		active_event_id_by_room.erase(definition.room_id)

	event_resolved.emit(definition)


func get_discovered_count() -> int:
	return discovered_event_ids.size()


func get_discovered_kind_counts() -> Dictionary:
	return discovered_kind_counts.duplicate(true)


func get_discovered_entries() -> Array:
	var entries := []
	for event_id in discovered_event_ids:
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
			"resolved": resolved_event_ids.has(definition.id),
		})

	return entries


func get_lobby_summary_text() -> String:
	var total_count := get_discovered_count()
	if total_count == 0:
		return "Anomalies found: 0"

	var parts := []
	for kind in discovered_kind_counts.keys():
		parts.append("%s %d" % [String(kind).capitalize(), int(discovered_kind_counts[kind])])

	return "Anomalies found: %d (%s)" % [total_count, ", ".join(parts)]


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
		discovered_event_ids.append(String(event_id))

	resolved_event_ids.clear()
	for event_id in state.get("resolved_event_ids", []):
		resolved_event_ids.append(String(event_id))

	active_jumpscare_id = ""


func _try_spawn_random_anomaly(scene_id: String) -> void:
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

	for definition in candidates:
		if rng.randf() <= definition.spawn_chance:
			active_event_id_by_room[room_id] = definition.id
			anomaly_spawned.emit(definition)
			return


func _active_definitions_for_scene(scene_id: String) -> Array:
	var result := []
	var room_id := room_registry.get_room_id(scene_id)
	var event_id := String(active_event_id_by_room.get(room_id, ""))
	if event_id.is_empty() or not definitions_by_id.has(event_id):
		return result

	var definition = definitions_by_id[event_id]
	if definition.applies_to_scene(scene_id):
		result.append(definition)

	return result


func _mark_active_events_seen_in_scene(scene_id: String, seconds: float) -> void:
	for definition in _active_definitions_for_scene(scene_id):
		var view_key := "%s:%s" % [definition.id, scene_id]
		seen_scene_seconds[view_key] = maxf(float(seen_scene_seconds.get(view_key, 0.0)), seconds)
