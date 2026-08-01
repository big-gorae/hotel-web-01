class_name HotelMoldOverlay
extends Control

const MAX_STACK := 6
const MOLD_TEXTURE: Texture2D = preload("res://resource/images/overlays/mold_patch_example.png")
const WALL_CENTER := Vector2(0.835, 0.380)
const STAGE_WIDTHS := [0.0, 0.045, 0.070, 0.095, 0.120, 0.145, 0.175]
const STAGE_OPACITIES := [0.0, 0.54, 0.61, 0.69, 0.76, 0.83, 0.90]

var stack := 0
var photo_rect := Rect2()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false


func set_photo_rect(value: Rect2) -> void:
	photo_rect = value
	queue_redraw()


func set_stack(value: int) -> void:
	stack = clampi(value, 0, MAX_STACK)
	queue_redraw()


func _draw() -> void:
	if stack <= 0 or photo_rect.size.x <= 0.0 or photo_rect.size.y <= 0.0:
		return

	var decal_width: float = photo_rect.size.x * float(STAGE_WIDTHS[stack])
	var texture_aspect := MOLD_TEXTURE.get_height() / float(MOLD_TEXTURE.get_width())
	var decal_size := Vector2(decal_width, decal_width * texture_aspect)
	var center := photo_rect.position + WALL_CENTER * photo_rect.size
	var decal_rect := Rect2(center - decal_size * 0.5, decal_size)
	var opacity: float = float(STAGE_OPACITIES[stack])
	draw_texture_rect(MOLD_TEXTURE, decal_rect, false, Color(0.82, 0.84, 0.74, opacity))
