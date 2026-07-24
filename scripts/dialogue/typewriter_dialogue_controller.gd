class_name HotelTypewriterDialogueController
extends Node

signal line_completed

const DEFAULT_CHARACTERS_PER_SECOND := 35.0
const DEFAULT_PUNCTUATION_DELAY := 0.08
const PUNCTUATION := [".", ",", "!", "?", ";", ":", "…", "。", "，", "！", "？"]

var characters_per_second := DEFAULT_CHARACTERS_PER_SECOND
var punctuation_delay := DEFAULT_PUNCTUATION_DELAY
var target_label: Label
var continue_indicator: Label
var full_text := ""
var visible_character_count := 0
var typing := false
var _elapsed := 0.0
var _next_character_delay := 0.0
var _indicator_time := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func setup(new_target_label: Label, new_continue_indicator: Label) -> void:
	target_label = new_target_label
	continue_indicator = new_continue_indicator
	if continue_indicator != null:
		continue_indicator.text = "▼"
		continue_indicator.visible = false


func play_line(text: String) -> void:
	full_text = text
	visible_character_count = 0
	_elapsed = 0.0
	_next_character_delay = _base_character_delay()
	_indicator_time = 0.0
	typing = not full_text.is_empty() and characters_per_second > 0.0

	if target_label != null:
		target_label.text = full_text
		target_label.visible_characters = 0 if typing else -1
	_set_indicator_visible(not typing)
	if not typing:
		line_completed.emit()


func show_instant(text: String, show_continue := false) -> void:
	full_text = text
	visible_character_count = full_text.length()
	typing = false
	_elapsed = 0.0
	if target_label != null:
		target_label.text = full_text
		target_label.visible_characters = -1
	_set_indicator_visible(show_continue)


func reveal_all() -> bool:
	if not typing:
		return false
	visible_character_count = full_text.length()
	typing = false
	_elapsed = 0.0
	if target_label != null:
		target_label.visible_characters = -1
	_set_indicator_visible(true)
	line_completed.emit()
	return true


func clear() -> void:
	full_text = ""
	visible_character_count = 0
	typing = false
	_elapsed = 0.0
	if target_label != null:
		target_label.text = ""
		target_label.visible_characters = -1
	_set_indicator_visible(false)


func is_typing() -> bool:
	return typing


func is_line_complete() -> bool:
	return not typing and visible_character_count >= full_text.length()


func get_visible_character_count() -> int:
	return visible_character_count


func _process(delta: float) -> void:
	if typing:
		_advance_typing(delta)
	if continue_indicator != null and continue_indicator.visible:
		_indicator_time += delta
		continue_indicator.modulate.a = 0.58 + sin(_indicator_time * 4.2) * 0.22


func _advance_typing(delta: float) -> void:
	_elapsed += maxf(delta, 0.0)
	while typing and _elapsed >= _next_character_delay:
		_elapsed -= _next_character_delay
		visible_character_count += 1
		if target_label != null:
			target_label.visible_characters = visible_character_count
		if visible_character_count >= full_text.length():
			typing = false
			_set_indicator_visible(true)
			line_completed.emit()
			return
		var revealed_character := full_text.substr(visible_character_count - 1, 1)
		_next_character_delay = _base_character_delay()
		if PUNCTUATION.has(revealed_character):
			_next_character_delay += punctuation_delay


func _base_character_delay() -> float:
	return 1.0 / maxf(characters_per_second, 1.0)


func _set_indicator_visible(value: bool) -> void:
	if continue_indicator == null:
		return
	continue_indicator.visible = value
	continue_indicator.modulate.a = 0.80
	_indicator_time = 0.0
