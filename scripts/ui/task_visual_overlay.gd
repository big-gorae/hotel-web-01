class_name HotelTaskVisualOverlay
extends Control

const MANIFEST_ROOT := "res://resource/task_overlay_manifests"

var _task_manager = null
var _manifests_by_scene: Dictionary = {}
var _current_scene_id := ""
var _active_event_id := ""
var _photo_rect := Rect2()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	reload_manifests()


func setup(task_manager) -> void:
	if _task_manager != null and _task_manager.tasks_changed.is_connected(_on_tasks_changed):
		_task_manager.tasks_changed.disconnect(_on_tasks_changed)
	_task_manager = task_manager
	if _task_manager != null and not _task_manager.tasks_changed.is_connected(_on_tasks_changed):
		_task_manager.tasks_changed.connect(_on_tasks_changed)
	_rebuild()


func reload_manifests() -> void:
	_manifests_by_scene.clear()
	var directory := DirAccess.open(MANIFEST_ROOT)
	if directory == null:
		_rebuild()
		return

	directory.list_dir_begin()
	var filename := directory.get_next()
	while not filename.is_empty():
		if not directory.current_is_dir() and filename.get_extension().to_lower() == "json":
			var manifest := _load_manifest("%s/%s" % [MANIFEST_ROOT, filename])
			var scene_id := String(manifest.get("scene_id", ""))
			if not scene_id.is_empty():
				_manifests_by_scene[scene_id] = manifest
		filename = directory.get_next()
	directory.list_dir_end()
	_rebuild()


func set_scene(scene_id: String) -> void:
	_current_scene_id = scene_id
	_rebuild()


func set_photo_rect(value: Rect2) -> void:
	_photo_rect = value
	_layout_layers()


func set_active_event_id(event_id: String) -> void:
	if _active_event_id == event_id:
		return
	_active_event_id = event_id
	_rebuild()


func refresh() -> void:
	_rebuild()


func get_visible_task_ids() -> Array[String]:
	var result: Array[String] = []
	for child in get_children():
		var task_id := String(child.get_meta("task_id", ""))
		if not task_id.is_empty():
			result.append(task_id)
	return result


func _load_manifest(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return {}
	if not parsed.get("layers", []) is Array:
		return {}
	return parsed


func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	visible = false
	if _task_manager == null or not _manifests_by_scene.has(_current_scene_id):
		return

	var manifest: Dictionary = _manifests_by_scene[_current_scene_id]
	for raw_layer in manifest.get("layers", []):
		if not raw_layer is Dictionary:
			continue
		var layer: Dictionary = raw_layer
		var task_id := String(layer.get("task_id", ""))
		if task_id.is_empty() or not _task_manager.has_definition(task_id):
			continue
		if not layer.get("visible_states", ["pending"]).has(_task_manager.get_task_state(task_id)):
			continue
		if not _active_event_id.is_empty() and layer.get("suppressed_by_event_ids", []).has(_active_event_id):
			continue
		_add_layer(layer, task_id)

	visible = get_child_count() > 0
	_layout_layers()


func _add_layer(layer: Dictionary, task_id: String) -> void:
	var texture := load(String(layer.get("path", ""))) as Texture2D
	if texture == null:
		return
	var texture_rect := TextureRect.new()
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.z_index = int(layer.get("z_index", 0))
	texture_rect.set_meta("task_id", task_id)
	texture_rect.set_meta("slot", String(layer.get("slot", "")))
	add_child(texture_rect)


func _layout_layers() -> void:
	for child in get_children():
		if child is Control:
			child.position = _photo_rect.position
			child.size = _photo_rect.size


func _on_tasks_changed() -> void:
	_rebuild()
