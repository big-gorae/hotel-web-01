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
const HotelShowerCurtainStateScript = preload("res://scripts/interactions/shower_curtain_state.gd")
const HotelSceneCatalogScript = preload("res://scripts/scenes/hotel_scene_catalog.gd")
const HotelEyeCloseControllerScript = preload("res://scripts/systems/eye_close_controller.gd")
const HotelMoldGrowthSystemScript = preload("res://scripts/horror/mold_growth_system.gd")
const HotelMoldOverlayScript = preload("res://scripts/ui/mold_overlay.gd")
const HotelNightAnomalyDirectorScript = preload("res://scripts/horror/night_anomaly_director.gd")
const HotelRoom109OverlayScript = preload("res://scripts/ui/room_109_overlay.gd")
const HotelTypewriterDialogueControllerScript = preload("res://scripts/dialogue/typewriter_dialogue_controller.gd")
const HotelAnomalyContentRuntimeScript = preload("res://scripts/horror/anomaly_content_runtime.gd")
const HotelAnomalyContentCatalogScript = preload("res://scripts/horror/anomaly_content_catalog.gd")
const HotelAnomalyVisualOverlayScript = preload("res://scripts/ui/anomaly_visual_overlay.gd")
const HotelAnomalyPresentationLayerScript = preload("res://scripts/ui/anomaly_presentation_layer.gd")
const HotelHoldProgressOverlayScript = preload("res://scripts/ui/hold_progress_overlay.gd")
const HotelJumpscareLabScript = preload("res://scripts/ui/jumpscare_lab.gd")
const HotelAnomalyAudioControllerScript = preload("res://scripts/horror/anomaly_audio_controller.gd")
const HotelEquippedItemHazardControllerScript = preload("res://scripts/horror/equipped_item_hazard_controller.gd")
const HotelChoiceDialogueOverlayScript = preload("res://scripts/ui/choice_dialogue_overlay.gd")
const HotelStoryDeliveryManagerScript = preload("res://scripts/story/story_delivery_manager.gd")

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
const DEBUG_CURTAIN_PREV_PHOTO := "res://resource/images/prev/화장실 닫힌 커튼 후보.png"
const FOOTSTEP_SOUND := "res://resource/sounds/footstep.ogg"
const FOOTSTEP_COUNT := 3
const FOOTSTEP_INTERVAL_SECONDS := 0.22
const FOOTSTEP_VOLUME_DB := -9.0
const FOOTSTEP_PITCHES := [0.94, 1.03, 0.98, 1.06]
const LOBBY_BACKGROUND_PHOTO := "res://resource/images/front_desk.png"
const LETHAL_GIMMICKS_ENABLED := true
const MOLD_PIG_MASK_EVENT_ID := "room_105_closet_woman"
const DEBUG_CURTAIN_GAMEPLAY := 0
const DEBUG_CURTAIN_OPEN := 1
const DEBUG_CURTAIN_CLOSED_EDIT := 2
const DEBUG_CURTAIN_CLOSED_PREV := 3
const MVP_NIGHT_DEBUG_EVENT_IDS := [
	"laundry_red_washer",
	"room_106_abandoned_child",
	"vacant_room_blanket_child",
]
const DIALOGUE_GRADIENT_SHADER_CODE := "shader_type canvas_item;\nuniform vec4 top_color : source_color = vec4(0.0, 0.0, 0.0, 0.94);\nuniform vec4 bottom_color : source_color = vec4(0.0, 0.0, 0.0, 0.10);\nvoid fragment() {\n\tfloat fade = smoothstep(0.0, 1.0, UV.y);\n\tCOLOR = mix(top_color, bottom_color, fade);\n}\n"

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
var shower_curtain_state = null
var eye_close_controller = null
var mold_growth_system = null
var night_anomaly_director = null
var anomaly_content_runtime = null
var equipped_item_hazard_controller = null
var story_delivery_manager = null
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
var mold_spray_player: AudioStreamPlayer
var game_started := false
var intro_dialogue_active := false
var intro_dialogue_index := 0
var mold_removal_in_progress := false
var debug_curtain_preview_mode := DEBUG_CURTAIN_GAMEPLAY
var debug_last_closed_curtain_preview := DEBUG_CURTAIN_CLOSED_EDIT
var debug_anomaly_preview_event_id := ""

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
var end_shift_button: Button
var debug_panel: PanelContainer
var persistent_dialogue_panel: PanelContainer
var persistent_dialogue_label: Label
var persistent_dialogue_hint_label: Label
var intro_input_blocker: ColorRect
var dialogue_gradient: ColorRect
var typewriter_dialogue_controller
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
var debug_curtain_preview_selector: OptionButton
var debug_anomaly_selector: OptionButton
var debug_jumpscare_lab_button: Button
var menu_overlay: ColorRect
var brightness_slider: HSlider
var brightness_value_label: Label
var equipment_hud
var jumpscare_controller
var jumpscare_lab
var scene_transition_fader
var lobby_overlay: Control
var mold_overlay
var room_109_overlay
var anomaly_visual_overlay
var anomaly_presentation_layer
var hold_progress_overlay
var choice_dialogue_overlay
var anomaly_audio_controller
var eye_radius_slider: HSlider
var phone_bell_panel: PanelContainer
var phone_bell_label: Label
var system_message_panel: PanelContainer
var system_message_label: Label
var system_message_tween: Tween
var mold_closet_timer: Timer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_PASS
	_hide_editor_hotspot_definitions()
	_validate_scene_authoring()
	inventory_model = HotelInventoryModelScript.new()
	playback_pause_manager = HotelPlaybackPauseManagerScript.new()
	day_save_manager = HotelDaySaveManagerScript.new()
	meta_progress_save_manager = HotelMetaProgressSaveManagerScript.new()
	story_delivery_manager = HotelStoryDeliveryManagerScript.new()
	flag_store = HotelFlagStoreScript.new()
	flag_store.set_value(HotelInteractionActionRunnerScript.LAUNDRY_OPEN_FLAG, true)
	shower_curtain_state = HotelShowerCurtainStateScript.new()
	shower_curtain_state.setup(flag_store)
	task_manager = HotelTaskManagerScript.new()
	task_manager.setup_default_catalog()
	horror_event_manager = HotelHorrorEventManagerScript.new()
	horror_event_manager.setup_default_catalog(flag_store)
	horror_event_manager.set_jumpscares_enabled(LETHAL_GIMMICKS_ENABLED)
	horror_event_manager.set_random_spawning_enabled(false)
	horror_event_manager.jumpscare_started.connect(_on_jumpscare_started)
	horror_event_manager.jumpscare_finished.connect(_on_jumpscare_finished)
	horror_event_manager.event_seen.connect(_on_horror_collection_changed)
	horror_event_manager.event_resolved.connect(_on_horror_collection_changed)
	rule_book_manager = HotelRuleBookManagerScript.new()
	rule_book_manager.setup_default_catalog()
	mold_growth_system = HotelMoldGrowthSystemScript.new()
	mold_growth_system.setup()
	mold_growth_system.register_room("room_105")
	mold_growth_system.stack_changed.connect(_on_mold_stack_changed)
	mold_growth_system.maximum_reached.connect(_on_mold_maximum_reached)
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
	_build_anomaly_runtime()
	_build_audio()
	_show_lobby()


func _process(delta: float) -> void:
	if game_started and not intro_dialogue_active and not _is_lobby_open() and not _is_menu_open():
		horror_event_manager.tick_scene_view(current_scene_id, delta)
		var content_active: bool = anomaly_content_runtime != null and anomaly_content_runtime.has_active_anomaly()
		var night_active: bool = night_anomaly_director != null and night_anomaly_director.has_active_anomaly()
		var mold_entity_active: bool = (
			mold_closet_timer != null
			and not mold_closet_timer.is_stopped()
			and mold_growth_system.get_mold_stack("room_105") >= HotelMoldGrowthSystemScript.MAX_STACK
		)
		if anomaly_content_runtime != null:
			anomaly_content_runtime.set_external_anomaly_active(night_active or mold_entity_active)
		if night_anomaly_director != null:
			night_anomaly_director.set_external_anomaly_active(content_active or mold_entity_active)
		if not content_active and not night_active and not mold_entity_active:
			mold_growth_system.advance(delta)
		mold_entity_active = (
			mold_closet_timer != null
			and not mold_closet_timer.is_stopped()
			and mold_growth_system.get_mold_stack("room_105") >= HotelMoldGrowthSystemScript.MAX_STACK
		)
		if night_anomaly_director != null:
			night_anomaly_director.set_external_anomaly_active(content_active or mold_entity_active)
		if night_anomaly_director != null:
			night_anomaly_director.advance(delta)
		if anomaly_content_runtime != null:
			anomaly_content_runtime.set_external_anomaly_active(
				mold_entity_active or (night_anomaly_director != null and night_anomaly_director.has_active_anomaly())
			)
			anomaly_content_runtime.advance(delta)
		if equipped_item_hazard_controller != null:
			equipped_item_hazard_controller.advance(delta)
		if mold_closet_timer != null and not mold_closet_timer.is_stopped():
			_sync_anomaly_visual_overlay()
		_sync_eye_close_anomaly_context()
		_update_shift_end_button()


func _is_debug_ui_enabled() -> bool:
	var value := OS.get_environment(DEBUG_UI_ENV).strip_edges().to_lower()
	return DEBUG_UI_ENABLED_VALUES.has(value) or OS.has_feature("editor")


func _input(event: InputEvent) -> void:
	if intro_dialogue_active:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
			_advance_intro_dialogue()
			get_viewport().set_input_as_handled()
		return

	if (
		event is InputEventKey
		and event.pressed
		and not event.echo
		and event.keycode == KEY_ESCAPE
		and jumpscare_lab != null
		and jumpscare_lab.visible
	):
		jumpscare_lab.close_lab()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		if game_started and not _is_lobby_open() and not _is_menu_open() and not horror_event_manager.is_jumpscare_active():
			eye_close_controller.toggle_closed()
			get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and not event.echo and event.keycode == KEY_F:
		if game_started and not _is_lobby_open() and not _is_menu_open() and not horror_event_manager.is_jumpscare_active():
			if event.pressed:
				_use_equipped_item()
			else:
				if anomaly_content_runtime != null:
					anomaly_content_runtime.release_hold()
				if night_anomaly_director != null:
					night_anomaly_director.release_hand_action()
			get_viewport().set_input_as_handled()
			return

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
	if intro_dialogue_active and scene_id != current_scene_id:
		return
	if not HOTEL_SCENES.has(scene_id):
		push_warning("Unknown hotel scene: %s" % scene_id)
		return
	if night_anomaly_director != null and current_scene_id != scene_id and not night_anomaly_director.can_change_scene(scene_id):
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
	_sync_scene_3d_overlay()
	title_label.text = _scene_text(scene_id, scene_data, "title")
	_show_title_banner()
	_set_persistent_dialogue(_scene_text(scene_id, scene_data, "intro"))
	horror_event_manager.enter_scene(scene_id)
	if night_anomaly_director != null:
		night_anomaly_director.enter_scene(scene_id)
	if anomaly_content_runtime != null:
		anomaly_content_runtime.enter_scene(scene_id)
	if (
		mold_closet_timer != null
		and not mold_closet_timer.is_stopped()
		and scene_id.begins_with("room_105")
		and eye_close_controller != null
	):
		eye_close_controller.close_eyes()
	if anomaly_visual_overlay != null:
		anomaly_visual_overlay.set_scene(scene_id)
	_build_hotspots(_scene_hotspots(scene_id, scene_data))
	_build_navigation(scene_data["exits"])
	_apply_brightness()
	_update_layout()
	_sync_mold_display()
	_sync_mold_closet_threat()
	_sync_eye_close_anomaly_context()


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

	mold_overlay = HotelMoldOverlayScript.new()
	gameplay_layer.add_child(mold_overlay)

	anomaly_visual_overlay = HotelAnomalyVisualOverlayScript.new()
	gameplay_layer.add_child(anomaly_visual_overlay)

	anomaly_presentation_layer = HotelAnomalyPresentationLayerScript.new()
	gameplay_layer.add_child(anomaly_presentation_layer)

	scene_3d_overlay = HotelScene3DOverlayScript.new()
	gameplay_layer.add_child(scene_3d_overlay)

	brightness_overlay = ColorRect.new()
	brightness_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	brightness_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gameplay_layer.add_child(brightness_overlay)
	_apply_brightness()

	post_process_filter = HotelPostProcessFilterScript.new()
	gameplay_layer.add_child(post_process_filter)

	room_109_overlay = HotelRoom109OverlayScript.new()
	gameplay_layer.add_child(room_109_overlay)

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

	end_shift_button = Button.new()
	end_shift_button.visible = false
	end_shift_button.text = "근무 종료"
	end_shift_button.focus_mode = Control.FOCUS_NONE
	end_shift_button.custom_minimum_size = Vector2(94.0, 34.0)
	end_shift_button.add_theme_font_size_override("font_size", 14)
	end_shift_button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.06, 0.065, 0.07, 0.88), Color(1.0, 0.76, 0.35, 0.58), 8))
	end_shift_button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.16, 0.12, 0.055, 0.95), Color(1.0, 0.82, 0.42, 0.90), 8))
	end_shift_button.pressed.connect(_end_shift)
	gameplay_layer.add_child(end_shift_button)

	debug_panel = PanelContainer.new()
	debug_panel.anchor_left = 1.0
	debug_panel.anchor_right = 1.0
	debug_panel.anchor_top = 0.0
	debug_panel.anchor_bottom = 0.0
	debug_panel.offset_left = -1045.0
	debug_panel.offset_top = 18.0
	debug_panel.offset_right = -18.0
	debug_panel.offset_bottom = 108.0
	debug_panel.visible = debug_ui_enabled
	debug_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.78), Color(1.0, 1.0, 1.0, 0.10), 8))
	gameplay_layer.add_child(debug_panel)

	var corner_column := VBoxContainer.new()
	corner_column.add_theme_constant_override("separation", 6)
	debug_panel.add_child(corner_column)

	var corner_row := HBoxContainer.new()
	corner_row.add_theme_constant_override("separation", 8)
	corner_column.add_child(corner_row)

	hotspot_toggle = _make_debug_button("▣", _ui_text("debug.hotspots.show", "Show click areas"), _toggle_hotspots)
	corner_row.add_child(hotspot_toggle)

	chat_toggle = _make_debug_button("💬", _ui_text("debug.dialogue.hide", "Hide dialogue panel"), _toggle_chat)
	corner_row.add_child(chat_toggle)

	navigation_toggle = _make_debug_button("🧭", _ui_text("debug.navigation.show", "Show quick travel buttons"), _toggle_navigation)
	corner_row.add_child(navigation_toggle)

	filter_toggle = _make_debug_button("🎛", _ui_text("debug.filters.show", "Show filter selector"), _toggle_filter_selector)
	corner_row.add_child(filter_toggle)

	debug_curtain_preview_selector = OptionButton.new()
	debug_curtain_preview_selector.custom_minimum_size = Vector2(232.0, 32.0)
	debug_curtain_preview_selector.focus_mode = Control.FOCUS_NONE
	debug_curtain_preview_selector.tooltip_text = "Bathroom photo comparison: gameplay, open, edit_002 closed, or prev closed."
	debug_curtain_preview_selector.add_item("🛁 Gameplay", DEBUG_CURTAIN_GAMEPLAY)
	debug_curtain_preview_selector.add_item("🛁 Open", DEBUG_CURTAIN_OPEN)
	debug_curtain_preview_selector.add_item("🛁 Closed A · edit_002", DEBUG_CURTAIN_CLOSED_EDIT)
	debug_curtain_preview_selector.add_item("🛁 Closed B · prev", DEBUG_CURTAIN_CLOSED_PREV)
	debug_curtain_preview_selector.item_selected.connect(_on_debug_curtain_preview_selected)
	corner_row.add_child(debug_curtain_preview_selector)

	debug_anomaly_selector = OptionButton.new()
	debug_anomaly_selector.custom_minimum_size = Vector2(226.0, 32.0)
	debug_anomaly_selector.focus_mode = Control.FOCUS_NONE
	debug_anomaly_selector.tooltip_text = "Force one confirmed anomaly. Deferred-resolution events are preview-only."
	debug_anomaly_selector.add_item("☠ Anomaly preview", 0)
	var anomaly_debug_index := 1
	debug_anomaly_selector.add_item("곰팡이 돼지 가면 남자 · %s" % MOLD_PIG_MASK_EVENT_ID, anomaly_debug_index)
	debug_anomaly_selector.set_item_metadata(anomaly_debug_index, MOLD_PIG_MASK_EVENT_ID)
	anomaly_debug_index += 1
	for event_id in MVP_NIGHT_DEBUG_EVENT_IDS:
		debug_anomaly_selector.add_item(String(event_id), anomaly_debug_index)
		debug_anomaly_selector.set_item_metadata(anomaly_debug_index, event_id)
		anomaly_debug_index += 1
	for event_id in HotelAnomalyContentCatalogScript.debug_event_ids():
		debug_anomaly_selector.add_item(String(event_id), anomaly_debug_index)
		debug_anomaly_selector.set_item_metadata(anomaly_debug_index, event_id)
		anomaly_debug_index += 1
	debug_anomaly_selector.item_selected.connect(_on_debug_anomaly_selected)
	corner_row.add_child(debug_anomaly_selector)

	var tuning_row := HBoxContainer.new()
	tuning_row.add_theme_constant_override("separation", 8)
	corner_column.add_child(tuning_row)

	debug_jumpscare_lab_button = Button.new()
	debug_jumpscare_lab_button.text = "⚡ 점프스케어 연구소"
	debug_jumpscare_lab_button.custom_minimum_size = Vector2(220.0, 32.0)
	debug_jumpscare_lab_button.focus_mode = Control.FOCUS_NONE
	debug_jumpscare_lab_button.tooltip_text = "원본 확대, 돌진 시점과 속도, 화면 진동을 조절하고 프리뷰합니다."
	debug_jumpscare_lab_button.pressed.connect(_open_jumpscare_lab)
	tuning_row.add_child(debug_jumpscare_lab_button)

	eye_radius_slider = HSlider.new()
	eye_radius_slider.min_value = 28.0
	eye_radius_slider.max_value = 320.0
	eye_radius_slider.step = 4.0
	eye_radius_slider.value = 150.0
	eye_radius_slider.custom_minimum_size = Vector2(96.0, 32.0)
	eye_radius_slider.tooltip_text = _ui_text("debug.eyes.radius", "Closed-eye vision radius")
	eye_radius_slider.value_changed.connect(_on_eye_radius_debug_changed)
	tuning_row.add_child(eye_radius_slider)

	phone_bell_panel = PanelContainer.new()
	phone_bell_panel.visible = false
	phone_bell_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	phone_bell_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.18, 0.025, 0.025, 0.90), Color(1.0, 0.25, 0.22, 0.72), 8))
	gameplay_layer.add_child(phone_bell_panel)
	phone_bell_label = Label.new()
	phone_bell_label.add_theme_font_size_override("font_size", 20)
	phone_bell_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.72))
	phone_bell_panel.add_child(phone_bell_label)

	system_message_panel = PanelContainer.new()
	system_message_panel.visible = false
	system_message_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	system_message_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.025, 0.025, 0.03, 0.92), Color(0.75, 0.12, 0.12, 0.55), 8))
	gameplay_layer.add_child(system_message_panel)
	system_message_label = Label.new()
	system_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	system_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	system_message_label.add_theme_font_size_override("font_size", 18)
	system_message_label.add_theme_color_override("font_color", Color(0.96, 0.90, 0.84))
	system_message_panel.add_child(system_message_label)

	persistent_dialogue_panel = PanelContainer.new()
	persistent_dialogue_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	persistent_dialogue_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	persistent_dialogue_panel.gui_input.connect(_on_persistent_dialogue_input)
	persistent_dialogue_panel.add_theme_stylebox_override("panel", _make_dialogue_panel_style())
	gameplay_layer.add_child(persistent_dialogue_panel)

	dialogue_gradient = ColorRect.new()
	dialogue_gradient.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_gradient.color = Color.WHITE
	dialogue_gradient.material = _make_dialogue_gradient_material()
	persistent_dialogue_panel.add_child(dialogue_gradient)

	var bottom_layout := VBoxContainer.new()
	bottom_layout.add_theme_constant_override("separation", 10)
	persistent_dialogue_panel.add_child(bottom_layout)

	persistent_dialogue_label = Label.new()
	persistent_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	persistent_dialogue_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	persistent_dialogue_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	persistent_dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	persistent_dialogue_label.add_theme_font_size_override("font_size", 20)
	persistent_dialogue_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	bottom_layout.add_child(persistent_dialogue_label)

	persistent_dialogue_hint_label = Label.new()
	persistent_dialogue_hint_label.visible = false
	persistent_dialogue_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	persistent_dialogue_hint_label.add_theme_font_size_override("font_size", 16)
	persistent_dialogue_hint_label.add_theme_color_override("font_color", Color(0.92, 0.88, 0.76, 0.84))
	bottom_layout.add_child(persistent_dialogue_hint_label)

	typewriter_dialogue_controller = HotelTypewriterDialogueControllerScript.new()
	typewriter_dialogue_controller.setup(persistent_dialogue_label, persistent_dialogue_hint_label)
	gameplay_layer.add_child(typewriter_dialogue_controller)

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

	eye_close_controller = HotelEyeCloseControllerScript.new()
	gameplay_layer.add_child(eye_close_controller)

	hold_progress_overlay = HotelHoldProgressOverlayScript.new()
	gameplay_layer.add_child(hold_progress_overlay)

	choice_dialogue_overlay = HotelChoiceDialogueOverlayScript.new()
	gameplay_layer.add_child(choice_dialogue_overlay)
	choice_dialogue_overlay.choice_selected.connect(_on_content_choice_selected)
	choice_dialogue_overlay.narrative_finished.connect(_on_content_fatal_narrative_finished)

	intro_input_blocker = ColorRect.new()
	intro_input_blocker.process_mode = Node.PROCESS_MODE_ALWAYS
	intro_input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	intro_input_blocker.color = Color(0.0, 0.0, 0.0, 0.0)
	intro_input_blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro_input_blocker.visible = false
	gameplay_layer.add_child(intro_input_blocker)

	_position_bottom_panels()
	_apply_persistent_dialogue_display()
	_apply_navigation_display()
	_sync_debug_toggles()
	_build_menu()
	_build_jumpscare_lab()
	_build_lobby()
	_update_day_display()


func _build_anomaly_runtime() -> void:
	night_anomaly_director = HotelNightAnomalyDirectorScript.new()
	gameplay_layer.add_child(night_anomaly_director)
	night_anomaly_director.setup(eye_close_controller)
	night_anomaly_director.set_lethal_outcomes_enabled(LETHAL_GIMMICKS_ENABLED)
	night_anomaly_director.dialogue_requested.connect(_on_night_dialogue_requested)
	if LETHAL_GIMMICKS_ENABLED:
		night_anomaly_director.death_requested.connect(_trigger_game_over_event)
	night_anomaly_director.phone_bell_changed.connect(_on_phone_bell_changed)
	night_anomaly_director.state_changed.connect(_on_night_anomaly_state_changed)
	night_anomaly_director.event_started.connect(_on_anomaly_event_started)
	night_anomaly_director.event_survived.connect(_on_night_event_survived)
	night_anomaly_director.hold_started.connect(_on_anomaly_hold_started)
	night_anomaly_director.hold_progress_changed.connect(_on_anomaly_hold_progress_changed)
	night_anomaly_director.hold_ended.connect(_on_anomaly_hold_ended)
	if LETHAL_GIMMICKS_ENABLED:
		mold_closet_timer = Timer.new()
		mold_closet_timer.one_shot = true
		mold_closet_timer.wait_time = 10.0
		mold_closet_timer.timeout.connect(_on_mold_closet_timeout)
		gameplay_layer.add_child(mold_closet_timer)

	anomaly_content_runtime = HotelAnomalyContentRuntimeScript.new()
	gameplay_layer.add_child(anomaly_content_runtime)
	anomaly_content_runtime.setup(inventory_model, eye_close_controller)
	anomaly_content_runtime.set_lethal_outcomes_enabled(LETHAL_GIMMICKS_ENABLED)
	anomaly_content_runtime.state_changed.connect(_on_content_anomaly_state_changed)
	anomaly_content_runtime.event_started.connect(_on_anomaly_event_started)
	anomaly_content_runtime.event_resolved.connect(_on_content_anomaly_resolved)
	anomaly_content_runtime.choice_requested.connect(_on_content_choice_requested)
	anomaly_content_runtime.choice_closed.connect(_on_content_choice_closed)
	anomaly_content_runtime.fatal_narrative_requested.connect(_on_content_fatal_narrative_requested)
	anomaly_content_runtime.hold_started.connect(_on_anomaly_hold_started)
	anomaly_content_runtime.hold_progress_changed.connect(_on_anomaly_hold_progress_changed)
	anomaly_content_runtime.hold_ended.connect(_on_anomaly_hold_ended)
	if LETHAL_GIMMICKS_ENABLED:
		anomaly_content_runtime.death_requested.connect(_trigger_game_over_event)

	equipped_item_hazard_controller = HotelEquippedItemHazardControllerScript.new()
	equipped_item_hazard_controller.bind_inventory(inventory_model)
	equipped_item_hazard_controller.set_lethal_outcomes_enabled(LETHAL_GIMMICKS_ENABLED)
	equipped_item_hazard_controller.hazard_started.connect(_on_equipped_hazard_started)
	equipped_item_hazard_controller.hazard_progress_changed.connect(_on_equipped_hazard_progress_changed)
	equipped_item_hazard_controller.hazard_stopped.connect(_on_equipped_hazard_stopped)
	if LETHAL_GIMMICKS_ENABLED:
		equipped_item_hazard_controller.death_requested.connect(_on_equipped_hazard_death_requested)


func _hide_editor_hotspot_definitions() -> void:
	var definitions := get_node_or_null("HotspotDefinitions")
	if definitions is CanvasItem:
		definitions.visible = false


func _build_audio() -> void:
	anomaly_audio_controller = HotelAnomalyAudioControllerScript.new()
	gameplay_layer.add_child(anomaly_audio_controller)
	if anomaly_content_runtime != null:
		anomaly_content_runtime.sound_requested.connect(anomaly_audio_controller.play_cue)
	if night_anomaly_director != null:
		night_anomaly_director.sound_requested.connect(anomaly_audio_controller.play_cue)

	mold_spray_player = AudioStreamPlayer.new()
	mold_spray_player.process_mode = Node.PROCESS_MODE_PAUSABLE
	mold_spray_player.stream = _make_mold_spray_stream()
	mold_spray_player.volume_db = -5.0
	gameplay_layer.add_child(mold_spray_player)

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


func _play_mold_spray_sound() -> void:
	if mold_spray_player == null or DisplayServer.get_name() == "headless":
		return
	mold_spray_player.stop()
	mold_spray_player.play()


func _make_mold_spray_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 0.62
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	var noise_rng := RandomNumberGenerator.new()
	noise_rng.seed = 44105
	data.resize(samples * 2)
	for index in range(samples):
		var time := float(index) / float(mix_rate)
		var first_burst := sin(PI * clampf(time / 0.22, 0.0, 1.0)) if time <= 0.22 else 0.0
		var second_time := time - 0.31
		var second_burst := sin(PI * clampf(second_time / 0.24, 0.0, 1.0)) if second_time >= 0.0 and second_time <= 0.24 else 0.0
		var envelope := pow(maxf(first_burst, second_burst), 0.48)
		var white_noise := noise_rng.randf_range(-1.0, 1.0)
		var spray_body := white_noise * 0.78 + sin(TAU * 2850.0 * time) * 0.10 + sin(TAU * 910.0 * time) * 0.08
		var value := spray_body * envelope * 0.30
		data.encode_s16(index * 2, clampi(int(value * 32767.0), -32768, 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = data
	return stream


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

	if LETHAL_GIMMICKS_ENABLED:
		jumpscare_controller = HotelJumpscareControllerScript.new()
		jumpscare_controller.finished.connect(_on_jumpscare_controller_finished)
		add_child(jumpscare_controller)


func _build_jumpscare_lab() -> void:
	if not LETHAL_GIMMICKS_ENABLED:
		return
	jumpscare_lab = HotelJumpscareLabScript.new()
	add_child(jumpscare_lab)
	jumpscare_lab.setup(horror_event_manager, jumpscare_controller, localization)


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
	story_delivery_manager.start_new_run()
	HotelItemCatalogScript.reset_to_initial_items(inventory_model)
	horror_event_manager.start_new_run()
	task_manager.start_new_run()
	rule_book_manager.import_state({})
	rule_book_manager.set_current_day(1)
	flag_store.clear()
	flag_store.set_value(HotelInteractionActionRunnerScript.LAUNDRY_OPEN_FLAG, true)
	laundry_second_washer_open = _is_laundry_second_washer_open()
	game_brightness = DEFAULT_BRIGHTNESS
	mold_growth_system.import_state({})
	mold_growth_system.register_room("room_105")
	mold_growth_system.set_enabled(false)
	eye_close_controller.open_eyes()
	_start_day(1, false, false)


func _start_saved_day(day: int) -> void:
	_start_day(day, true, false)


func _start_day(day: int, use_saved_state: bool, play_transition_sound: bool) -> void:
	_clear_intro_dialogue_state()
	game_started = true
	day_save_manager.set_current_day(day)
	rule_book_manager.set_current_day(day)
	mold_growth_system.set_enabled(day >= 2)

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
	call_deferred("_present_day_opening")


func _present_day_opening() -> void:
	if not game_started or intro_dialogue_active or _is_lobby_open():
		return
	if story_delivery_manager != null and story_delivery_manager.has_active_sequence():
		_begin_intro_dialogue()
		return
	_present_latest_rule_page()


func _present_latest_rule_page() -> void:
	if not game_started or intro_dialogue_active or _is_lobby_open() or menu_overlay == null:
		return
	menu_overlay.open_rule_book()
	_set_game_paused(true)


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
		"mold": mold_growth_system.export_state(),
		"night_anomalies": night_anomaly_director.export_state(),
		"content_anomalies": anomaly_content_runtime.export_state(),
		"story_delivery": story_delivery_manager.export_state(),
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
	rule_book_manager.set_current_day(day)
	if slot.has("mold"):
		mold_growth_system.import_state(slot.get("mold", {}))
	else:
		mold_growth_system.import_state({})
		mold_growth_system.register_room("room_105")
		mold_growth_system.set_enabled(day >= 2)
	if slot.has("night_anomalies"):
		night_anomaly_director.import_state(slot.get("night_anomalies", {}))
	else:
		night_anomaly_director.start_day(day)
	if slot.has("content_anomalies"):
		anomaly_content_runtime.import_state(slot.get("content_anomalies", {}))
	else:
		anomaly_content_runtime.start_day(day)
	if slot.has("story_delivery"):
		story_delivery_manager.import_state(slot.get("story_delivery", {}))
	else:
		story_delivery_manager.prepare_day(day)
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
	rule_book_manager.set_current_day(day_save_manager.current_day)
	mold_growth_system.import_state({})
	mold_growth_system.register_room("room_105")
	mold_growth_system.set_enabled(day_save_manager.current_day >= 2)
	night_anomaly_director.start_day(day_save_manager.current_day)
	anomaly_content_runtime.start_day(day_save_manager.current_day)
	story_delivery_manager.prepare_day(day_save_manager.current_day)
	eye_close_controller.open_eyes()
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
		if _is_content_anomaly_hotspot_id(String(hotspot.get("id", ""))):
			button.button_down.connect(_on_anomaly_hotspot_button_down.bind(hotspot))
			button.button_up.connect(_on_anomaly_hotspot_button_up)
			button.mouse_exited.connect(_on_anomaly_hotspot_button_up)
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
	if intro_dialogue_active:
		return
	show_scene(scene_id)


func _on_filter_preset_selected(preset_name: String) -> void:
	set_post_process_preset(preset_name)


func _on_hotspot_pressed(hotspot: Dictionary) -> void:
	if intro_dialogue_active:
		return
	var hotspot_id := String(hotspot.get("id", ""))
	if _is_content_anomaly_hotspot_id(hotspot_id):
		if anomaly_content_runtime != null:
			var handled := bool(anomaly_content_runtime.handle_click(hotspot_id))
			if (
				handled
				and debug_anomaly_preview_event_id == anomaly_content_runtime.HANGING_GIRL_EVENT_ID
				and hotspot_id == "anomaly_pickup:hanging_girl_doll"
			):
				show_scene("room_107_bed_nightstand", false)
		return
	if (
		anomaly_content_runtime != null
		and anomaly_content_runtime.handle_world_hotspot(hotspot_id, current_scene_id)
	):
		return
	if shower_curtain_state != null and hotspot_id == HotelShowerCurtainStateScript.HOTSPOT_ID:
		_toggle_shower_curtain()
		return
	if night_anomaly_director != null and night_anomaly_director.handle_hotspot(hotspot_id):
		_save_current_day()
		return
	_apply_interaction_result(interaction_runner.execute_hotspot(hotspot, _make_interaction_context(hotspot)))


func _use_equipped_item() -> void:
	if night_anomaly_director != null and night_anomaly_director.begin_hand_action():
		return
	if inventory_model == null or inventory_model.equipped_item == null:
		return

	var item_id := String(inventory_model.equipped_item.id)
	for button in hotspot_buttons:
		if not button.is_hovered():
			continue
		var anomaly_hotspot: Dictionary = button.get_meta("hotspot")
		var anomaly_hotspot_id := String(anomaly_hotspot.get("id", ""))
		if _try_dispose_equipped_hell_mirror(anomaly_hotspot_id):
			return
		if anomaly_hotspot_id.begins_with("anomaly_hold:") and anomaly_content_runtime != null:
			anomaly_content_runtime.begin_item_hold(anomaly_hotspot_id, item_id, get_viewport().get_mouse_position())
			return

	var room_id: String = String(horror_event_manager.room_registry.get_room_id(current_scene_id))
	var removed_mold := false
	if mold_overlay.visible:
		mold_removal_in_progress = true
		removed_mold = mold_growth_system.remove_mold(room_id, item_id)
		mold_removal_in_progress = false
	if removed_mold:
		_play_mold_spray_sound()
		_save_current_day()
		return

	for button in hotspot_buttons:
		if button.is_hovered():
			var hotspot: Dictionary = button.get_meta("hotspot")
			var result = interaction_runner.execute_item_on_hotspot(hotspot, _make_interaction_context(hotspot))
			if result.consumed or result.has_dialogue():
				_apply_interaction_result(result, false)
				return


func _try_dispose_equipped_hell_mirror(hotspot_id: String) -> bool:
	if (
		inventory_model == null
		or inventory_model.equipped_item == null
		or String(inventory_model.equipped_item.id) != HotelNightAnomalyDirectorScript.HELL_MIRROR_ITEM_ID
		or hotspot_id != "laundry_second_washer"
		or night_anomaly_director == null
		or not night_anomaly_director.destroy_hell_mirror_in_washer(inventory_model)
	):
		return false
	flag_store.set_value(HotelInteractionActionRunnerScript.LAUNDRY_OPEN_FLAG, false)
	laundry_second_washer_open = false
	_refresh_current_scene_photo()
	_build_hotspots(_scene_hotspots(current_scene_id, HOTEL_SCENES[current_scene_id]))
	_save_current_day()
	return true


func _on_anomaly_hotspot_button_down(hotspot: Dictionary) -> void:
	if anomaly_content_runtime == null:
		return
	if String(hotspot.get("anomaly_input", "")) == "item_hold":
		return
	var item_id := ""
	if inventory_model != null and inventory_model.equipped_item != null:
		item_id = String(inventory_model.equipped_item.id)
	anomaly_content_runtime.begin_pointer_hold(
		String(hotspot.get("id", "")),
		item_id,
		get_viewport().get_mouse_position()
	)


func _on_anomaly_hotspot_button_up() -> void:
	if anomaly_content_runtime != null:
		anomaly_content_runtime.release_hold()


func _is_content_anomaly_hotspot_id(hotspot_id: String) -> bool:
	return (
		hotspot_id.begins_with("anomaly_hold:")
		or hotspot_id.begins_with("anomaly_bell:")
		or hotspot_id.begins_with("anomaly_surface:")
		or hotspot_id.begins_with("anomaly_choice:")
		or hotspot_id.begins_with("anomaly_pickup:")
	)


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


func _apply_interaction_result(result, show_dialogue := true) -> void:
	if result == null:
		return

	if not result.changed_scene_id.is_empty():
		show_scene(result.changed_scene_id)

	if result.should_refresh_photo:
		_refresh_current_scene_photo()

	if result.should_refresh_hotspots and HOTEL_SCENES.has(current_scene_id):
		_build_hotspots(_scene_hotspots(current_scene_id, HOTEL_SCENES[current_scene_id]))
		_update_layout()

	if show_dialogue and result.has_dialogue():
		_show_transient_dialogue(localization.translate(result.dialogue_key, result.fallback_dialogue))

	if result.should_save:
		_save_current_day()


func _play_transition_footsteps() -> void:
	if footstep_stream == null or footstep_players.is_empty() or footstep_timer == null:
		return

	footstep_timer.stop()
	footstep_index = 0
	if anomaly_content_runtime != null:
		anomaly_content_runtime.notify_player_action("footstep")
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



func _refresh_current_scene_photo() -> void:
	if not HOTEL_SCENES.has(current_scene_id):
		return

	var scene_data: Dictionary = HOTEL_SCENES[current_scene_id]
	current_texture = load(_scene_photo(current_scene_id, scene_data)) as Texture2D
	photo.texture = current_texture
	_sync_scene_3d_overlay()
	_apply_brightness()
	_update_layout()


func _toggle_shower_curtain() -> void:
	var scene_data: Dictionary = HOTEL_SCENES.get(current_scene_id, {})
	if shower_curtain_state == null or not shower_curtain_state.supports_scene(scene_data):
		return

	if _is_debug_curtain_preview_active(scene_data):
		var next_mode := debug_last_closed_curtain_preview if debug_curtain_preview_mode == DEBUG_CURTAIN_OPEN else DEBUG_CURTAIN_OPEN
		if anomaly_audio_controller != null:
			anomaly_audio_controller.play_cue("shower_curtain_move")
		_set_debug_curtain_preview_mode(next_mode)
		var debug_message := "Debug preview: shower curtain open." if next_mode == DEBUG_CURTAIN_OPEN else "Debug preview: %s." % _debug_curtain_preview_label(next_mode)
		_show_transient_dialogue(debug_message)
		return

	if anomaly_audio_controller != null:
		anomaly_audio_controller.play_cue("shower_curtain_move")
	var closed: bool = shower_curtain_state.toggle(current_scene_id)
	if anomaly_content_runtime != null:
		anomaly_content_runtime.handle_curtain_toggled(current_scene_id, closed)
	_refresh_current_scene_photo()
	_build_hotspots(_scene_hotspots(current_scene_id, scene_data))
	_save_current_day()


func _sync_scene_3d_overlay() -> void:
	if scene_3d_overlay == null:
		return
	var scene_data: Dictionary = HOTEL_SCENES.get(current_scene_id, {})
	if shower_curtain_state != null and shower_curtain_state.supports_scene(scene_data) and _is_effective_shower_curtain_closed(current_scene_id, scene_data):
		scene_3d_overlay.clear_overlay()
		return
	if current_scene_id == "room_106_bathroom":
		var child_visible: bool = (
			night_anomaly_director != null
			and night_anomaly_director.child_state in [
				night_anomaly_director.CHILD_CRYING,
				night_anomaly_director.CHILD_SONG_DONE,
			]
		)
		if not child_visible:
			scene_3d_overlay.clear_overlay()
			return
	scene_3d_overlay.show_scene_overlay(current_scene_id)


func _on_debug_curtain_preview_selected(index: int) -> void:
	if debug_curtain_preview_selector == null:
		return
	_set_debug_curtain_preview_mode(debug_curtain_preview_selector.get_item_id(index))


func _on_debug_anomaly_selected(index: int) -> void:
	if debug_anomaly_selector == null or anomaly_content_runtime == null or index <= 0:
		return
	var event_id := String(debug_anomaly_selector.get_item_metadata(index))
	var target_scene_id := ""
	if event_id == MOLD_PIG_MASK_EVENT_ID:
		_start_mold_pig_mask_preview()
		debug_anomaly_selector.select(0)
		return
	elif event_id in MVP_NIGHT_DEBUG_EVENT_IDS:
		anomaly_content_runtime.start_day(day_save_manager.current_day)
		night_anomaly_director.start_day(day_save_manager.current_day)
		match event_id:
			"laundry_red_washer":
				night_anomaly_director.force_red_laundry()
				target_scene_id = "laundry_room"
			"room_106_abandoned_child":
				night_anomaly_director.force_child_encounter()
				target_scene_id = "room_106_bathroom"
			"vacant_room_blanket_child":
				night_anomaly_director.force_blanket_child()
				target_scene_id = "room_108_bed_window"
	else:
		night_anomaly_director.start_day(day_save_manager.current_day)
		if not anomaly_content_runtime.force_event(event_id):
			return
		debug_anomaly_preview_event_id = event_id
		var definition: Dictionary = anomaly_content_runtime.definitions.get(event_id, {})
		target_scene_id = String(definition.get("scene_id", ""))
		if event_id == "bathroom_shower_legs":
			target_scene_id = anomaly_content_runtime.get_active_scene_id()
		elif event_id == anomaly_content_runtime.HANGING_GIRL_EVENT_ID:
			# The preview begins at the companion pickup so the authored
			# solution can be played instead of only showing the entity.
			target_scene_id = "laundry_room"
	if not target_scene_id.is_empty() and HOTEL_SCENES.has(target_scene_id):
		show_scene(target_scene_id, false)
	debug_anomaly_selector.select(0)


func _start_mold_pig_mask_preview() -> bool:
	if (
		mold_growth_system == null
		or mold_closet_timer == null
		or anomaly_content_runtime == null
		or night_anomaly_director == null
	):
		return false
	anomaly_content_runtime.start_day(day_save_manager.current_day)
	night_anomaly_director.start_day(day_save_manager.current_day)
	debug_anomaly_preview_event_id = MOLD_PIG_MASK_EVENT_ID
	if not mold_closet_timer.is_stopped():
		mold_closet_timer.stop()
	show_scene("room_105_bathroom_entry", false)
	mold_growth_system.force_stack("room_105", HotelMoldGrowthSystemScript.MAX_STACK)
	# The production event closes the player's eyes as an initial shock. The
	# integrated preview reopens them so the door and pig-mask phases are visible.
	if eye_close_controller != null:
		eye_close_controller.open_eyes()
	_sync_mold_display()
	_sync_mold_closet_threat()
	_sync_anomaly_visual_overlay()
	return not mold_closet_timer.is_stopped()


func _open_jumpscare_lab() -> void:
	if not debug_ui_enabled or jumpscare_lab == null:
		return
	jumpscare_lab.open_lab()


func _set_debug_curtain_preview_mode(mode: int) -> void:
	debug_curtain_preview_mode = clampi(mode, DEBUG_CURTAIN_GAMEPLAY, DEBUG_CURTAIN_CLOSED_PREV)
	if debug_curtain_preview_mode in [DEBUG_CURTAIN_CLOSED_EDIT, DEBUG_CURTAIN_CLOSED_PREV]:
		debug_last_closed_curtain_preview = debug_curtain_preview_mode
	if debug_curtain_preview_selector != null:
		debug_curtain_preview_selector.select(debug_curtain_preview_mode)

	var scene_data: Dictionary = HOTEL_SCENES.get(current_scene_id, {})
	if shower_curtain_state == null or not shower_curtain_state.supports_scene(scene_data):
		return
	_refresh_current_scene_photo()
	_build_hotspots(_scene_hotspots(current_scene_id, scene_data))


func _is_debug_curtain_preview_active(scene_data: Dictionary) -> bool:
	return debug_ui_enabled and debug_curtain_preview_mode != DEBUG_CURTAIN_GAMEPLAY and shower_curtain_state != null and shower_curtain_state.supports_scene(scene_data)


func _is_effective_shower_curtain_closed(scene_id: String, scene_data: Dictionary) -> bool:
	if _is_debug_curtain_preview_active(scene_data):
		return debug_curtain_preview_mode != DEBUG_CURTAIN_OPEN
	return shower_curtain_state != null and shower_curtain_state.is_closed(scene_id)


func _debug_curtain_preview_photo(scene_data: Dictionary) -> String:
	match debug_curtain_preview_mode:
		DEBUG_CURTAIN_OPEN:
			return String(scene_data.get("photo", ""))
		DEBUG_CURTAIN_CLOSED_EDIT:
			return String(scene_data.get("curtain_closed_photo", ""))
		DEBUG_CURTAIN_CLOSED_PREV:
			return DEBUG_CURTAIN_PREV_PHOTO
	return ""


func _debug_curtain_preview_label(mode: int) -> String:
	if mode == DEBUG_CURTAIN_CLOSED_PREV:
		return "closed B · prev"
	return "closed A · edit_002"


func _is_laundry_second_washer_open() -> bool:
	if flag_store != null:
		return flag_store.get_bool(HotelInteractionActionRunnerScript.LAUNDRY_OPEN_FLAG, true)

	return laundry_second_washer_open


func _on_mold_stack_changed(room_id: String, stack: int) -> void:
	if room_id != "room_105":
		return
	_sync_mold_display()
	_sync_eye_close_anomaly_context()
	if not mold_removal_in_progress:
		if stack > 0:
			_show_system_message(_ui_text("mold.stack", "Black mold is spreading in Room 105. (%d/6)") % stack)
	_sync_mold_closet_threat()
	_sync_anomaly_visual_overlay()


func _on_mold_maximum_reached(room_id: String) -> void:
	if room_id != "room_105":
		return
	if not LETHAL_GIMMICKS_ENABLED:
		return
	horror_event_manager.mark_event_seen(MOLD_PIG_MASK_EVENT_ID)
	if anomaly_audio_controller != null:
		anomaly_audio_controller.play_cue("closet_woman_laugh")
	if current_scene_id.begins_with("room_105") and eye_close_controller != null:
		eye_close_controller.close_eyes()
	_sync_mold_closet_threat()


func _sync_mold_display() -> void:
	if mold_overlay == null or mold_growth_system == null:
		return
	var shows_mold_wall := current_scene_id == "room_105_bathroom_entry"
	var mold_stack: int = mold_growth_system.get_mold_stack("room_105")
	mold_overlay.set_stack(mold_stack if shows_mold_wall else 0)
	mold_overlay.visible = shows_mold_wall and mold_stack > 0
	if mold_overlay.visible and current_texture != null:
		mold_overlay.set_photo_rect(_get_photo_draw_rect())


func _sync_mold_closet_threat() -> void:
	if mold_closet_timer == null:
		return
	var threatened: bool = mold_growth_system.get_mold_stack("room_105") >= HotelMoldGrowthSystemScript.MAX_STACK
	if threatened and mold_closet_timer.is_stopped():
		mold_closet_timer.start()
	elif not threatened and not mold_closet_timer.is_stopped():
		mold_closet_timer.stop()


func _on_mold_closet_timeout() -> void:
	if mold_growth_system.get_mold_stack("room_105") >= HotelMoldGrowthSystemScript.MAX_STACK:
		_trigger_game_over_event(MOLD_PIG_MASK_EVENT_ID)


func _on_phone_bell_changed(count: int, maximum: int) -> void:
	if phone_bell_panel == null or phone_bell_label == null:
		return
	phone_bell_panel.visible = count > 0
	phone_bell_label.text = "☎  %02d / %02d" % [count, maximum]
	_position_runtime_status()


func _on_night_anomaly_state_changed() -> void:
	if HOTEL_SCENES.has(current_scene_id):
		_build_hotspots(_scene_hotspots(current_scene_id, HOTEL_SCENES[current_scene_id]))
		_update_layout()
	_sync_scene_3d_overlay()
	_sync_eye_close_anomaly_context()
	_sync_room_109_display()
	_sync_anomaly_visual_overlay()


func _on_content_anomaly_state_changed() -> void:
	if anomaly_content_runtime == null:
		return
	var content_state: Dictionary = anomaly_content_runtime.get_presentation_state()
	if String(content_state.get("event_id", "")) == "bathroom_shower_legs" and String(content_state.get("state", "")) == "curtain_closed":
		var curtain_scene_id := String(content_state.get("scene_id", ""))
		if shower_curtain_state != null and not shower_curtain_state.is_closed(curtain_scene_id):
			flag_store.set_value(shower_curtain_state.flag_id_for_scene(curtain_scene_id), true)
			if curtain_scene_id == current_scene_id:
				_refresh_current_scene_photo()
	_sync_anomaly_visual_overlay()
	_sync_shadow_distress_audio()
	var content_hold_active: bool = (
		anomaly_content_runtime.hold_controller != null
		and anomaly_content_runtime.hold_controller.is_active()
	)
	if not content_hold_active and HOTEL_SCENES.has(current_scene_id):
		_build_hotspots(_scene_hotspots(current_scene_id, HOTEL_SCENES[current_scene_id]))
		_update_layout()
	_sync_eye_close_anomaly_context()


func _sync_shadow_distress_audio() -> void:
	if anomaly_audio_controller == null:
		return
	var shadow_distressed: bool = (
		anomaly_content_runtime != null
		and anomaly_content_runtime.current_event_id == anomaly_content_runtime.SHADOW_EVENT_ID
		and anomaly_content_runtime.current_state == "bell_distressed"
	)
	anomaly_audio_controller.set_shadow_heartbeat_active(shadow_distressed)


func _sync_anomaly_visual_overlay() -> void:
	if anomaly_visual_overlay == null:
		return
	var presentation_state := {}
	if (
		mold_closet_timer != null
		and not mold_closet_timer.is_stopped()
		and mold_growth_system != null
		and mold_growth_system.get_mold_stack("room_105") >= HotelMoldGrowthSystemScript.MAX_STACK
	):
		presentation_state = {
			"event_id": MOLD_PIG_MASK_EVENT_ID,
			"state": "face" if mold_closet_timer.time_left <= 5.0 else "door_open",
			"scene_id": "room_105_bathroom_entry",
		}
	elif anomaly_content_runtime != null and anomaly_content_runtime.has_active_anomaly():
		presentation_state = anomaly_content_runtime.get_presentation_state()
	elif night_anomaly_director != null:
		presentation_state = night_anomaly_director.get_presentation_state()
	anomaly_visual_overlay.apply_presentation_state(presentation_state)
	anomaly_visual_overlay.set_scene(current_scene_id)
	var artifact_rendered := false
	if anomaly_presentation_layer != null:
		anomaly_presentation_layer.set_scene(current_scene_id)
		artifact_rendered = anomaly_presentation_layer.apply_presentation_state(presentation_state)
	anomaly_visual_overlay.set_suppressed(artifact_rendered)
	if current_texture != null:
		anomaly_visual_overlay.set_photo_rect(_get_photo_draw_rect())
		if anomaly_presentation_layer != null:
			anomaly_presentation_layer.set_photo_rect(_get_photo_draw_rect())


func _on_content_anomaly_resolved(event_id: String) -> void:
	if debug_anomaly_preview_event_id == event_id:
		debug_anomaly_preview_event_id = ""
	horror_event_manager.mark_event_seen(event_id)
	horror_event_manager.resolve_event(event_id)
	_save_current_day()


func _on_content_choice_requested(prompt_key: String, fallback_prompt: String, choices: Array) -> void:
	if choice_dialogue_overlay == null:
		return
	var localized_choices := []
	for raw_choice in choices:
		var choice: Dictionary = raw_choice.duplicate(true)
		choice["text"] = localization.translate(
			String(choice.get("text_key", "")),
			String(choice.get("fallback_text", "")),
		)
		localized_choices.append(choice)
	choice_dialogue_overlay.show_prompt(
		localization.translate(prompt_key, fallback_prompt),
		localized_choices,
	)


func _on_content_choice_selected(choice_id: String) -> void:
	if anomaly_content_runtime == null:
		return
	if anomaly_content_runtime.handle_choice(choice_id):
		_save_current_day()


func _on_content_choice_closed() -> void:
	if choice_dialogue_overlay != null:
		choice_dialogue_overlay.close()


func _on_content_fatal_narrative_requested(raw_lines: Array) -> void:
	if choice_dialogue_overlay == null:
		return
	var localized_lines: Array[String] = []
	for raw_line in raw_lines:
		localized_lines.append(localization.translate(
			String(raw_line.get("key", "")),
			String(raw_line.get("fallback", "")),
		))
	choice_dialogue_overlay.show_narrative(localized_lines, 0.34)


func _on_content_fatal_narrative_finished() -> void:
	if anomaly_content_runtime != null:
		anomaly_content_runtime.finish_fatal_narrative()


func _on_anomaly_event_started(event_id: String) -> void:
	if event_id == "laundry_baby_face_surfaces":
		flag_store.set_value(HotelInteractionActionRunnerScript.LAUNDRY_OPEN_FLAG, true)
		laundry_second_washer_open = true
		if current_scene_id == "laundry_room":
			_refresh_current_scene_photo()
	horror_event_manager.mark_event_seen(event_id)
	_save_current_day()


func _on_anomaly_hold_started(mode: String, focus_position: Vector2) -> void:
	if hold_progress_overlay == null:
		return
	hold_progress_overlay.show_hold(mode, focus_position)
	hold_progress_overlay.move_to_front()


func _on_anomaly_hold_progress_changed(progress: float) -> void:
	if hold_progress_overlay != null:
		hold_progress_overlay.set_progress(progress)


func _on_anomaly_hold_ended() -> void:
	if hold_progress_overlay != null:
		hold_progress_overlay.hide_hold()


func _on_equipped_hazard_started(_item_id: String) -> void:
	if anomaly_audio_controller != null:
		anomaly_audio_controller.start_hell_mirror_loop()


func _on_equipped_hazard_progress_changed(_item_id: String, progress: float) -> void:
	if anomaly_audio_controller != null:
		anomaly_audio_controller.set_hell_mirror_intensity(progress)


func _on_equipped_hazard_stopped(_item_id: String) -> void:
	if anomaly_audio_controller != null:
		anomaly_audio_controller.stop_loop()


func _on_equipped_hazard_death_requested(_item_id: String) -> void:
	_trigger_game_over_event("hell_mirror")


func _on_night_event_survived(event_id: String) -> void:
	horror_event_manager.resolve_event(event_id)
	_save_current_day()


func _sync_eye_close_anomaly_context() -> void:
	if eye_close_controller == null:
		return
	var has_mold: bool = current_scene_id == "room_105_bathroom_entry" and mold_growth_system.get_mold_stack("room_105") > 0
	var has_night_event: bool = night_anomaly_director != null and night_anomaly_director.is_scene_anomalous(current_scene_id)
	var has_content_event: bool = anomaly_content_runtime != null and anomaly_content_runtime.is_scene_anomalous(current_scene_id)
	eye_close_controller.set_anomaly_context(has_mold or has_night_event or has_content_event)


func _trigger_game_over_event(event_id: String) -> void:
	if not LETHAL_GIMMICKS_ENABLED:
		return
	if horror_event_manager.is_jumpscare_active():
		return
	if eye_close_controller != null:
		eye_close_controller.open_eyes()
	if horror_event_manager.is_jumpscare_active():
		return
	if not horror_event_manager.trigger_jumpscare(event_id):
		push_warning("Unknown game-over event: %s" % event_id)


func _on_eye_radius_debug_changed(value: float) -> void:
	if eye_close_controller != null:
		eye_close_controller.set_debug_vision_radius(value)


func _set_debug_mold_stage(stage: int) -> void:
	var safe_stage := clampi(stage, 1, HotelMoldGrowthSystemScript.MAX_STACK)
	if mold_growth_system != null:
		mold_growth_system.force_stack("room_105", safe_stage)


func _show_system_message(message: String) -> void:
	if system_message_panel == null or system_message_label == null:
		return
	system_message_label.text = message
	system_message_label.custom_minimum_size = Vector2(minf(720.0, get_viewport_rect().size.x - 64.0), 0.0)
	system_message_panel.visible = true
	system_message_panel.modulate.a = 1.0
	_position_runtime_status()
	if system_message_tween != null:
		system_message_tween.kill()
	system_message_tween = create_tween()
	system_message_tween.tween_interval(3.2)
	system_message_tween.tween_property(system_message_panel, "modulate:a", 0.0, 0.5)
	system_message_tween.finished.connect(func(): system_message_panel.visible = false)


func _on_night_dialogue_requested(message_key: String) -> void:
	_show_system_message(localization.translate(message_key, message_key))


func _position_runtime_status() -> void:
	var viewport_size := get_viewport_rect().size
	if phone_bell_panel != null:
		phone_bell_panel.size = phone_bell_panel.get_combined_minimum_size()
		phone_bell_panel.position = Vector2(viewport_size.x - phone_bell_panel.size.x - 22.0, 82.0)
	if system_message_panel != null:
		system_message_panel.size = system_message_panel.get_combined_minimum_size()
		system_message_panel.position = Vector2((viewport_size.x - system_message_panel.size.x) * 0.5, 92.0)


func _sync_room_109_display() -> void:
	if room_109_overlay == null or day_save_manager == null:
		return
	var content_event_id := ""
	if anomaly_content_runtime != null:
		content_event_id = anomaly_content_runtime.current_event_id
	var day_seven_passage_active: bool = (
		night_anomaly_director != null
		and night_anomaly_director.room_109_passage_state in [
			night_anomaly_director.ROOM_109_PASSAGE_WAITING,
			night_anomaly_director.ROOM_109_PASSAGE_FOOTSTEPS,
		]
	)
	room_109_overlay.visible = (
		game_started
		and current_scene_id == "corridor"
		and (content_event_id == "room_109_open_door" or day_seven_passage_active)
	)
	if room_109_overlay.visible and current_texture != null:
		room_109_overlay.set_photo_rect(_get_photo_draw_rect())


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
	if not game_started or intro_dialogue_active:
		return

	menu_overlay.open()
	_set_game_paused(true)


func _hide_menu() -> void:
	if menu_overlay == null:
		return

	menu_overlay.close()
	_set_game_paused(intro_dialogue_active)


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
	var advances_with_mouse: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	var advances_with_touch: bool = event is InputEventScreenTouch and event.pressed
	if not advances_with_mouse and not advances_with_touch:
		return
	if intro_dialogue_active:
		_advance_intro_dialogue()
	else:
		_hide_persistent_dialogue()
	get_viewport().set_input_as_handled()


func _begin_intro_dialogue() -> void:
	if story_delivery_manager == null or not story_delivery_manager.has_active_sequence():
		_present_latest_rule_page()
		return
	intro_dialogue_active = true
	intro_dialogue_index = story_delivery_manager.get_current_step() - 1
	show_persistent_dialogue = true
	if equipment_hud != null:
		equipment_hud.visible = false
	intro_input_blocker.visible = true
	intro_input_blocker.move_to_front()
	persistent_dialogue_panel.move_to_front()
	_refresh_intro_dialogue()
	_set_game_paused(true)


func _advance_intro_dialogue() -> void:
	if not intro_dialogue_active:
		return
	if typewriter_dialogue_controller != null and typewriter_dialogue_controller.reveal_all():
		return
	if not story_delivery_manager.advance():
		_save_current_day()
		_finish_intro_dialogue()
		return
	intro_dialogue_index = story_delivery_manager.get_current_step() - 1
	_save_current_day()
	_refresh_intro_dialogue()


func _refresh_intro_dialogue() -> void:
	var beat: Dictionary = story_delivery_manager.get_current_beat()
	if beat.is_empty():
		_finish_intro_dialogue()
		return
	var line := localization.translate(
		String(beat.get("content_key", "")),
		String(beat.get("fallback_content", "")),
	)
	current_persistent_dialogue_text = line
	_apply_persistent_dialogue_display()
	typewriter_dialogue_controller.play_line(line)


func _finish_intro_dialogue() -> void:
	_clear_intro_dialogue_state()
	_hide_persistent_dialogue()
	_present_latest_rule_page()


func _clear_intro_dialogue_state() -> void:
	intro_dialogue_active = false
	intro_dialogue_index = 0
	if equipment_hud != null:
		equipment_hud.visible = true
	if intro_input_blocker != null:
		intro_input_blocker.visible = false
	if persistent_dialogue_hint_label != null:
		persistent_dialogue_hint_label.visible = false
	if typewriter_dialogue_controller != null:
		typewriter_dialogue_controller.clear()
	_sync_debug_toggles()


func is_intro_dialogue_active() -> bool:
	return intro_dialogue_active


func get_intro_dialogue_step() -> int:
	return intro_dialogue_index + 1 if intro_dialogue_active else 0


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
	if scene_id == "laundry_room":
		if _is_laundry_second_washer_open():
			return localization.translate_scene_photo(scene_id, LAUNDRY_OPEN_PHOTO, "open")
		return localization.translate_scene_photo(scene_id, LAUNDRY_CLOSED_PHOTO, "closed")
	if shower_curtain_state != null and shower_curtain_state.supports_scene(scene_data):
		if _is_debug_curtain_preview_active(scene_data):
			return _debug_curtain_preview_photo(scene_data)
		var variant := "curtain_closed" if shower_curtain_state.is_closed(scene_id) else ""
		return localization.translate_scene_photo(scene_id, shower_curtain_state.photo_path(scene_id, scene_data), variant)

	return localization.translate_scene_photo(scene_id, scene_data["photo"])


func _scene_hotspots(scene_id: String, scene_data: Dictionary) -> Array:
	var editor_hotspots := _editor_hotspots_for_scene(scene_id)
	var hotspots := editor_hotspots.duplicate(true)
	for task_hotspot in task_manager.get_hotspots_for_scene(scene_id):
		hotspots.append(task_hotspot)
	for horror_hotspot in horror_event_manager.get_revealed_hotspots(scene_id):
		hotspots.append(horror_hotspot)
	if night_anomaly_director != null:
		for anomaly_hotspot in night_anomaly_director.get_dynamic_hotspots(scene_id):
			if String(anomaly_hotspot.get("id", "")) == "room_109_open_door":
				var passage_active: bool = (
					night_anomaly_director.room_109_passage_state in [
						night_anomaly_director.ROOM_109_PASSAGE_WAITING,
						night_anomaly_director.ROOM_109_PASSAGE_FOOTSTEPS,
					]
				)
				if (anomaly_content_runtime == null or anomaly_content_runtime.current_event_id != "room_109_open_door") and not passage_active:
					continue
			hotspots.append(anomaly_hotspot)
	if anomaly_content_runtime != null:
		for content_hotspot in anomaly_content_runtime.get_dynamic_hotspots(scene_id):
			hotspots.append(content_hotspot)
	if shower_curtain_state != null and shower_curtain_state.supports_scene(scene_data):
		hotspots.append(shower_curtain_state.make_hotspot_for_state(_is_effective_shower_curtain_closed(scene_id, scene_data)))

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
		debug_panel.visible = debug_ui_enabled and not intro_dialogue_active

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

	if debug_curtain_preview_selector != null:
		var scene_data: Dictionary = HOTEL_SCENES.get(current_scene_id, {})
		var supports_curtain_preview: bool = shower_curtain_state != null and shower_curtain_state.supports_scene(scene_data)
		debug_curtain_preview_selector.disabled = not supports_curtain_preview
		debug_curtain_preview_selector.select(debug_curtain_preview_mode)
		debug_curtain_preview_selector.tooltip_text = "Bathroom photo comparison: gameplay, open, edit_002 closed, or prev closed." if supports_curtain_preview else "Enter a Room 105-108 bathroom to compare curtain photos."

	if filter_bar != null:
		filter_bar.sync_selected_preset()


func _position_bottom_panels() -> void:
	if persistent_dialogue_panel != null:
		persistent_dialogue_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		persistent_dialogue_panel.offset_left = 18.0
		persistent_dialogue_panel.offset_top = -265.0
		persistent_dialogue_panel.offset_right = -18.0
		persistent_dialogue_panel.offset_bottom = -64.0

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
	if typewriter_dialogue_controller != null:
		typewriter_dialogue_controller.show_instant(current_persistent_dialogue_text)
	else:
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
	if mold_overlay != null and mold_overlay.visible and current_texture != null:
		mold_overlay.set_photo_rect(_get_photo_draw_rect())
	if anomaly_visual_overlay != null and current_texture != null:
		anomaly_visual_overlay.set_photo_rect(_get_photo_draw_rect())
	if anomaly_presentation_layer != null and current_texture != null:
		anomaly_presentation_layer.set_photo_rect(_get_photo_draw_rect())
	if hold_progress_overlay != null and hold_progress_overlay.is_showing_hold():
		hold_progress_overlay.set_focus_position(get_viewport().get_mouse_position())
	_position_title_panel()
	_position_transient_dialogue()
	_update_hotspot_layout()
	_update_day_display()
	_position_runtime_status()
	_sync_room_109_display()


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
	if end_shift_button != null:
		end_shift_button.position = Vector2(18.0, 102.0)


func _update_day_display() -> void:
	if day_badge_panel == null or day_badge_label == null:
		return

	day_badge_panel.visible = game_started
	day_badge_label.text = _day_name(day_save_manager.current_day)
	day_badge_panel.size = day_badge_panel.get_combined_minimum_size()
	_refresh_debug_day_buttons()
	_update_shift_end_button()


func _update_shift_end_button() -> void:
	if end_shift_button == null:
		return
	end_shift_button.visible = (
		game_started
		and not intro_dialogue_active
		and current_scene_id == START_SCENE_ID
		and task_manager != null
		and task_manager.is_all_complete()
		and anomaly_content_runtime != null
		and anomaly_content_runtime.is_daily_schedule_complete()
		and night_anomaly_director != null
		and night_anomaly_director.is_daily_schedule_complete()
		and not horror_event_manager.is_jumpscare_active()
	)


func _end_shift() -> void:
	_update_shift_end_button()
	if end_shift_button == null or not end_shift_button.visible:
		return
	if _must_die_from_hell_mirror_at_shift_end():
		_trigger_game_over_event("hell_mirror")
		return
	_save_current_day()
	if day_save_manager.current_day >= HotelDaySaveManagerScript.TOTAL_DAYS:
		_show_lobby()
		return
	var next_day: int = day_save_manager.current_day + 1
	day_save_manager.unlock_day(next_day)
	_start_day(next_day, false, true)


func _must_die_from_hell_mirror_at_shift_end() -> bool:
	return inventory_model != null and inventory_model.has_item_id(HotelNightAnomalyDirectorScript.HELL_MIRROR_ITEM_ID)


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


func _make_dialogue_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	style.content_margin_left = 28.0
	style.content_margin_right = 28.0
	style.content_margin_top = 22.0
	style.content_margin_bottom = 14.0
	return style


func _make_dialogue_gradient_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = DIALOGUE_GRADIENT_SHADER_CODE
	var material := ShaderMaterial.new()
	material.shader = shader
	return material
