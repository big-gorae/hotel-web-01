class_name HotelJumpscareController
extends Control

signal finished

var title_label: Label
var description_label: Label
var timer: Timer
var active := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()


func play(definition) -> void:
	active = true
	visible = true
	move_to_front()
	title_label.text = definition.fallback_title
	description_label.text = definition.fallback_description
	timer.wait_time = maxf(definition.jumpscare_duration, 0.1)
	timer.start()


func stop() -> void:
	timer.stop()
	active = false
	visible = false


func _build() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.92)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	center.add_child(layout)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 40)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.28))
	layout.add_child(title_label)

	description_label = Label.new()
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.add_theme_font_size_override("font_size", 18)
	description_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	layout.add_child(description_label)

	timer = Timer.new()
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)


func _on_timer_timeout() -> void:
	stop()
	finished.emit()
