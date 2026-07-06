class_name HotelDaySaveManager
extends RefCounted

const TOTAL_DAYS := 5
const SAVE_VERSION := 1
const SAVE_PATH := "user://hotel_save.json"

var current_day := 1
var unlocked_days: Array[int] = [1]
var day_slots: Dictionary = {}


func load_save_data() -> void:
	unlocked_days = [1]
	day_slots.clear()
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var save_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		push_warning("Failed to open save file: %s" % SAVE_PATH)
		return

	var parsed = JSON.parse_string(save_file.get_as_text())
	if not parsed is Dictionary:
		push_warning("Ignoring invalid save file: %s" % SAVE_PATH)
		return

	var save_data: Dictionary = parsed
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


func unlock_day(day: int) -> void:
	var safe_day := clamp_day(day)
	if not unlocked_days.has(safe_day):
		unlocked_days.append(safe_day)
		unlocked_days.sort()


func clamp_day(day: int) -> int:
	return clampi(day, 1, TOTAL_DAYS)


func _write_save_data() -> void:
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		push_warning("Failed to write save file: %s" % SAVE_PATH)
		return

	save_file.store_string(JSON.stringify({
		"version": SAVE_VERSION,
		"current_day": current_day,
		"unlocked_days": unlocked_days,
		"day_slots": day_slots,
	}, "\t"))
