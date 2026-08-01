class_name HotelMoldGrowthSystem
extends RefCounted

signal stack_changed(room_id: String, stack: int)
signal maximum_reached(room_id: String)

const MAX_STACK := 6
const MOLD_REMOVER_ITEM_ID := "mold_remover"

var initial_cooldown_min := 45.0
var initial_cooldown_max := 90.0
var growth_interval := 20.0
var enabled := false
var rng := RandomNumberGenerator.new()

var _stacks: Dictionary = {}
var _seconds_until_growth: Dictionary = {}


func setup(seed_value := 0) -> void:
	if seed_value == 0:
		rng.randomize()
	else:
		rng.seed = seed_value


func set_enabled(value: bool) -> void:
	enabled = value


func register_room(room_id: String) -> void:
	if room_id.is_empty() or _stacks.has(room_id):
		return
	_stacks[room_id] = 0
	_seconds_until_growth[room_id] = _next_initial_cooldown()


func advance(delta: float) -> void:
	if not enabled or delta <= 0.0:
		return

	for room_id_variant in _stacks.keys():
		var room_id := String(room_id_variant)
		var stack := get_mold_stack(room_id)
		if stack >= MAX_STACK:
			continue

		var remaining := float(_seconds_until_growth.get(room_id, _next_initial_cooldown())) - delta
		while remaining <= 0.0 and stack < MAX_STACK:
			stack += 1
			_stacks[room_id] = stack
			stack_changed.emit(room_id, stack)
			if stack >= MAX_STACK:
				maximum_reached.emit(room_id)
				remaining = 0.0
				break
			remaining += growth_interval
		_seconds_until_growth[room_id] = remaining


func get_mold_stack(room_id: String) -> int:
	return clampi(int(_stacks.get(room_id, 0)), 0, MAX_STACK)


func can_remove_with_item(item_id: String) -> bool:
	return item_id == MOLD_REMOVER_ITEM_ID


func remove_mold(room_id: String, item_id: String) -> bool:
	if not can_remove_with_item(item_id) or get_mold_stack(room_id) <= 0:
		return false

	_stacks[room_id] = maxi(get_mold_stack(room_id) - 2, 0)
	_seconds_until_growth[room_id] = _next_initial_cooldown()
	stack_changed.emit(room_id, get_mold_stack(room_id))
	return true


func force_stack(room_id: String, stack: int) -> void:
	register_room(room_id)
	var safe_stack := clampi(stack, 0, MAX_STACK)
	_stacks[room_id] = safe_stack
	_seconds_until_growth[room_id] = growth_interval if safe_stack > 0 else _next_initial_cooldown()
	stack_changed.emit(room_id, safe_stack)
	if safe_stack == MAX_STACK:
		maximum_reached.emit(room_id)


func export_state() -> Dictionary:
	return {
		"enabled": enabled,
		"stacks": _stacks.duplicate(true),
		"seconds_until_growth": _seconds_until_growth.duplicate(true),
	}


func import_state(state: Dictionary) -> void:
	enabled = bool(state.get("enabled", enabled))
	_stacks = state.get("stacks", {}).duplicate(true)
	_seconds_until_growth = state.get("seconds_until_growth", {}).duplicate(true)


func _next_initial_cooldown() -> float:
	return rng.randf_range(initial_cooldown_min, initial_cooldown_max)
