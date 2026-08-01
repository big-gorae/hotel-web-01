class_name HotelRuleBookScreen
extends PanelContainer

signal page_changed(day: int)

const RULE_COUNT := 16
const RuleBookPageCatalog := preload("res://scripts/rules/rule_book_page_catalog.gd")

var localization = null
var rule_book_manager = null
var current_page_day := 1
var title_label: Label
var subtitle_label: Label
var day_label: Label
var latest_badge: Label
var page_label: Label
var previous_button: Button
var next_button: Button
var text_page_scroll: ScrollContainer
var page_background: TextureRect
var page_photo: TextureRect
var rules_box: VBoxContainer
var page_image_overrides: Dictionary = {}


func setup(new_localization, new_rule_book_manager = null) -> void:
	localization = new_localization
	rule_book_manager = new_rule_book_manager
	_build()
	show_latest_page()


func show_latest_page() -> void:
	show_page(_latest_day())


func show_page(day: int) -> void:
	current_page_day = clampi(day, 1, _latest_day())
	refresh_text()
	page_changed.emit(current_page_day)


func get_current_page_day() -> int:
	return current_page_day


func get_page_rule_count() -> int:
	return _rules_for_page().size()


func set_page_image_override(day: int, image_path: String) -> void:
	var safe_day := maxi(day, 1)
	if image_path.is_empty():
		page_image_overrides.erase(safe_day)
	else:
		page_image_overrides[safe_day] = image_path
	if current_page_day == safe_day:
		refresh_text()


func get_page_image_path(day := -1) -> String:
	var target_day := current_page_day if day < 1 else day
	if page_image_overrides.has(target_day):
		return String(page_image_overrides[target_day])
	var language_code: String = localization.get_language_code() if localization != null and localization.has_method("get_language_code") else ""
	return RuleBookPageCatalog.resolve_page_image_path(target_day, language_code)


func is_page_image_mode() -> bool:
	return page_photo != null and page_photo.visible


func refresh_text() -> void:
	if title_label == null:
		return

	current_page_day = clampi(current_page_day, 1, _latest_day())
	title_label.text = _text("rule_book.title", "Hotel Management Rules")
	subtitle_label.text = _text("rule_book.subtitle", "Issued by: Manager")
	day_label.text = _text("rule_book.day", "DAY %d · NEW RULES") % current_page_day
	latest_badge.text = _text("rule_book.latest", "LATEST")
	latest_badge.visible = current_page_day == _latest_day()
	page_label.text = "%02d  /  %02d" % [current_page_day, _latest_day()]
	previous_button.disabled = current_page_day <= 1
	next_button.disabled = current_page_day >= _latest_day()
	previous_button.tooltip_text = _text("rule_book.previous_day", "Previous day")
	next_button.tooltip_text = _text("rule_book.next_day", "Next day")
	_refresh_page_image()

	for child in rules_box.get_children():
		child.queue_free()

	var page_rules := _rules_for_page()
	for index in range(page_rules.size()):
		var rule_data: Dictionary = page_rules[index]
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", _make_rule_style(index))
		rules_box.add_child(card)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		card.add_child(row)

		var number := Label.new()
		number.text = "%02d" % int(rule_data.get("order", index + 1))
		number.custom_minimum_size = Vector2(44.0, 0.0)
		number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		number.add_theme_font_size_override("font_size", 18)
		number.add_theme_color_override("font_color", Color(0.36, 0.13, 0.09, 0.92))
		row.add_child(number)

		var divider := VSeparator.new()
		divider.modulate = Color(0.24, 0.16, 0.10, 0.30)
		row.add_child(divider)

		var rule := Label.new()
		rule.text = _translate(String(rule_data.get("text_key", "")), String(rule_data.get("fallback_text", "")))
		rule.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rule.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		rule.add_theme_font_size_override("font_size", 17)
		rule.add_theme_color_override("font_color", Color(0.11, 0.10, 0.085, 0.96))
		row.add_child(rule)


func _build() -> void:
	for child in get_children():
		child.queue_free()

	custom_minimum_size = Vector2(570.0, 420.0)
	add_theme_stylebox_override("panel", _make_panel_style(Color(0.026, 0.030, 0.034, 0.97), Color(1.0, 0.79, 0.25, 0.24), 12))

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	add_child(layout)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 25)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42))
	layout.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 13)
	subtitle_label.add_theme_color_override("font_color", Color(0.66, 0.66, 0.62))
	layout.add_child(subtitle_label)

	var day_header := HBoxContainer.new()
	day_header.add_theme_constant_override("separation", 10)
	layout.add_child(day_header)

	day_label = Label.new()
	day_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	day_label.add_theme_font_size_override("font_size", 15)
	day_label.add_theme_color_override("font_color", Color(0.88, 0.84, 0.72))
	day_header.add_child(day_label)

	latest_badge = Label.new()
	latest_badge.add_theme_font_size_override("font_size", 12)
	latest_badge.add_theme_color_override("font_color", Color(1.0, 0.80, 0.30))
	latest_badge.add_theme_stylebox_override("normal", _make_badge_style())
	day_header.add_child(latest_badge)

	var separator := HSeparator.new()
	separator.modulate = Color(1.0, 0.80, 0.30, 0.20)
	layout.add_child(separator)

	var page_content := PanelContainer.new()
	page_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_content.clip_contents = true
	page_content.add_theme_stylebox_override("panel", _make_page_content_style())
	layout.add_child(page_content)

	page_background = TextureRect.new()
	page_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	page_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	page_background.texture = load(RuleBookPageCatalog.get_text_background_path()) as Texture2D
	page_content.add_child(page_background)

	var text_margin := MarginContainer.new()
	text_margin.add_theme_constant_override("margin_left", 88)
	text_margin.add_theme_constant_override("margin_right", 42)
	text_margin.add_theme_constant_override("margin_top", 12)
	text_margin.add_theme_constant_override("margin_bottom", 12)
	page_content.add_child(text_margin)

	text_page_scroll = ScrollContainer.new()
	text_page_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_page_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	text_margin.add_child(text_page_scroll)

	rules_box = VBoxContainer.new()
	rules_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rules_box.add_theme_constant_override("separation", 10)
	text_page_scroll.add_child(rules_box)

	page_photo = TextureRect.new()
	page_photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_photo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_photo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	page_photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	page_photo.visible = false
	page_content.add_child(page_photo)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	layout.add_child(footer)

	previous_button = _make_page_button("‹", _show_previous_page)
	footer.add_child(previous_button)

	page_label = Label.new()
	page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	page_label.add_theme_font_size_override("font_size", 14)
	page_label.add_theme_color_override("font_color", Color(0.70, 0.68, 0.60))
	footer.add_child(page_label)

	next_button = _make_page_button("›", _show_next_page)
	footer.add_child(next_button)


func _show_previous_page() -> void:
	show_page(current_page_day - 1)


func _show_next_page() -> void:
	show_page(current_page_day + 1)


func _make_page_button(text_value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(72.0, 36.0)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(callback)
	return button


func _text(key: String, fallback: String) -> String:
	return _translate("ui.%s" % key, fallback)


func _translate(key: String, fallback: String) -> String:
	if localization == null:
		return fallback
	return localization.translate(key, fallback)


func _latest_day() -> int:
	return maxi(rule_book_manager.get_latest_page_day(), 1) if rule_book_manager != null else 1


func _rules_for_page() -> Array:
	if rule_book_manager != null:
		var rules := []
		for definition in rule_book_manager.get_rules_for_day(current_page_day):
			rules.append({
				"order": definition.order,
				"text_key": definition.text_key,
				"fallback_text": definition.fallback_text,
			})
		return rules

	var rules := []
	for index in range(1, RULE_COUNT + 1):
		rules.append({
			"order": index,
			"text_key": "ui.rule_book.rule.%d" % index,
			"fallback_text": "",
		})
	return rules


func _refresh_page_image() -> void:
	if page_photo == null or text_page_scroll == null:
		return
	var image_path := get_page_image_path()
	var texture: Texture2D = load(image_path) as Texture2D if not image_path.is_empty() else null
	page_photo.texture = texture
	page_photo.visible = texture != null
	text_page_scroll.visible = texture == null
	page_background.visible = texture == null
	custom_minimum_size = Vector2(570.0, 560.0 if texture != null else 420.0)


func _make_panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	return style


func _make_rule_style(index: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.92, 0.88, 0.73, 0.10 if index % 2 == 0 else 0.04)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 9.0
	style.content_margin_bottom = 9.0
	return style


func _make_page_content_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.20, 0.19, 0.15, 0.96)
	style.border_color = Color(0.48, 0.42, 0.30, 0.52)
	style.set_border_width_all(1)
	style.set_corner_radius_all(7)
	return style


func _make_badge_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.20, 0.14, 0.035, 0.92)
	style.border_color = Color(1.0, 0.78, 0.25, 0.48)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 9.0
	style.content_margin_right = 9.0
	style.content_margin_top = 3.0
	style.content_margin_bottom = 3.0
	return style
