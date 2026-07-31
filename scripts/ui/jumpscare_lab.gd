class_name HotelJumpscareLab
extends Control

signal preview_requested(event_id: String)

const FIT_COVER := "cover"
const FIT_CONTAIN := "contain"
const EVENT_LABELS := {
	"room_105_closet_woman": "곰팡이 돼지 가면 남자",
	"room_106_abandoned_child": "가짜 엄마",
}

const TUNABLE_FIELDS := [
	{
		"key": "jumpscare_hold_seconds",
		"label": "돌진 시작",
		"min": 0.0,
		"max": 1.2,
		"step": 0.01,
		"suffix": " 초",
		"hint": "첫 등장 후 돌진을 시작할 때까지",
	},
	{
		"key": "jumpscare_initial_zoom",
		"label": "원본 확대",
		"min": 0.5,
		"max": 1.8,
		"step": 0.01,
		"suffix": " 배",
		"hint": "처음 나타나는 원본 사진의 크기",
	},
	{
		"key": "jumpscare_lunge_seconds",
		"label": "돌진 시간",
		"min": 0.05,
		"max": 1.0,
		"step": 0.01,
		"suffix": " 초",
		"hint": "최종 확대까지 걸리는 시간",
	},
	{
		"key": "jumpscare_lunge_zoom",
		"label": "돌진 확대",
		"min": 1.1,
		"max": 4.0,
		"step": 0.05,
		"suffix": " 배",
		"hint": "돌진이 끝났을 때의 크기",
	},
	{
		"key": "jumpscare_duration",
		"label": "전체 길이",
		"min": 0.5,
		"max": 4.0,
		"step": 0.05,
		"suffix": " 초",
		"hint": "첫 등장부터 종료까지",
	},
	{
		"key": "jumpscare_focus_x",
		"label": "확대 중심 X",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"suffix": "",
		"hint": "0은 왼쪽, 1은 오른쪽",
	},
	{
		"key": "jumpscare_focus_y",
		"label": "확대 중심 Y",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"suffix": "",
		"hint": "0은 위, 1은 아래",
	},
	{
		"key": "jumpscare_initial_shake",
		"label": "첫 충격 진동",
		"min": 0.0,
		"max": 24.0,
		"step": 0.5,
		"suffix": " px",
		"hint": "첫 프레임의 화면 진동",
	},
	{
		"key": "jumpscare_lunge_shake",
		"label": "돌진 진동",
		"min": 0.0,
		"max": 32.0,
		"step": 0.5,
		"suffix": " px",
		"hint": "돌진 순간의 화면 진동",
	},
	{
		"key": "jumpscare_audio_volume_db",
		"label": "충격음 음량",
		"min": -30.0,
		"max": 0.0,
		"step": 0.5,
		"suffix": " dB",
		"hint": "프리뷰 음량",
	},
]

var horror_event_manager
var jumpscare_controller
var localization
var selected_definition

var event_selector: OptionButton
var fit_selector: OptionButton
var controls: Dictionary = {}
var preview_button: Button
var reset_button: Button
var close_button: Button
var status_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	visible = false


func setup(new_event_manager, new_jumpscare_controller, new_localization = null) -> void:
	horror_event_manager = new_event_manager
	jumpscare_controller = new_jumpscare_controller
	localization = new_localization
	_populate_events()


func open_lab(event_id := "room_106_abandoned_child") -> void:
	if event_selector.item_count <= 0:
		_populate_events()
	select_event_by_id(event_id)
	visible = true
	move_to_front()


func close_lab() -> void:
	visible = false


func select_event_by_id(event_id: String) -> bool:
	for index in event_selector.item_count:
		if String(event_selector.get_item_metadata(index)) == event_id:
			event_selector.select(index)
			_on_event_selected(index)
			return true
	if event_selector.item_count > 0:
		event_selector.select(0)
		_on_event_selected(0)
	return false


func set_control_value(key: String, value: float) -> void:
	var spin := controls.get(key) as SpinBox
	if spin != null:
		spin.value = value


func get_control_value(key: String) -> float:
	var spin := controls.get(key) as SpinBox
	return float(spin.value) if spin != null else 0.0


func build_preview_definition():
	if selected_definition == null:
		return null
	var preview = selected_definition.copy()
	preview.jumpscare_outcome = "continue"
	preview.jumpscare_fit_mode = (
		FIT_CONTAIN
		if fit_selector.get_selected_id() == 1
		else FIT_COVER
	)
	preview.jumpscare_hold_seconds = get_control_value("jumpscare_hold_seconds")
	preview.jumpscare_initial_zoom = get_control_value("jumpscare_initial_zoom")
	preview.jumpscare_lunge_seconds = get_control_value("jumpscare_lunge_seconds")
	preview.jumpscare_lunge_zoom = get_control_value("jumpscare_lunge_zoom")
	preview.jumpscare_duration = maxf(
		get_control_value("jumpscare_duration"),
		preview.jumpscare_hold_seconds + preview.jumpscare_lunge_seconds + 0.2
	)
	preview.jumpscare_focus_point = Vector2(
		get_control_value("jumpscare_focus_x"),
		get_control_value("jumpscare_focus_y")
	)
	preview.jumpscare_initial_shake = get_control_value("jumpscare_initial_shake")
	preview.jumpscare_lunge_shake = get_control_value("jumpscare_lunge_shake")
	preview.jumpscare_audio_volume_db = get_control_value("jumpscare_audio_volume_db")
	return preview


func preview_selected() -> bool:
	if jumpscare_controller == null:
		return false
	var preview = build_preview_definition()
	if preview == null:
		return false
	jumpscare_controller.play(preview, localization)
	preview_requested.emit(String(preview.id))
	status_label.text = "%s 프리뷰 재생 · 사망/저장 미적용" % _event_label(preview)
	return true


func _build_ui() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.78)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(880.0, 650.0)
	panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color(0.025, 0.028, 0.035, 0.98), Color(0.85, 0.18, 0.14, 0.72), 12)
	)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var title_row := HBoxContainer.new()
	layout.add_child(title_row)
	var title := Label.new()
	title.text = "⚡ 점프스케어 연구소"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1.0, 0.83, 0.55))
	title_row.add_child(title)
	close_button = Button.new()
	close_button.text = "닫기"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(close_lab)
	title_row.add_child(close_button)

	var intro := Label.new()
	intro.text = "값을 조절한 뒤 프리뷰를 누르세요. 변경값은 연구소에서만 사용되며 게임 데이터에는 저장되지 않습니다."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_theme_color_override("font_color", Color(0.78, 0.80, 0.84))
	layout.add_child(intro)

	var source_grid := GridContainer.new()
	source_grid.columns = 2
	source_grid.add_theme_constant_override("h_separation", 14)
	source_grid.add_theme_constant_override("v_separation", 8)
	layout.add_child(source_grid)
	source_grid.add_child(_make_label("엔티티"))
	event_selector = OptionButton.new()
	event_selector.custom_minimum_size = Vector2(460.0, 34.0)
	event_selector.focus_mode = Control.FOCUS_NONE
	event_selector.item_selected.connect(_on_event_selected)
	source_grid.add_child(event_selector)
	source_grid.add_child(_make_label("원본 맞춤"))
	fit_selector = OptionButton.new()
	fit_selector.custom_minimum_size = Vector2(240.0, 34.0)
	fit_selector.focus_mode = Control.FOCUS_NONE
	fit_selector.add_item("화면 채우기 · Cover", 0)
	fit_selector.add_item("원본 비율 · Contain", 1)
	source_grid.add_child(fit_selector)

	var separator := HSeparator.new()
	layout.add_child(separator)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 7)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(grid)
	for field in TUNABLE_FIELDS:
		grid.add_child(_make_label(String(field["label"])))
		var spin := SpinBox.new()
		spin.min_value = float(field["min"])
		spin.max_value = float(field["max"])
		spin.step = float(field["step"])
		spin.suffix = String(field["suffix"])
		spin.allow_greater = false
		spin.allow_lesser = false
		spin.custom_minimum_size = Vector2(185.0, 32.0)
		spin.update_on_text_changed = true
		controls[String(field["key"])] = spin
		grid.add_child(spin)
		var hint := _make_label(String(field["hint"]))
		hint.add_theme_color_override("font_color", Color(0.60, 0.64, 0.70))
		grid.add_child(hint)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 10)
	layout.add_child(action_row)
	preview_button = Button.new()
	preview_button.text = "▶ 현재 값으로 프리뷰"
	preview_button.custom_minimum_size = Vector2(250.0, 42.0)
	preview_button.focus_mode = Control.FOCUS_NONE
	preview_button.pressed.connect(preview_selected)
	action_row.add_child(preview_button)
	reset_button = Button.new()
	reset_button.text = "↺ 엔티티 기본값"
	reset_button.custom_minimum_size = Vector2(190.0, 42.0)
	reset_button.focus_mode = Control.FOCUS_NONE
	reset_button.pressed.connect(_load_selected_definition)
	action_row.add_child(reset_button)
	status_label = Label.new()
	status_label.text = "프리뷰는 사망 판정과 저장을 변경하지 않습니다."
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_label.add_theme_color_override("font_color", Color(0.72, 0.84, 0.74))
	action_row.add_child(status_label)


func _populate_events() -> void:
	event_selector.clear()
	if horror_event_manager == null:
		return
	var event_ids: Array[String] = []
	for event_id in horror_event_manager.definitions_by_id:
		var definition = horror_event_manager.get_definition(String(event_id))
		if definition != null and not String(definition.jumpscare_image_path).is_empty():
			event_ids.append(String(event_id))
	event_ids.sort()
	for event_id in event_ids:
		var definition = horror_event_manager.get_definition(event_id)
		var label := "%s · %s" % [_event_label(definition), event_id]
		event_selector.add_item(label)
		event_selector.set_item_metadata(event_selector.item_count - 1, event_id)
	if event_selector.item_count > 0:
		event_selector.select(0)
		_on_event_selected(0)


func _on_event_selected(index: int) -> void:
	if horror_event_manager == null or index < 0 or index >= event_selector.item_count:
		return
	var event_id := String(event_selector.get_item_metadata(index))
	selected_definition = horror_event_manager.get_definition(event_id)
	_load_selected_definition()


func _load_selected_definition() -> void:
	if selected_definition == null:
		return
	fit_selector.select(1 if String(selected_definition.jumpscare_fit_mode) == FIT_CONTAIN else 0)
	set_control_value("jumpscare_hold_seconds", float(selected_definition.jumpscare_hold_seconds))
	set_control_value("jumpscare_initial_zoom", float(selected_definition.jumpscare_initial_zoom))
	set_control_value("jumpscare_lunge_seconds", float(selected_definition.jumpscare_lunge_seconds))
	set_control_value("jumpscare_lunge_zoom", float(selected_definition.jumpscare_lunge_zoom))
	set_control_value("jumpscare_duration", float(selected_definition.jumpscare_duration))
	set_control_value("jumpscare_focus_x", float(selected_definition.jumpscare_focus_point.x))
	set_control_value("jumpscare_focus_y", float(selected_definition.jumpscare_focus_point.y))
	set_control_value("jumpscare_initial_shake", float(selected_definition.jumpscare_initial_shake))
	set_control_value("jumpscare_lunge_shake", float(selected_definition.jumpscare_lunge_shake))
	set_control_value("jumpscare_audio_volume_db", float(selected_definition.jumpscare_audio_volume_db))
	status_label.text = "%s 기본값 불러옴" % _event_label(selected_definition)


func _event_label(definition) -> String:
	return String(EVENT_LABELS.get(String(definition.id), definition.fallback_title))


func _make_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.90, 0.90, 0.92))
	return label


func _make_panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	return style
