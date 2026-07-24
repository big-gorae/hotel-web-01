class_name HotelPauseMenu
extends ColorRect

signal continue_requested
signal main_menu_requested
signal quit_requested
signal brightness_changed(value: float)
signal rule_book_opened

var localization = null
var rule_book_manager = null
var menu_content_shell: VBoxContainer
var brightness_slider: HSlider
var brightness_value_label: Label
var inventory_tab_button: Button
var rule_book_tab_button: Button
var controls_tab_button: Button
var inventory_screen
var rule_book_screen
var controls_screen


func setup(inventory_model, new_localization, new_rule_book_manager, brightness: float, minimum_brightness: float, maximum_brightness: float) -> void:
	localization = new_localization
	rule_book_manager = new_rule_book_manager
	process_mode = Node.PROCESS_MODE_ALWAYS
	color = Color(0.0, 0.0, 0.0, 0.58)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build(inventory_model, brightness, minimum_brightness, maximum_brightness)
	show_inventory()


func open() -> void:
	show_inventory()
	visible = true


func open_rule_book() -> void:
	show_rule_book()
	visible = true


func close() -> void:
	visible = false


func show_inventory() -> void:
	inventory_screen.visible = true
	rule_book_screen.visible = false
	controls_screen.visible = false
	_sync_tabs("inventory")


func show_rule_book() -> void:
	inventory_screen.visible = false
	controls_screen.visible = false
	rule_book_screen.visible = true
	rule_book_screen.show_latest_page()
	_sync_tabs("rule_book")


func show_controls() -> void:
	inventory_screen.visible = false
	rule_book_screen.visible = false
	controls_screen.visible = true
	_sync_tabs("controls")


func set_brightness_value(value: float) -> void:
	if brightness_slider != null and not is_equal_approx(brightness_slider.value, value):
		brightness_slider.set_value_no_signal(value)
	if brightness_value_label != null:
		brightness_value_label.text = "%d%%" % roundi(value * 100.0)


func _build(inventory_model, brightness: float, minimum_brightness: float, maximum_brightness: float) -> void:
	var center := CenterContainer.new()
	center.process_mode = Node.PROCESS_MODE_ALWAYS
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var shell := HBoxContainer.new()
	shell.process_mode = Node.PROCESS_MODE_ALWAYS
	shell.add_theme_constant_override("separation", 24)
	center.add_child(shell)

	var menu_panel := PanelContainer.new()
	menu_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_panel.custom_minimum_size = Vector2(360.0, 0.0)
	menu_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.94), Color(1.0, 1.0, 1.0, 0.16), 12))
	shell.add_child(menu_panel)

	var layout := VBoxContainer.new()
	layout.process_mode = Node.PROCESS_MODE_ALWAYS
	layout.add_theme_constant_override("separation", 14)
	menu_panel.add_child(layout)

	var title := Label.new()
	title.text = _text("menu.title", "Menu")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	layout.add_child(title)

	layout.add_child(_make_button(_text("menu.continue", "Continue"), func(): continue_requested.emit()))
	layout.add_child(_make_button(_text("menu.main_menu", "Main Menu"), func(): main_menu_requested.emit()))

	var brightness_label := Label.new()
	brightness_label.text = _text("menu.brightness", "Brightness")
	brightness_label.add_theme_font_size_override("font_size", 16)
	brightness_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	layout.add_child(brightness_label)

	var brightness_row := HBoxContainer.new()
	brightness_row.add_theme_constant_override("separation", 10)
	layout.add_child(brightness_row)

	brightness_slider = HSlider.new()
	brightness_slider.min_value = minimum_brightness
	brightness_slider.max_value = maximum_brightness
	brightness_slider.step = 0.01
	brightness_slider.value = brightness
	brightness_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brightness_slider.value_changed.connect(_on_brightness_changed)
	brightness_row.add_child(brightness_slider)

	brightness_value_label = Label.new()
	brightness_value_label.custom_minimum_size = Vector2(56.0, 0.0)
	brightness_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	brightness_value_label.add_theme_font_size_override("font_size", 16)
	brightness_value_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	brightness_row.add_child(brightness_value_label)
	set_brightness_value(brightness)

	layout.add_child(_make_button(_text("menu.quit", "Quit"), func(): quit_requested.emit()))

	menu_content_shell = VBoxContainer.new()
	menu_content_shell.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_content_shell.add_theme_constant_override("separation", 0)
	shell.add_child(menu_content_shell)

	var tab_bar := HBoxContainer.new()
	tab_bar.process_mode = Node.PROCESS_MODE_ALWAYS
	tab_bar.add_theme_constant_override("separation", 2)
	menu_content_shell.add_child(tab_bar)
	inventory_tab_button = _make_tab_button(_text("menu.inventory", "Inventory"), show_inventory)
	rule_book_tab_button = _make_tab_button(_text("menu.rule_book", "Rule Book"), show_rule_book)
	controls_tab_button = _make_tab_button(_text("menu.controls", "Controls"), show_controls)
	tab_bar.add_child(inventory_tab_button)
	tab_bar.add_child(rule_book_tab_button)
	tab_bar.add_child(controls_tab_button)

	var InventoryScreen := preload("res://scripts/ui/inventory_screen.gd")
	inventory_screen = InventoryScreen.new()
	inventory_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_screen.custom_minimum_size = Vector2(570.0, 420.0)
	inventory_screen.setup(inventory_model, localization)
	menu_content_shell.add_child(inventory_screen)

	var RuleBookScreen := preload("res://scripts/ui/rule_book_screen.gd")
	rule_book_screen = RuleBookScreen.new()
	rule_book_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	rule_book_screen.custom_minimum_size = Vector2(570.0, 420.0)
	rule_book_screen.setup(localization, rule_book_manager)
	rule_book_screen.page_changed.connect(_on_rule_book_page_changed)
	menu_content_shell.add_child(rule_book_screen)

	var ControlsScreen := preload("res://scripts/ui/controls_screen.gd")
	controls_screen = ControlsScreen.new()
	controls_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	controls_screen.setup(localization)
	menu_content_shell.add_child(controls_screen)
	_sync_content_width()


func _make_button(text_value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(callback)
	return button


func _make_tab_button(text_value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.text = text_value
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(callback)
	return button


func _on_brightness_changed(value: float) -> void:
	set_brightness_value(value)
	brightness_changed.emit(value)


func _on_rule_book_page_changed(day: int) -> void:
	rule_book_manager.mark_day_read(day)
	rule_book_opened.emit()


func _sync_tabs(active_tab: String) -> void:
	_style_tab(inventory_tab_button, active_tab == "inventory")
	_style_tab(rule_book_tab_button, active_tab == "rule_book")
	_style_tab(controls_tab_button, active_tab == "controls")


func _sync_content_width() -> void:
	var target_width: float = inventory_screen.get_combined_minimum_size().x
	var target_height := 420.0
	menu_content_shell.custom_minimum_size = Vector2(target_width, 0.0)
	inventory_screen.custom_minimum_size = Vector2(target_width, target_height)
	rule_book_screen.custom_minimum_size = Vector2(target_width, target_height)
	controls_screen.custom_minimum_size = Vector2(target_width, target_height)


func _style_tab(button: Button, active: bool) -> void:
	button.button_pressed = active
	var background := Color(0.09, 0.075, 0.045, 0.98) if active else Color(0.03, 0.035, 0.04, 0.76)
	var border := Color(1.0, 0.78, 0.32, 0.92) if active else Color(1.0, 1.0, 1.0, 0.12)
	button.custom_minimum_size = Vector2(138.0, 38.0)
	button.add_theme_stylebox_override("normal", _make_tab_style(background, border, active))
	button.add_theme_stylebox_override("hover", _make_tab_style(Color(0.15, 0.12, 0.065, 0.98), Color(1.0, 0.82, 0.28, 0.92), true))
	button.add_theme_stylebox_override("pressed", _make_tab_style(Color(0.09, 0.075, 0.045, 1.0), Color(1.0, 0.78, 0.32, 1.0), true))
	button.add_theme_color_override("font_color", Color(1.0, 0.88, 0.58) if active else Color(0.72, 0.72, 0.68))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.88, 0.58))


func _text(key: String, fallback: String) -> String:
	return localization.translate("ui.%s" % key, fallback) if localization != null else fallback


func _make_panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style


func _make_tab_style(background: Color, border: Color, active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 9.0 if active else 7.0
	style.content_margin_bottom = 9.0 if active else 7.0
	return style
