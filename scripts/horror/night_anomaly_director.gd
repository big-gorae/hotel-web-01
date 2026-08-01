class_name HotelNightAnomalyDirector
extends Node

signal dialogue_requested(message: String)
signal death_requested(event_id: String)
signal phone_bell_changed(count: int, maximum: int)
signal state_changed
signal event_started(event_id: String)
signal event_survived(event_id: String)
signal hold_started(mode: String, focus_position: Vector2)
signal hold_progress_changed(progress: float)
signal hold_ended
signal sound_requested(cue_id: String)

const PHONE_MAX_BELLS := 13
const PHONE_EVENT_ID := "room_108_light_repair_call"
const ROOM_109_EVENT_ID := "room_109_open_door"
const LAUNDRY_EVENT_ID := "laundry_red_washer"
const CHILD_EVENT_ID := "room_106_abandoned_child"
const BLANKET_CHILD_EVENT_ID := "vacant_room_blanket_child"
const ROOM_109_PASSAGE_EVENT_ID := "room_109_day7_passage"
const HELL_MIRROR_ITEM_ID := "hell_mirror"
const CLOSET_PIG_EVENT_ID := "room_105_closet_pig_man"
const GameMode := preload("res://scripts/systems/game_mode.gd")

# Keep the Story route editable as one plain Day table. An omitted Day has no
# primary event. Infinity uses the separate random pool in _eligible_daily_events().
const STORY_PRIMARY_EVENT_BY_DAY := {
	2: CLOSET_PIG_EVENT_ID,
	4: PHONE_EVENT_ID,
	5: LAUNDRY_EVENT_ID,
	6: CHILD_EVENT_ID,
	7: ROOM_109_PASSAGE_EVENT_ID,
}

const LAUNDRY_IDLE := "idle"
const LAUNDRY_WASHING := "washing"
const LAUNDRY_RED := "red"
const LAUNDRY_MUSIC := "music"
const LAUNDRY_READY := "ready"
const LAUNDRY_DISCARDED := "discarded"

const CHILD_IDLE := "idle"
const CHILD_WAITING := "waiting"
const CHILD_CRYING := "crying"
const CHILD_SONG_DONE := "song_done"
const CHILD_HELD := "held"

const BLANKET_IDLE := "idle"
const BLANKET_VISIBLE := "visible"
const BLANKET_RESOLVED := "resolved"

const ROOM_109_PASSAGE_IDLE := "idle"
const ROOM_109_PASSAGE_WAITING := "waiting"
const ROOM_109_PASSAGE_FOOTSTEPS := "footsteps"
const ROOM_109_PASSAGE_DONE := "done"

var phone_initial_delay := 24.0
var phone_repeat_delay := 58.0
var phone_bell_interval := 1.15
var laundry_red_delay := 9.0
var laundry_music_duration := 7.0
var child_appearance_delay := 7.0
var child_response_seconds := 6.0
var child_song_duration := 6.5
var laundry_neglect_duration := 18.0
var laundry_post_music_death_delay := 2.4
var phone_death_delay := 2.4
var phone_forbidden_duration := 18.0
var blanket_response_seconds := 18.0
var blanket_eye_close_duration := 6.0
var blanket_death_delay := 1.4
var room_109_passage_wait_seconds := 3.0
var room_109_passage_footstep_seconds := 6.0

var current_day := 1
var game_mode := GameMode.STORY
var current_scene_id := ""
var eye_close_controller = null
var lethal_outcomes_enabled := true
var external_anomaly_active := false

var phone_ringing := false
var phone_bell_count := 0
var room_108_forbidden := false
var laundry_state := LAUNDRY_IDLE
var child_state := CHILD_IDLE
var blanket_state := BLANKET_IDLE
var blanket_scene_id := ""
var room_109_passage_state := ROOM_109_PASSAGE_IDLE

var _phone_seconds := 0.0
var _laundry_seconds := 0.0
var _child_seconds := 0.0
var _laundry_neglect_seconds := 0.0
var _laundry_fatal_pending := false
var _phone_fatal_pending := false
var _phone_death_seconds := 0.0
var _phone_forbidden_seconds := 0.0
var _child_song_held := false
var _blanket_seconds := 0.0
var _blanket_closed_seconds := 0.0
var _blanket_fatal_pending := false
var _blanket_death_seconds := 0.0
var _blanket_laugh_seconds := 0.0
var _room_109_passage_seconds := 0.0
var _room_109_footstep_cue_seconds := 0.0
var _completion_music_player: AudioStreamPlayer
var _phone_bell_player: AudioStreamPlayer
var _washer_spin_player: AudioStreamPlayer
var _planned_event_id := ""
var _planned_event_started := false
var _planned_event_completed := false
var _rng := RandomNumberGenerator.new()
var _random_seed_override := -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_completion_music_player = AudioStreamPlayer.new()
	_completion_music_player.stream = _make_completion_music()
	_completion_music_player.finished.connect(_on_completion_music_finished)
	add_child(_completion_music_player)
	_phone_bell_player = AudioStreamPlayer.new()
	_phone_bell_player.stream = _make_phone_bell()
	_phone_bell_player.volume_db = -7.0
	add_child(_phone_bell_player)
	_washer_spin_player = AudioStreamPlayer.new()
	_washer_spin_player.stream = _make_washer_spin()
	_washer_spin_player.volume_db = -16.0
	add_child(_washer_spin_player)


func _exit_tree() -> void:
	for player in [_completion_music_player, _phone_bell_player, _washer_spin_player]:
		if player != null:
			player.stop()
			player.stream = null


func setup(new_eye_close_controller) -> void:
	eye_close_controller = new_eye_close_controller
	if eye_close_controller == null:
		return
	if not eye_close_controller.closed_changed.is_connected(_on_eye_closed_changed):
		eye_close_controller.closed_changed.connect(_on_eye_closed_changed)
	if not eye_close_controller.song_completed.is_connected(_on_song_completed):
		eye_close_controller.song_completed.connect(_on_song_completed)
	if not eye_close_controller.song_interrupted.is_connected(_on_song_interrupted):
		eye_close_controller.song_interrupted.connect(_on_song_interrupted)


func set_lethal_outcomes_enabled(value: bool) -> void:
	lethal_outcomes_enabled = value


func set_external_anomaly_active(value: bool) -> void:
	external_anomaly_active = value


func set_game_mode(mode_id: String) -> void:
	game_mode = GameMode.normalize(mode_id)


func has_active_anomaly() -> bool:
	return (
		phone_ringing
		or _phone_fatal_pending
		or room_108_forbidden
		or laundry_state in [LAUNDRY_WASHING, LAUNDRY_RED, LAUNDRY_MUSIC, LAUNDRY_READY]
		or child_state in [CHILD_WAITING, CHILD_CRYING, CHILD_SONG_DONE]
		or blanket_state == BLANKET_VISIBLE
		or room_109_passage_state in [ROOM_109_PASSAGE_WAITING, ROOM_109_PASSAGE_FOOTSTEPS]
	)


func start_day(day: int) -> void:
	current_day = maxi(day, 1)
	external_anomaly_active = false
	if _random_seed_override >= 0:
		_rng.seed = _random_seed_override + current_day
	else:
		_rng.randomize()
	phone_ringing = false
	phone_bell_count = 0
	room_108_forbidden = false
	laundry_state = LAUNDRY_IDLE
	child_state = CHILD_IDLE
	blanket_state = BLANKET_IDLE
	blanket_scene_id = ""
	room_109_passage_state = ROOM_109_PASSAGE_IDLE
	_phone_seconds = phone_initial_delay
	_laundry_seconds = 0.0
	_child_seconds = 0.0
	_laundry_neglect_seconds = 0.0
	_laundry_fatal_pending = false
	_phone_fatal_pending = false
	_phone_death_seconds = 0.0
	_phone_forbidden_seconds = 0.0
	_child_song_held = false
	_blanket_seconds = 0.0
	_blanket_closed_seconds = 0.0
	_blanket_fatal_pending = false
	_blanket_death_seconds = 0.0
	_blanket_laugh_seconds = 0.0
	_room_109_passage_seconds = 0.0
	_room_109_footstep_cue_seconds = 0.0
	_planned_event_id = _pick_daily_event()
	_planned_event_started = false
	_planned_event_completed = _planned_event_id.is_empty()
	if _completion_music_player != null:
		_completion_music_player.stop()
	if _washer_spin_player != null:
		_washer_spin_player.stop()
	phone_bell_changed.emit(0, PHONE_MAX_BELLS)
	state_changed.emit()


func enter_scene(scene_id: String) -> void:
	current_scene_id = scene_id
	if (
		_can_start_planned_event(ROOM_109_PASSAGE_EVENT_ID)
		and scene_id == "corridor"
		and room_109_passage_state == ROOM_109_PASSAGE_IDLE
	):
		room_109_passage_state = ROOM_109_PASSAGE_WAITING
		_room_109_passage_seconds = room_109_passage_wait_seconds
		_room_109_footstep_cue_seconds = 0.0
		_mark_planned_event_started(ROOM_109_PASSAGE_EVENT_ID)
		state_changed.emit()
	if scene_id == "laundry_room" and laundry_state == LAUNDRY_RED:
		sound_requested.emit("washer_small_scream")
	if external_anomaly_active:
		return
	if _can_start_planned_event(LAUNDRY_EVENT_ID) and scene_id == "laundry_room" and laundry_state == LAUNDRY_IDLE:
		laundry_state = LAUNDRY_WASHING
		_laundry_seconds = laundry_red_delay
		_mark_planned_event_started(LAUNDRY_EVENT_ID)
		if _audio_playback_allowed() and _washer_spin_player != null:
			_washer_spin_player.play()
		state_changed.emit()
	if _can_start_planned_event(CHILD_EVENT_ID) and scene_id == "room_106_bathroom" and child_state == CHILD_IDLE:
		child_state = CHILD_WAITING
		_child_seconds = child_appearance_delay
		state_changed.emit()
	if _can_start_planned_event(BLANKET_CHILD_EVENT_ID) and blanket_state == BLANKET_IDLE and scene_id == "room_108_bed_window":
		force_blanket_child(scene_id)


func advance(delta: float) -> void:
	if delta <= 0.0 or external_anomaly_active:
		return
	if room_108_forbidden:
		_phone_forbidden_seconds = maxf(_phone_forbidden_seconds - delta, 0.0)
		if _phone_forbidden_seconds <= 0.0:
			room_108_forbidden = false
			_complete_planned_event(PHONE_EVENT_ID)
			state_changed.emit()
		return
	if phone_ringing:
		_advance_phone(delta)
		return
	if _phone_fatal_pending:
		_advance_phone(delta)
		return
	if laundry_state in [LAUNDRY_WASHING, LAUNDRY_RED, LAUNDRY_MUSIC, LAUNDRY_READY]:
		_advance_laundry(delta)
		return
	if child_state in [CHILD_WAITING, CHILD_CRYING, CHILD_SONG_DONE]:
		_advance_child(delta)
		return
	if blanket_state == BLANKET_VISIBLE:
		_advance_blanket(delta)
		return
	if room_109_passage_state in [ROOM_109_PASSAGE_WAITING, ROOM_109_PASSAGE_FOOTSTEPS]:
		_advance_room_109_passage(delta)
		return
	if _can_start_planned_event(PHONE_EVENT_ID) or phone_ringing or _phone_fatal_pending:
		_advance_phone(delta)


func can_change_scene(target_scene_id: String) -> bool:
	if not lethal_outcomes_enabled:
		return true
	if room_108_forbidden and target_scene_id.begins_with("room_108"):
		death_requested.emit(PHONE_EVENT_ID)
		return false
	if current_scene_id == "laundry_room" and laundry_state == LAUNDRY_MUSIC and target_scene_id != "laundry_room":
		death_requested.emit(LAUNDRY_EVENT_ID)
		return false
	if current_scene_id == "room_106_bathroom" and child_state in [CHILD_CRYING, CHILD_SONG_DONE] and target_scene_id != "room_106_bathroom":
		death_requested.emit(CHILD_EVENT_ID)
		return false
	if room_109_passage_state in [ROOM_109_PASSAGE_WAITING, ROOM_109_PASSAGE_FOOTSTEPS] and target_scene_id != "corridor":
		death_requested.emit(ROOM_109_EVENT_ID)
		return false
	return true


func handle_hotspot(hotspot_id: String) -> bool:
	match hotspot_id:
		"phone":
			return _answer_phone()
		"laundry_second_washer":
			return _handle_washer()
		"room_109_open_door":
			if not lethal_outcomes_enabled:
				return false
			death_requested.emit(ROOM_109_EVENT_ID)
			return true
		"abandoned_child":
			return _hold_child()
		"blanket_child":
			sound_requested.emit("blanket_laugh_soft")
			return true
	return false


func destroy_hell_mirror_in_washer(target_inventory) -> bool:
	if (
		current_scene_id != "laundry_room"
		or laundry_state not in [LAUNDRY_IDLE, LAUNDRY_DISCARDED]
		or target_inventory == null
		or not target_inventory.has_item_id(HELL_MIRROR_ITEM_ID)
	):
		return false
	if not target_inventory.remove_item_by_id(HELL_MIRROR_ITEM_ID):
		return false
	sound_requested.emit("hell_mirror_washer_destroy")
	state_changed.emit()
	return true


func get_dynamic_hotspots(scene_id: String) -> Array:
	var hotspots := []
	if scene_id == "corridor" and room_109_passage_state in [ROOM_109_PASSAGE_WAITING, ROOM_109_PASSAGE_FOOTSTEPS]:
		hotspots.append({
			"id": "room_109_open_door",
			"label": "Room 109",
			"rect": Rect2(0.735, 0.285, 0.055, 0.325),
			"text": "The open doorway is too dark to judge its depth.",
		})
	if scene_id == "room_106_bathroom" and child_state == CHILD_SONG_DONE:
		hotspots.append({
			"id": "abandoned_child",
			"label": "Child",
			"rect": Rect2(0.46, 0.58, 0.18, 0.24),
			"text": "The crying has stopped. The child is waiting.",
		})
	if scene_id == blanket_scene_id and blanket_state == BLANKET_VISIBLE:
		hotspots.append({
			"id": "blanket_child",
			"label": "",
			"rect": Rect2(0.245, 0.455, 0.505, 0.335),
		})
	return hotspots


func is_scene_anomalous(scene_id: String) -> bool:
	if scene_id == "laundry_room" and laundry_state in [LAUNDRY_RED, LAUNDRY_MUSIC, LAUNDRY_READY]:
		return true
	if scene_id == "room_106_bathroom" and child_state in [CHILD_CRYING, CHILD_SONG_DONE]:
		return true
	if room_108_forbidden and scene_id.begins_with("room_108"):
		return true
	if blanket_state == BLANKET_VISIBLE and scene_id == blanket_scene_id:
		return true
	if room_109_passage_state in [ROOM_109_PASSAGE_WAITING, ROOM_109_PASSAGE_FOOTSTEPS] and scene_id == "corridor":
		return true
	return false


func force_phone_ring() -> void:
	if current_day < 4:
		current_day = 4
	phone_ringing = true
	phone_bell_count = 0
	_phone_fatal_pending = false
	_phone_death_seconds = 0.0
	_phone_seconds = 0.0
	_prepare_forced_event(PHONE_EVENT_ID)
	_mark_planned_event_started(PHONE_EVENT_ID)
	phone_bell_changed.emit(0, PHONE_MAX_BELLS)
	state_changed.emit()


func force_red_laundry() -> void:
	if current_day < 5:
		current_day = 5
	laundry_state = LAUNDRY_RED
	_laundry_seconds = 0.0
	_laundry_neglect_seconds = laundry_neglect_duration
	_prepare_forced_event(LAUNDRY_EVENT_ID)
	_mark_planned_event_started(LAUNDRY_EVENT_ID)
	if _audio_playback_allowed() and _washer_spin_player != null and not _washer_spin_player.playing:
		_washer_spin_player.play()
	state_changed.emit()


func force_child_encounter() -> void:
	if current_day < 6:
		current_day = 6
	child_state = CHILD_CRYING
	_child_seconds = child_response_seconds
	_prepare_forced_event(CHILD_EVENT_ID)
	_mark_planned_event_started(CHILD_EVENT_ID)
	state_changed.emit()


func force_blanket_child(scene_id := "room_108_bed_window") -> void:
	if current_day < 4:
		current_day = 4
	blanket_state = BLANKET_VISIBLE
	blanket_scene_id = scene_id
	_blanket_seconds = blanket_response_seconds
	_blanket_closed_seconds = 0.0
	_blanket_fatal_pending = false
	_blanket_death_seconds = 0.0
	_blanket_laugh_seconds = 1.2
	_prepare_forced_event(BLANKET_CHILD_EVENT_ID)
	_mark_planned_event_started(BLANKET_CHILD_EVENT_ID)
	state_changed.emit()


func begin_hand_action() -> bool:
	if child_state != CHILD_CRYING or eye_close_controller == null or not eye_close_controller.is_closed():
		return false
	if _child_song_held:
		return true
	_child_song_held = true
	if eye_close_controller.start_song(child_song_duration):
		hold_started.emit("horizontal", Vector2.ZERO)
		hold_progress_changed.emit(0.0)
		return true
	_child_song_held = false
	return false


func release_hand_action() -> void:
	if not _child_song_held:
		return
	_child_song_held = false
	if eye_close_controller != null:
		eye_close_controller.stop_song(false)
	hold_ended.emit()
	hold_progress_changed.emit(0.0)


func get_presentation_state() -> Dictionary:
	if laundry_state in [LAUNDRY_RED, LAUNDRY_MUSIC, LAUNDRY_READY]:
		return {
			"event_id": LAUNDRY_EVENT_ID,
			"state": laundry_state,
			"scene_id": "laundry_room",
		}
	if child_state in [CHILD_CRYING, CHILD_SONG_DONE]:
		return {
			"event_id": CHILD_EVENT_ID,
			"state": child_state,
			"scene_id": "room_106_bathroom",
		}
	if blanket_state == BLANKET_VISIBLE:
		return {
			"event_id": BLANKET_CHILD_EVENT_ID,
			"state": "visible",
			"scene_id": blanket_scene_id,
		}
	if room_109_passage_state in [ROOM_109_PASSAGE_WAITING, ROOM_109_PASSAGE_FOOTSTEPS]:
		return {
			"event_id": ROOM_109_PASSAGE_EVENT_ID,
			"state": room_109_passage_state,
			"scene_id": "corridor",
		}
	return {}


func export_state() -> Dictionary:
	return {
		"game_mode": game_mode,
		"current_day": current_day,
		"phone_ringing": phone_ringing,
		"phone_bell_count": phone_bell_count,
		"phone_seconds": _phone_seconds,
		"room_108_forbidden": room_108_forbidden,
		"laundry_state": laundry_state,
		"laundry_seconds": _laundry_seconds,
		"child_state": child_state,
		"child_seconds": _child_seconds,
		"laundry_neglect_seconds": _laundry_neglect_seconds,
		"laundry_fatal_pending": _laundry_fatal_pending,
		"phone_fatal_pending": _phone_fatal_pending,
		"phone_death_seconds": _phone_death_seconds,
		"phone_forbidden_seconds": _phone_forbidden_seconds,
		"blanket_state": blanket_state,
		"blanket_scene_id": blanket_scene_id,
		"blanket_seconds": _blanket_seconds,
		"blanket_closed_seconds": _blanket_closed_seconds,
		"blanket_fatal_pending": _blanket_fatal_pending,
		"blanket_death_seconds": _blanket_death_seconds,
		"blanket_laugh_seconds": _blanket_laugh_seconds,
		"room_109_passage_state": room_109_passage_state,
		"room_109_passage_seconds": _room_109_passage_seconds,
		"room_109_footstep_cue_seconds": _room_109_footstep_cue_seconds,
		"planned_event_id": _planned_event_id,
		"planned_event_started": _planned_event_started,
		"planned_event_completed": _planned_event_completed,
		"rng_state": _rng.state,
	}


func import_state(state: Dictionary) -> void:
	game_mode = GameMode.normalize(String(state.get("game_mode", game_mode)))
	current_day = maxi(int(state.get("current_day", current_day)), 1)
	phone_ringing = bool(state.get("phone_ringing", false))
	phone_bell_count = clampi(int(state.get("phone_bell_count", 0)), 0, PHONE_MAX_BELLS)
	_phone_seconds = float(state.get("phone_seconds", phone_initial_delay))
	room_108_forbidden = bool(state.get("room_108_forbidden", false))
	laundry_state = String(state.get("laundry_state", LAUNDRY_IDLE))
	_laundry_seconds = float(state.get("laundry_seconds", 0.0))
	child_state = String(state.get("child_state", CHILD_IDLE))
	_child_seconds = float(state.get("child_seconds", 0.0))
	_laundry_neglect_seconds = float(state.get("laundry_neglect_seconds", laundry_neglect_duration))
	_laundry_fatal_pending = bool(state.get("laundry_fatal_pending", false))
	_phone_fatal_pending = bool(state.get("phone_fatal_pending", false))
	_phone_death_seconds = float(state.get("phone_death_seconds", 0.0))
	_phone_forbidden_seconds = float(state.get("phone_forbidden_seconds", phone_forbidden_duration if room_108_forbidden else 0.0))
	_child_song_held = false
	blanket_state = String(state.get("blanket_state", BLANKET_IDLE))
	blanket_scene_id = String(state.get("blanket_scene_id", ""))
	_blanket_seconds = float(state.get("blanket_seconds", blanket_response_seconds))
	_blanket_closed_seconds = float(state.get("blanket_closed_seconds", 0.0))
	_blanket_fatal_pending = bool(state.get("blanket_fatal_pending", false))
	_blanket_death_seconds = float(state.get("blanket_death_seconds", 0.0))
	_blanket_laugh_seconds = float(state.get("blanket_laugh_seconds", 1.2))
	room_109_passage_state = String(state.get("room_109_passage_state", ROOM_109_PASSAGE_IDLE))
	_room_109_passage_seconds = float(state.get("room_109_passage_seconds", 0.0))
	_room_109_footstep_cue_seconds = float(state.get("room_109_footstep_cue_seconds", 0.0))
	_planned_event_id = String(state.get("planned_event_id", ""))
	_planned_event_started = bool(state.get("planned_event_started", false))
	_planned_event_completed = bool(state.get("planned_event_completed", _planned_event_id.is_empty()))
	if state.has("rng_state"):
		_rng.state = int(state["rng_state"])
	if laundry_state == LAUNDRY_MUSIC and _audio_playback_allowed() and _completion_music_player != null:
		_completion_music_player.play()
	if laundry_state in [LAUNDRY_WASHING, LAUNDRY_RED] and _audio_playback_allowed() and _washer_spin_player != null:
		_washer_spin_player.play()
	phone_bell_changed.emit(phone_bell_count if phone_ringing else 0, PHONE_MAX_BELLS)
	state_changed.emit()


func _advance_phone(delta: float) -> void:
	if game_mode == GameMode.STORY and current_day < 4:
		return
	if _phone_fatal_pending:
		_phone_death_seconds = maxf(_phone_death_seconds - delta, 0.0)
		if _phone_death_seconds <= 0.0:
			_phone_fatal_pending = false
			if lethal_outcomes_enabled:
				death_requested.emit(PHONE_EVENT_ID)
		return
	_phone_seconds -= delta
	if _phone_seconds > 0.0:
		return
	if not phone_ringing:
		phone_ringing = true
		phone_bell_count = 1
		_mark_planned_event_started(PHONE_EVENT_ID)
	else:
		phone_bell_count += 1
	phone_bell_changed.emit(phone_bell_count, PHONE_MAX_BELLS)
	if _audio_playback_allowed() and _phone_bell_player != null:
		_phone_bell_player.play()
	if phone_bell_count >= PHONE_MAX_BELLS:
		phone_ringing = false
		if lethal_outcomes_enabled:
			_phone_fatal_pending = true
			_phone_death_seconds = phone_death_delay
			sound_requested.emit("phone_pickup_laugh")
		else:
			phone_bell_count = 0
			_phone_seconds = phone_repeat_delay
			phone_bell_changed.emit(0, PHONE_MAX_BELLS)
			state_changed.emit()
		return
	_phone_seconds = phone_bell_interval


func _answer_phone() -> bool:
	if not phone_ringing:
		return false
	phone_ringing = false
	phone_bell_count = 0
	_phone_seconds = 0.0
	room_108_forbidden = true
	_phone_forbidden_seconds = phone_forbidden_duration
	_phone_fatal_pending = false
	phone_bell_changed.emit(0, PHONE_MAX_BELLS)
	dialogue_requested.emit("night.phone.room_108_repair_call")
	state_changed.emit()
	return true


func _advance_laundry(delta: float) -> void:
	if laundry_state == LAUNDRY_RED:
		_laundry_neglect_seconds = maxf(_laundry_neglect_seconds - delta, 0.0)
		if _laundry_neglect_seconds <= 0.0:
			laundry_state = LAUNDRY_MUSIC
			_laundry_fatal_pending = true
			_laundry_seconds = laundry_music_duration + laundry_post_music_death_delay
			if _washer_spin_player != null:
				_washer_spin_player.stop()
			if _audio_playback_allowed() and _completion_music_player != null:
				_completion_music_player.play()
			state_changed.emit()
		return
	if laundry_state == LAUNDRY_MUSIC and _laundry_fatal_pending:
		_laundry_seconds = maxf(_laundry_seconds - delta, 0.0)
		if _laundry_seconds <= 0.0 and lethal_outcomes_enabled:
			_laundry_fatal_pending = false
			death_requested.emit(LAUNDRY_EVENT_ID)
		return
	if laundry_state != LAUNDRY_WASHING:
		return
	_laundry_seconds -= delta
	if _laundry_seconds > 0.0:
		return
	laundry_state = LAUNDRY_RED
	_laundry_neglect_seconds = laundry_neglect_duration
	state_changed.emit()


func _handle_washer() -> bool:
	match laundry_state:
		LAUNDRY_WASHING:
			return true
		LAUNDRY_RED:
			laundry_state = LAUNDRY_MUSIC
			_laundry_fatal_pending = false
			_laundry_seconds = laundry_music_duration
			if _washer_spin_player != null:
				_washer_spin_player.stop()
			if _audio_playback_allowed() and _completion_music_player != null:
				_completion_music_player.play()
			state_changed.emit()
			return true
		LAUNDRY_MUSIC:
			if lethal_outcomes_enabled:
				death_requested.emit(LAUNDRY_EVENT_ID)
			return true
		LAUNDRY_READY:
			if lethal_outcomes_enabled and (eye_close_controller == null or not eye_close_controller.is_closed()):
				death_requested.emit(LAUNDRY_EVENT_ID)
				return true
			laundry_state = LAUNDRY_DISCARDED
			_complete_planned_event(LAUNDRY_EVENT_ID)
			state_changed.emit()
			return true
	return false


func _on_completion_music_finished() -> void:
	if laundry_state != LAUNDRY_MUSIC:
		return
	if _laundry_fatal_pending:
		return
	laundry_state = LAUNDRY_READY
	_laundry_seconds = 0.0
	state_changed.emit()


func _audio_playback_allowed() -> bool:
	return DisplayServer.get_name() != "headless"


func _advance_child(delta: float) -> void:
	if child_state == CHILD_WAITING:
		_child_seconds -= delta
		if _child_seconds <= 0.0:
			force_child_encounter()
	elif child_state == CHILD_CRYING:
		if eye_close_controller != null and eye_close_controller.is_song_active():
			var remaining: float = eye_close_controller.get_song_seconds_remaining()
			hold_progress_changed.emit(clampf(1.0 - remaining / child_song_duration, 0.0, 1.0))
			return
		_child_seconds -= delta
		if _child_seconds <= 0.0:
			if lethal_outcomes_enabled:
				death_requested.emit(CHILD_EVENT_ID)
			else:
				_child_seconds = child_response_seconds


func _on_eye_closed_changed(closed: bool) -> void:
	if not closed and _child_song_held:
		release_hand_action()
	state_changed.emit()


func _on_song_completed() -> void:
	if child_state != CHILD_CRYING:
		return
	_child_song_held = false
	hold_progress_changed.emit(1.0)
	hold_ended.emit()
	child_state = CHILD_SONG_DONE
	_child_seconds = 0.0
	state_changed.emit()


func _on_song_interrupted() -> void:
	_child_song_held = false
	hold_progress_changed.emit(0.0)
	hold_ended.emit()


func _advance_blanket(delta: float) -> void:
	if _blanket_fatal_pending:
		_blanket_death_seconds = maxf(_blanket_death_seconds - delta, 0.0)
		if _blanket_death_seconds <= 0.0 and lethal_outcomes_enabled:
			_blanket_fatal_pending = false
			death_requested.emit(BLANKET_CHILD_EVENT_ID)
		return
	_blanket_laugh_seconds -= delta
	if _blanket_laugh_seconds <= 0.0:
		var danger_progress := 1.0 - clampf(_blanket_seconds / blanket_response_seconds, 0.0, 1.0)
		sound_requested.emit("blanket_laugh_distorted" if danger_progress >= 0.58 else "blanket_laugh_soft")
		_blanket_laugh_seconds = 2.6
	var eyes_closed_here: bool = (
		current_scene_id == blanket_scene_id
		and eye_close_controller != null
		and eye_close_controller.is_closed()
	)
	if eyes_closed_here:
		if _blanket_closed_seconds <= 0.0:
			hold_started.emit("horizontal", Vector2.ZERO)
		_blanket_closed_seconds = minf(_blanket_closed_seconds + delta, blanket_eye_close_duration)
		hold_progress_changed.emit(_blanket_closed_seconds / blanket_eye_close_duration)
		if _blanket_closed_seconds >= blanket_eye_close_duration:
			blanket_state = BLANKET_RESOLVED
			hold_ended.emit()
			_complete_planned_event(BLANKET_CHILD_EVENT_ID)
			state_changed.emit()
		return
	if _blanket_closed_seconds > 0.0:
		_blanket_closed_seconds = 0.0
		hold_progress_changed.emit(0.0)
		hold_ended.emit()
	_blanket_seconds = maxf(_blanket_seconds - delta, 0.0)
	if _blanket_seconds <= 0.0:
		sound_requested.emit("blanket_found_japanese")
		_blanket_fatal_pending = true
		_blanket_death_seconds = blanket_death_delay


func _advance_room_109_passage(delta: float) -> void:
	_room_109_passage_seconds = maxf(_room_109_passage_seconds - delta, 0.0)
	if room_109_passage_state == ROOM_109_PASSAGE_WAITING:
		if _room_109_passage_seconds <= 0.0:
			room_109_passage_state = ROOM_109_PASSAGE_FOOTSTEPS
			_room_109_passage_seconds = room_109_passage_footstep_seconds
			_room_109_footstep_cue_seconds = 0.0
			state_changed.emit()
		return
	_room_109_footstep_cue_seconds -= delta
	if _room_109_footstep_cue_seconds <= 0.0:
		sound_requested.emit("room_109_passing_footstep")
		_room_109_footstep_cue_seconds = 0.72
	if _room_109_passage_seconds <= 0.0:
		room_109_passage_state = ROOM_109_PASSAGE_DONE
		_complete_planned_event(ROOM_109_PASSAGE_EVENT_ID)
		state_changed.emit()


func _hold_child() -> bool:
	if child_state != CHILD_SONG_DONE:
		return false
	child_state = CHILD_HELD
	_complete_planned_event(CHILD_EVENT_ID)
	state_changed.emit()
	return true


func is_daily_schedule_complete() -> bool:
	return _planned_event_completed


func get_planned_event_id() -> String:
	return _planned_event_id


func set_random_seed(seed: int) -> void:
	_random_seed_override = seed
	_rng.seed = seed


func _eligible_daily_events() -> Array[String]:
	if game_mode == GameMode.INFINITY:
		return [
			CLOSET_PIG_EVENT_ID,
			PHONE_EVENT_ID,
			LAUNDRY_EVENT_ID,
			CHILD_EVENT_ID,
			BLANKET_CHILD_EVENT_ID,
		]
	var story_event_id := String(STORY_PRIMARY_EVENT_BY_DAY.get(current_day, ""))
	var eligible: Array[String] = []
	if not story_event_id.is_empty():
		eligible.append(story_event_id)
	return eligible


func _pick_daily_event() -> String:
	var eligible := _eligible_daily_events()
	if eligible.is_empty():
		return ""
	return eligible[_rng.randi_range(0, eligible.size() - 1)]


func _can_start_planned_event(event_id: String) -> bool:
	return (
		_planned_event_id == event_id
		and not _planned_event_started
		and not _planned_event_completed
		and not has_active_anomaly()
	)


func notify_external_planned_event_started(event_id: String) -> bool:
	if _planned_event_id != event_id or _planned_event_completed:
		return false
	_planned_event_started = true
	state_changed.emit()
	return true


func notify_external_planned_event_completed(event_id: String) -> bool:
	if _planned_event_id != event_id or _planned_event_completed:
		return false
	_planned_event_started = true
	_planned_event_completed = true
	event_survived.emit(event_id)
	state_changed.emit()
	return true


func _prepare_forced_event(event_id: String) -> void:
	if _planned_event_id != event_id:
		_planned_event_id = event_id
		_planned_event_started = false
		_planned_event_completed = false


func _mark_planned_event_started(event_id: String) -> void:
	if _planned_event_id != event_id:
		_prepare_forced_event(event_id)
	if _planned_event_started:
		return
	_planned_event_started = true
	event_started.emit(event_id)


func _complete_planned_event(event_id: String) -> void:
	if _planned_event_id != event_id:
		return
	_planned_event_started = true
	_planned_event_completed = true
	event_survived.emit(event_id)


func _make_completion_music() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := laundry_music_duration
	var samples := int(mix_rate * duration)
	var notes := [523.25, 659.25, 783.99, 659.25, 523.25, 392.0, 523.25]
	var data := PackedByteArray()
	data.resize(samples * 2)
	for index in range(samples):
		var time := float(index) / float(mix_rate)
		var note_index := mini(int(time / (duration / notes.size())), notes.size() - 1)
		var local_time := fmod(time, duration / notes.size())
		var envelope := exp(-local_time * 3.2)
		var value := sin(TAU * float(notes[note_index]) * time) * envelope * 0.22
		data.encode_s16(index * 2, clampi(int(value * 32767.0), -32768, 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = data
	return stream


func _make_phone_bell() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 0.72
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for index in range(samples):
		var time := float(index) / float(mix_rate)
		var envelope := exp(-time * 2.6) * (0.82 + sin(TAU * 7.0 * time) * 0.18)
		var ring := sin(TAU * 440.0 * time) * 0.52 + sin(TAU * 480.0 * time) * 0.48
		data.encode_s16(index * 2, clampi(int(ring * envelope * 7200.0), -32768, 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = data
	return stream


func _make_washer_spin() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 1.8
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for index in samples:
		var time := float(index) / float(mix_rate)
		var motor := sin(TAU * 54.0 * time) * 0.42 + sin(TAU * 108.0 * time) * 0.18
		var drum := sin(TAU * 1.65 * time) * sin(TAU * 76.0 * time) * 0.20
		data.encode_s16(index * 2, clampi(int((motor + drum) * 7800.0), -32768, 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = samples
	return stream
