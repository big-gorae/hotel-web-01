class_name HotelScene3DOverlay
extends Control

const Scene3DOverlayCatalog := preload("res://scripts/overlays/scene_3d_overlay_catalog.gd")

var definitions_by_scene: Dictionary = {}
var current_overlay_scene_id := ""
var viewport_container: SubViewportContainer
var viewport: SubViewport
var camera: Camera3D
var key_light: DirectionalLight3D
var fill_light: OmniLight3D
var model_parent: Node3D


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_load_default_catalog()


func _ready() -> void:
	_build_viewport()


func show_scene_overlay(scene_id: String) -> void:
	if not definitions_by_scene.has(scene_id):
		clear_overlay()
		return

	current_overlay_scene_id = scene_id
	visible = true
	_clear_model()
	_apply_definition(definitions_by_scene[scene_id])


func clear_overlay() -> void:
	current_overlay_scene_id = ""
	visible = false
	_clear_model()


func has_overlay_for_scene(scene_id: String) -> bool:
	return definitions_by_scene.has(scene_id)


func get_model_count() -> int:
	if model_parent == null:
		return 0

	return model_parent.get_child_count()


func _load_default_catalog() -> void:
	definitions_by_scene.clear()
	for definition in Scene3DOverlayCatalog.build_definitions():
		var scene_id := String(definition.get("scene_id", ""))
		if not scene_id.is_empty():
			definitions_by_scene[scene_id] = definition.duplicate(true)


func _build_viewport() -> void:
	viewport_container = SubViewportContainer.new()
	viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport_container.stretch = true
	viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(viewport_container)

	viewport = SubViewport.new()
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport_container.add_child(viewport)

	model_parent = Node3D.new()
	model_parent.name = "ModelParent"
	viewport.add_child(model_parent)

	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.0
	camera.position = Vector3(0.0, 0.0, 8.0)
	camera.current = true
	viewport.add_child(camera)

	key_light = DirectionalLight3D.new()
	key_light.light_energy = 1.0
	key_light.rotation_degrees = Vector3(-48.0, -24.0, 0.0)
	viewport.add_child(key_light)

	fill_light = OmniLight3D.new()
	fill_light.light_energy = 0.55
	fill_light.omni_range = 6.0
	fill_light.position = Vector3(0.0, 1.5, 3.0)
	viewport.add_child(fill_light)


func _apply_definition(definition: Dictionary) -> void:
	var model_path := String(definition.get("model_path", ""))
	var packed_scene := load(model_path) as PackedScene
	if packed_scene == null:
		push_warning("Missing 3D overlay model: %s" % model_path)
		clear_overlay()
		return

	camera.size = float(definition.get("camera_size", 4.0))
	key_light.light_energy = float(definition.get("light_energy", 1.0))

	var model := packed_scene.instantiate()
	var model_root := Node3D.new()
	model_root.name = String(definition.get("id", "Scene3DOverlayModel"))
	model_parent.add_child(model_root)
	model_root.add_child(model)

	_fit_model_height(model_root, float(definition.get("target_height", 1.0)), float(definition.get("scale_multiplier", 1.0)))
	model_root.position = definition.get("model_position", Vector3.ZERO)
	model_root.rotation_degrees = definition.get("model_rotation_degrees", Vector3.ZERO)


func _fit_model_height(model_root: Node3D, target_height: float, scale_multiplier: float) -> void:
	var max_height := 0.0
	for mesh_instance in model_root.find_children("*", "MeshInstance3D", true, false):
		var mesh := mesh_instance as MeshInstance3D
		var mesh_height: float = absf(mesh.get_aabb().size.y * mesh.scale.y)
		max_height = maxf(max_height, mesh_height)

	if max_height <= 0.0:
		model_root.scale = Vector3.ONE * scale_multiplier
		return

	model_root.scale = Vector3.ONE * (target_height / max_height) * scale_multiplier


func _clear_model() -> void:
	if model_parent == null:
		return

	for child in model_parent.get_children():
		child.queue_free()
