class_name HotelAnomalyPresentationLayer
extends Control

const Manifest := preload("res://scripts/horror/anomaly_presentation_manifest.gd")
const MANIFEST_ROOT := "res://resource/anomaly_manifests"

var _manifests_by_event: Dictionary = {}
var _active_event_id := ""
var _active_state_id := ""
var _current_scene_id := ""
var _photo_rect := Rect2()
var _rendering_artifact := false
var _presentation_state: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	reload_manifests()


func reload_manifests() -> void:
	_manifests_by_event.clear()
	var directory := DirAccess.open(MANIFEST_ROOT)
	if directory == null:
		return
	directory.list_dir_begin()
	var filename := directory.get_next()
	while not filename.is_empty():
		if not directory.current_is_dir() and filename.get_extension().to_lower() == "json" and filename != "schema.json":
			# Full file/hash verification belongs to import-time tests. Runtime keeps
			# startup light and lets _add_artifact fall back if a texture is missing.
			var result := Manifest.load_and_validate("%s/%s" % [MANIFEST_ROOT, filename], false)
			if bool(result.get("is_valid", false)):
				var manifest: Dictionary = result.get("manifest", {})
				var event_id := String(manifest.get("event_id", ""))
				var scene_id := String(manifest.get("source_scene_id", ""))
				var manifests_by_scene: Dictionary = _manifests_by_event.get(event_id, {})
				manifests_by_scene[scene_id] = manifest
				_manifests_by_event[event_id] = manifests_by_scene
		filename = directory.get_next()
	directory.list_dir_end()
	_rebuild()


func set_scene(scene_id: String) -> void:
	_current_scene_id = scene_id
	_rebuild()


func set_photo_rect(value: Rect2) -> void:
	_photo_rect = value
	_layout_artifacts()


func apply_presentation_state(state: Dictionary) -> bool:
	_presentation_state = state.duplicate(true)
	_active_event_id = String(state.get("event_id", ""))
	_active_state_id = String(state.get("state", "visible"))
	_rebuild()
	return _rendering_artifact


func is_rendering_artifact() -> bool:
	return _rendering_artifact


func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_rendering_artifact = false
	visible = false
	if _active_event_id.is_empty() or not _manifests_by_event.has(_active_event_id):
		return
	var manifests_by_scene: Dictionary = _manifests_by_event[_active_event_id]
	if not manifests_by_scene.has(_current_scene_id):
		return
	var manifest: Dictionary = manifests_by_scene[_current_scene_id]
	var states: Dictionary = manifest.get("states", {})
	var state: Dictionary = states.get(_active_state_id, states.get("visible", {}))
	if state.is_empty() or bool(state.get("base_only", false)):
		return
	if state.has("full_scene_variant"):
		_add_artifact(state["full_scene_variant"], 0)
	for layer in state.get("layers", []):
		if layer is Dictionary:
			_add_artifact(layer, int(layer.get("z_index", 0)))
	if _active_event_id == "laundry_baby_face_surfaces":
		_add_restored_surface_layers(manifest, _presentation_state.get("closed_surfaces", []))
	_rendering_artifact = get_child_count() > 0
	visible = _rendering_artifact
	_layout_artifacts()


func _add_artifact(artifact: Dictionary, layer_z_index: int) -> void:
	var texture := load(String(artifact.get("path", ""))) as Texture2D
	if texture == null:
		return
	var texture_rect := TextureRect.new()
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.z_index = layer_z_index
	add_child(texture_rect)


func _add_restored_surface_layers(manifest: Dictionary, closed_surfaces) -> void:
	var source_texture := load(String(manifest.get("source_path", ""))) as Texture2D
	if source_texture == null:
		return
	var canvas: Dictionary = manifest.get("canvas", {})
	var canvas_size := Vector2(float(canvas.get("width", 0)), float(canvas.get("height", 0)))
	if canvas_size.x <= 0.0 or canvas_size.y <= 0.0:
		return
	var surface_rects: Dictionary = preload("res://scripts/horror/anomaly_content_catalog.gd").surface_rects()
	for raw_surface_id in closed_surfaces:
		var surface_id := String(raw_surface_id)
		if not surface_rects.has(surface_id):
			continue
		var normalized_rect: Rect2 = surface_rects[surface_id]
		var atlas := AtlasTexture.new()
		atlas.atlas = source_texture
		atlas.region = Rect2(normalized_rect.position * canvas_size, normalized_rect.size * canvas_size)
		var patch := TextureRect.new()
		patch.texture = atlas
		patch.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		patch.stretch_mode = TextureRect.STRETCH_SCALE
		patch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		patch.z_index = 100
		patch.set_meta("normalized_rect", normalized_rect)
		add_child(patch)


func _layout_artifacts() -> void:
	for child in get_children():
		if child is Control:
			if child.has_meta("normalized_rect"):
				var normalized_rect: Rect2 = child.get_meta("normalized_rect")
				child.position = _photo_rect.position + normalized_rect.position * _photo_rect.size
				child.size = normalized_rect.size * _photo_rect.size
			else:
				child.position = _photo_rect.position
				child.size = _photo_rect.size
