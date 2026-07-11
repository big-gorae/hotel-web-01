class_name HotelSceneTransitionFader
extends ColorRect

signal screen_covered
signal transition_finished

const DEFAULT_FADE_OUT_SECONDS := 0.11
const DEFAULT_HOLD_SECONDS := 0.035
const DEFAULT_FADE_IN_SECONDS := 0.14

var active_tween: Tween
var transitioning := false


func _init() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	color = Color(0.0, 0.0, 0.0, 0.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func is_transitioning() -> bool:
	return transitioning


func play_scene_change(scene_change_callback: Callable, fade_out_seconds := DEFAULT_FADE_OUT_SECONDS, hold_seconds := DEFAULT_HOLD_SECONDS, fade_in_seconds := DEFAULT_FADE_IN_SECONDS) -> void:
	if transitioning:
		return

	transitioning = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	color = Color(0.0, 0.0, 0.0, 0.0)

	if active_tween != null:
		active_tween.kill()

	active_tween = create_tween()
	active_tween.set_pause_mode(Tween.TWEEN_PAUSE_BOUND)
	active_tween.tween_property(self, "color:a", 1.0, fade_out_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	active_tween.tween_callback(_emit_screen_covered)
	active_tween.tween_callback(scene_change_callback)
	active_tween.tween_interval(hold_seconds)
	active_tween.tween_property(self, "color:a", 0.0, fade_in_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	active_tween.tween_callback(_finish_transition)


func _emit_screen_covered() -> void:
	screen_covered.emit()


func _finish_transition() -> void:
	transitioning = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	active_tween = null
	transition_finished.emit()
