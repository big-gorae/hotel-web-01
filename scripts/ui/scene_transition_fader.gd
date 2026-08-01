class_name HotelSceneTransitionFader
extends ColorRect

signal screen_covered
signal transition_finished

const DEFAULT_FADE_OUT_SECONDS := 0.11
const DEFAULT_HOLD_SECONDS := 0.035
const DEFAULT_FADE_IN_SECONDS := 0.14
const DEFAULT_ANOMALY_FADE_OUT_SECONDS := 0.45
const DEFAULT_ANOMALY_HOLD_SECONDS := 0.10
const DEFAULT_ANOMALY_FADE_IN_SECONDS := 0.52

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
	)


func set_anomaly_fade_seconds(fade_seconds: float) -> void:
	var safe_seconds := clampf(fade_seconds, 0.05, 1.50)
	anomaly_fade_out_seconds = safe_seconds
	anomaly_fade_in_seconds = safe_seconds * 1.15


func _play_transition(
	scene_change_callback: Callable,
	fade_out_seconds: float,
	hold_seconds: float,
	fade_in_seconds: float,
	fade_out_ease := Tween.EASE_OUT,
	fade_in_ease := Tween.EASE_IN,
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
	active_tween.tween_property(self, "color:a", 1.0, maxf(fade_out_seconds, 0.01)).set_trans(Tween.TRANS_SINE).set_ease(fade_out_ease)
	active_tween.tween_callback(_emit_screen_covered)
	if scene_change_callback.is_valid():
		active_tween.tween_callback(scene_change_callback)
	active_tween.tween_interval(maxf(hold_seconds, 0.0))
	active_tween.tween_property(self, "color:a", 0.0, maxf(fade_in_seconds, 0.01)).set_trans(Tween.TRANS_SINE).set_ease(fade_in_ease)
	active_tween.tween_callback(_finish_transition)


func _emit_screen_covered() -> void:
	screen_covered.emit()


func _finish_transition() -> void:
	transitioning = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	active_tween = null
	transition_finished.emit()
