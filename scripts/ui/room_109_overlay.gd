class_name HotelRoom109Overlay
extends Control

var photo_rect := Rect2()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false


func set_photo_rect(value: Rect2) -> void:
	photo_rect = value
	queue_redraw()


func _draw() -> void:
	if photo_rect.size.x <= 0.0 or photo_rect.size.y <= 0.0:
		return
	var normalized := Rect2(0.735, 0.285, 0.055, 0.325)
	var door := Rect2(photo_rect.position + normalized.position * photo_rect.size, normalized.size * photo_rect.size)
	var inset := door.size.x * 0.12
	var opening := PackedVector2Array([
		door.position + Vector2(inset, 0.0),
		door.position + Vector2(door.size.x - inset * 0.35, door.size.y * 0.035),
		door.end - Vector2(inset * 0.15, 0.0),
		door.position + Vector2(0.0, door.size.y),
	])
	draw_polygon(opening, PackedColorArray([Color(0.0, 0.0, 0.0, 0.93)]))
	draw_polyline(PackedVector2Array([opening[0], opening[1], opening[2], opening[3]]), Color(0.20, 0.13, 0.08, 0.92), maxf(door.size.x * 0.08, 2.0))
	var font := ThemeDB.fallback_font
	var font_size := maxi(int(door.size.x * 0.24), 10)
	draw_string(font, door.position + Vector2(door.size.x * 0.27, door.size.y * 0.20), "109", HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(0.56, 0.47, 0.34, 0.82))
