class_name HotelAnomalyAudioController
extends Node

const BUS_NAME := "Anomaly"
const ONE_SHOT_PLAYER_COUNT := 4
const BLANKET_FOUND_VOICE_PATH := "res://resource/sounds/anomalies/blanket_found_ja.ogg"
const BABY_WALLPAPER_CRY_PATH := "res://resource/sounds/anomalies/baby_wallpaper_cry.ogg"
const BLANKET_LAUGH_SOFT_PATH := "res://resource/sounds/anomalies/blanket_child_laugh_soft.ogg"
const BLANKET_LAUGH_DISTORTED_PATH := "res://resource/sounds/anomalies/blanket_child_laugh_distorted.ogg"
const SHOWER_CURTAIN_MOVE_PATH := "res://resource/sounds/anomalies/shower_curtain_move.ogg"
const CURTAIN_LEGS_REVEAL_PATH := "res://resource/sounds/anomalies/curtain_legs_reveal.ogg"
const SHADOW_FOOTSTEP_SEQUENCE_PATH := "res://resource/sounds/anomalies/shadow_footstep_sequence.ogg"
const FRONT_GLASS_FACE_BARN_OWL_PATH := "res://resource/sounds/anomalies/front_glass_face_barn_owl_call.ogg"
const FRONT_GLASS_FACE_BARN_OWL_DISTORTED_PATH := "res://resource/sounds/anomalies/front_glass_face_barn_owl_call_distorted.ogg"

var _players: Array[AudioStreamPlayer] = []
var _loop_player: AudioStreamPlayer
var _shadow_heartbeat_player: AudioStreamPlayer
var _shadow_heartbeat_active := false
var _cue_cache: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_ensure_bus()
	for _index in ONE_SHOT_PLAYER_COUNT:
		var player := AudioStreamPlayer.new()
		player.bus = BUS_NAME
		add_child(player)
		_players.append(player)
	_loop_player = AudioStreamPlayer.new()
	_loop_player.bus = BUS_NAME
	add_child(_loop_player)
	_shadow_heartbeat_player = AudioStreamPlayer.new()
	_shadow_heartbeat_player.bus = BUS_NAME
	add_child(_shadow_heartbeat_player)


func _exit_tree() -> void:
	stop_loop()
	set_shadow_heartbeat_active(false)
	for player in _players:
		player.stop()
		player.stream = null
	_players.clear()
	_cue_cache.clear()


func play_cue(cue_id: String) -> void:
	if cue_id.is_empty() or not _audio_playback_allowed():
		return
	var player := _available_player()
	player.stop()
	player.stream = _stream_for_cue(cue_id)
	player.volume_db = _volume_for_cue(cue_id)
	player.play()


func start_hell_mirror_loop() -> void:
	if not _audio_playback_allowed() or _loop_player == null:
		return
	_loop_player.stop()
	_loop_player.stream = _make_soul_scream_stream(3.6, true)
	_loop_player.volume_db = -28.0
	_loop_player.play()


func set_hell_mirror_intensity(progress: float) -> void:
	if _loop_player == null:
		return
	_loop_player.volume_db = lerpf(-28.0, -10.0, clampf(progress, 0.0, 1.0))
	_loop_player.pitch_scale = lerpf(0.86, 1.04, clampf(progress, 0.0, 1.0))


func stop_loop() -> void:
	if _loop_player != null:
		_loop_player.stop()
		_loop_player.stream = null


func set_shadow_heartbeat_active(active: bool) -> void:
	_shadow_heartbeat_active = active
	if _shadow_heartbeat_player == null:
		return
	if not active:
		_shadow_heartbeat_player.stop()
		_shadow_heartbeat_player.stream = null
		return
	if _shadow_heartbeat_player.stream == null:
		_shadow_heartbeat_player.stream = _make_heartbeat_stream()
		_shadow_heartbeat_player.volume_db = -7.0
	if _audio_playback_allowed() and not _shadow_heartbeat_player.playing:
		_shadow_heartbeat_player.play()


func is_shadow_heartbeat_active() -> bool:
	return _shadow_heartbeat_active


func _available_player() -> AudioStreamPlayer:
	for player in _players:
		if not player.playing:
			return player
	return _players[0]


func _stream_for_cue(cue_id: String) -> AudioStream:
	if _cue_cache.has(cue_id):
		return _cue_cache[cue_id]
	var stream: AudioStream
	match cue_id:
		"desk_bell", "desk_bell_echo":
			stream = _make_bell_stream()
		"baby_short_cry":
			stream = _load_optional_stream(BABY_WALLPAPER_CRY_PATH)
			if stream == null:
				stream = _make_cry_stream()
		"shower_curtain_move":
			stream = _load_optional_stream(SHOWER_CURTAIN_MOVE_PATH)
			if stream == null:
				stream = _make_door_stream()
		"curtain_legs_reveal":
			stream = _load_optional_stream(CURTAIN_LEGS_REVEAL_PATH)
			if stream == null:
				stream = _make_sting_stream()
		"girl_visit_laugh":
			stream = _make_laugh_stream()
		"pig_squeal":
			stream = _make_pig_squeal_stream()
		"closet_door_close":
			stream = _make_door_stream()
		"phone_pickup_laugh":
			stream = _make_laugh_stream()
		"washer_small_scream":
			stream = _make_cry_stream()
		"blanket_found_japanese":
			stream = _load_optional_stream(BLANKET_FOUND_VOICE_PATH)
			if stream == null:
				stream = _make_found_voice_proxy_stream()
		"blanket_laugh_soft":
			stream = _load_optional_stream(BLANKET_LAUGH_SOFT_PATH)
			if stream == null:
				stream = _make_laugh_stream()
		"blanket_laugh_distorted":
			stream = _load_optional_stream(BLANKET_LAUGH_DISTORTED_PATH)
			if stream == null:
				stream = _make_soul_scream_stream(1.2, false)
		"soul_scream":
			stream = _make_soul_scream_stream(2.2, false)
		"shadow_scream":
			stream = _make_soul_scream_stream(1.15, false)
		"tv_static_rise":
			stream = _make_noise_stream(0.20, false)
		"footstep_echo":
			stream = _load_optional_stream(SHADOW_FOOTSTEP_SEQUENCE_PATH)
			if stream == null:
				stream = _make_thump_stream()
		"glass_face_barn_owl_call":
			stream = _load_optional_stream(FRONT_GLASS_FACE_BARN_OWL_PATH)
			if stream == null:
				stream = _make_sting_stream()
		"glass_face_barn_owl_call_distorted":
			stream = _load_optional_stream(FRONT_GLASS_FACE_BARN_OWL_DISTORTED_PATH)
			if stream == null:
				stream = _make_sting_stream()
		"door_echo":
			stream = _make_door_stream()
		"room_109_passing_footstep":
			stream = _make_thump_stream()
		"bathtub_drain":
			stream = _make_bathtub_drain_stream()
		"hell_mirror_washer_destroy":
			stream = _make_hell_mirror_washer_stream()
		_:
			stream = _make_sting_stream()
	_cue_cache[cue_id] = stream
	return stream


func _load_optional_stream(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as AudioStream


func _volume_for_cue(cue_id: String) -> float:
	match cue_id:
		"soul_scream":
			return -7.0
		"shadow_scream":
			return -4.0
		"baby_short_cry":
			return -11.0
		"shower_curtain_move":
			return -8.0
		"curtain_legs_reveal":
			return -7.0
		"blanket_laugh_soft":
			return -7.0
		"blanket_laugh_distorted":
			return -6.0
		"footstep_echo":
			return -9.0
		"tv_static_rise":
			return -17.0
		"girl_visit_laugh":
			return -10.0
		"pig_squeal":
			return -6.0
		"glass_face_barn_owl_call":
			return 0.0
		"glass_face_barn_owl_call_distorted":
			return 0.0
		"closet_door_close":
			return -7.0
		"bathtub_drain":
			return -5.0
		"hell_mirror_washer_destroy":
			return -6.0
	return -9.0


func _make_pig_squeal_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 1.55
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	var noise_state := 0x51A7C3
	var phase := 0.0
	for index in samples:
		var time := float(index) / mix_rate
		var progress := time / duration
		var pitch_curve := pow(progress, 0.72)
		var frequency := lerpf(720.0, 185.0, pitch_curve)
		frequency += sin(TAU * 5.6 * time) * lerpf(95.0, 28.0, progress)
		phase += TAU * frequency / mix_rate
		noise_state = int((noise_state * 1664525 + 1013904223) & 0x7fffffff)
		var noise := (float(noise_state) / 1073741824.0) - 1.0
		var voice := sin(phase) * 0.52 + sin(phase * 2.03) * 0.26 + sin(phase * 0.51) * 0.12
		var rasp := noise * (0.20 + absf(sin(phase)) * 0.18)
		var pulse := 0.62 + sin(TAU * 9.0 * time) * 0.18 + sin(TAU * 14.0 * time) * 0.10
		var attack := smoothstep(0.0, 0.045, time)
		var release := 1.0 - smoothstep(duration - 0.32, duration, time)
		var value := (voice + rasp) * pulse * attack * release * 0.58
		data.encode_s16(index * 2, clampi(int(value * 32767.0), -32768, 32767))
	return _make_wav(data, mix_rate, false)


func _make_bathtub_drain_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 4.4
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	var noise_state := 0x4D3A2B1C
	var smoothed_noise := 0.0
	for index in samples:
		var time := float(index) / mix_rate
		noise_state = int((noise_state * 1103515245 + 12345) & 0x7fffffff)
		var noise := (float(noise_state) / 1073741824.0) - 1.0
		smoothed_noise = lerpf(smoothed_noise, noise, 0.075)
		var flow_envelope := (1.0 - smoothstep(duration - 0.8, duration, time)) * minf(time / 0.18, 1.0)
		var gurgle_rate := lerpf(3.2, 8.6, time / duration)
		var gurgle := sin(TAU * gurgle_rate * time + sin(TAU * 0.47 * time) * 2.4)
		var pipe := sin(TAU * 83.0 * time + gurgle * 0.7) * 0.16
		var value := (smoothed_noise * 0.62 + gurgle * 0.22 + pipe) * flow_envelope
		data.encode_s16(index * 2, clampi(int(value * 16500.0), -32768, 32767))
	return _make_wav(data, mix_rate, false)


func _make_hell_mirror_washer_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 3.8
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	var noise_state := 0x1327A95
	for index in samples:
		var time := float(index) / mix_rate
		noise_state = int((noise_state * 1664525 + 1013904223) & 0x7fffffff)
		var noise := (float(noise_state) / 1073741824.0) - 1.0
		var motor_ramp := smoothstep(0.0, 1.1, time)
		var motor := sin(TAU * lerpf(38.0, 71.0, motor_ramp) * time) * 0.34
		var drum := sin(TAU * 2.1 * time) * sin(TAU * 94.0 * time) * 0.15
		var crack_time := fmod(time, 0.43)
		var crack := noise * exp(-crack_time * 38.0) * (0.34 if time > 1.25 else 0.0)
		var trapped_voice := sin(TAU * (310.0 + sin(TAU * 1.7 * time) * 90.0) * time) * exp(-maxf(time - 2.0, 0.0) * 2.2) * 0.08
		var value := (motor + drum + crack + trapped_voice) * minf(time / 0.08, 1.0)
		data.encode_s16(index * 2, clampi(int(value * 15000.0), -32768, 32767))
	return _make_wav(data, mix_rate, false)


func _ensure_bus() -> void:
	if AudioServer.get_bus_index(BUS_NAME) >= 0:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_NAME)


func _make_bell_stream() -> AudioStreamWAV:
	return _make_tone_stream(0.44, [784.0, 1174.0], 0.38, 6.8)


func _make_heartbeat_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 1.02
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for index in samples:
		var time := float(index) / mix_rate
		var first_pulse := _heartbeat_pulse(time, 0.10, 0.042)
		var second_pulse := _heartbeat_pulse(time, 0.31, 0.052) * 0.72
		var value := (first_pulse + second_pulse) * sin(TAU * 58.0 * time)
		data.encode_s16(index * 2, clampi(int(value * 16500.0), -32768, 32767))
	return _make_wav(data, mix_rate, true)


func _heartbeat_pulse(time: float, center: float, width: float) -> float:
	var distance := (time - center) / width
	return exp(-distance * distance * 2.6)


func _make_cry_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 0.72
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for index in samples:
		var time := float(index) / mix_rate
		var sweep := lerpf(710.0, 390.0, time / duration) + sin(TAU * 6.7 * time) * 55.0
		var envelope := sin(PI * clampf(time / duration, 0.0, 1.0))
		var value := (sin(TAU * sweep * time) * 0.55 + sin(TAU * sweep * 2.03 * time) * 0.20) * envelope
		data.encode_s16(index * 2, clampi(int(value * 13500.0), -32768, 32767))
	return _make_wav(data, mix_rate, false)


func _make_sting_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 0.55
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5171
	for index in samples:
		var time := float(index) / mix_rate
		var envelope := exp(-time * 4.4)
		var noise := rng.randf_range(-1.0, 1.0)
		var value := (noise * 0.32 + sin(TAU * (930.0 - time * 720.0) * time) * 0.68) * envelope
		data.encode_s16(index * 2, clampi(int(value * 16000.0), -32768, 32767))
	return _make_wav(data, mix_rate, false)


func _make_laugh_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 1.45
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for index in samples:
		var time := float(index) / mix_rate
		var pulse := pow(maxf(sin(TAU * 3.2 * time), 0.0), 2.2)
		var pitch := 390.0 + sin(TAU * 2.1 * time) * 82.0
		var value := (sin(TAU * pitch * time) * 0.52 + sin(TAU * pitch * 1.97 * time) * 0.18) * pulse
		data.encode_s16(index * 2, clampi(int(value * 11800.0), -32768, 32767))
	return _make_wav(data, mix_rate, false)


func _make_soul_scream_stream(duration: float, looped: bool) -> AudioStreamWAV:
	var mix_rate := 22050
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 9901
	for index in samples:
		var time := float(index) / mix_rate
		var envelope := 0.74 if looped else sin(PI * clampf(time / duration, 0.0, 1.0))
		var pitch := 520.0 + sin(TAU * 0.83 * time) * 170.0
		var rasp := rng.randf_range(-1.0, 1.0) * 0.18
		var value := (sin(TAU * pitch * time) * 0.45 + sin(TAU * pitch * 2.4 * time) * 0.21 + rasp) * envelope
		data.encode_s16(index * 2, clampi(int(value * 12000.0), -32768, 32767))
	return _make_wav(data, mix_rate, looped)


func _make_noise_stream(duration: float, looped: bool) -> AudioStreamWAV:
	var mix_rate := 22050
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1423
	for index in samples:
		var value := rng.randf_range(-1.0, 1.0) * 0.42
		data.encode_s16(index * 2, clampi(int(value * 12500.0), -32768, 32767))
	return _make_wav(data, mix_rate, looped)


func _make_thump_stream() -> AudioStreamWAV:
	return _make_tone_stream(0.32, [62.0, 89.0], 0.62, 9.0)


func _make_door_stream() -> AudioStreamWAV:
	return _make_tone_stream(0.62, [74.0, 121.0, 181.0], 0.45, 3.6)


func _make_found_voice_proxy_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 1.55
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for index in samples:
		var time := float(index) / mix_rate
		var syllable := int(time / 0.26)
		var local_time := fmod(time, 0.26)
		var pitches := [330.0, 390.0, 440.0, 365.0, 510.0, 420.0]
		var pitch: float = pitches[mini(syllable, pitches.size() - 1)]
		var envelope := sin(PI * clampf(local_time / 0.26, 0.0, 1.0))
		var value := (sin(TAU * pitch * time) * 0.52 + sin(TAU * pitch * 2.02 * time) * 0.18) * envelope
		data.encode_s16(index * 2, clampi(int(value * 12500.0), -32768, 32767))
	return _make_wav(data, mix_rate, false)


func _make_tone_stream(duration: float, frequencies: Array[float], amplitude: float, decay: float) -> AudioStreamWAV:
	var mix_rate := 22050
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for index in samples:
		var time := float(index) / mix_rate
		var value := 0.0
		for frequency in frequencies:
			value += sin(TAU * frequency * time)
		value = value / frequencies.size() * amplitude * exp(-time * decay)
		data.encode_s16(index * 2, clampi(int(value * 32767.0), -32768, 32767))
	return _make_wav(data, mix_rate, false)


func _make_wav(data: PackedByteArray, mix_rate: int, looped: bool) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = data
	if looped:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = data.size() / 2
	return stream


func _audio_playback_allowed() -> bool:
	return DisplayServer.get_name() != "headless"
