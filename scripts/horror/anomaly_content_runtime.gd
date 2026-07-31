class_name HotelAnomalyContentRuntime
extends Node

signal state_changed
signal event_started(event_id: String)
signal event_resolved(event_id: String)
signal death_requested(event_id: String)
signal sound_requested(cue_id: String)
signal hold_started(mode: String, focus_position: Vector2)
signal hold_progress_changed(progress: float)
signal hold_ended
signal choice_requested(prompt_key: String, fallback_prompt: String, choices: Array)
signal choice_closed
signal fatal_narrative_requested(lines: Array)

const ContentCatalog := preload("res://scripts/horror/anomaly_content_catalog.gd")
const Scheduler := preload("res://scripts/horror/anomaly_scheduler.gd")
const HoldController := preload("res://scripts/interactions/hold_interaction_controller.gd")

const SPAWN_DELAY_SECONDS := 14.0
const INTER_EVENT_COOLDOWN_SECONDS := 8.0
const BELL_SEQUENCE_WINDOW_SECONDS := 1.05
const SHADOW_ECHO_DELAY_SECONDS := 0.90
const SHADOW_BELL_PRESS_TARGET := 3
const SHADOW_BELL_SEQUENCE_WINDOW_SECONDS := 1.05
const SHADOW_ROOM_TRANSITION_TARGET := 4
const SHADOW_ROOM_TRANSITION_WINDOW_SECONDS := 2.20
const MAX_PRODUCTION_EVENTS_PER_DAY := 1
const SHADOW_EVENT_ID := "hotel_following_shadow"
const HANGING_GIRL_EVENT_ID := "room_107_hanging_girl"
const HANGING_GIRL_DOLL_ITEM_ID := "cute_doll"

var definitions: Dictionary = {}
var scheduler = null
var hold_controller = null
var inventory_model = null
var eye_close_controller = null

var current_day := 1
var current_scene_id := ""
var current_event_id := ""
var current_state := "idle"
var external_anomaly_active := false
var lethal_outcomes_enabled := true

var _spawn_seconds := SPAWN_DELAY_SECONDS
var _resolved_event_ids: Array[String] = []
var _current_scene_override := ""
var _hold_hotspot_id := ""
var _hold_required_item_id := ""
var _hold_mode := "circular"
var _bell_press_count := 0
var _bell_sequence_seconds := 0.0
var _closed_surfaces: Array[String] = []
var _curtain_open_count := 0
var _curtain_target_count := 3
var _curtain_legs_visible := false
var _curtain_has_legs := true
var _fatal_seconds_remaining := 0.0
var _entity_recognized := false
var _entity_stage := 0
var _entity_stage_seconds := 0.0
var _shadow_echo_queue: Array[Dictionary] = []
var _shadow_bell_press_count := 0
var _shadow_bell_sequence_seconds := 0.0
var _shadow_room_transition_count := 0
var _shadow_room_transition_seconds := 0.0
var _hanging_girl_selected_choices: Array[String] = []
var _hanging_girl_doll_taken := false
var _hanging_girl_dialogue_open := false
var _hanging_girl_fatal_pending := false
var _debug_force_pending := false
var _rng := RandomNumberGenerator.new()
var _random_seed_override := -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	definitions = ContentCatalog.build_definitions()
	_reset_scheduler()
	hold_controller = HoldController.new()
	hold_controller.hold_started.connect(_on_hold_started)
	hold_controller.progress_changed.connect(_on_hold_progress_changed)
	hold_controller.hold_cancelled.connect(_on_hold_cancelled)
	hold_controller.hold_completed.connect(_on_hold_completed)


func setup(new_inventory_model, new_eye_close_controller) -> void:
	inventory_model = new_inventory_model
	eye_close_controller = new_eye_close_controller


func set_lethal_outcomes_enabled(value: bool) -> void:
	lethal_outcomes_enabled = value


func set_external_anomaly_active(value: bool) -> void:
	external_anomaly_active = value


func start_day(day: int) -> void:
	current_day = maxi(day, 1)
	external_anomaly_active = false
	if _random_seed_override >= 0:
		_rng.seed = _random_seed_override + current_day
	else:
		_rng.randomize()
	current_event_id = ""
	current_state = "idle"
	_spawn_seconds = SPAWN_DELAY_SECONDS
	_resolved_event_ids.clear()
	_hanging_girl_selected_choices.clear()
	_hanging_girl_doll_taken = false
	_hanging_girl_dialogue_open = false
	_hanging_girl_fatal_pending = false
	_clear_event_state()
	_reset_scheduler()
	state_changed.emit()


func enter_scene(scene_id: String) -> void:
	var previous_scene_id := current_scene_id
	if previous_scene_id != scene_id:
		_track_shadow_room_transition(previous_scene_id, scene_id)
	current_scene_id = scene_id
	if current_event_id == "room_109_open_door" and scene_id == "corridor":
		_entity_recognized = true
	if current_event_id == HANGING_GIRL_EVENT_ID and scene_id == "room_107_bed_nightstand":
		_entity_recognized = true
		sound_requested.emit("girl_visit_laugh")
	state_changed.emit()


func advance(delta: float) -> void:
	if delta <= 0.0:
		return
	if hold_controller != null:
		hold_controller.advance(delta)
	if _bell_sequence_seconds > 0.0:
		_bell_sequence_seconds = maxf(_bell_sequence_seconds - delta, 0.0)
		if _bell_sequence_seconds <= 0.0 and _bell_press_count % 3 != 0:
			_bell_press_count = 0 if current_state == "visible" else 3
	if _shadow_bell_sequence_seconds > 0.0:
		_shadow_bell_sequence_seconds = maxf(_shadow_bell_sequence_seconds - delta, 0.0)
		if _shadow_bell_sequence_seconds <= 0.0:
			_shadow_bell_press_count = 0
	if _shadow_room_transition_seconds > 0.0:
		_shadow_room_transition_seconds = maxf(_shadow_room_transition_seconds - delta, 0.0)
		if _shadow_room_transition_seconds <= 0.0:
			_shadow_room_transition_count = 0
	for index in range(_shadow_echo_queue.size() - 1, -1, -1):
		var echo: Dictionary = _shadow_echo_queue[index]
		echo["seconds"] = float(echo.get("seconds", 0.0)) - delta
		if float(echo["seconds"]) <= 0.0:
			sound_requested.emit(String(echo.get("cue", "")))
			_shadow_echo_queue.remove_at(index)
		else:
			_shadow_echo_queue[index] = echo

	if external_anomaly_active:
		return
	if current_event_id.is_empty():
		_spawn_seconds -= delta
		if _spawn_seconds <= 0.0:
			_enqueue_day_event()
		scheduler.advance(delta)
		return
	_advance_entity(delta)


func has_active_anomaly() -> bool:
	return not current_event_id.is_empty()


func is_daily_schedule_complete() -> bool:
	var target := 0 if current_day < 2 else MAX_PRODUCTION_EVENTS_PER_DAY
	return current_event_id.is_empty() and _resolved_event_ids.size() >= target


func set_random_seed(seed: int) -> void:
	_random_seed_override = seed
	_rng.seed = seed


func is_scene_anomalous(scene_id: String) -> bool:
	if current_event_id.is_empty():
		return false
	return get_active_scene_id() == scene_id or current_event_id == SHADOW_EVENT_ID


func get_active_definition() -> Dictionary:
	return definitions.get(current_event_id, {}).duplicate(true)


func get_active_scene_id() -> String:
	if not _current_scene_override.is_empty():
		return _current_scene_override
	return String(definitions.get(current_event_id, {}).get("scene_id", ""))


func get_presentation_state() -> Dictionary:
	return {
		"event_id": current_event_id,
		"state": current_state,
		"scene_id": get_active_scene_id(),
		"closed_surfaces": _closed_surfaces.duplicate(),
		"curtain_legs_visible": _curtain_legs_visible,
		"entity_stage": _entity_stage,
		"hanging_girl_doll_taken": _hanging_girl_doll_taken,
		"hold_progress": hold_controller.get_progress() if hold_controller != null else 0.0,
	}


func get_dynamic_hotspots(scene_id: String) -> Array:
	if current_event_id.is_empty():
		return []
	if current_event_id == SHADOW_EVENT_ID:
		return []
	if current_event_id == HANGING_GIRL_EVENT_ID and scene_id == "laundry_room":
		if not _hanging_girl_doll_taken and (inventory_model == null or not inventory_model.has_item_id(HANGING_GIRL_DOLL_ITEM_ID)):
			return [{
				"id": "anomaly_pickup:hanging_girl_doll",
				"label": "Cute Doll",
				"rect": Rect2(0.125, 0.440, 0.080, 0.130),
				"anomaly_input": "click",
			}]
		return []
	if scene_id != get_active_scene_id():
		return []
	var definition: Dictionary = definitions[current_event_id]
	var treatment := String(definition.get("treatment", ""))
	if treatment == ContentCatalog.TREATMENT_UNRESOLVED:
		if current_event_id == "room_109_open_door":
			return [{
				"id": "room_109_open_door",
				"label": "Room 109",
				"rect": Rect2(0.735, 0.285, 0.055, 0.325),
			}]
		if current_event_id == HANGING_GIRL_EVENT_ID:
			return [{
				"id": "anomaly_choice:hanging_girl",
				"label": "Hanging Wooden Girl",
				# Match the approved full-scene image: the hanging figure occupies
				# the right side of the bed, not the old center-left placeholder.
				"rect": Rect2(0.625, 0.185, 0.165, 0.725),
				"anomaly_input": "click",
			}]
		return []
	if treatment == ContentCatalog.TREATMENT_CURTAIN_CYCLE:
		return []
	if treatment == ContentCatalog.TREATMENT_SURFACE_SEQUENCE:
		var surface_hotspots := []
		for surface_id in ContentCatalog.surface_rects().keys():
			if _closed_surfaces.has(String(surface_id)):
				continue
			surface_hotspots.append({
				"id": "anomaly_surface:%s" % surface_id,
				"label": "",
				"rect": ContentCatalog.surface_rects()[surface_id],
				"anomaly_input": "click",
			})
		return surface_hotspots
	if treatment == ContentCatalog.TREATMENT_BELL_SEQUENCE:
		return [{
			"id": "anomaly_bell:%s" % current_event_id,
			"label": "",
			"rect": Rect2(0.445, 0.555, 0.095, 0.105),
			"anomaly_input": "click",
		}]
	return [{
		"id": "anomaly_hold:%s" % current_event_id,
		"label": "",
		"rect": definition.get("rect", Rect2()),
		"anomaly_input": "item_hold" if not String(definition.get("required_item_id", "")).is_empty() else "hold",
	}]


func handle_click(hotspot_id: String) -> bool:
	if current_event_id.is_empty():
		return false
	if hotspot_id == "anomaly_pickup:hanging_girl_doll":
		return _take_hanging_girl_doll()
	if hotspot_id == "anomaly_choice:hanging_girl":
		_open_hanging_girl_entry_choice()
		return true
	if hotspot_id.begins_with("anomaly_bell:"):
		_press_bell()
		return true
	if hotspot_id.begins_with("anomaly_surface:"):
		_close_surface(hotspot_id.get_slice(":", 1))
		return true
	return false


func handle_world_hotspot(hotspot_id: String, scene_id: String) -> bool:
	if current_event_id != SHADOW_EVENT_ID:
		return false
	if hotspot_id != "desk_bell" or scene_id != "front_desk":
		return false
	_press_shadow_bell()
	return true


func handle_choice(choice_id: String) -> bool:
	if current_event_id != HANGING_GIRL_EVENT_ID or not _hanging_girl_dialogue_open:
		return false
	if not _hanging_girl_selected_choices.has(choice_id):
		_hanging_girl_selected_choices.append(choice_id)

	match choice_id:
		"entry_talk":
			_request_hanging_choice(
				"horror.hanging_girl.prompt.play",
				"데롱데롱 놀이야~ 재밌겠지?",
				[
					_choice("fun_yes", "horror.hanging_girl.choice.fun_yes", "재미있어 보여"),
					_choice("fun_no", "horror.hanging_girl.choice.fun_no", "재미없어 보여"),
					_choice("ignore", "horror.hanging_girl.choice.ignore", "무시한다"),
				],
			)
		"entry_ignore", "ignore":
			_hanging_girl_dialogue_open = false
			choice_closed.emit()
		"fun_no":
			current_state = "hostile"
			state_changed.emit()
			_request_hanging_choice(
				"horror.hanging_girl.prompt.angry",
				"이 씨발새끼야.",
				_hanging_angry_choices(),
			)
		"better_game":
			_request_hanging_choice(
				"horror.hanging_girl.prompt.which_game",
				"어떤 놀인데?",
				[
					_choice("doll_play", "horror.hanging_girl.choice.doll_play", "인형 놀이"),
					_choice("hide_and_seek", "horror.hanging_girl.choice.hide_and_seek", "숨바꼭질 놀이"),
					_choice("your_mom_game", "horror.hanging_girl.choice.your_mom", "니 엄마다"),
				],
			)
		"walter":
			if inventory_model == null or not inventory_model.has_item_id(HANGING_GIRL_DOLL_ITEM_ID):
				return false
			_request_hanging_choice(
				"horror.hanging_girl.prompt.who_walter",
				"윌터가 누구야?",
				[
					_choice("your_mom_walter", "horror.hanging_girl.choice.your_mom", "니 엄마다"),
					_choice("doll_friend", "horror.hanging_girl.choice.doll_friend", "내 인형 친구야"),
				],
			)
		"doll_friend":
			if inventory_model == null or not inventory_model.remove_item_by_id(HANGING_GIRL_DOLL_ITEM_ID):
				return false
			_hanging_girl_dialogue_open = false
			choice_closed.emit()
			_resolve_current()
		"fun_yes", "changed_mind", "you_play", "doll_play", "hide_and_seek", "your_mom_game", "your_mom_walter":
			_begin_hanging_girl_fatal_narrative()
		_:
			return false
	return true


func finish_fatal_narrative() -> void:
	if not _hanging_girl_fatal_pending or current_event_id != HANGING_GIRL_EVENT_ID:
		return
	_hanging_girl_fatal_pending = false
	_hanging_girl_dialogue_open = false
	if lethal_outcomes_enabled:
		death_requested.emit(HANGING_GIRL_EVENT_ID)


func begin_pointer_hold(hotspot_id: String, equipped_item_id: String, focus_position: Vector2) -> bool:
	if current_event_id.is_empty() or not hotspot_id.begins_with("anomaly_hold:"):
		return false
	var definition: Dictionary = definitions[current_event_id]
	var required_item_id := String(definition.get("required_item_id", ""))
	if not required_item_id.is_empty() and equipped_item_id != required_item_id:
		return false
	return _begin_hold(hotspot_id, required_item_id, focus_position)


func begin_item_hold(hotspot_id: String, equipped_item_id: String, focus_position: Vector2) -> bool:
	if current_event_id.is_empty() or not hotspot_id.begins_with("anomaly_hold:"):
		return false
	var definition: Dictionary = definitions[current_event_id]
	var required_item_id := String(definition.get("required_item_id", ""))
	if required_item_id.is_empty() or equipped_item_id != required_item_id:
		return false
	return _begin_hold(hotspot_id, required_item_id, focus_position)


func release_hold() -> void:
	if hold_controller == null or not hold_controller.is_active():
		return
	hold_controller.cancel()


func handle_curtain_toggled(scene_id: String, is_closed: bool) -> bool:
	if current_event_id != "bathroom_shower_legs" or scene_id != get_active_scene_id():
		return false
	if is_closed:
		_curtain_legs_visible = false
		current_state = "curtain_closed"
		state_changed.emit()
		return true
	_curtain_open_count += 1
	if _curtain_open_count >= _curtain_target_count:
		_curtain_legs_visible = false
		_resolve_current()
		return true
	if not _curtain_has_legs:
		_curtain_legs_visible = false
		_resolve_current()
		return true
	_curtain_legs_visible = true
	current_state = "legs"
	if _curtain_open_count == 1:
		sound_requested.emit("curtain_legs_reveal")
	state_changed.emit()
	return true


func notify_player_action(cue_id: String) -> void:
	if current_event_id != SHADOW_EVENT_ID:
		return
	if cue_id not in ["footstep", "door"]:
		return
	_shadow_echo_queue.append({
		"cue": "%s_echo" % cue_id,
		"seconds": SHADOW_ECHO_DELAY_SECONDS,
	})


func force_event(event_id: String) -> bool:
	if not definitions.has(event_id):
		return false
	if not current_event_id.is_empty():
		scheduler.fail_active(current_event_id)
	_clear_event_state()
	# Debug previews must start immediately even if the previous event left an
	# inter-event cooldown or another pending preview in the scheduler.
	_reset_scheduler()
	current_event_id = ""
	current_state = "idle"
	_spawn_seconds = SPAWN_DELAY_SECONDS
	_debug_force_pending = true
	return scheduler.enqueue(event_id, 100)


func export_state() -> Dictionary:
	return {
		"current_day": current_day,
		"current_scene_id": current_scene_id,
		"current_event_id": current_event_id,
		"current_state": current_state,
		"spawn_seconds": _spawn_seconds,
		"resolved_event_ids": _resolved_event_ids.duplicate(),
		"current_scene_override": _current_scene_override,
		"bell_press_count": _bell_press_count,
		"bell_sequence_seconds": _bell_sequence_seconds,
		"closed_surfaces": _closed_surfaces.duplicate(),
		"curtain_open_count": _curtain_open_count,
		"curtain_target_count": _curtain_target_count,
		"curtain_legs_visible": _curtain_legs_visible,
		"curtain_has_legs": _curtain_has_legs,
		"fatal_seconds_remaining": _fatal_seconds_remaining,
		"entity_recognized": _entity_recognized,
		"entity_stage": _entity_stage,
		"entity_stage_seconds": _entity_stage_seconds,
		"shadow_echo_queue": _shadow_echo_queue.duplicate(true),
		"shadow_bell_press_count": _shadow_bell_press_count,
		"shadow_bell_sequence_seconds": _shadow_bell_sequence_seconds,
		"shadow_room_transition_count": _shadow_room_transition_count,
		"shadow_room_transition_seconds": _shadow_room_transition_seconds,
		"hanging_girl_selected_choices": _hanging_girl_selected_choices.duplicate(),
		"hanging_girl_doll_taken": _hanging_girl_doll_taken,
		"hanging_girl_dialogue_open": _hanging_girl_dialogue_open,
		"hanging_girl_fatal_pending": _hanging_girl_fatal_pending,
		"rng_state": _rng.state,
		"scheduler": scheduler.export_state(),
	}


func import_state(state: Dictionary) -> void:
	current_day = maxi(int(state.get("current_day", current_day)), 1)
	current_scene_id = String(state.get("current_scene_id", current_scene_id))
	current_event_id = String(state.get("current_event_id", ""))
	current_state = String(state.get("current_state", "idle"))
	_spawn_seconds = maxf(float(state.get("spawn_seconds", SPAWN_DELAY_SECONDS)), 0.0)
	_resolved_event_ids = _string_array(state.get("resolved_event_ids", []))
	_current_scene_override = String(state.get("current_scene_override", ""))
	_bell_press_count = int(state.get("bell_press_count", 0))
	_bell_sequence_seconds = maxf(float(state.get("bell_sequence_seconds", 0.0)), 0.0)
	_closed_surfaces = _string_array(state.get("closed_surfaces", []))
	_curtain_open_count = int(state.get("curtain_open_count", 0))
	_curtain_target_count = clampi(int(state.get("curtain_target_count", 3)), 3, 5)
	_curtain_legs_visible = bool(state.get("curtain_legs_visible", false))
	_curtain_has_legs = bool(state.get("curtain_has_legs", true))
	_fatal_seconds_remaining = maxf(float(state.get("fatal_seconds_remaining", 0.0)), 0.0)
	_entity_recognized = bool(state.get("entity_recognized", false))
	_entity_stage = maxi(int(state.get("entity_stage", 0)), 0)
	_entity_stage_seconds = maxf(float(state.get("entity_stage_seconds", 0.0)), 0.0)
	_shadow_echo_queue.clear()
	for raw_echo in state.get("shadow_echo_queue", []):
		if raw_echo is Dictionary:
			_shadow_echo_queue.append(raw_echo.duplicate(true))
	_shadow_bell_press_count = clampi(int(state.get("shadow_bell_press_count", 0)), 0, SHADOW_BELL_PRESS_TARGET)
	_shadow_bell_sequence_seconds = maxf(float(state.get("shadow_bell_sequence_seconds", 0.0)), 0.0)
	_shadow_room_transition_count = clampi(int(state.get("shadow_room_transition_count", 0)), 0, SHADOW_ROOM_TRANSITION_TARGET)
	_shadow_room_transition_seconds = maxf(float(state.get("shadow_room_transition_seconds", 0.0)), 0.0)
	_hanging_girl_selected_choices = _string_array(state.get("hanging_girl_selected_choices", []))
	_hanging_girl_doll_taken = bool(state.get("hanging_girl_doll_taken", false))
	_hanging_girl_dialogue_open = false
	_hanging_girl_fatal_pending = false
	if state.has("rng_state"):
		_rng.state = int(state["rng_state"])
	_reset_scheduler()
	scheduler.import_state(state.get("scheduler", {}))
	state_changed.emit()


func _reset_scheduler() -> void:
	scheduler = Scheduler.new()
	scheduler.event_started.connect(_on_scheduled_event_started)


func _enqueue_day_event() -> void:
	if _resolved_event_ids.size() >= MAX_PRODUCTION_EVENTS_PER_DAY:
		_spawn_seconds = SPAWN_DELAY_SECONDS
		return
	var candidates: Array[String] = []
	for event_id in ContentCatalog.production_event_ids():
		var definition: Dictionary = definitions[event_id]
		if int(definition.get("min_day", 99)) <= current_day and not _resolved_event_ids.has(event_id):
			candidates.append(event_id)
	if candidates.is_empty():
		_spawn_seconds = SPAWN_DELAY_SECONDS
		return
	var index := _rng.randi_range(0, candidates.size() - 1)
	scheduler.enqueue(candidates[index], 0)


func _on_scheduled_event_started(event_id: String) -> void:
	if not definitions.has(event_id):
		scheduler.fail_active(event_id)
		return
	current_event_id = event_id
	current_state = "visible"
	_clear_event_state()
	var definition: Dictionary = definitions[event_id]
	_fatal_seconds_remaining = float(definition.get("fatal_seconds", 0.0))
	if event_id == "bathroom_shower_legs":
		# The MVP photo variant currently matches Room 105. Add per-room
		# manifests before restoring randomized bathroom placement.
		_current_scene_override = "room_105_bathroom"
		_curtain_target_count = _rng.randi_range(3, 5)
		_curtain_has_legs = true if _debug_force_pending else _rng.randi_range(0, 1) == 1
		current_state = "curtain_closed"
	elif event_id == SHADOW_EVENT_ID:
		current_state = "attached"
	elif event_id == HANGING_GIRL_EVENT_ID:
		_hanging_girl_selected_choices.clear()
		_hanging_girl_doll_taken = (
			inventory_model != null
			and inventory_model.has_item_id(HANGING_GIRL_DOLL_ITEM_ID)
		)
	_debug_force_pending = false
	event_started.emit(event_id)
	state_changed.emit()


func _begin_hold(hotspot_id: String, required_item_id: String, focus_position: Vector2) -> bool:
	var duration := float(definitions[current_event_id].get("hold_seconds", 0.0))
	if duration <= 0.0:
		return false
	_hold_hotspot_id = hotspot_id
	_hold_required_item_id = required_item_id
	_hold_mode = "circular"
	return hold_controller.begin(hotspot_id, duration)


func _on_hold_started(_hold_id: String, _duration_seconds: float) -> void:
	hold_started.emit(_hold_mode, get_viewport().get_mouse_position() if is_inside_tree() else Vector2.ZERO)


func _on_hold_progress_changed(_hold_id: String, progress: float) -> void:
	hold_progress_changed.emit(progress)
	if current_event_id == "room_108_tv_ghost":
		current_state = "hostile" if progress >= 0.55 else "flicker"
		sound_requested.emit("tv_static_rise")
	state_changed.emit()


func _on_hold_cancelled(_hold_id: String) -> void:
	if current_event_id == "room_108_tv_ghost":
		current_state = "visible"
		state_changed.emit()
	hold_ended.emit()
	_hold_hotspot_id = ""
	_hold_required_item_id = ""


func _on_hold_completed(_hold_id: String) -> void:
	hold_ended.emit()
	if current_event_id == "room_106_horrific_mirror":
		_complete_mirror_transfer()
	else:
		_resolve_current()


func _press_bell() -> void:
	if _bell_sequence_seconds <= 0.0:
		_bell_press_count = 0 if current_state == "visible" else 3
	_bell_sequence_seconds = BELL_SEQUENCE_WINDOW_SECONDS
	_bell_press_count += 1
	sound_requested.emit("desk_bell")
	if _bell_press_count == 3:
		current_state = "hostile"
		_bell_sequence_seconds = BELL_SEQUENCE_WINDOW_SECONDS
		state_changed.emit()
	elif _bell_press_count >= 6:
		_resolve_current()


func _press_shadow_bell() -> void:
	sound_requested.emit("desk_bell")
	_shadow_echo_queue.append({
		"cue": "desk_bell_echo",
		"seconds": SHADOW_ECHO_DELAY_SECONDS,
	})
	if current_state != "attached":
		return
	if _shadow_bell_sequence_seconds <= 0.0:
		_shadow_bell_press_count = 0
	_shadow_bell_sequence_seconds = SHADOW_BELL_SEQUENCE_WINDOW_SECONDS
	_shadow_bell_press_count += 1
	if _shadow_bell_press_count < SHADOW_BELL_PRESS_TARGET:
		return
	_shadow_bell_press_count = SHADOW_BELL_PRESS_TARGET
	_shadow_bell_sequence_seconds = 0.0
	current_state = "bell_distressed"
	sound_requested.emit("shadow_scream")
	state_changed.emit()


func _track_shadow_room_transition(previous_scene_id: String, scene_id: String) -> void:
	if current_event_id != SHADOW_EVENT_ID or current_state != "bell_distressed":
		return
	if not _is_shadow_room_boundary(previous_scene_id, scene_id):
		return
	if _shadow_room_transition_seconds <= 0.0:
		_shadow_room_transition_count = 0
	_shadow_room_transition_count += 1
	_shadow_room_transition_seconds = SHADOW_ROOM_TRANSITION_WINDOW_SECONDS
	if _shadow_room_transition_count < SHADOW_ROOM_TRANSITION_TARGET:
		return
	sound_requested.emit("shadow_scream")
	_resolve_current()


func _is_shadow_room_boundary(previous_scene_id: String, scene_id: String) -> bool:
	var previous_is_room := previous_scene_id.begins_with("room_")
	var next_is_room := scene_id.begins_with("room_")
	return (
		(previous_scene_id == "corridor" and next_is_room)
		or (scene_id == "corridor" and previous_is_room)
	)


func _close_surface(surface_id: String) -> void:
	if not ContentCatalog.surface_rects().has(surface_id) or _closed_surfaces.has(surface_id):
		return
	_closed_surfaces.append(surface_id)
	sound_requested.emit("baby_short_cry")
	state_changed.emit()
	if _closed_surfaces.size() >= ContentCatalog.surface_rects().size():
		_resolve_current()


func _complete_mirror_transfer() -> void:
	if inventory_model == null:
		return
	if not inventory_model.replace_item_by_id("small_mirror", "hell_mirror", true):
		return
	sound_requested.emit("soul_scream")
	_resolve_current()


func _resolve_current() -> void:
	if current_event_id.is_empty():
		return
	var resolved_id := current_event_id
	if not _resolved_event_ids.has(resolved_id):
		_resolved_event_ids.append(resolved_id)
	current_state = "resolved"
	_clear_event_state()
	scheduler.complete_active(resolved_id, INTER_EVENT_COOLDOWN_SECONDS)
	current_event_id = ""
	_spawn_seconds = SPAWN_DELAY_SECONDS
	event_resolved.emit(resolved_id)
	state_changed.emit()


func _advance_entity(delta: float) -> void:
	if not definitions.has(current_event_id):
		return
	var definition: Dictionary = definitions[current_event_id]
	if String(definition.get("type", "")) != ContentCatalog.TYPE_ENTITY:
		return
	if current_event_id in ["room_109_open_door", HANGING_GIRL_EVENT_ID] and not _entity_recognized:
		return
	if current_event_id == HANGING_GIRL_EVENT_ID and _hanging_girl_dialogue_open:
		return
	_fatal_seconds_remaining = maxf(_fatal_seconds_remaining - delta, 0.0)
	if current_event_id == HANGING_GIRL_EVENT_ID:
		_entity_stage_seconds += delta
		var next_stage := clampi(int(_entity_stage_seconds / 10.0), 0, 4)
		if next_stage != _entity_stage:
			_entity_stage = next_stage
			if _entity_stage >= 3:
				sound_requested.emit("girl_visit_laugh")
			state_changed.emit()
	if _fatal_seconds_remaining <= 0.0 and lethal_outcomes_enabled and current_state != "fatal":
		current_state = "fatal"
		state_changed.emit()
		death_requested.emit(current_event_id)


func _clear_event_state(clear_scene_override := true) -> void:
	if hold_controller != null and hold_controller.is_active():
		hold_controller.cancel()
	if clear_scene_override:
		_current_scene_override = ""
	_hold_hotspot_id = ""
	_hold_required_item_id = ""
	_bell_press_count = 0
	_bell_sequence_seconds = 0.0
	_closed_surfaces.clear()
	_curtain_open_count = 0
	_curtain_legs_visible = false
	_curtain_has_legs = true
	_fatal_seconds_remaining = 0.0
	_entity_recognized = false
	_entity_stage = 0
	_entity_stage_seconds = 0.0
	_shadow_bell_press_count = 0
	_shadow_bell_sequence_seconds = 0.0
	_shadow_room_transition_count = 0
	_shadow_room_transition_seconds = 0.0
	_hanging_girl_dialogue_open = false
	_hanging_girl_fatal_pending = false
	_shadow_echo_queue.clear()


func _take_hanging_girl_doll() -> bool:
	if current_event_id != HANGING_GIRL_EVENT_ID or inventory_model == null:
		return false
	if _hanging_girl_doll_taken or inventory_model.has_item_id(HANGING_GIRL_DOLL_ITEM_ID):
		return false
	inventory_model.add_item_by_id(HANGING_GIRL_DOLL_ITEM_ID)
	_hanging_girl_doll_taken = true
	state_changed.emit()
	return true


func _open_hanging_girl_entry_choice() -> void:
	if current_event_id != HANGING_GIRL_EVENT_ID or _hanging_girl_fatal_pending:
		return
	_hanging_girl_dialogue_open = true
	_request_hanging_choice(
		"horror.hanging_girl.prompt.interact",
		"목을 맨 목각 여자 인형이 이쪽을 보고 있다.",
		[
			_choice("entry_talk", "horror.hanging_girl.choice.talk", "대화한다"),
			_choice("entry_ignore", "horror.hanging_girl.choice.ignore", "무시한다"),
		],
	)


func _hanging_angry_choices() -> Array:
	var choices := [
		_choice("changed_mind", "horror.hanging_girl.choice.changed_mind", "다시 보니 재미있어 보여"),
		_choice("you_play", "horror.hanging_girl.choice.you_play", "너나 많이 해"),
		_choice("better_game", "horror.hanging_girl.choice.better_game", "더 재밌는 놀이를 알려줄게"),
	]
	if inventory_model != null and inventory_model.has_item_id(HANGING_GIRL_DOLL_ITEM_ID):
		choices.append(_choice("walter", "horror.hanging_girl.choice.walter", "윌터는 재미있어 보인대"))
	return choices


func _request_hanging_choice(prompt_key: String, fallback_prompt: String, choices: Array) -> void:
	var marked_choices := []
	for raw_choice in choices:
		var choice: Dictionary = raw_choice.duplicate(true)
		choice["selected"] = _hanging_girl_selected_choices.has(String(choice.get("id", "")))
		marked_choices.append(choice)
	choice_requested.emit(prompt_key, fallback_prompt, marked_choices)


func _choice(choice_id: String, text_key: String, fallback_text: String) -> Dictionary:
	return {
		"id": choice_id,
		"text_key": text_key,
		"fallback_text": fallback_text,
	}


func _begin_hanging_girl_fatal_narrative() -> void:
	_hanging_girl_fatal_pending = true
	_hanging_girl_dialogue_open = true
	fatal_narrative_requested.emit([
		{"key": "horror.hanging_girl.death.1", "fallback": "밧줄이 목을 조였다."},
		{"key": "horror.hanging_girl.death.2", "fallback": "죽지 못한 채 몸이 오래 흔들렸다."},
		{"key": "horror.hanging_girl.death.3", "fallback": "혀가 입 밖으로 밀려 나왔다."},
		{"key": "horror.hanging_girl.death.4", "fallback": "토사물이 턱과 가슴을 타고 흘렀다."},
		{"key": "horror.hanging_girl.death.5", "fallback": "괄약근이 풀리며 장에 남은 것이 전부 쏟아졌다."},
		{"key": "horror.hanging_girl.death.6", "fallback": "발버둥은 한참 뒤에야 멎었다."},
	])


func _string_array(raw_values) -> Array[String]:
	var values: Array[String] = []
	for raw_value in raw_values:
		values.append(String(raw_value))
	return values
