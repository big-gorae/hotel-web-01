class_name HotelHoldProgressOverlay
extends Control

const MODE_CIRCULAR := "circular"
const MODE_HORIZONTAL := "horizontal"
const ROLE_ANOMALY := "anomaly"
const ROLE_TASK := "task"
const ANOMALY_COLOR := Color(0.93, 0.12, 0.10, 0.96)
const TASK_COLOR := Color(0.18, 0.82, 0.30, 0.96)

var _mode := MODE_CIRCULAR
var _progress := 0.0
var _focus_position := Vector2.ZERO
var _active := false
var _role := ROLE_ANOMALY


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false


func show_hold(mode: String, focus_position := Vector2.ZERO, role := ROLE_ANOMALY) -> void:
	_mode = mode if mode in [MODE_CIRCULAR, MODE_HORIZONTAL] else MODE_CIRCULAR
	_role = role if role in [ROLE_ANOMALY, ROLE_TASK] else ROLE_ANOMALY
	_focus_position = focus_position
	_progress = 0.0
	_active = true
	visible = true
	queue_redraw()


func set_progress(value: float) -> void:
	_progress = clampf(value, 0.0, 1.0)
	if _active:
		queue_redraw()


func set_focus_position(value: Vector2) -> void:
	_focus_position = value
	if _active and _mode == MODE_CIRCULAR:
		queue_redraw()


func hide_hold() -> void:
	_active = false
	_progress = 0.0
	visible = false
	queue_redraw()


func is_showing_hold() -> bool:
	return _active


func _draw() -> void:
	if not _active:
		return
	if _mode == MODE_HORIZONTAL:
		_draw_horizontal()
	else:
		_draw_circular()


func _draw_circular() -> void:
	var center := _focus_position
	if center == Vector2.ZERO:
		center = size * 0.5
	var radius := 23.0
	draw_circle(center, radius + 5.0, Color(0.0, 0.0, 0.0, 0.72))
	draw_arc(center, radius, 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.22), 4.0, true)
	if _progress > 0.0:
		draw_arc(
			center,
			radius,
			-PI * 0.5,
			-PI * 0.5 + TAU * _progress,
			maxi(4, int(64.0 * _progress)),
			_progress_color(),
			5.0,
			true
		)
	draw_circle(center, 2.5, Color(1.0, 1.0, 1.0, 0.82))


func _draw_horizontal() -> void:
	var width := minf(440.0, size.x * 0.52)
	var height := 12.0
	var rect := Rect2(
		Vector2((size.x - width) * 0.5, size.y - 118.0),
		Vector2(width, height)
	)
	draw_rect(rect.grow(6.0), Color(0.0, 0.0, 0.0, 0.74), true)
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.16), true)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * _progress, rect.size.y)), _progress_color(), true)
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.34), false, 1.0)


func get_role() -> String:
	return _role


func get_progress_color() -> Color:
	return _progress_color()


func _progress_color() -> Color:
	return TASK_COLOR if _role == ROLE_TASK else ANOMALY_COLOR
