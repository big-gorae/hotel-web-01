class_name HotelJumpscarePresentation
extends Control

signal finished

@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var timer: Timer = %Timer

var active_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	timer.timeout.connect(_finish)


func play(definition, localization = null) -> void:
	title_label.text = _translate(localization, String(definition.title_key), String(definition.fallback_title))
	description_label.text = _translate(localization, String(definition.description_key), String(definition.fallback_description))
	timer.wait_time = maxf(float(definition.jumpscare_duration), 0.1)
	timer.start()
	modulate.a = 0.0
	scale = Vector2(1.04, 1.04)
	pivot_offset = size * 0.5
	if active_tween != null:
		active_tween.kill()
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.tween_property(self, "modulate:a", 1.0, minf(timer.wait_time * 0.18, 0.12))
	active_tween.tween_property(self, "scale", Vector2.ONE, minf(timer.wait_time * 0.35, 0.25)).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func stop() -> void:
	timer.stop()
	if active_tween != null:
		active_tween.kill()
		active_tween = null


func _finish() -> void:
	stop()
	finished.emit()


func _translate(localization, key: String, fallback: String) -> String:
	if localization == null or key.is_empty():
		return fallback

	return localization.translate(key, fallback)
