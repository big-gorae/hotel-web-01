class_name HotelStoryDeliveryManager
extends RefCounted

const DAY_BEATS := {
	1: [
		{
			"id": "story.unpaid_wages_call",
			"content_key": "story.day.1.line.1",
			"fallback_content": "At 12:47 a.m., an unfamiliar number called.\n‘Unclaimed wages remain under your name. Come collect them in person.’",
		},
		{
			"id": "story.debt_forces_acceptance",
			"content_key": "story.day.1.line.2",
			"fallback_content": "I had never worked at this hotel. But after months spent hiding from gambling debt and illegal work, money left under my name was difficult to ignore.",
		},
	],
	2: [{
		"id": "story.previous_shift_under_player_name",
		"content_key": "story.day.2.line.1",
		"fallback_content": "A previous employee record was filed under my name. Two contact numbers had been written beneath it.",
	}],
	3: [{
		"id": "story.second_contact_matches_player",
		"content_key": "story.day.3.line.1",
		"fallback_content": "The second contact number was mine. It was the number I had changed after going into hiding.",
	}],
	4: [{
		"id": "story.previous_worker_was_sister",
		"content_key": "story.day.4.line.1",
		"fallback_content": "The photograph attached to the record was my missing older sister. She had worked here under my name.",
	}],
	5: [{
		"id": "story.sister_investigated_disappearance",
		"content_key": "story.day.5.line.1",
		"fallback_content": "Dates and room numbers filled the margins of her record. She had been tracing rumors of people disappearing from this hotel.",
	}],
	6: [{
		"id": "story.do_not_say_looking_for_sibling",
		"content_key": "story.day.6.line.1",
		"fallback_content": "One sentence remained on the back, in my sister’s handwriting.\n‘Do not say you came looking for your younger sister.’",
	}],
	7: [{
		"id": "story.younger_sister_recognition",
		"content_key": "story.day.7.line.1",
		"fallback_content": "She came here looking for her younger sister.\nI am that sister.",
	}],
}

var completed_story_beat_ids: Array[String] = []
var unlocked_evidence_ids: Array[String] = []
var current_story_sequence_id := ""
var story_sequence_step := 0


func start_new_run() -> void:
	completed_story_beat_ids.clear()
	unlocked_evidence_ids.clear()
	current_story_sequence_id = ""
	story_sequence_step = 0


func prepare_day(day: int) -> bool:
	var sequence_id := _sequence_id(day)
	var beats: Array = DAY_BEATS.get(day, [])
	if beats.is_empty() or _is_day_complete(day):
		current_story_sequence_id = ""
		story_sequence_step = 0
		return false
	if current_story_sequence_id != sequence_id:
		current_story_sequence_id = sequence_id
		story_sequence_step = _first_incomplete_step(beats)
	return has_active_sequence()


func has_active_sequence() -> bool:
	if current_story_sequence_id.is_empty():
		return false
	var beats := _current_beats()
	return story_sequence_step >= 0 and story_sequence_step < beats.size()


func get_current_beat() -> Dictionary:
	if not has_active_sequence():
		return {}
	return _current_beats()[story_sequence_step].duplicate(true)


func get_current_step() -> int:
	return story_sequence_step + 1 if has_active_sequence() else 0


func advance() -> bool:
	if not has_active_sequence():
		return false
	var beats := _current_beats()
	var beat_id := String(beats[story_sequence_step].get("id", ""))
	if not beat_id.is_empty() and not completed_story_beat_ids.has(beat_id):
		completed_story_beat_ids.append(beat_id)
		unlocked_evidence_ids.append(beat_id)
	story_sequence_step += 1
	if story_sequence_step >= beats.size():
		current_story_sequence_id = ""
		story_sequence_step = 0
		return false
	return true


func export_state() -> Dictionary:
	return {
		"completed_story_beat_ids": completed_story_beat_ids.duplicate(),
		"unlocked_evidence_ids": unlocked_evidence_ids.duplicate(),
		"current_story_sequence_id": current_story_sequence_id,
		"story_sequence_step": story_sequence_step,
	}


func import_state(state: Dictionary) -> void:
	completed_story_beat_ids = _string_array(state.get("completed_story_beat_ids", []))
	unlocked_evidence_ids = _string_array(state.get("unlocked_evidence_ids", []))
	current_story_sequence_id = String(state.get("current_story_sequence_id", ""))
	story_sequence_step = maxi(int(state.get("story_sequence_step", 0)), 0)
	if not has_active_sequence():
		current_story_sequence_id = ""
		story_sequence_step = 0


func _is_day_complete(day: int) -> bool:
	for beat in DAY_BEATS.get(day, []):
		if not completed_story_beat_ids.has(String(beat.get("id", ""))):
			return false
	return true


func _first_incomplete_step(beats: Array) -> int:
	for index in beats.size():
		if not completed_story_beat_ids.has(String(beats[index].get("id", ""))):
			return index
	return beats.size()


func _current_beats() -> Array:
	var day := int(current_story_sequence_id.trim_prefix("story.day."))
	return DAY_BEATS.get(day, [])


func _sequence_id(day: int) -> String:
	return "story.day.%d" % day


func _string_array(values) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text := String(value)
		if not text.is_empty() and not result.has(text):
			result.append(text)
	return result
