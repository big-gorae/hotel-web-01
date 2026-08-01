class_name HotelClosetWomanPresentation
extends Control

signal finished

var door_open := 0.0:
	set(value):
		door_open = value
		queue_redraw()
var woman_scale := 0.34:
	set(value):
		woman_scale = value
		queue_redraw()
var _tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func play(definition, _localization = null) -> void:
	var duration := maxf(float(definition.jumpscare_duration), 1.2)
	door_open = 0.0
	woman_scale = 0.34
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "door_open", 1.0, duration * 0.48).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "woman_scale", 1.58, duration * 0.92).set_delay(duration * 0.16).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	_tween.set_parallel(false)
	_tween.tween_interval(duration * 0.08)
	_tween.finished.connect(func(): finished.emit(), CONNECT_ONE_SHOT)


func stop() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null


func _draw() -> void:
	var viewport := size
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(0.0, 0.0, 0.0, 0.74))
	var closet_size := Vector2(minf(viewport.x * 0.50, 620.0), viewport.y * 0.86)
	var closet_pos := (viewport - closet_size) * 0.5
	draw_rect(Rect2(closet_pos, closet_size), Color(0.005, 0.004, 0.004, 1.0))

	var center := closet_pos + closet_size * Vector2(0.5, 0.56)
	var body_height := closet_size.y * 0.48 * woman_scale
	var body_width := closet_size.x * 0.14 * woman_scale
	draw_circle(center - Vector2(0.0, body_height * 0.46), body_width * 0.37, Color(0.015, 0.012, 0.014, 1.0))
	draw_polygon(PackedVector2Array([
		center - Vector2(body_width * 0.42, body_height * 0.31),
		center + Vector2(body_width * 0.42, -body_height * 0.31),
		center + Vector2(body_width * 0.66, body_height * 0.50),
		center + Vector2(-body_width * 0.66, body_height * 0.50),
	]), PackedColorArray([Color(0.012, 0.009, 0.011, 1.0)]))
	var eye_y := center.y - body_height * 0.47
	draw_circle(Vector2(center.x - body_width * 0.13, eye_y), 2.4 * woman_scale, Color(0.55, 0.03, 0.025, 0.94))
	draw_circle(Vector2(center.x + body_width * 0.13, eye_y), 2.4 * woman_scale, Color(0.55, 0.03, 0.025, 0.94))

	var half_width := closet_size.x * 0.5
	var slide := half_width * 0.88 * door_open
	var left_door := Rect2(closet_pos - Vector2(slide, 0.0), Vector2(half_width, closet_size.y))
	var right_door := Rect2(closet_pos + Vector2(half_width + slide, 0.0), Vector2(half_width, closet_size.y))
	for door in [left_door, right_door]:
		draw_rect(door, Color(0.105, 0.065, 0.038, 1.0))
		draw_rect(door.grow(-9.0), Color(0.065, 0.038, 0.024, 1.0), false, 3.0)
	draw_circle(left_door.position + Vector2(left_door.size.x - 20.0, left_door.size.y * 0.52), 5.0, Color(0.52, 0.39, 0.18))
	draw_circle(right_door.position + Vector2(20.0, right_door.size.y * 0.52), 5.0, Color(0.52, 0.39, 0.18))
