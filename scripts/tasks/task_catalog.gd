class_name HotelTaskCatalog
extends RefCounted

const TaskDefinition := preload("res://scripts/tasks/task_definition.gd")


static func build_definitions() -> Array:
	return [
		_make_room_105_fold_bedding(),
		_make_room_105_clean_sink(),
		_make_room_107_collect_papers(),
	]


static func _make_room_105_fold_bedding():
	var task := TaskDefinition.new()
	task.id = "room_105_fold_bedding"
	task.room_id = "room_105"
	task.scene_ids = ["room_105_door_window"]
	task.hotspot_id = "task_room_105_fold_bedding"
	task.task_type = "fold_bedding"
	task.completion_flag_id = "task.room_105.bedding.folded"
	task.rect = Rect2(0.050, 0.515, 0.420, 0.330)
	task.label_key = "task.room_105_fold_bedding.label"
	task.text_key = "task.room_105_fold_bedding.text"
	task.done_text_key = "task.room_105_fold_bedding.done"
	task.fallback_label = "Bedding"
	task.fallback_text = "The bed is not quite ready for a guest."
	task.fallback_done_text = "You fold the bedding into a neat, stiff square."
	return task


static func _make_room_105_clean_sink():
	var task := TaskDefinition.new()
	task.id = "room_105_clean_sink"
	task.room_id = "room_105"
	task.scene_ids = ["room_105_bathroom"]
	task.hotspot_id = "task_room_105_clean_sink"
	task.task_type = "clean_stain"
	task.rect = Rect2(0.060, 0.640, 0.330, 0.220)
	task.required_item_id = "cleaning_cloth"
	task.completion_flag_id = "task.room_105.sink.cleaned"
	task.label_key = "task.room_105_clean_sink.label"
	task.text_key = "task.room_105_clean_sink.text"
	task.done_text_key = "task.room_105_clean_sink.done"
	task.blocked_text_key = "task.room_105_clean_sink.blocked"
	task.fallback_label = "Sink Stain"
	task.fallback_text = "The sink has a dull stain that should be wiped down."
	task.fallback_done_text = "The sink looks clean enough for the next guest."
	task.fallback_blocked_text = "You need something to wipe the sink with."
	return task


static func _make_room_107_collect_papers():
	var task := TaskDefinition.new()
	task.id = "room_107_collect_papers"
	task.room_id = "room_107"
	task.scene_ids = ["room_107_bed_nightstand"]
	task.hotspot_id = "task_room_107_collect_papers"
	task.task_type = "collect_trash"
	task.rect = Rect2(0.420, 0.700, 0.250, 0.170)
	task.reward_item_id = "collected_trash"
	task.completion_flag_id = "task.room_107.papers.collected"
	task.label_key = "task.room_107_collect_papers.label"
	task.text_key = "task.room_107_collect_papers.text"
	task.done_text_key = "task.room_107_collect_papers.done"
	task.fallback_label = "Loose Papers"
	task.fallback_text = "A few papers are scattered on the carpet."
	task.fallback_done_text = "You collect the loose papers from the carpet."
	return task
