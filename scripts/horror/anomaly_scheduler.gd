class_name HotelAnomalyScheduler
extends RefCounted

signal event_queued(event_id: String)
signal event_started(event_id: String)
signal event_resolving(event_id: String)
signal event_completed(event_id: String)
signal event_failed(event_id: String)
signal cooldown_started(duration_seconds: float)
signal cooldown_finished

const DEFAULT_COOLDOWN_SECONDS := 2.0

var active_anomaly_id := ""
var pending_anomaly_queue: Array[Dictionary] = []
var inter_anomaly_cooldown := 0.0
var blocked_conflict_tags: Array[String] = []

var _next_sequence := 0


func enqueue(event_id: String, priority := 0, conflict_tags: Array[String] = []) -> bool:
	if event_id.is_empty() or contains(event_id):
		return false

	pending_anomaly_queue.append({
		"event_id": event_id,
		"priority": priority,
		"conflict_tags": conflict_tags.duplicate(),
		"sequence": _next_sequence,
	})
	_next_sequence += 1
	_sort_queue()
	event_queued.emit(event_id)
	_try_start_next()
	return true


func contains(event_id: String) -> bool:
	if active_anomaly_id == event_id:
		return true
	for entry in pending_anomaly_queue:
		if String(entry.get("event_id", "")) == event_id:
			return true
	return false


func begin_resolving(event_id: String) -> bool:
	if active_anomaly_id != event_id:
		return false
	event_resolving.emit(event_id)
	return true


func complete_active(event_id: String, cooldown_seconds := DEFAULT_COOLDOWN_SECONDS) -> bool:
	if active_anomaly_id != event_id:
		return false

	active_anomaly_id = ""
	event_completed.emit(event_id)
	_start_cooldown(cooldown_seconds)
	return true


func fail_active(event_id: String) -> bool:
	if active_anomaly_id != event_id:
		return false

	active_anomaly_id = ""
	inter_anomaly_cooldown = 0.0
	event_failed.emit(event_id)
	return true


func advance(delta: float) -> void:
	if delta <= 0.0 or not active_anomaly_id.is_empty():
		return
	if inter_anomaly_cooldown <= 0.0:
		_try_start_next()
		return

	inter_anomaly_cooldown = maxf(inter_anomaly_cooldown - delta, 0.0)
	if inter_anomaly_cooldown > 0.0001:
		return

	inter_anomaly_cooldown = 0.0
	cooldown_finished.emit()
	_try_start_next()


func set_blocked_conflict_tags(tags: Array[String]) -> void:
	blocked_conflict_tags = _unique_strings(tags)
	_try_start_next()


func export_state() -> Dictionary:
	return {
		"active_anomaly_id": active_anomaly_id,
		"pending_anomaly_queue": pending_anomaly_queue.duplicate(true),
		"inter_anomaly_cooldown": inter_anomaly_cooldown,
		"blocked_conflict_tags": blocked_conflict_tags.duplicate(),
		"next_sequence": _next_sequence,
	}


func import_state(state: Dictionary) -> void:
	active_anomaly_id = String(state.get("active_anomaly_id", ""))
	inter_anomaly_cooldown = maxf(float(state.get("inter_anomaly_cooldown", 0.0)), 0.0)
	blocked_conflict_tags = _unique_strings(_string_array(state.get("blocked_conflict_tags", [])))
	pending_anomaly_queue.clear()

	var seen_ids := {}
	if not active_anomaly_id.is_empty():
		seen_ids[active_anomaly_id] = true
	for raw_entry in state.get("pending_anomaly_queue", []):
		if not raw_entry is Dictionary:
			continue
		var event_id := String(raw_entry.get("event_id", ""))
		if event_id.is_empty() or seen_ids.has(event_id):
			continue
		seen_ids[event_id] = true
		pending_anomaly_queue.append({
			"event_id": event_id,
			"priority": int(raw_entry.get("priority", 0)),
			"conflict_tags": _unique_strings(_string_array(raw_entry.get("conflict_tags", []))),
			"sequence": maxi(int(raw_entry.get("sequence", pending_anomaly_queue.size())), 0),
		})

	_next_sequence = maxi(int(state.get("next_sequence", pending_anomaly_queue.size())), pending_anomaly_queue.size())
	_sort_queue()
	_try_start_next()


func _start_cooldown(duration_seconds: float) -> void:
	inter_anomaly_cooldown = maxf(duration_seconds, 0.0)
	if inter_anomaly_cooldown <= 0.0:
		_try_start_next()
		return
	cooldown_started.emit(inter_anomaly_cooldown)


func _try_start_next() -> void:
	if not active_anomaly_id.is_empty() or inter_anomaly_cooldown > 0.0:
		return

	for index in pending_anomaly_queue.size():
		var entry := pending_anomaly_queue[index]
		if _has_blocked_conflict(entry.get("conflict_tags", [])):
			continue

		active_anomaly_id = String(entry.get("event_id", ""))
		pending_anomaly_queue.remove_at(index)
		event_started.emit(active_anomaly_id)
		return


func _has_blocked_conflict(raw_tags) -> bool:
	for tag in raw_tags:
		if blocked_conflict_tags.has(String(tag)):
			return true
	return false


func _sort_queue() -> void:
	pending_anomaly_queue.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_priority := int(left.get("priority", 0))
		var right_priority := int(right.get("priority", 0))
		if left_priority != right_priority:
			return left_priority > right_priority
		return int(left.get("sequence", 0)) < int(right.get("sequence", 0))
	)


func _unique_strings(values: Array[String]) -> Array[String]:
	var unique: Array[String] = []
	for value in values:
		if not value.is_empty() and not unique.has(value):
			unique.append(value)
	return unique


func _string_array(raw_values) -> Array[String]:
	var values: Array[String] = []
	for raw_value in raw_values:
		values.append(String(raw_value))
	return values
