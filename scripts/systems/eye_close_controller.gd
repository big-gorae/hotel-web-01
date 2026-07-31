class_name HotelEyeCloseController
extends Control

signal closed_changed(closed: bool)
signal song_started(duration: float)
signal song_completed
signal song_interrupted

const EyeCloseProfile := preload("res://scripts/systems/eye_close_profile.gd")

var profile = EyeCloseProfile.new()
var anomaly_context := false
var debug_radius_override := -1.0

var _closed := false
var _song_active := false
var _song_seconds_remaining := 0.0
var _mask: ColorRect
var _mask_material: ShaderMaterial
var _heartbeat_player: AudioStreamPlayer
var _breathing_player: AudioStreamPlayer
var _song_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_mask()
	_build_audio_players()
	visible = false
	set_process(true)


func _exit_tree() -> void:
	for player in [_heartbeat_player, _breathing_player, _song_player]:
		if player != null:
			player.stop()
			player.stream = null
	profile.heartbeat_stream = null
	profile.breathing_stream = null
	profile.song_stream = null


func _process(delta: float) -> void:
	if not _closed:
		return

	_update_mask_uniforms()
	if _song_active:
		_song_seconds_remaining = maxf(_song_seconds_remaining - delta, 0.0)
		if is_zero_approx(_song_seconds_remaining):
			_song_active = false
			if _song_player != null:
				_song_player.stop()
			_update_mask_uniforms()
			song_completed.emit()


func apply_profile(new_profile) -> void:
	if new_profile == null:
		return
	profile = new_profile.copy() if new_profile.has_method("copy") else new_profile
	_apply_audio_profile()
	_update_mask_uniforms()


func set_sound_effects(heartbeat_stream: AudioStream, breathing_stream: AudioStream, heartbeat_volume_db := -8.0, breathing_volume_db := -13.0) -> void:
	profile.heartbeat_stream = heartbeat_stream
	profile.breathing_stream = breathing_stream
	profile.heartbeat_volume_db = heartbeat_volume_db
	profile.breathing_volume_db = breathing_volume_db
	_apply_audio_profile()


func set_song_sound(song_stream: AudioStream, volume_db := -7.0) -> void:
	profile.song_stream = song_stream
	profile.song_volume_db = volume_db
	_apply_audio_profile()


func set_anomaly_context(value: bool) -> void:
	anomaly_context = value
	_sync_audio()
	_update_mask_uniforms()


func toggle_closed() -> void:
	if _closed:
		open_eyes()
	else:
		close_eyes()


func close_eyes() -> void:
	if _closed:
		return
	_closed = true
	visible = true
	move_to_front()
	_update_mask_uniforms()
	_sync_audio()
	closed_changed.emit(true)


func open_eyes() -> void:
	if not _closed:
		return
	var interrupted := _song_active
	_song_active = false
	_song_seconds_remaining = 0.0
	if _song_player != null:
		_song_player.stop()
	_closed = false
	visible = false
	_sync_audio()
	closed_changed.emit(false)
	if interrupted:
		song_interrupted.emit()


func is_closed() -> bool:
	return _closed


func is_song_active() -> bool:
	return _song_active


func start_song(duration: float) -> bool:
	if not _closed or duration <= 0.0:
		return false
	_song_active = true
	_song_seconds_remaining = duration
	if _audio_playback_allowed() and _song_player != null and _song_player.stream != null:
		_song_player.play()
	_update_mask_uniforms()
	song_started.emit(duration)
	return true


func stop_song(emit_interrupted := false) -> void:
	if not _song_active:
		return
	_song_active = false
	_song_seconds_remaining = 0.0
	if _song_player != null:
		_song_player.stop()
	_update_mask_uniforms()
	if emit_interrupted:
		song_interrupted.emit()


func get_song_seconds_remaining() -> float:
	return _song_seconds_remaining


func set_debug_vision_radius(radius: float) -> void:
	debug_radius_override = radius if radius > 0.0 else -1.0
	_update_mask_uniforms()


func get_effective_vision_radius() -> float:
	if debug_radius_override > 0.0:
		return debug_radius_override
	if _song_active:
		return profile.song_vision_radius
	if anomaly_context:
		return profile.anomaly_vision_radius
	return profile.vision_radius


func _build_mask() -> void:
	_mask = ColorRect.new()
	_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mask.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 viewport_size = vec2(1280.0, 720.0);
uniform vec2 focus_position = vec2(640.0, 360.0);
uniform float radius = 150.0;
uniform float feather = 42.0;
uniform float visible_brightness = 0.36;

void fragment() {
	vec2 pixel = UV * viewport_size;
	vec2 slit_position = pixel - focus_position;
	float slit_half_width = max(radius * 2.10, 1.0);
	float slit_half_height = max(radius * 0.34, 1.0);
	float normalized_x = abs(slit_position.x) / slit_half_width;
	float lid_curve = pow(max(1.0 - normalized_x * normalized_x, 0.0), 0.72);
	float opening_at_x = slit_half_height * lid_curve;
	float vertical_edge = abs(slit_position.y) - opening_at_x;
	float horizontal_edge = abs(slit_position.x) - slit_half_width;
	float slit_distance = max(vertical_edge, horizontal_edge);
	float darkness = smoothstep(-feather * 0.42, feather * 0.58, slit_distance);
	vec2 blur_offset = 1.5 / viewport_size;
	vec3 visible_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 1.15).rgb * 0.40;
	visible_color += textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(blur_offset.x, 0.0), 1.15).rgb * 0.15;
	visible_color += textureLod(SCREEN_TEXTURE, SCREEN_UV - vec2(blur_offset.x, 0.0), 1.15).rgb * 0.15;
	visible_color += textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, blur_offset.y), 1.15).rgb * 0.15;
	visible_color += textureLod(SCREEN_TEXTURE, SCREEN_UV - vec2(0.0, blur_offset.y), 1.15).rgb * 0.15;
	float luma = dot(visible_color, vec3(0.299, 0.587, 0.114));
	visible_color = mix(vec3(luma), visible_color, 0.82);
	visible_color = (visible_color - 0.5) * 1.14 + 0.5 - 0.025;
	visible_color = mix(visible_color, visible_color * vec3(0.92, 1.0, 0.96), 0.08);
	visible_color *= visible_brightness;
	COLOR = vec4(mix(visible_color, vec3(0.0), darkness), 1.0);
}
"""
	_mask_material = ShaderMaterial.new()
	_mask_material.shader = shader
	_mask.material = _mask_material
	add_child(_mask)


func _build_audio_players() -> void:
	_heartbeat_player = AudioStreamPlayer.new()
	_breathing_player = AudioStreamPlayer.new()
	_song_player = AudioStreamPlayer.new()
	add_child(_heartbeat_player)
	add_child(_breathing_player)
	add_child(_song_player)
	if profile.heartbeat_stream == null:
		profile.heartbeat_stream = _make_heartbeat_stream()
	if profile.breathing_stream == null:
		profile.breathing_stream = _make_breathing_stream()
	if profile.song_stream == null:
		profile.song_stream = _make_humming_stream()
	_apply_audio_profile()


func _apply_audio_profile() -> void:
	if _heartbeat_player == null or _breathing_player == null or _song_player == null:
		return
	_heartbeat_player.stream = profile.heartbeat_stream
	_heartbeat_player.volume_db = profile.heartbeat_volume_db
	_breathing_player.stream = profile.breathing_stream
	_breathing_player.volume_db = profile.breathing_volume_db
	_song_player.stream = profile.song_stream
	_song_player.volume_db = profile.song_volume_db
	_sync_audio()


func _sync_audio() -> void:
	if _heartbeat_player == null or _breathing_player == null:
		return
	var should_play := _closed and anomaly_context
	for player in [_heartbeat_player, _breathing_player]:
		if _audio_playback_allowed() and should_play and player.stream != null and not player.playing:
			player.play()
		elif not should_play and player.playing:
			player.stop()


func _audio_playback_allowed() -> bool:
	return DisplayServer.get_name() != "headless"


func _update_mask_uniforms() -> void:
	if _mask_material == null or not _closed:
		return
	var viewport_size := get_viewport_rect().size
	_mask_material.set_shader_parameter("viewport_size", viewport_size)
	_mask_material.set_shader_parameter("focus_position", get_viewport().get_mouse_position())
	_mask_material.set_shader_parameter("radius", get_effective_vision_radius())
	_mask_material.set_shader_parameter("feather", profile.feather_width)
	_mask_material.set_shader_parameter("visible_brightness", clampf(profile.visible_brightness, 0.0, 1.0))


func _make_heartbeat_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 1.05
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for index in range(samples):
		var time := float(index) / float(mix_rate)
		var value := _heartbeat_pulse(time, 0.08) + _heartbeat_pulse(time, 0.32) * 0.72
		data.encode_s16(index * 2, clampi(int(value * 32767.0), -32768, 32767))
	return _make_looping_wav(data, mix_rate, samples)


func _heartbeat_pulse(time: float, center: float) -> float:
	var elapsed := time - center
	if elapsed < 0.0 or elapsed > 0.16:
		return 0.0
	return sin(elapsed * 92.0) * exp(-elapsed * 24.0) * 0.72


func _make_breathing_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 3.2
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for index in range(samples):
		var time := float(index) / float(mix_rate)
		var envelope := pow(maxf(sin(PI * time / duration), 0.0), 1.7)
		var air := sin(time * 117.0) * 0.38 + sin(time * 173.0) * 0.22 + sin(time * 43.0) * 0.14
		data.encode_s16(index * 2, clampi(int(air * envelope * 7200.0), -32768, 32767))
	return _make_looping_wav(data, mix_rate, samples)


func _make_humming_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 3.25
	var samples := int(mix_rate * duration)
	var notes := [220.0, 246.94, 261.63, 246.94, 220.0]
	var data := PackedByteArray()
	data.resize(samples * 2)
	for index in range(samples):
		var time := float(index) / float(mix_rate)
		var note_index := mini(int(time / (duration / notes.size())), notes.size() - 1)
		var frequency := float(notes[note_index])
		var vibrato := sin(TAU * 4.7 * time) * 1.8
		var local_time := fmod(time, duration / notes.size())
		var note_duration := duration / notes.size()
		var envelope := sin(PI * clampf(local_time / note_duration, 0.0, 1.0))
		var voice := sin(TAU * (frequency + vibrato) * time) + sin(TAU * frequency * 2.0 * time) * 0.18
		data.encode_s16(index * 2, clampi(int(voice * envelope * 4800.0), -32768, 32767))
	return _make_looping_wav(data, mix_rate, samples)


func _make_looping_wav(data: PackedByteArray, mix_rate: int, sample_count: int) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	stream.data = data
	return stream
