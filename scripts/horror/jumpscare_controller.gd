class_name HotelJumpscareController
extends Control

signal finished

const DEFAULT_PRESENTATION_SCENE := "res://scenes/horror/default_jumpscare_presentation.tscn"

var active := false
var current_presentation: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func play(definition, localization = null) -> void:
	stop()
	var scene_path := String(definition.presentation_scene_path)
	if scene_path.is_empty():
		scene_path = DEFAULT_PRESENTATION_SCENE

	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		push_warning("Missing jumpscare presentation: %s" % scene_path)
		packed_scene = load(DEFAULT_PRESENTATION_SCENE) as PackedScene
	if packed_scene == null:
		finished.emit()
		return

	current_presentation = packed_scene.instantiate() as Control
	if current_presentation == null:
		push_warning("Jumpscare presentation root must be a Control: %s" % scene_path)
		finished.emit()
		return

	active = true
	visible = true
	move_to_front()
	add_child(current_presentation)
	current_presentation.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if current_presentation.has_signal("finished"):
		current_presentation.finished.connect(_on_presentation_finished, CONNECT_ONE_SHOT)
	if current_presentation.has_method("play"):
		current_presentation.play(definition, localization)
	else:
		push_warning("Jumpscare presentation has no play method: %s" % scene_path)
		_on_presentation_finished()


func stop() -> void:
	if current_presentation != null:
		if current_presentation.has_method("stop"):
			current_presentation.stop()
		current_presentation.queue_free()
		current_presentation = null
	active = false
	visible = false


func _on_presentation_finished() -> void:
	stop()
	finished.emit()
