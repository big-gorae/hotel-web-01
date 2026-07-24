class_name HotelNightAnomalyDirector
extends Node

signal dialogue_requested(message: String)
signal death_requested(event_id: String)
signal phone_bell_changed(count: int, maximum: int)
signal state_changed
signal event_survived(event_id: String)

const PHONE_MAX_BELLS := 13
const PHONE_EVENT_ID := "room_108_light_repair_call"
const ROOM_109_EVENT_ID := "room_109_open_door"
const LAUNDRY_EVENT_ID := "laundry_red_washer"
const CHILD_EVENT_ID := "room_106_abandoned_child"

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

var phone_initial_delay := 24.0
var phone_repeat_delay := 58.0
var phone_bell_interval := 1.15
var laundry_red_delay := 9.0
var laundry_music_duration := 7.0
var child_appearance_delay := 7.0
var child_response_seconds := 6.0
var child_song_duration := 6.5

var current_day := 1
var current_scene_id := ""
var eye_close_controller = null
var lethal_outcomes_enabled := true

var phone_ringing := false
var phone_bell_count := 0
var room_108_forbidden := false
var laundry_state := LAUNDRY_IDLE
var child_state := CHILD_IDLE

var _phone_seconds := 0.0
var _laundry_seconds := 0.0
var _child_seconds := 0.0
var _completion_music_player: AudioStreamPlayer
var _phone_bell_player: AudioStreamPlayer


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


func _exit_tree() -> void:
	for player in [_completion_music_player, _phone_bell_player]:
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


func start_day(day: int) -> void:
	current_day = maxi(day, 1)
	phone_ringing = false
	phone_bell_count = 0
	room_108_forbidden = false
	laundry_state = LAUNDRY_IDLE
	child_state = CHILD_IDLE
	_phone_seconds = phone_initial_delay
	_laundry_seconds = 0.0
	_child_seconds = 0.0
	if _completion_music_player != null:
		_completion_music_player.stop()
	phone_bell_changed.emit(0, PHONE_MAX_BELLS)
	state_changed.emit()


func enter_scene(scene_id: String) -> void:
	current_scene_id = scene_id
	if current_day >= 5 and scene_id == "laundry_room" and laundry_state == LAUNDRY_IDLE:
		laundry_state = LAUNDRY_WASHING
		_laundry_seconds = laundry_red_delay
		dialogue_requested.emit("The second washer is already running.")
		state_changed.emit()
	if current_day >= 6 and scene_id == "room_106_bathroom" and child_state == CHILD_IDLE:
		child_state = CHILD_WAITING
		_child_seconds = child_appearance_delay
		state_changed.emit()


func advance(delta: float) -> void:
	if delta <= 0.0:
		return
	_advance_phone(delta)
	_advance_laundry(delta)
	_advance_child(delta)


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
	return false


func get_dynamic_hotspots(scene_id: String) -> Array:
	var hotspots := []
	if current_day >= 3 and scene_id == "corridor":
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
	return hotspots


func is_scene_anomalous(scene_id: String) -> bool:
	if scene_id == "laundry_room" and laundry_state in [LAUNDRY_RED, LAUNDRY_MUSIC, LAUNDRY_READY]:
		return true
	if scene_id == "room_106_bathroom" and child_state in [CHILD_CRYING, CHILD_SONG_DONE]:
		return true
	if room_108_forbidden and scene_id.begins_with("room_108"):
		return true
	return false


func force_phone_ring() -> void:
	if current_day < 4:
		current_day = 4
	phone_ringing = true
	phone_bell_count = 0
	_phone_seconds = 0.0
	phone_bell_changed.emit(0, PHONE_MAX_BELLS)
	state_changed.emit()


func force_red_laundry() -> void:
	if current_day < 5:
		current_day = 5
	laundry_state = LAUNDRY_RED
	_laundry_seconds = 0.0
	state_changed.emit()


func force_child_encounter() -> void:
	if current_day < 6:
		current_day = 6
	child_state = CHILD_CRYING
	_child_seconds = child_response_seconds
	dialogue_requested.emit("A child is crying in the bathroom. Do not leave.")
	state_changed.emit()
	if eye_close_controller != null and eye_close_controller.is_closed():
		eye_close_controller.start_song(child_song_duration)


func export_state() -> Dictionary:
	return {
		"current_day": current_day,
		"phone_ringing": phone_ringing,
		"phone_bell_count": phone_bell_count,
		"phone_seconds": _phone_seconds,
		"room_108_forbidden": room_108_forbidden,
		"laundry_state": laundry_state,
		"laundry_seconds": _laundry_seconds,
		"child_state": child_state,
		"child_seconds": _child_seconds,
	}


func import_state(state: Dictionary) -> void:
	current_day = maxi(int(state.get("current_day", current_day)), 1)
	phone_ringing = bool(state.get("phone_ringing", false))
	phone_bell_count = clampi(int(state.get("phone_bell_count", 0)), 0, PHONE_MAX_BELLS)
	_phone_seconds = float(state.get("phone_seconds", phone_initial_delay))
	room_108_forbidden = bool(state.get("room_108_forbidden", false))
	laundry_state = String(state.get("laundry_state", LAUNDRY_IDLE))
	_laundry_seconds = float(state.get("laundry_seconds", 0.0))
	child_state = String(state.get("child_state", CHILD_IDLE))
	_child_seconds = float(state.get("child_seconds", 0.0))
	if laundry_state == LAUNDRY_MUSIC and _audio_playback_allowed() and _completion_music_player != null:
		_completion_music_player.play()
	phone_bell_changed.emit(phone_bell_count if phone_ringing else 0, PHONE_MAX_BELLS)
	state_changed.emit()


func _advance_phone(delta: float) -> void:
	if current_day < 4:
		return
	_phone_seconds -= delta
	if _phone_seconds > 0.0:
		return
	if not phone_ringing:
		phone_ringing = true
		phone_bell_count = 1
		dialogue_requested.emit("The front desk phone is ringing.")
	else:
		phone_bell_count += 1
	phone_bell_changed.emit(phone_bell_count, PHONE_MAX_BELLS)
	if _audio_playback_allowed() and _phone_bell_player != null:
		_phone_bell_player.play()
	if phone_bell_count >= PHONE_MAX_BELLS:
		phone_ringing = false
		if lethal_outcomes_enabled:
			death_requested.emit(PHONE_EVENT_ID)
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
	_phone_seconds = phone_repeat_delay
	room_108_forbidden = true
	phone_bell_changed.emit(0, PHONE_MAX_BELLS)
	dialogue_requested.emit("Room 108. The light is out. Come repair it. The line goes dead.")
	state_changed.emit()
	return true


func _advance_laundry(delta: float) -> void:
	if laundry_state != LAUNDRY_WASHING:
		return
	_laundry_seconds -= delta
	if _laundry_seconds > 0.0:
		return
	laundry_state = LAUNDRY_RED
	dialogue_requested.emit("The washer glass has turned red.")
	state_changed.emit()


func _handle_washer() -> bool:
	match laundry_state:
		LAUNDRY_WASHING:
			dialogue_requested.emit("The washer is still running.")
			return true
		LAUNDRY_RED:
			laundry_state = LAUNDRY_MUSIC
			_laundry_seconds = laundry_music_duration
			if _audio_playback_allowed() and _completion_music_player != null:
				_completion_music_player.play()
			dialogue_requested.emit("The washer stops. Its completion music begins.")
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
			dialogue_requested.emit("Without looking, you discard the entire load.")
			event_survived.emit(LAUNDRY_EVENT_ID)
			state_changed.emit()
			return true
	return false


func _on_completion_music_finished() -> void:
	if laundry_state != LAUNDRY_MUSIC:
		return
	laundry_state = LAUNDRY_READY
	_laundry_seconds = 0.0
	dialogue_requested.emit("The completion music ends. The red laundry is still inside.")
	state_changed.emit()


func _audio_playback_allowed() -> bool:
	return DisplayServer.get_name() != "headless"


func _advance_child(delta: float) -> void:
	if child_state == CHILD_WAITING:
		_child_seconds -= delta
		if _child_seconds <= 0.0:
			force_child_encounter()
	elif child_state == CHILD_CRYING and (eye_close_controller == null or not eye_close_controller.is_song_active()):
		_child_seconds -= delta
		if _child_seconds <= 0.0:
			if lethal_outcomes_enabled:
				death_requested.emit(CHILD_EVENT_ID)
			else:
				_child_seconds = child_response_seconds


func _on_eye_closed_changed(closed: bool) -> void:
	if closed and child_state == CHILD_CRYING and eye_close_controller != null:
		if eye_close_controller.start_song(child_song_duration):
			dialogue_requested.emit("You begin to sing.")
	state_changed.emit()


func _on_song_completed() -> void:
	if child_state != CHILD_CRYING:
		return
	child_state = CHILD_SONG_DONE
	_child_seconds = 0.0
	dialogue_requested.emit("The child stops crying. It reaches toward you.")
	state_changed.emit()


func _on_song_interrupted() -> void:
	if lethal_outcomes_enabled and child_state == CHILD_CRYING:
		death_requested.emit(CHILD_EVENT_ID)


func _hold_child() -> bool:
	if child_state != CHILD_SONG_DONE:
		return false
	child_state = CHILD_HELD
	dialogue_requested.emit("You hold the child gently until the bathroom is silent.")
	event_survived.emit(CHILD_EVENT_ID)
	state_changed.emit()
	return true


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
