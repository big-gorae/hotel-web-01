class_name HotelDaySaveManager
extends RefCounted

const JsonSaveStore := preload("res://scripts/systems/json_save_store.gd")
const GameMode := preload("res://scripts/systems/game_mode.gd")

const TOTAL_DAYS := 7
const SAVE_VERSION := 3
const SAVE_PATH := "user://hotel_save.json"
const INFINITY_SAVE_PATH := "user://hotel_infinity_save.json"

var game_mode := GameMode.STORY
var current_day := 1
var unlocked_days: Array[int] = [1]
var day_slots: Dictionary = {}


func load_save_data() -> void:
	current_day = 1
	unlocked_days = [1]
	day_slots.clear()
	var loaded_data := JsonSaveStore.load_dictionary(get_save_path())
	if loaded_data.is_empty():
		return

	var save_data := _migrate_save_data(loaded_data)
	if save_data.is_empty():
		return
	unlocked_days.clear()
	for value in save_data.get("unlocked_days", [1]):
		unlock_day(int(value))

	var saved_slots: Dictionary = save_data.get("day_slots", {})
	for key in saved_slots.keys():
		var day := clamp_day(int(key))
		var slot = saved_slots[key]
		if slot is Dictionary:
			day_slots[str(day)] = slot
			unlock_day(day)

	if unlocked_days.is_empty():
		unlocked_days = [1]

	current_day = clamp_day(int(save_data.get("current_day", 1)))


func set_game_mode(mode_id: String, reload_data := true) -> void:
	game_mode = GameMode.normalize(mode_id)
	if reload_data:
		load_save_data()


func get_game_mode() -> String:
	return game_mode


func is_infinity_mode() -> bool:
	return GameMode.is_infinity(game_mode)


func get_save_path() -> String:
	return INFINITY_SAVE_PATH if is_infinity_mode() else SAVE_PATH


func start_new_shift() -> void:
	current_day = 1
	unlocked_days = [1]
	day_slots.clear()


func set_current_day(day: int) -> void:
	current_day = clamp_day(day)
	unlock_day(current_day)


func save_current_state(state: Dictionary) -> void:
	unlock_day(current_day)
	var stored_state := state.duplicate(true)
	stored_state["day"] = current_day
	day_slots[str(current_day)] = stored_state
	_write_save_data()


func get_day_state(day: int) -> Dictionary:
	var safe_day := clamp_day(day)
	var state = day_slots.get(str(safe_day), {})
	if state is Dictionary:
		return state.duplicate(true)

	return {}


func has_save_data() -> bool:
	return not day_slots.is_empty()


func has_saved_day(day: int) -> bool:
	return day_slots.has(str(clamp_day(day)))


func latest_saved_day() -> int:
	var latest_day := 1
	for key in day_slots.keys():
		latest_day = max(latest_day, int(key))

	return latest_day


func get_saved_days() -> Array[int]:
	var saved_days: Array[int] = []
	for key in day_slots.keys():
		var day := clamp_day(int(key))
		if not saved_days.has(day):
			saved_days.append(day)
	saved_days.sort()
	return saved_days


func unlock_day(day: int) -> void:
	var safe_day := clamp_day(day)
	if not unlocked_days.has(safe_day):
		unlocked_days.append(safe_day)
		unlocked_days.sort()


func clamp_day(day: int) -> int:
	return maxi(day, 1) if is_infinity_mode() else clampi(day, 1, TOTAL_DAYS)


func _write_save_data() -> void:
	JsonSaveStore.write_dictionary_atomic(get_save_path(), {
		"version": SAVE_VERSION,
		"game_mode": game_mode,
		"current_day": current_day,
		"unlocked_days": unlocked_days,
		"day_slots": day_slots,
	})


func _migrate_save_data(save_data: Dictionary) -> Dictionary:
	var version := int(save_data.get("version", 1))
	if version > SAVE_VERSION:
		push_warning("Save version %d is newer than supported version %d." % [version, SAVE_VERSION])
		return {}

	var migrated := save_data.duplicate(true)
	if version <= 1:
		if not migrated.get("day_slots", {}) is Dictionary:
			migrated["day_slots"] = {}
		if not migrated.get("unlocked_days", []) is Array:
			migrated["unlocked_days"] = [1]
		migrated["version"] = 2
	if version <= 2:
		migrated["game_mode"] = game_mode
		migrated["version"] = 3

	return migrated
