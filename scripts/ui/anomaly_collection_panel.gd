class_name HotelAnomalyCollectionPanel
extends PanelContainer

signal close_requested

var horror_event_manager = null
var localization = null
var count_label: Label
var empty_label: Label
var entries_box: VBoxContainer


func setup(new_horror_event_manager, new_localization) -> void:
	horror_event_manager = new_horror_event_manager
	localization = new_localization
	if localization != null and not localization.language_changed.is_connected(_on_language_changed):
		localization.language_changed.connect(_on_language_changed)
	_build()
	refresh()


func refresh() -> void:
	if entries_box == null or horror_event_manager == null:
		return

	for child in entries_box.get_children():
		child.queue_free()

	var entries: Array = horror_event_manager.get_discovered_entries()
	var entity_count := entries.filter(func(entry): return String(entry.get("collection_kind", "")) == "entity").size()
	var phenomenon_count := entries.size() - entity_count
	count_label.text = _text(
		"anomaly_collection.count",
		"Discovered: %d · Entities: %d · Phenomena: %d",
	) % [entries.size(), entity_count, phenomenon_count]
	empty_label.visible = entries.is_empty()

	for entry in entries:
		entries_box.add_child(_make_entry_card(entry))


func _build() -> void:
	for child in get_children():
		child.queue_free()

	custom_minimum_size = Vector2(540.0, 420.0)
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_stylebox_override("panel", _make_panel_style(Color(0.015, 0.018, 0.022, 0.88), Color(1.0, 0.82, 0.28, 0.20), 10))

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	add_child(layout)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	layout.add_child(header)

	var title := Label.new()
	title.text = _text("anomaly_collection.title", "Anomaly Collection")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42))
	header.add_child(title)

	var close_button := Button.new()
	close_button.text = "×"
	close_button.custom_minimum_size = Vector2(34.0, 30.0)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_button.pressed.connect(close_requested.emit)
	header.add_child(close_button)

	count_label = Label.new()
	count_label.add_theme_font_size_override("font_size", 14)
	count_label.add_theme_color_override("font_color", Color(0.76, 0.72, 0.64))
	layout.add_child(count_label)

	empty_label = Label.new()
	empty_label.text = _text("anomaly_collection.empty", "No anomalies discovered yet.")
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	empty_label.add_theme_font_size_override("font_size", 15)
	empty_label.add_theme_color_override("font_color", Color(0.72, 0.72, 0.68))
	layout.add_child(empty_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)

	entries_box = VBoxContainer.new()
	entries_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entries_box.add_theme_constant_override("separation", 10)
	scroll.add_child(entries_box)


func _make_entry_card(entry: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_panel_style(Color(1.0, 1.0, 1.0, 0.045), Color(1.0, 1.0, 1.0, 0.11), 8))

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 6)
	card.add_child(layout)

	var title := Label.new()
	title.text = _event_title(entry)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 17)
	title.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	layout.add_child(title)

	var meta := Label.new()
	meta.text = "%s · %s · %s" % [_room_name(entry), _type_name(entry), _status_name(entry)]
	meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	meta.add_theme_font_size_override("font_size", 13)
	meta.add_theme_color_override("font_color", Color(0.70, 0.68, 0.62))
	layout.add_child(meta)

	var body_label := Label.new()
	body_label.text = _body_label(entry)
	body_label.add_theme_font_size_override("font_size", 11)
	body_label.add_theme_color_override("font_color", _kind_color(entry))
	layout.add_child(body_label)

	var body := Label.new()
	body.text = _event_body(entry)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 14)
	body.add_theme_color_override("font_color", Color(0.86, 0.83, 0.76))
	layout.add_child(body)

	return card


func _event_title(entry: Dictionary) -> String:
	return _translate(String(entry.get("title_key", "")), String(entry.get("fallback_title", "")))


func _event_body(entry: Dictionary) -> String:
	return _translate(String(entry.get("body_key", "")), String(entry.get("fallback_body", "")))


func _room_name(entry: Dictionary) -> String:
	var room_id := String(entry.get("room_id", ""))
	return _translate("horror.room.%s" % room_id, String(entry.get("room_name", room_id)))


func _type_name(entry: Dictionary) -> String:
	var kind := String(entry.get("collection_kind", "phenomenon"))
	return _text("anomaly_collection.kind.%s" % kind, kind.capitalize())


func _body_label(entry: Dictionary) -> String:
	if String(entry.get("collection_kind", "phenomenon")) == "entity":
		return _text("anomaly_collection.body.story", "STORY")
	return _text("anomaly_collection.body.description", "PHENOMENON DESCRIPTION")


func _kind_color(entry: Dictionary) -> Color:
	if String(entry.get("collection_kind", "phenomenon")) == "entity":
		return Color(0.96, 0.66, 0.42)
	return Color(0.62, 0.78, 0.84)


func _status_name(entry: Dictionary) -> String:
	if bool(entry.get("resolved", false)):
		return _text("anomaly_collection.status.resolved", "Resolved")

	return _text("anomaly_collection.status.active", "Active")


func _text(key: String, fallback: String) -> String:
	return _translate("ui.%s" % key, fallback)


func _translate(key: String, fallback: String) -> String:
	if localization == null:
		return fallback

	return localization.translate(key, fallback)


func _on_language_changed(_language: int) -> void:
	_build()
	refresh()


func _make_panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style
