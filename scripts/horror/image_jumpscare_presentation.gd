class_name HotelImageJumpscarePresentation
extends Control

signal finished
signal phase_changed(phase: String)

const DEFAULT_HOLD_SECONDS := 0.3
const DEFAULT_LUNGE_SECONDS := 0.13
const DEFAULT_DURATION := 1.5
const SHARED_AUDIO_PROFILE := "shared_shock_v1"

@onready var subject_stage: Control = %SubjectStage
@onready var backdrop_subject: TextureRect = %BackdropSubject
@onready var subject: TextureRect = %Subject
@onready var impact_flash: ColorRect = %ImpactFlash
@onready var audio_player: AudioStreamPlayer = %AudioPlayer

var active_tween: Tween
var flash_tween: Tween
var elapsed := 0.0
var lunge_started := false
var lunge_elapsed := 0.0
var playing := false
var initial_zoom := 1.08
var lunge_zoom := 2.05
var focus_point := Vector2(0.5, 0.5)
var initial_shake := 9.0
var lunge_shake := 14.0
var source_texture: Texture2D
var source_rect := Rect2(0.0, 0.0, 1.0, 1.0)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	set_process(false)
	resized.connect(_sync_stage_pivot)


func play(definition, _localization = null) -> void:
	stop()
	var image_path := String(definition.jumpscare_image_path)
	if image_path.is_empty() or not ResourceLoader.exists(image_path):
		push_warning("Missing jumpscare source image: %s" % image_path)
		finished.emit()
		return

	source_texture = load(image_path) as Texture2D
	if source_texture == null:
		push_warning("Jumpscare source is not a texture: %s" % image_path)
		finished.emit()
		return
	source_rect = Rect2(definition.jumpscare_source_rect).intersection(
		Rect2(0.0, 0.0, 1.0, 1.0)
	)
	subject.texture = _build_subject_texture(source_texture, source_rect)
	backdrop_subject.texture = subject.texture
	subject.stretch_mode = (
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if String(definition.jumpscare_fit_mode) == "contain"
		else TextureRect.STRETCH_KEEP_ASPECT_COVERED
	)

	var hold_seconds := maxf(float(definition.jumpscare_hold_seconds), 0.0)
	var lunge_seconds := maxf(float(definition.jumpscare_lunge_seconds), 0.05)
	var duration := maxf(float(definition.jumpscare_duration), hold_seconds + lunge_seconds + 0.2)
	initial_zoom = clampf(float(definition.jumpscare_initial_zoom), 0.5, 2.0)
	lunge_zoom = maxf(float(definition.jumpscare_lunge_zoom), initial_zoom + 0.1)
	focus_point = Vector2(definition.jumpscare_focus_point).clamp(
		Vector2.ZERO,
		Vector2.ONE
	)
	initial_shake = maxf(float(definition.jumpscare_initial_shake), 0.0)
	lunge_shake = maxf(float(definition.jumpscare_lunge_shake), 0.0)

	elapsed = 0.0
	lunge_started = false
	lunge_elapsed = 0.0
	playing = true
	visible = true
	set_process(true)
	_sync_stage_pivot()
	subject_stage.position = Vector2.ZERO
	subject_stage.rotation = 0.0
	subject_stage.scale = Vector2.ONE * initial_zoom

	_play_impact_audio(definition)
	_flash(Color(1.0, 0.92, 0.84, 0.20), 0.055)
	phase_changed.emit("reveal")

	active_tween = create_tween()
	active_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	active_tween.tween_property(
		subject_stage,
		"scale",
		Vector2.ONE * initial_zoom * 1.035,
		hold_seconds
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	active_tween.tween_callback(_begin_lunge)
	active_tween.tween_property(
		subject_stage,
		"scale",
		Vector2.ONE * lunge_zoom,
		lunge_seconds
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	active_tween.tween_interval(maxf(duration - hold_seconds - lunge_seconds, 0.0))
	active_tween.tween_callback(_finish)


func _build_subject_texture(texture: Texture2D, normalized_rect: Rect2) -> Texture2D:
	if (
		normalized_rect.size.x <= 0.0
		or normalized_rect.size.y <= 0.0
		or (
			normalized_rect.position.is_equal_approx(Vector2.ZERO)
			and normalized_rect.size.is_equal_approx(Vector2.ONE)
		)
	):
		return texture
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(
		normalized_rect.position * texture.get_size(),
		normalized_rect.size * texture.get_size(),
	)
	return atlas


func stop() -> void:
	playing = false
	set_process(false)
	if active_tween != null:
		active_tween.kill()
		active_tween = null
	if flash_tween != null:
		flash_tween.kill()
		flash_tween = null
	if audio_player != null:
		audio_player.stop()
		audio_player.stream = null
	if subject_stage != null:
		subject_stage.position = Vector2.ZERO
		subject_stage.rotation = 0.0


func _process(delta: float) -> void:
	if not playing:
		return
	elapsed += delta
	if lunge_started:
		lunge_elapsed += delta

	var shake_amplitude := 1.35
	if elapsed < 0.16:
		shake_amplitude = lerpf(initial_shake, 1.35, elapsed / 0.16)
	elif lunge_started:
		shake_amplitude = lerpf(lunge_shake, 2.0, clampf(lunge_elapsed / 0.20, 0.0, 1.0))
	subject_stage.position = Vector2(
		sin(elapsed * 137.0),
		cos(elapsed * 181.0)
	) * shake_amplitude
	subject_stage.rotation = sin(elapsed * 97.0) * deg_to_rad(shake_amplitude * 0.055)


func _sync_stage_pivot() -> void:
	if subject_stage != null:
		subject_stage.pivot_offset = size * focus_point


func _begin_lunge() -> void:
	lunge_started = true
	lunge_elapsed = 0.0
	_flash(Color(0.62, 0.025, 0.015, 0.16), 0.050)
	phase_changed.emit("lunge")


func _flash(color: Color, fade_seconds: float) -> void:
	if impact_flash == null:
		return
	if flash_tween != null:
		flash_tween.kill()
	impact_flash.color = color
	flash_tween = create_tween()
	flash_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	flash_tween.tween_property(impact_flash, "color:a", 0.0, fade_seconds)


func _play_impact_audio(definition) -> void:
	var audio_path := String(definition.jumpscare_audio_path)
	if not audio_path.is_empty() and ResourceLoader.exists(audio_path):
		audio_player.stream = load(audio_path) as AudioStream
	else:
		audio_player.stream = _make_shared_shock_stream(
			maxf(float(definition.jumpscare_hold_seconds), 0.0)
		)
	audio_player.volume_db = clampf(float(definition.jumpscare_audio_volume_db), -30.0, 0.0)
	if DisplayServer.get_name() != "headless":
		audio_player.play()


func _make_shared_shock_stream(lunge_at_seconds := DEFAULT_HOLD_SECONDS) -> AudioStreamWAV:
	var mix_rate := 44100
	var duration := 1.15
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 105106
	for index in samples:
		var time := float(index) / float(mix_rate)
		var first_impact := exp(-time * 12.0)
		var lunge_time := maxf(time - lunge_at_seconds, 0.0)
		var second_impact := exp(-lunge_time * 17.0) if time >= lunge_at_seconds else 0.0
		var scream_envelope := sin(PI * clampf(time / 0.92, 0.0, 1.0))
		var scream_pitch := 510.0 + time * 940.0 + sin(TAU * 18.0 * time) * 74.0
		var scream := (
			sin(TAU * scream_pitch * time) * 0.34
			+ sin(TAU * scream_pitch * 2.13 * time) * 0.16
		) * scream_envelope
		var harsh_noise := rng.randf_range(-1.0, 1.0) * (
			first_impact * 0.72
			+ second_impact * 0.48
			+ scream_envelope * 0.10
		)
		var bass_hit := sin(TAU * 58.0 * lunge_time) * second_impact * 0.72
		var value := tanh((scream + harsh_noise + bass_hit) * 1.25) * 0.72
		data.encode_s16(index * 2, clampi(int(value * 32767.0), -32768, 32767))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = data
	return stream


func _finish() -> void:
	stop()
	finished.emit()
