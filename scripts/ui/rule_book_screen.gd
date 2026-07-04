class_name HotelRuleBookScreen
extends PanelContainer

const RULE_COUNT := 7

var localization = null
var title_label: Label
var subtitle_label: Label
var rules_box: VBoxContainer


func setup(new_localization) -> void:
	localization = new_localization
	_build()
	refresh_text()


func refresh_text() -> void:
	if title_label == null:
		return

	title_label.text = _text("rule_book.title", "Rule Book")
	subtitle_label.text = _text("rule_book.subtitle", "Hotel night rules")

	for child in rules_box.get_children():
		rules_box.remove_child(child)
		child.free()

	for index in range(1, RULE_COUNT + 1):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		rules_box.add_child(row)

		var number := Label.new()
		number.text = "%02d" % index
		number.custom_minimum_size = Vector2(38.0, 0.0)
		number.add_theme_font_size_override("font_size", 15)
		number.add_theme_color_override("font_color", Color(1.0, 0.82, 0.28))
		row.add_child(number)

		var rule := Label.new()
		rule.text = _text("rule_book.rule.%d" % index, "")
		rule.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rule.add_theme_font_size_override("font_size", 16)
		rule.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
		row.add_child(rule)


func _build() -> void:
	for child in get_children():
		child.queue_free()

	custom_minimum_size = Vector2(570.0, 420.0)
	add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.94), Color(1.0, 0.82, 0.28, 0.20), 12))

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	add_child(layout)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42))
	layout.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", Color(0.72, 0.72, 0.68))
	layout.add_child(subtitle_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)

	rules_box = VBoxContainer.new()
	rules_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rules_box.add_theme_constant_override("separation", 14)
	scroll.add_child(rules_box)


func _text(key: String, fallback: String) -> String:
	if localization == null:
		return fallback

	return localization.translate("ui.%s" % key, fallback)


func _make_panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 16.0
	style.content_margin_bottom = 16.0
	return style
