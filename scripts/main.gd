extends Control

const HotelLocalization = preload("res://scripts/localization.gd")
const HotelInventoryModelScript = preload("res://scripts/items/inventory_model.gd")
const HotelItemCatalogScript = preload("res://scripts/items/item_catalog.gd")
const HotelEquipmentHudScript = preload("res://scripts/ui/equipment_hud.gd")
const HotelPauseMenuScript = preload("res://scripts/ui/pause_menu.gd")
const HotelLobbyScreenScript = preload("res://scripts/ui/lobby_screen.gd")
const HotelFilterSelectorPanelScript = preload("res://scripts/ui/filter_selector_panel.gd")
const HotelScene3DOverlayScript = preload("res://scripts/ui/scene_3d_overlay.gd")
const HotelSceneTransitionFaderScript = preload("res://scripts/ui/scene_transition_fader.gd")
const HotelPlaybackPauseManagerScript = preload("res://scripts/systems/playback_pause_manager.gd")
const HotelDaySaveManagerScript = preload("res://scripts/systems/day_save_manager.gd")
const HotelMetaProgressSaveManagerScript = preload("res://scripts/systems/meta_progress_save_manager.gd")
const HotelFlagStoreScript = preload("res://scripts/systems/flag_store.gd")
const HotelPostProcessFilterScript = preload("res://scripts/systems/post_process_filter.gd")
const HotelHorrorEventManagerScript = preload("res://scripts/horror/horror_event_manager.gd")
const HotelJumpscareControllerScript = preload("res://scripts/horror/jumpscare_controller.gd")
const HotelTaskManagerScript = preload("res://scripts/tasks/task_manager.gd")
const HotelRuleBookManagerScript = preload("res://scripts/rules/rule_book_manager.gd")
const HotelInteractionContextScript = preload("res://scripts/interactions/interaction_context.gd")
const HotelInteractionActionRunnerScript = preload("res://scripts/interactions/interaction_action_runner.gd")
const HotelSceneCatalogScript = preload("res://scripts/scenes/hotel_scene_catalog.gd")

const START_SCENE_ID := "front_desk"
const PARALLAX_PADDING := 48.0
const PARALLAX_STRENGTH := 18.0
const TITLE_VISIBLE_SECONDS := 2.0
const TITLE_FADE_SECONDS := 1.0
const DEBUG_UI_ENV := "HOTEL_DEBUG_UI"
const DEBUG_UI_ENABLED_VALUES := ["1", "true", "yes", "on"]
const DEFAULT_BRIGHTNESS := 1.0
const MIN_BRIGHTNESS := 0.55
const MAX_BRIGHTNESS := 1.45
const LAUNDRY_OPEN_PHOTO := "res://resource/images/laundry_room.png"
const LAUNDRY_CLOSED_PHOTO := "res://resource/images/laundry_room_washer_closed.png"
const FOOTSTEP_SOUND := "res://resource/sounds/footstep.ogg"
const FOOTSTEP_COUNT := 3
const FOOTSTEP_INTERVAL_SECONDS := 0.22
const FOOTSTEP_VOLUME_DB := -9.0
const FOOTSTEP_PITCHES := [0.94, 1.03, 0.98, 1.06]
const LOBBY_BACKGROUND_PHOTO := "res://resource/images/front_desk.png"

const IDLE_STYLE := {
	"bg": Color(1.0, 1.0, 1.0, 0.05),
	"border": Color(1.0, 1.0, 1.0, 0.22),
}
const HOVER_STYLE := {
	"bg": Color(1.0, 0.82, 0.28, 0.2),
	"border": Color(1.0, 0.82, 0.28, 0.9),
}
const PRESS_STYLE := {
	"bg": Color(0.25, 0.72, 1.0, 0.22),
	"border": Color(0.45, 0.82, 1.0, 0.95),
}
const HIDDEN_STYLE := {
	"bg": Color(1.0, 1.0, 1.0, 0.0),
	"border": Color(1.0, 1.0, 1.0, 0.0),
}

const HOTEL_SCENES := HotelSceneCatalogScript.SCENES

var localization := HotelLocalization.new()
var inventory_model = null
var playback_pause_manager = null
var day_save_manager = null
var meta_progress_save_manager = null
var flag_store = null
var task_manager = null
var horror_event_manager = null
var rule_book_manager = null
var interaction_runner = null
var current_scene_id := START_SCENE_ID
var current_texture: Texture2D
var hotspot_buttons: Array[Button] = []
var debug_ui_enabled := false
var show_hotspots := false
var show_persistent_dialogue := false
var show_navigation := false
var show_filter_selector := false
var laundry_second_washer_open := true
var game_brightness := DEFAULT_BRIGHTNESS
var current_persistent_dialogue_text := ""
var mouse_position := Vector2.ZERO
var title_tween: Tween
var transient_dialogue_tween: Tween
var footstep_stream: AudioStream
var footstep_players: Array[AudioStreamPlayer] = []
var footstep_timer: Timer
var footstep_index := 0
var game_started := false

var gameplay_layer: Control
var photo: TextureRect
var scene_3d_overlay
var brightness_overlay: ColorRect
var post_process_filter
var hotspot_layer: Control
var title_panel: PanelContainer
var title_label: Label
var day_badge_panel: PanelContainer
var day_badge_label: Label
var debug_panel: PanelContainer
var persistent_dialogue_panel: PanelContainer
var persistent_dialogue_label: Label
var transient_dialogue_panel: PanelContainer
var transient_dialogue_label: Label
var navigation_panel: PanelContainer
var nav_bar: HBoxContainer
var debug_day_bar: HBoxContainer
var filter_bar
var hotspot_toggle: Button
var chat_toggle: Button
var navigation_toggle: Button
var filter_toggle: Button
var menu_overlay: ColorRect
var brightness_slider: HSlider
var brightness_value_label: Label
var equipment_hud
var jumpscare_controller
var scene_transition_fader
var lobby_overlay: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_PASS
	_hide_editor_hotspot_definitions()
	_validate_scene_authoring()
	inventory_model = HotelInventoryModelScript.new()
	playback_pause_manager = HotelPlaybackPauseManagerScript.new()
	day_save_manager = HotelDaySaveManagerScript.new()
	meta_progress_save_manager = HotelMetaProgressSaveManagerScript.new()
	flag_store = HotelFlagStoreScript.new()
	flag_store.set_value(HotelInteractionActionRunnerScript.LAUNDRY_OPEN_FLAG, true)
	task_manager = HotelTaskManagerScript.new()
	task_manager.setup_default_catalog()
	horror_event_manager = HotelHorrorEventManagerScript.new()
	horror_event_manager.setup_default_catalog(flag_store)
	horror_event_manager.jumpscare_started.connect(_on_jumpscare_started)
	horror_event_manager.jumpscare_finished.connect(_on_jumpscare_finished)
	horror_event_manager.event_seen.connect(_on_horror_collection_changed)
	horror_event_manager.event_resolved.connect(_on_horror_collection_changed)
	rule_book_manager = HotelRuleBookManagerScript.new()
	rule_book_manager.setup_default_catalog()
	interaction_runner = HotelInteractionActionRunnerScript.new()
	interaction_runner.setup(flag_store, inventory_model, task_manager, horror_event_manager, rule_book_manager)
	debug_ui_enabled = _is_debug_ui_enabled()
	get_tree().root.size_changed.connect(_update_layout)
	HotelItemCatalogScript.register_defaults(inventory_model)
	HotelItemCatalogScript.reset_to_initial_items(inventory_model)
	day_save_manager.load_save_data()
	meta_progress_save_manager.load_save_data()
	horror_event_manager.import_collection_state(meta_progress_save_manager.get_collection_state())
	_build_ui()
	_build_audio()
	_show_lobby()


func _process(delta: float) -> void:
	if game_started and not _is_lobby_open() and not _is_menu_open():
		horror_event_manager.tick_scene_view(current_scene_id, delta)


func _is_debug_ui_enabled() -> bool:
	var value := OS.get_environment(DEBUG_UI_ENV).strip_edges().to_lower()
	return DEBUG_UI_ENABLED_VALUES.has(value) or OS.has_feature("editor")


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if horror_event_manager.is_jumpscare_active():
			get_viewport().set_input_as_handled()
			return

		if _is_lobby_open():
			get_viewport().set_input_as_handled()
			return

		_toggle_menu()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion and not _is_menu_open():
		mouse_position = event.position
		_update_layout()


func show_scene(scene_id: String, play_transition_sound := true) -> void:
	if not HOTEL_SCENES.has(scene_id):
		push_warning("Unknown hotel scene: %s" % scene_id)
		return

	if _should_use_scene_transition(scene_id, play_transition_sound):
		scene_transition_fader.play_scene_change(_apply_scene_change.bind(scene_id, play_transition_sound))
		return

	_apply_scene_change(scene_id, play_transition_sound)


func _should_use_scene_transition(scene_id: String, play_transition_sound: bool) -> bool:
	return play_transition_sound and current_scene_id != scene_id and scene_transition_fader != null and not scene_transition_fader.is_transitioning()


func _apply_scene_change(scene_id: String, play_transition_sound := true) -> void:
	if play_transition_sound and current_scene_id != scene_id:
		_play_transition_footsteps()

	current_scene_id = scene_id
	var scene_data: Dictionary = HOTEL_SCENES[current_scene_id]
	current_texture = load(_scene_photo(scene_id, scene_data)) as Texture2D
	photo.texture = current_texture
	if scene_3d_overlay != null:
		scene_3d_overlay.show_scene_overlay(scene_id)
	title_label.text = _scene_text(scene_id, scene_data, "title")
	_show_title_banner()
	_set_persistent_dialogue(_scene_text(scene_id, scene_data, "intro"))
	horror_event_manager.enter_scene(scene_id)
	_build_hotspots(_scene_hotspots(scene_id, scene_data))
	_build_navigation(scene_data["exits"])
	_apply_brightness()
	_update_layout()


func _build_ui() -> void:
	gameplay_layer = Control.new()
	gameplay_layer.process_mode = Node.PROCESS_MODE_PAUSABLE
	gameplay_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	gameplay_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(gameplay_layer)

	photo = TextureRect.new()
	photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gameplay_layer.add_child(photo)

	scene_3d_overlay = HotelScene3DOverlayScript.new()
	gameplay_layer.add_child(scene_3d_overlay)

	brightness_overlay = ColorRect.new()
	brightness_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	brightness_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gameplay_layer.add_child(brightness_overlay)
	_apply_brightness()

	post_process_filter = HotelPostProcessFilterScript.new()
	gameplay_layer.add_child(post_process_filter)

	hotspot_layer = Control.new()
	hotspot_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hotspot_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gameplay_layer.add_child(hotspot_layer)

	title_panel = PanelContainer.new()
	title_panel.position = Vector2(18.0, 18.0)
	title_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.78), Color(1.0, 1.0, 1.0, 0.10), 8))
	gameplay_layer.add_child(title_panel)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	title_panel.add_child(title_label)

	day_badge_panel = PanelContainer.new()
	day_badge_panel.visible = false
	day_badge_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	day_badge_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.10, 0.075, 0.035, 0.78), Color(1.0, 0.72, 0.25, 0.42), 999))
	gameplay_layer.add_child(day_badge_panel)

	day_badge_label = Label.new()
	day_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_badge_label.add_theme_font_size_override("font_size", 14)
	day_badge_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.58))
	day_badge_panel.add_child(day_badge_label)

	debug_panel = PanelContainer.new()
	debug_panel.anchor_left = 1.0
	debug_panel.anchor_right = 1.0
	debug_panel.anchor_top = 0.0
	debug_panel.anchor_bottom = 0.0
	debug_panel.offset_left = -280.0
	debug_panel.offset_top = 18.0
	debug_panel.offset_right = -18.0
	debug_panel.offset_bottom = 66.0
	debug_panel.visible = debug_ui_enabled
	debug_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.78), Color(1.0, 1.0, 1.0, 0.10), 8))
	gameplay_layer.add_child(debug_panel)

	var corner_row := HBoxContainer.new()
	corner_row.add_theme_constant_override("separation", 8)
	debug_panel.add_child(corner_row)

	hotspot_toggle = _make_debug_button("▣", _ui_text("debug.hotspots.show", "Show click areas"), _toggle_hotspots)
	corner_row.add_child(hotspot_toggle)

	chat_toggle = _make_debug_button("💬", _ui_text("debug.dialogue.hide", "Hide dialogue panel"), _toggle_chat)
	corner_row.add_child(chat_toggle)

	navigation_toggle = _make_debug_button("🧭", _ui_text("debug.navigation.show", "Show quick travel buttons"), _toggle_navigation)
	corner_row.add_child(navigation_toggle)

	filter_toggle = _make_debug_button("🎛", _ui_text("debug.filters.show", "Show filter selector"), _toggle_filter_selector)
	corner_row.add_child(filter_toggle)

	persistent_dialogue_panel = PanelContainer.new()
	persistent_dialogue_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	persistent_dialogue_panel.gui_input.connect(_on_persistent_dialogue_input)
	persistent_dialogue_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.82), Color(1.0, 1.0, 1.0, 0.10), 8))
	gameplay_layer.add_child(persistent_dialogue_panel)

	var bottom_layout := VBoxContainer.new()
	bottom_layout.add_theme_constant_override("separation", 10)
	persistent_dialogue_panel.add_child(bottom_layout)

	persistent_dialogue_label = Label.new()
	persistent_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	persistent_dialogue_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	persistent_dialogue_label.add_theme_font_size_override("font_size", 18)
	persistent_dialogue_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	bottom_layout.add_child(persistent_dialogue_label)

	transient_dialogue_panel = PanelContainer.new()
	transient_dialogue_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transient_dialogue_panel.visible = false
	transient_dialogue_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.78), Color(1.0, 1.0, 1.0, 0.0), 8))
	gameplay_layer.add_child(transient_dialogue_panel)

	transient_dialogue_label = Label.new()
	transient_dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transient_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	transient_dialogue_label.max_lines_visible = 2
	transient_dialogue_label.add_theme_font_size_override("font_size", 18)
	transient_dialogue_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	transient_dialogue_panel.add_child(transient_dialogue_label)

	navigation_panel = PanelContainer.new()
	navigation_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.82), Color(1.0, 1.0, 1.0, 0.10), 8))
	gameplay_layer.add_child(navigation_panel)

	var navigation_layout := VBoxContainer.new()
	navigation_layout.add_theme_constant_override("separation", 8)
	navigation_panel.add_child(navigation_layout)

	nav_bar = HBoxContainer.new()
	nav_bar.add_theme_constant_override("separation", 8)
	navigation_layout.add_child(nav_bar)

	debug_day_bar = HBoxContainer.new()
	debug_day_bar.add_theme_constant_override("separation", 8)
	navigation_layout.add_child(debug_day_bar)
	_build_debug_day_bar()

	filter_bar = HotelFilterSelectorPanelScript.new()
	filter_bar.setup(
		post_process_filter,
		_ui_text("debug.filters.title", "Filter"),
		_ui_text("debug.filters.tooltip", "Apply this screen filter."),
		_ui_text("debug.filters.intensity", "Intensity"),
		_ui_text("debug.filters.intensity_tooltip", "Filter intensity.")
	)
	filter_bar.preset_selected.connect(_on_filter_preset_selected)
	navigation_layout.add_child(filter_bar)

	equipment_hud = HotelEquipmentHudScript.new()
	equipment_hud.anchor_left = 0.0
	equipment_hud.anchor_right = 0.0
	equipment_hud.anchor_top = 1.0
	equipment_hud.anchor_bottom = 1.0
	equipment_hud.offset_left = 18.0
	equipment_hud.offset_top = -106.0
	equipment_hud.offset_right = 112.0
	equipment_hud.offset_bottom = -18.0
	gameplay_layer.add_child(equipment_hud)
	equipment_hud.bind_inventory(inventory_model, localization)
	equipment_hud.activated.connect(_show_menu)

	scene_transition_fader = HotelSceneTransitionFaderScript.new()
	gameplay_layer.add_child(scene_transition_fader)

	_position_bottom_panels()
	_apply_persistent_dialogue_display()
	_apply_navigation_display()
	_sync_debug_toggles()
	_build_menu()
	_build_lobby()
	_update_day_display()


func _hide_editor_hotspot_definitions() -> void:
	var definitions := get_node_or_null("HotspotDefinitions")
	if definitions is CanvasItem:
		definitions.visible = false


func _build_audio() -> void:
	footstep_stream = load(FOOTSTEP_SOUND) as AudioStream
	if footstep_stream == null:
		push_warning("Missing footstep sound: %s" % FOOTSTEP_SOUND)
		return

	for index in range(FOOTSTEP_COUNT):
		var player := AudioStreamPlayer.new()
		player.process_mode = Node.PROCESS_MODE_PAUSABLE
		player.stream = footstep_stream
		player.volume_db = FOOTSTEP_VOLUME_DB
		gameplay_layer.add_child(player)
		footstep_players.append(player)

	footstep_timer = Timer.new()
	footstep_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	footstep_timer.one_shot = false
	footstep_timer.wait_time = FOOTSTEP_INTERVAL_SECONDS
	footstep_timer.timeout.connect(_on_footstep_timer_timeout)
	gameplay_layer.add_child(footstep_timer)


func _build_menu() -> void:
	menu_overlay = HotelPauseMenuScript.new()
	add_child(menu_overlay)
	menu_overlay.setup(inventory_model, localization, rule_book_manager, game_brightness, MIN_BRIGHTNESS, MAX_BRIGHTNESS)
	menu_overlay.continue_requested.connect(_hide_menu)
	menu_overlay.main_menu_requested.connect(_return_to_lobby)
	menu_overlay.quit_requested.connect(_quit_game)
	menu_overlay.brightness_changed.connect(_on_brightness_changed)
	menu_overlay.rule_book_opened.connect(_on_rule_book_opened)
	brightness_slider = menu_overlay.brightness_slider
	brightness_value_label = menu_overlay.brightness_value_label

	jumpscare_controller = HotelJumpscareControllerScript.new()
	jumpscare_controller.finished.connect(_on_jumpscare_controller_finished)
	add_child(jumpscare_controller)


func _build_lobby() -> void:
	lobby_overlay = HotelLobbyScreenScript.new()
	add_child(lobby_overlay)
	lobby_overlay.setup(localization, horror_event_manager, day_save_manager, LOBBY_BACKGROUND_PHOTO)
	lobby_overlay.start_shift_requested.connect(_start_shift)
	lobby_overlay.day_selected.connect(_start_saved_day)
	lobby_overlay.quit_requested.connect(_quit_game)


func set_post_process_preset(preset_name: String) -> void:
	if post_process_filter != null:
		post_process_filter.apply_preset(preset_name)
	if filter_bar != null:
		filter_bar.sync_selected_preset()


func clear_post_process_filter() -> void:
	if post_process_filter != null:
		post_process_filter.clear_filter()
	if filter_bar != null:
		filter_bar.sync_selected_preset()


func _show_lobby() -> void:
	game_started = false
	if lobby_overlay != null:
		lobby_overlay.open(_localized_horror_summary())

	_set_game_paused(true)


func _start_shift() -> void:
	day_save_manager.start_new_shift()
	HotelItemCatalogScript.reset_to_initial_items(inventory_model)
	horror_event_manager.start_new_run()
	task_manager.start_new_run()
	rule_book_manager.import_state({})
	flag_store.clear()
	flag_store.set_value(HotelInteractionActionRunnerScript.LAUNDRY_OPEN_FLAG, true)
	laundry_second_washer_open = _is_laundry_second_washer_open()
	game_brightness = DEFAULT_BRIGHTNESS
	_start_day(1, false, false)


func _start_saved_day(day: int) -> void:
	_start_day(day, true, false)


func _start_day(day: int, use_saved_state: bool, play_transition_sound: bool) -> void:
	game_started = true
	day_save_manager.set_current_day(day)

	if lobby_overlay != null:
		lobby_overlay.close()

	_set_game_paused(false)

	var target_scene_id := START_SCENE_ID
	if use_saved_state:
		target_scene_id = _restore_day_state(day_save_manager.current_day)
	else:
		_reset_day_runtime_state()

	show_scene(target_scene_id, play_transition_sound)
	_save_current_day()
	_update_day_display()


func _is_lobby_open() -> bool:
	return lobby_overlay != null and lobby_overlay.visible


func _save_current_day() -> void:
	day_save_manager.save_current_state(_capture_day_state())
	_refresh_lobby_continue_state()


func _capture_day_state() -> Dictionary:
	laundry_second_washer_open = _is_laundry_second_washer_open()
	return {
		"scene_id": current_scene_id,
		"laundry_second_washer_open": laundry_second_washer_open,
		"game_brightness": game_brightness,
		"flags": flag_store.export_state(),
		"inventory": inventory_model.export_state(),
		"tasks": task_manager.export_state(),
		"horror": horror_event_manager.export_state(),
		"rules": rule_book_manager.export_state(),
	}


func _restore_day_state(day: int) -> String:
	var slot: Dictionary = day_save_manager.get_day_state(day)
	if slot.has("flags"):
		flag_store.import_state(slot.get("flags", {}))
	else:
		flag_store.clear()
		flag_store.set_value(HotelInteractionActionRunnerScript.LAUNDRY_OPEN_FLAG, bool(slot.get("laundry_second_washer_open", true)))
	laundry_second_washer_open = _is_laundry_second_washer_open()
	game_brightness = float(slot.get("game_brightness", DEFAULT_BRIGHTNESS))
	if brightness_slider != null:
		brightness_slider.value = game_brightness

	if slot.has("inventory"):
		inventory_model.import_state(slot.get("inventory", {}))
	task_manager.import_state(slot.get("tasks", {}))
	horror_event_manager.import_state(slot.get("horror", {}))
	meta_progress_save_manager.save_collection_state(horror_event_manager.export_collection_state())
	rule_book_manager.import_state(slot.get("rules", {}))
	var saved_scene_id := String(slot.get("scene_id", START_SCENE_ID))
	if not HOTEL_SCENES.has(saved_scene_id):
		return START_SCENE_ID

	return saved_scene_id


func _reset_day_runtime_state() -> void:
	flag_store.clear()
	flag_store.set_value(HotelInteractionActionRunnerScript.LAUNDRY_OPEN_FLAG, true)
	laundry_second_washer_open = _is_laundry_second_washer_open()
	game_brightness = DEFAULT_BRIGHTNESS
	task_manager.start_new_run()
	horror_event_manager.start_new_run()
	rule_book_manager.import_state({})
	if brightness_slider != null:
		brightness_slider.value = game_brightness


func _change_day(day: int) -> void:
	var target_day: int = day_save_manager.clamp_day(day)
	if target_day == day_save_manager.current_day:
		return

	_save_current_day()
	_start_day(target_day, day_save_manager.has_saved_day(target_day), false)


func _day_name(day: int) -> String:
	return _ui_text("day.label", "Day %d") % day


func _refresh_lobby_continue_state() -> void:
	if lobby_overlay != null:
		lobby_overlay.refresh_continue_state()


func _localized_horror_summary() -> String:
	var total_count: int = horror_event_manager.get_discovered_count()
	if total_count == 0:
		return _ui_text("lobby.horror_summary.none", "Anomalies found: 0")

	var parts := []
	var kind_counts: Dictionary = horror_event_manager.get_discovered_kind_counts()
	for kind in kind_counts.keys():
		var kind_name := _ui_text("anomaly_collection.kind.%s" % kind, String(kind).capitalize())
		parts.append("%s %d" % [kind_name, int(kind_counts[kind])])
	return _ui_text("lobby.horror_summary.count", "Anomalies found: %d (%s)") % [total_count, ", ".join(parts)]


func _build_hotspots(hotspots: Array) -> void:
	for button in hotspot_buttons:
		button.queue_free()
	hotspot_buttons.clear()

	for hotspot in hotspots:
		var label := _hotspot_text(hotspot, "label")
		var button := Button.new()
		button.text = label
		button.tooltip_text = _hotspot_tooltip(hotspot, label)
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.set_meta("hotspot", hotspot)
		button.add_theme_font_size_override("font_size", 15)
		button.pressed.connect(_on_hotspot_pressed.bind(hotspot))
		hotspot_layer.add_child(button)
		hotspot_buttons.append(button)

	_apply_hotspot_display()


func _build_navigation(exits: Array) -> void:
	for child in nav_bar.get_children():
		child.queue_free()

	for exit_data in exits:
		var button := Button.new()
		button.text = _exit_label(exit_data)
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(_on_navigation_pressed.bind(exit_data["target"]))
		nav_bar.add_child(button)

	_apply_navigation_display()


func _build_debug_day_bar() -> void:
	if debug_day_bar == null:
		return

	for child in debug_day_bar.get_children():
		child.queue_free()

	var title := Label.new()
	title.text = _ui_text("debug.days.title", "Day")
	title.custom_minimum_size = Vector2(54.0, 0.0)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.58))
	debug_day_bar.add_child(title)

	for day in range(1, HotelDaySaveManagerScript.TOTAL_DAYS + 1):
		var day_button := Button.new()
		day_button.text = str(day)
		day_button.toggle_mode = true
		day_button.focus_mode = Control.FOCUS_NONE
		day_button.custom_minimum_size = Vector2(38.0, 32.0)
		day_button.tooltip_text = _ui_text("debug.days.tooltip", "Jump to this day and autosave the current day.")
		day_button.pressed.connect(_change_day.bind(day))
		debug_day_bar.add_child(day_button)

	_refresh_debug_day_buttons()


func _on_navigation_pressed(scene_id: String) -> void:
	show_scene(scene_id)


func _on_filter_preset_selected(preset_name: String) -> void:
	set_post_process_preset(preset_name)


func _on_hotspot_pressed(hotspot: Dictionary) -> void:
	_apply_interaction_result(interaction_runner.execute_hotspot(hotspot, _make_interaction_context(hotspot)))


func _run_hotspot_action(action: String) -> void:
	_apply_interaction_result(interaction_runner.execute_action(action, _make_interaction_context({})))


func _make_interaction_context(hotspot: Dictionary):
	var context = HotelInteractionContextScript.new()
	context.scene_id = current_scene_id
	context.room_id = horror_event_manager.room_registry.get_room_id(current_scene_id)
	context.hotspot_id = String(hotspot.get("id", ""))
	context.day = day_save_manager.current_day
	if inventory_model.equipped_item != null:
		context.equipped_item_id = String(inventory_model.equipped_item.id)
	if hotspot.has("horror_event_id"):
		context.horror_event_id = String(hotspot["horror_event_id"])
	return context


func _apply_interaction_result(result) -> void:
	if result == null:
		return

	if not result.changed_scene_id.is_empty():
		show_scene(result.changed_scene_id)

	if result.should_refresh_photo:
		_refresh_current_scene_photo()

	if result.should_refresh_hotspots and HOTEL_SCENES.has(current_scene_id):
		_build_hotspots(_scene_hotspots(current_scene_id, HOTEL_SCENES[current_scene_id]))
		_update_layout()

	if result.has_dialogue():
		_show_transient_dialogue(localization.translate(result.dialogue_key, result.fallback_dialogue))

	if result.should_save:
		_save_current_day()


func _play_transition_footsteps() -> void:
	if footstep_stream == null or footstep_players.is_empty() or footstep_timer == null:
		return

	footstep_timer.stop()
	footstep_index = 0
	_play_next_footstep()
	if footstep_index < FOOTSTEP_COUNT:
		footstep_timer.start()


func _on_footstep_timer_timeout() -> void:
	_play_next_footstep()
	if footstep_index >= FOOTSTEP_COUNT:
		footstep_timer.stop()


func _play_next_footstep() -> void:
	var player := footstep_players[footstep_index % footstep_players.size()]
	player.pitch_scale = FOOTSTEP_PITCHES[footstep_index % FOOTSTEP_PITCHES.size()]
	player.stop()
	player.play()
	footstep_index += 1


func _toggle_laundry_washer() -> void:
	flag_store.set_value(HotelInteractionActionRunnerScript.LAUNDRY_OPEN_FLAG, not _is_laundry_second_washer_open())
	laundry_second_washer_open = _is_laundry_second_washer_open()
	if current_scene_id == "laundry_room":
		_refresh_current_scene_photo()

	var state_key := "opened" if laundry_second_washer_open else "closed"
	var message := "The second washer door is open." if laundry_second_washer_open else "The second washer door is closed."
	_show_transient_dialogue(localization.translate("hotspot.laundry_room.laundry_second_washer.%s" % state_key, message))


func _refresh_current_scene_photo() -> void:
	if not HOTEL_SCENES.has(current_scene_id):
		return

	var scene_data: Dictionary = HOTEL_SCENES[current_scene_id]
	current_texture = load(_scene_photo(current_scene_id, scene_data)) as Texture2D
	photo.texture = current_texture
	_apply_brightness()
	_update_layout()


func _is_laundry_second_washer_open() -> bool:
	if flag_store != null:
		return flag_store.get_bool(HotelInteractionActionRunnerScript.LAUNDRY_OPEN_FLAG, true)

	return laundry_second_washer_open


func _toggle_hotspots() -> void:
	show_hotspots = not show_hotspots
	_apply_hotspot_display()


func _toggle_chat() -> void:
	show_persistent_dialogue = not show_persistent_dialogue
	_apply_persistent_dialogue_display()


func _toggle_navigation() -> void:
	show_navigation = not show_navigation
	_apply_navigation_display()


func _toggle_filter_selector() -> void:
	show_filter_selector = not show_filter_selector
	_apply_navigation_display()


func _toggle_menu() -> void:
	if menu_overlay == null:
		return

	if menu_overlay.visible:
		_hide_menu()
	else:
		_show_menu()


func _show_menu() -> void:
	if menu_overlay == null:
		return
	if not game_started:
		return

	menu_overlay.open()
	_set_game_paused(true)


func _hide_menu() -> void:
	if menu_overlay == null:
		return

	menu_overlay.close()
	_set_game_paused(false)


func _is_menu_open() -> bool:
	return menu_overlay != null and menu_overlay.visible


func _show_inventory_menu_panel() -> void:
	if menu_overlay != null:
		menu_overlay.show_inventory()


func _show_rule_book_menu_panel() -> void:
	if menu_overlay != null:
		menu_overlay.show_rule_book()


func _on_rule_book_opened() -> void:
	_save_current_day()

func _return_to_lobby() -> void:
	_save_current_day()
	if menu_overlay != null:
		menu_overlay.close()

	_show_lobby()


func _on_jumpscare_started(definition) -> void:
	if jumpscare_controller != null:
		jumpscare_controller.play(definition, localization)


func _on_jumpscare_controller_finished() -> void:
	horror_event_manager.finish_jumpscare()


func _on_jumpscare_finished(_definition, outcome: String) -> void:
	_save_current_day()
	if outcome == "game_over":
		_show_lobby()


func _on_horror_collection_changed(_definition) -> void:
	meta_progress_save_manager.save_collection_state(horror_event_manager.export_collection_state())


func _set_game_paused(paused: bool) -> void:
	if paused:
		playback_pause_manager.pause_tree(get_tree(), gameplay_layer)
	else:
		playback_pause_manager.resume_tree(get_tree())


func _quit_game() -> void:
	get_tree().quit()


func _on_brightness_changed(value: float) -> void:
	game_brightness = value
	_apply_brightness()


func _apply_brightness() -> void:
	if brightness_overlay == null:
		return

	var effective_brightness := game_brightness
	if effective_brightness < DEFAULT_BRIGHTNESS:
		var darkness := (DEFAULT_BRIGHTNESS - effective_brightness) / (DEFAULT_BRIGHTNESS - MIN_BRIGHTNESS)
		brightness_overlay.color = Color(0.0, 0.0, 0.0, darkness * 0.55)
	elif effective_brightness > DEFAULT_BRIGHTNESS:
		var lightness := (effective_brightness - DEFAULT_BRIGHTNESS) / (MAX_BRIGHTNESS - DEFAULT_BRIGHTNESS)
		brightness_overlay.color = Color(1.0, 1.0, 1.0, lightness * 0.28)
	else:
		brightness_overlay.color = Color(0.0, 0.0, 0.0, 0.0)

	_update_brightness_label()


func _update_brightness_label() -> void:
	if brightness_value_label == null:
		return

	if menu_overlay != null:
		menu_overlay.set_brightness_value(game_brightness)
	else:
		brightness_value_label.text = "%d%%" % roundi(game_brightness * 100.0)


func _on_persistent_dialogue_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_hide_persistent_dialogue()


func _show_transient_dialogue(message: String) -> void:
	if transient_dialogue_panel == null:
		return

	if not show_persistent_dialogue:
		_hide_transient_dialogue()
		return

	transient_dialogue_label.text = message
	_position_transient_dialogue()
	transient_dialogue_panel.visible = true
	transient_dialogue_panel.modulate.a = 1.0

	if transient_dialogue_tween != null:
		transient_dialogue_tween.kill()

	transient_dialogue_tween = create_tween()
	transient_dialogue_tween.tween_interval(2.0)
	transient_dialogue_tween.tween_property(transient_dialogue_panel, "modulate:a", 0.0, 0.6)
	transient_dialogue_tween.finished.connect(_hide_transient_dialogue)


func _hide_transient_dialogue() -> void:
	if transient_dialogue_panel != null:
		transient_dialogue_panel.visible = false

	transient_dialogue_tween = null


func _position_transient_dialogue() -> void:
	if transient_dialogue_panel == null or transient_dialogue_label == null:
		return

	var viewport_size := get_viewport_rect().size
	var max_width := minf(720.0, viewport_size.x - 48.0)
	var estimated_width := clampf(transient_dialogue_label.text.length() * 10.0 + 48.0, 220.0, max_width)
	transient_dialogue_label.custom_minimum_size = Vector2(estimated_width, 0.0)
	transient_dialogue_panel.size = transient_dialogue_panel.get_combined_minimum_size()
	transient_dialogue_panel.position = Vector2((viewport_size.x - transient_dialogue_panel.size.x) * 0.5, viewport_size.y - 205.0)


func _scene_text(scene_id: String, scene_data: Dictionary, field: String) -> String:
	return localization.translate("scene.%s.%s" % [scene_id, field], scene_data.get(field, ""))


func _scene_photo(scene_id: String, scene_data: Dictionary) -> String:
	if scene_id == "laundry_room" and not _is_laundry_second_washer_open():
		return localization.translate_scene_photo(scene_id, LAUNDRY_CLOSED_PHOTO, "closed")

	return localization.translate_scene_photo(scene_id, scene_data["photo"])


func _scene_hotspots(scene_id: String, scene_data: Dictionary) -> Array:
	var editor_hotspots := _editor_hotspots_for_scene(scene_id)
	var hotspots := editor_hotspots.duplicate(true)
	for task_hotspot in task_manager.get_hotspots_for_scene(scene_id):
		hotspots.append(task_hotspot)
	for horror_hotspot in horror_event_manager.get_revealed_hotspots(scene_id):
		hotspots.append(horror_hotspot)

	return hotspots


func _validate_scene_authoring() -> void:
	var definitions := get_node_or_null("HotspotDefinitions")
	if definitions == null:
		push_error("HotspotDefinitions is required. Runtime hotspots are authored only in scenes/main.tscn.")
		return

	for scene_id in HOTEL_SCENES.keys():
		var scene_group := definitions.get_node_or_null(String(scene_id))
		if scene_group == null:
			push_error("Missing editor hotspot scene group: %s" % scene_id)
			continue
		var hotspot_count := 0
		for child in scene_group.get_children():
			if child.has_method("to_hotspot_data"):
				hotspot_count += 1
		if hotspot_count == 0:
			push_warning("Scene has no authored hotspots: %s" % scene_id)


func _editor_hotspots_for_scene(scene_id: String) -> Array:
	var definitions := get_node_or_null("HotspotDefinitions")
	if definitions == null:
		return []

	var scene_group := definitions.get_node_or_null(scene_id)
	if scene_group == null:
		return []

	var authoring_size := Vector2(1280.0, 720.0)
	if scene_group is Control and scene_group.size.x > 0.0 and scene_group.size.y > 0.0:
		authoring_size = scene_group.size

	var hotspots := []
	for child in scene_group.get_children():
		if child.has_method("to_hotspot_data"):
			hotspots.append(child.to_hotspot_data(authoring_size))

	return hotspots


func _hotspot_text(hotspot: Dictionary, field: String) -> String:
	var hotspot_id: String = hotspot.get("id", "unknown")
	var direct_key := String(hotspot.get("%s_key" % field, ""))
	if not direct_key.is_empty():
		return localization.translate(direct_key, hotspot.get(field, ""))

	return localization.translate("hotspot.%s.%s.%s" % [current_scene_id, hotspot_id, field], hotspot.get(field, ""))


func _hotspot_tooltip(hotspot: Dictionary, fallback: String) -> String:
	if hotspot.has("text"):
		return _hotspot_text(hotspot, "text")

	return fallback


func _exit_label(exit_data: Dictionary) -> String:
	return localization.translate("exit.%s.%s.label" % [current_scene_id, exit_data["target"]], exit_data["label"])


func _ui_text(key: String, fallback: String) -> String:
	return localization.translate("ui.%s" % key, fallback)


func _apply_hotspot_display() -> void:
	_sync_debug_toggles()

	for button in hotspot_buttons:
		var hotspot: Dictionary = button.get_meta("hotspot")
		var label := _hotspot_text(hotspot, "label")
		if show_hotspots:
			button.text = label
			button.tooltip_text = _hotspot_tooltip(hotspot, label)
			button.add_theme_stylebox_override("normal", _make_panel_style(IDLE_STYLE["bg"], IDLE_STYLE["border"], 5))
			button.add_theme_stylebox_override("hover", _make_panel_style(HOVER_STYLE["bg"], HOVER_STYLE["border"], 5))
			button.add_theme_stylebox_override("pressed", _make_panel_style(PRESS_STYLE["bg"], PRESS_STYLE["border"], 5))
			button.add_theme_color_override("font_color", Color(1.0, 0.96, 0.78))
			button.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.62))
		else:
			button.text = ""
			button.tooltip_text = ""
			button.add_theme_stylebox_override("normal", _make_panel_style(HIDDEN_STYLE["bg"], HIDDEN_STYLE["border"], 5))
			button.add_theme_stylebox_override("hover", _make_panel_style(HIDDEN_STYLE["bg"], HIDDEN_STYLE["border"], 5))
			button.add_theme_stylebox_override("pressed", _make_panel_style(HIDDEN_STYLE["bg"], HIDDEN_STYLE["border"], 5))
			button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.0))
			button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 0.0))


func _apply_persistent_dialogue_display() -> void:
	persistent_dialogue_panel.visible = show_persistent_dialogue
	if not show_persistent_dialogue:
		_hide_transient_dialogue()

	_position_bottom_panels()
	_sync_debug_toggles()


func _apply_navigation_display() -> void:
	var effective_filter_selector := debug_ui_enabled and show_filter_selector
	navigation_panel.visible = show_navigation or effective_filter_selector
	if nav_bar != null:
		nav_bar.visible = show_navigation
	if debug_day_bar != null:
		debug_day_bar.visible = debug_ui_enabled and show_navigation
	if filter_bar != null:
		filter_bar.visible = effective_filter_selector
	_position_bottom_panels()
	_sync_debug_toggles()


func _sync_debug_toggles() -> void:
	if debug_panel != null:
		debug_panel.visible = debug_ui_enabled

	if hotspot_toggle == null:
		return

	hotspot_toggle.button_pressed = show_hotspots
	hotspot_toggle.tooltip_text = _ui_text("debug.hotspots.hide", "Hide click areas") if show_hotspots else _ui_text("debug.hotspots.show", "Show click areas")
	_style_debug_button(hotspot_toggle, show_hotspots)

	chat_toggle.button_pressed = show_persistent_dialogue
	chat_toggle.tooltip_text = _ui_text("debug.dialogue.hide", "Hide dialogue panel") if show_persistent_dialogue else _ui_text("debug.dialogue.show", "Show dialogue panel")
	_style_debug_button(chat_toggle, show_persistent_dialogue)

	navigation_toggle.button_pressed = show_navigation
	navigation_toggle.tooltip_text = _ui_text("debug.navigation.hide", "Hide quick travel buttons") if show_navigation else _ui_text("debug.navigation.show", "Show quick travel buttons")
	_style_debug_button(navigation_toggle, show_navigation)

	filter_toggle.button_pressed = show_filter_selector
	filter_toggle.tooltip_text = _ui_text("debug.filters.hide", "Hide filter selector") if show_filter_selector else _ui_text("debug.filters.show", "Show filter selector")
	_style_debug_button(filter_toggle, show_filter_selector)

	if filter_bar != null:
		filter_bar.sync_selected_preset()


func _position_bottom_panels() -> void:
	if persistent_dialogue_panel != null:
		persistent_dialogue_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		persistent_dialogue_panel.offset_left = 18.0
		persistent_dialogue_panel.offset_top = -150.0
		persistent_dialogue_panel.offset_right = -18.0
		persistent_dialogue_panel.offset_bottom = -18.0

	if navigation_panel != null:
		navigation_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		navigation_panel.offset_left = 18.0
		navigation_panel.offset_right = -18.0
		var visible_rows := 0
		visible_rows += 1 if show_navigation else 0
		visible_rows += 1 if debug_ui_enabled and show_navigation else 0
		visible_rows += 1 if debug_ui_enabled and show_filter_selector else 0
		var panel_height := maxf(56.0, 24.0 + visible_rows * 32.0 + max(visible_rows - 1, 0) * 8.0)
		if show_persistent_dialogue:
			navigation_panel.offset_bottom = -162.0
			navigation_panel.offset_top = navigation_panel.offset_bottom - panel_height
		else:
			navigation_panel.offset_bottom = -18.0
			navigation_panel.offset_top = navigation_panel.offset_bottom - panel_height


func _set_persistent_dialogue(message: String) -> void:
	current_persistent_dialogue_text = message
	persistent_dialogue_label.text = current_persistent_dialogue_text
	_apply_persistent_dialogue_display()


func _hide_persistent_dialogue() -> void:
	show_persistent_dialogue = false
	_apply_persistent_dialogue_display()


func _update_layout() -> void:
	if photo == null:
		return

	var viewport_size := get_viewport_rect().size
	var offset := _get_parallax_offset(viewport_size)
	photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	photo.position = Vector2(-PARALLAX_PADDING, -PARALLAX_PADDING) + offset
	photo.size = viewport_size + Vector2(PARALLAX_PADDING * 2.0, PARALLAX_PADDING * 2.0)
	if scene_3d_overlay != null:
		scene_3d_overlay.apply_photo_parallax(offset, PARALLAX_PADDING)
	_position_title_panel()
	_position_transient_dialogue()
	_update_hotspot_layout()
	_update_day_display()


func _update_hotspot_layout() -> void:
	if current_texture == null:
		return

	var image_rect := _get_photo_draw_rect()
	for button in hotspot_buttons:
		var hotspot: Dictionary = button.get_meta("hotspot")
		var normalized_rect: Rect2 = hotspot["rect"]
		button.position = image_rect.position + normalized_rect.position * image_rect.size
		button.size = normalized_rect.size * image_rect.size


func _get_photo_draw_rect() -> Rect2:
	var texture_size: Vector2 = current_texture.get_size()
	var scale: float = maxf(photo.size.x / texture_size.x, photo.size.y / texture_size.y)
	var draw_size: Vector2 = texture_size * scale
	var draw_position: Vector2 = photo.position + (photo.size - draw_size) * 0.5
	return Rect2(draw_position, draw_size)


func _get_parallax_offset(viewport_size: Vector2) -> Vector2:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return Vector2.ZERO

	var normalized_mouse := (mouse_position / viewport_size) - Vector2(0.5, 0.5)
	return -normalized_mouse * PARALLAX_STRENGTH


func _show_title_banner() -> void:
	_position_title_panel()

	if title_tween != null:
		title_tween.kill()

	title_panel.visible = true
	title_panel.modulate.a = 1.0
	title_tween = create_tween()
	title_tween.tween_interval(TITLE_VISIBLE_SECONDS)
	title_tween.tween_property(title_panel, "modulate:a", 0.0, TITLE_FADE_SECONDS)
	title_tween.finished.connect(_hide_title_banner)


func _hide_title_banner() -> void:
	title_panel.visible = false
	title_tween = null


func _position_title_panel() -> void:
	if title_panel == null:
		return

	title_panel.size = title_panel.get_combined_minimum_size()
	title_panel.position = Vector2(18.0, 18.0)
	if day_badge_panel != null:
		day_badge_panel.size = day_badge_panel.get_combined_minimum_size()
		day_badge_panel.position = Vector2(18.0, 64.0)


func _update_day_display() -> void:
	if day_badge_panel == null or day_badge_label == null:
		return

	day_badge_panel.visible = game_started
	day_badge_label.text = _day_name(day_save_manager.current_day)
	day_badge_panel.size = day_badge_panel.get_combined_minimum_size()
	_refresh_debug_day_buttons()


func _refresh_debug_day_buttons() -> void:
	if debug_day_bar == null:
		return

	for child in debug_day_bar.get_children():
		if child is Button:
			var day := int(child.text)
			child.button_pressed = day == day_save_manager.current_day
			_style_debug_button(child, day == day_save_manager.current_day)


func _make_debug_button(icon: String, tooltip: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = icon
	button.tooltip_text = tooltip
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(40.0, 32.0)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(callback)
	return button


func _style_debug_button(button: Button, enabled: bool) -> void:
	var background := Color(0.25, 0.72, 1.0, 0.24) if enabled else Color(1.0, 1.0, 1.0, 0.05)
	var border := Color(0.45, 0.82, 1.0, 0.85) if enabled else Color(1.0, 1.0, 1.0, 0.18)
	button.add_theme_stylebox_override("normal", _make_panel_style(background, border, 6))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(1.0, 0.82, 0.28, 0.20), Color(1.0, 0.82, 0.28, 0.85), 6))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.25, 0.72, 1.0, 0.30), Color(0.45, 0.82, 1.0, 0.95), 6))
	button.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 0.72) if enabled else Color(0.95, 0.95, 0.95, 0.50))


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
