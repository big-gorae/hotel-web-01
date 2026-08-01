class_name HotelClosetPigManSystem
extends Node

signal state_changed
signal event_started(event_id: String)
signal event_resolved(event_id: String)
signal death_requested(event_id: String)
signal sound_requested(cue_id: String)
signal hold_started(mode: String, focus_position: Vector2)
signal hold_progress_changed(progress: float)
signal hold_ended

const HoldController := preload("res://scripts/interactions/hold_interaction_controller.gd")

const EVENT_ID := "room_105_closet_pig_man"
const SCENE_ID := "room_105_bathroom_entry"
const HOLD_HOTSPOT_ID := "closet_pig_hold:wardrobe"

const STATE_IDLE := "idle"
const STATE_WAITING := "waiting"
const STATE_DOOR_OPEN := "door_open"
const STATE_EMERGING := "emerging"
const STATE_RESOLVED := "resolved"

# These waits are deliberately long. The event is announced by recurring global
# squeals, so players have time to infer the rule and reach Room 105.
const INITIAL_WAIT_SECONDS := 300.0
const DOOR_OPEN_WAIT_SECONDS := 240.0
const EMERGING_WAIT_SECONDS := 240.0
const HOLD_SECONDS := 5.0
const SQUEAL_INTERVAL_MIN_SECONDS := 24.0
const SQUEAL_INTERVAL_MAX_SECONDS := 42.0

var current_day := 1
var current_state := STATE_IDLE
var stage_seconds_remaining := 0.0
var squeal_seconds_remaining := 0.0
var enabled := false
var external_anomaly_active := false
var lethal_outcomes_enabled := true
var hold_controller = null

var _hold_focus_position := Vector2.ZERO
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_rng.randomize()
	hold_controller = HoldController.new()
	hold_controller.hold_started.connect(_on_hold_started)
	hold_controller.progress_changed.connect(_on_hold_progress_changed)
	hold_controller.hold_cancelled.connect(_on_hold_cancelled)
	hold_controller.hold_completed.connect(_on_hold_completed)


func set_lethal_outcomes_enabled(value: bool) -> void:
	lethal_outcomes_enabled = value


func set_external_anomaly_active(value: bool) -> void:
	external_anomaly_active = value


func start_day(day: int) -> void:
	current_day = maxi(day, 1)
	enabled = current_day >= 2
	external_anomaly_active = false
	release_hold()
	current_state = STATE_WAITING if enabled else STATE_IDLE
	stage_seconds_remaining = INITIAL_WAIT_SECONDS if enabled else 0.0
	squeal_seconds_remaining = 0.0
	state_changed.emit()


func advance(delta: float) -> void:
	if delta <= 0.0:
		return
	if hold_controller != null:
		hold_controller.advance(delta)
	if not enabled or current_state in [STATE_IDLE, STATE_RESOLVED]:
		return
	if current_state == STATE_WAITING and external_anomaly_active:
		return

	if is_active():
		_advance_global_squeals(delta)

	stage_seconds_remaining = maxf(stage_seconds_remaining - delta, 0.0)
	if stage_seconds_remaining > 0.0:
		return
	match current_state:
		STATE_WAITING:
			_begin_stage(STATE_DOOR_OPEN, DOOR_OPEN_WAIT_SECONDS, true)
		STATE_DOOR_OPEN:
			_begin_stage(STATE_EMERGING, EMERGING_WAIT_SECONDS, true)
		STATE_EMERGING:
			if lethal_outcomes_enabled:
				death_requested.emit(EVENT_ID)
			else:
				_resolve()


func is_active() -> bool:
	return current_state in [STATE_DOOR_OPEN, STATE_EMERGING]


func get_presentation_state() -> Dictionary:
	if not is_active():
		return {}
	return {
		"event_id": EVENT_ID,
		"scene_id": SCENE_ID,
		"state": "face" if current_state == STATE_EMERGING else STATE_DOOR_OPEN,
	}


func get_dynamic_hotspots(scene_id: String) -> Array:
	if scene_id != SCENE_ID or not is_active():
		return []
	return [{
		"id": HOLD_HOTSPOT_ID,
		"label_key": "hotspot.room_105_bathroom_entry.closet_pig_hold:wardrobe.label",
		"label": "Close wardrobe",
		"text_key": "hotspot.room_105_bathroom_entry.closet_pig_hold:wardrobe.text",
		"text": "Hold to push him inside and close the wardrobe.",
		"rect": Rect2(0.63, 0.20, 0.15, 0.55),
	}]


func begin_pointer_hold(hotspot_id: String, focus_position: Vector2) -> bool:
	if hotspot_id != HOLD_HOTSPOT_ID or not is_active() or hold_controller == null:
		return false
	_hold_focus_position = focus_position
	return hold_controller.begin(HOLD_HOTSPOT_ID, HOLD_SECONDS)


func release_hold() -> void:
	if hold_controller != null and hold_controller.is_active():
		hold_controller.cancel()


func force_event(state := STATE_DOOR_OPEN) -> bool:
	if state not in [STATE_DOOR_OPEN, STATE_EMERGING]:
		return false
	enabled = true
	_begin_stage(
		state,
		EMERGING_WAIT_SECONDS if state == STATE_EMERGING else DOOR_OPEN_WAIT_SECONDS,
		true,
	)
	return true


func export_state() -> Dictionary:
	return {
		"current_day": current_day,
		"current_state": current_state,
		"stage_seconds_remaining": stage_seconds_remaining,
		"squeal_seconds_remaining": squeal_seconds_remaining,
		"enabled": enabled,
	}


func import_state(state: Dictionary) -> void:
	release_hold()
	current_day = maxi(int(state.get("current_day", current_day)), 1)
	enabled = bool(state.get("enabled", current_day >= 2))
	current_state = String(state.get("current_state", STATE_WAITING if enabled else STATE_IDLE))
	if current_state not in [STATE_IDLE, STATE_WAITING, STATE_DOOR_OPEN, STATE_EMERGING, STATE_RESOLVED]:
		current_state = STATE_WAITING if enabled else STATE_IDLE
	stage_seconds_remaining = maxf(float(state.get("stage_seconds_remaining", _default_seconds_for_state(current_state))), 0.0)
	squeal_seconds_remaining = maxf(float(state.get("squeal_seconds_remaining", _next_squeal_interval())), 0.0)
	external_anomaly_active = false
	state_changed.emit()


func _begin_stage(state: String, duration_seconds: float, announce: bool) -> void:
	current_state = state
	stage_seconds_remaining = duration_seconds
	squeal_seconds_remaining = _next_squeal_interval()
	if announce:
		sound_requested.emit("pig_squeal")
	if state == STATE_DOOR_OPEN:
		event_started.emit(EVENT_ID)
	state_changed.emit()


func _advance_global_squeals(delta: float) -> void:
	squeal_seconds_remaining -= delta
	if squeal_seconds_remaining > 0.0:
		return
	sound_requested.emit("pig_squeal")
	squeal_seconds_remaining = _next_squeal_interval()


func _next_squeal_interval() -> float:
	return _rng.randf_range(SQUEAL_INTERVAL_MIN_SECONDS, SQUEAL_INTERVAL_MAX_SECONDS)


func _default_seconds_for_state(state: String) -> float:
	match state:
		STATE_WAITING:
			return INITIAL_WAIT_SECONDS
		STATE_DOOR_OPEN:
			return DOOR_OPEN_WAIT_SECONDS
		STATE_EMERGING:
			return EMERGING_WAIT_SECONDS
	return 0.0


func _on_hold_started(_hold_id: String, _duration_seconds: float) -> void:
	hold_started.emit("circular", _hold_focus_position)


func _on_hold_progress_changed(_hold_id: String, progress: float) -> void:
	hold_progress_changed.emit(progress)


func _on_hold_cancelled(_hold_id: String) -> void:
	hold_ended.emit()


func _on_hold_completed(_hold_id: String) -> void:
	hold_ended.emit()
	_resolve()


func _resolve() -> void:
	if current_state == STATE_RESOLVED:
		return
	current_state = STATE_RESOLVED
	stage_seconds_remaining = 0.0
	squeal_seconds_remaining = 0.0
	sound_requested.emit("closet_door_close")
	event_resolved.emit(EVENT_ID)
	state_changed.emit()
