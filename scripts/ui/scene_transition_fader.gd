class_name HotelSceneTransitionFader
extends ColorRect

signal screen_covered
signal transition_finished

const DEFAULT_FADE_OUT_SECONDS := 0.11
const DEFAULT_HOLD_SECONDS := 0.035
const DEFAULT_FADE_IN_SECONDS := 0.14
const DEFAULT_ANOMALY_FADE_OUT_SECONDS := 0.49
const DEFAULT_ANOMALY_HOLD_SECONDS := 0.02
const DEFAULT_ANOMALY_FADE_IN_SECONDS := 0.56
const ANOMALY_FADE_IN_RATIO := DEFAULT_ANOMALY_FADE_IN_SECONDS / DEFAULT_ANOMALY_FADE_OUT_SECONDS
const PERCEPTUAL_GAMMA := 2.2

var active_tween: Tween
var transitioning := false
var anomaly_fade_out_seconds := DEFAULT_ANOMALY_FADE_OUT_SECONDS
var anomaly_hold_seconds := DEFAULT_ANOMALY_HOLD_SECONDS
var anomaly_fade_in_seconds := DEFAULT_ANOMALY_FADE_IN_SECONDS


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	color = Color(0.0, 0.0, 0.0, 0.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func is_transitioning() -> bool:
	return transitioning


func play_scene_change(scene_change_callback: Callable, fade_out_seconds := DEFAULT_FADE_OUT_SECONDS, hold_seconds := DEFAULT_HOLD_SECONDS, fade_in_seconds := DEFAULT_FADE_IN_SECONDS) -> void:
	_play_transition(scene_change_callback, fade_out_seconds, hold_seconds, fade_in_seconds)


func play_anomaly_resolution(resolution_callback := Callable()) -> void:
	_play_transition(
		resolution_callback,
		anomaly_fade_out_seconds,
		anomaly_hold_seconds,
		anomaly_fade_in_seconds,
		Tween.EASE_IN_OUT,
		Tween.EASE_IN_OUT,
		true,
	)


func set_anomaly_fade_seconds(fade_seconds: float) -> void:
	var safe_seconds := clampf(fade_seconds, 0.0, 1.50)
	anomaly_fade_out_seconds = safe_seconds
	anomaly_fade_in_seconds = safe_seconds * ANOMALY_FADE_IN_RATIO


func _play_transition(
	scene_change_callback: Callable,
	fade_out_seconds: float,
	hold_seconds: float,
	fade_in_seconds: float,
	fade_out_ease := Tween.EASE_OUT,
	fade_in_ease := Tween.EASE_IN,
	use_perceptual_fade := false,
) -> void:
	if transitioning:
		return

	transitioning = true
	visible = true
	move_to_front()
	mouse_filter = Control.MOUSE_FILTER_STOP
	color = Color(0.0, 0.0, 0.0, 0.0)

	if active_tween != null:
		active_tween.kill()

	active_tween = create_tween()
	active_tween.set_pause_mode(Tween.TWEEN_PAUSE_BOUND)
	_append_fade(0.0, 1.0, fade_out_seconds, fade_out_ease, use_perceptual_fade)
	active_tween.tween_callback(_emit_screen_covered)
	if scene_change_callback.is_valid():
		active_tween.tween_callback(scene_change_callback)
	active_tween.tween_interval(maxf(hold_seconds, 0.0))
	_append_fade(1.0, 0.0, fade_in_seconds, fade_in_ease, use_perceptual_fade)
	active_tween.tween_callback(_finish_transition)


func _append_fade(from_darkness: float, to_darkness: float, duration: float, ease: Tween.EaseType, use_perceptual_fade: bool) -> void:
	if duration <= 0.0:
		if use_perceptual_fade:
			active_tween.tween_callback(_set_perceptual_darkness.bind(to_darkness))
		else:
			active_tween.tween_callback(_set_linear_darkness.bind(to_darkness))
		return
	if use_perceptual_fade:
		active_tween.tween_method(_set_perceptual_darkness, from_darkness, to_darkness, duration)
		return
	active_tween.tween_property(self, "color:a", to_darkness, duration).set_trans(Tween.TRANS_SINE).set_ease(ease)


func _set_linear_darkness(darkness: float) -> void:
	var target_color := color
	target_color.a = clampf(darkness, 0.0, 1.0)
	color = target_color


func _set_perceptual_darkness(darkness: float) -> void:
	var progress := clampf(darkness, 0.0, 1.0)
	var smoothed := progress * progress * progress * (progress * (progress * 6.0 - 15.0) + 10.0)
	var alpha := 1.0 - pow(1.0 - smoothed, PERCEPTUAL_GAMMA)
	color = Color(0.0, 0.0, 0.0, alpha)


func _emit_screen_covered() -> void:
	screen_covered.emit()


func _finish_transition() -> void:
	transitioning = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	active_tween = null
	transition_finished.emit()
