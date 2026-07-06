@tool
class_name HotelHotspotArea
extends Control

@export var hotspot_id := ""
@export var hotspot_label := ""
@export var target_scene_id := ""
@export_multiline var description_text := ""
@export var action := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if Engine.is_editor_hint():
		queue_redraw()


func _notification(what: int) -> void:
	if Engine.is_editor_hint() and what == NOTIFICATION_RESIZED:
		queue_redraw()


func to_hotspot_data(authoring_size: Vector2) -> Dictionary:
	var safe_size := authoring_size
	if safe_size.x <= 0.0 or safe_size.y <= 0.0:
		safe_size = Vector2(1280.0, 720.0)

	var data := {
		"id": hotspot_id if not hotspot_id.is_empty() else name,
		"label": hotspot_label if not hotspot_label.is_empty() else name,
		"rect": Rect2(position / safe_size, size / safe_size),
	}

	if not target_scene_id.is_empty():
		data["target"] = target_scene_id

	if not description_text.is_empty():
		data["text"] = description_text

	if not action.is_empty():
		data["action"] = action

	return data


func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 0.82, 0.28, 0.18), true)
	draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 0.82, 0.28, 0.85), false, 2.0)
