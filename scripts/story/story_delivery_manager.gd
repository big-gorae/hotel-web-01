class_name HotelStoryDeliveryManager
extends RefCounted

const DAY_BEATS := {
	1: [
		{
			"id": "story.call_uses_sister_name",
			"content_key": "story.day.1.line.1",
			"fallback_content": "At 12:47 a.m., an unfamiliar number called and addressed me by my missing older sister’s name.\n‘You have missed shifts to make up. Your unpaid wages and severance exceed fifty million won.’",
		},
		{
			"id": "story.player_claims_sister_identity",
			"content_key": "story.day.1.line.2",
			"fallback_content": "My sister would not answer, and our parents did not know where she was. I told the caller that I was her. It was the first trace she had left in months.",
		},
	],
	2: [{
		"id": "story.sister_employment_record",
		"content_key": "story.day.2.line.1",
		"fallback_content": "The employment record was in my sister’s name. The pay was abnormally high, but every attempt to contact the owner ended at the same unanswered number.",
	}],
	3: [{
		"id": "story.sister_undercover_investigation",
		"content_key": "story.day.3.line.1",
		"fallback_content": "My sister was a detective. She had taken this job undercover to investigate the excessive wages, the unreachable owner, and employees who disappeared after resigning.",
	}],
	4: [{
		"id": "story.blood_obscured_false_rule_warning",
		"content_key": "story.day.4.line.1",
		"fallback_content": "In my sister’s handwriting: ‘Rule ■■ is a lie.’ Blood covered the number. Directly below it, a neat printed line read: ‘Ignore instruction 9.’",
	}],
	5: [{
		"id": "story.sister_traced_missing_workers",
		"content_key": "story.day.5.line.1",
		"fallback_content": "Her notes matched large payments to workers who vanished. Each file ended with a voluntary resignation, but none of them had been reached afterward.",
	}],
	6: [{
		"id": "story.sister_last_room_109_recording",
		"content_key": "story.day.6.line.1",
		"fallback_content": "Her last recording ended with one sentence.\n‘Room 109 is open. I’m going in, as the rule says.’",
	}],
	7: [{
		"id": "story.room_109_invitation_wording",
		"content_key": "story.day.7.line.1",
		"fallback_content": "The last page of my sister’s notes copied Rule 6 word for word.\n‘If Room 109 is open, come inside.’",
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
