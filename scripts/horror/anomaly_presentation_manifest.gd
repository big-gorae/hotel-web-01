class_name HotelAnomalyPresentationManifest
extends RefCounted

const SCHEMA_VERSION := 1
const ANOMALY_IMAGE_ROOT := "res://resource/images/anomalies/"
const SceneCatalog := preload("res://scripts/scenes/hotel_scene_catalog.gd")


static func load_and_validate(path: String, verify_files := false) -> Dictionary:
	var manifest := {}
	var errors := PackedStringArray()

	if path.is_empty() or not FileAccess.file_exists(path):
		errors.append("Manifest file does not exist: %s" % path)
		return _result(manifest, errors)

	var json := JSON.new()
	var parse_error := json.parse(FileAccess.get_file_as_string(path))
	if parse_error != OK:
		errors.append("Manifest JSON is invalid at line %d: %s" % [json.get_error_line(), json.get_error_message()])
		return _result(manifest, errors)
	if not json.data is Dictionary:
		errors.append("Manifest root must be an object.")
		return _result(manifest, errors)

	manifest = json.data
	errors.append_array(validate_dict(manifest, verify_files))
	return _result(manifest, errors)


static func validate_dict(manifest: Dictionary, verify_files := false) -> PackedStringArray:
	var errors := PackedStringArray()
	if int(manifest.get("schema_version", -1)) != SCHEMA_VERSION:
		errors.append("schema_version must be %d." % SCHEMA_VERSION)

	_require_nonempty_string(manifest, "event_id", errors)
	var scene_id := _require_nonempty_string(manifest, "source_scene_id", errors)
	var source_path := _require_nonempty_string(manifest, "source_path", errors)
	var source_sha := _require_nonempty_string(manifest, "source_sha256", errors)
	if not source_sha.is_empty() and not _is_sha256(source_sha):
		errors.append("source_sha256 must be a lowercase 64-character SHA-256.")

	if not scene_id.is_empty():
		if not SceneCatalog.has_scene(scene_id):
			errors.append("source_scene_id is not registered: %s" % scene_id)
		else:
			var scene_data: Dictionary = SceneCatalog.get_scene(scene_id)
			var expected_paths: Array[String] = [String(scene_data.get("photo", ""))]
			for raw_variant_path in scene_data.get("photo_variants", []):
				var variant_path := String(raw_variant_path)
				if not expected_paths.has(variant_path):
					expected_paths.append(variant_path)
			if not expected_paths.has(source_path):
				errors.append("source_path does not match HotelSceneCatalog for %s." % scene_id)

	var canvas: Variant = manifest.get("canvas", {})
	var canvas_width := 0
	var canvas_height := 0
	if not canvas is Dictionary:
		errors.append("canvas must be an object.")
	else:
		canvas_width = int(canvas.get("width", 0))
		canvas_height = int(canvas.get("height", 0))
		if canvas_width <= 0 or canvas_height <= 0:
			errors.append("canvas width and height must be positive integers.")

	var states: Variant = manifest.get("states", {})
	if not states is Dictionary or states.is_empty():
		errors.append("states must be a non-empty object.")
	else:
		for raw_state_id in states:
			var state_id := String(raw_state_id)
			if state_id.is_empty():
				errors.append("state IDs must not be empty.")
				continue
			_validate_state(
				state_id,
				states[raw_state_id],
				canvas_width,
				canvas_height,
				verify_files,
				errors,
			)

	if verify_files and not source_path.is_empty():
		_validate_file(source_path, source_sha, canvas_width, canvas_height, "source", errors)

	return errors


static func _validate_state(
	state_id: String,
	state,
	canvas_width: int,
	canvas_height: int,
	verify_files: bool,
	errors: PackedStringArray,
) -> void:
	if not state is Dictionary:
		errors.append("state '%s' must be an object." % state_id)
		return

	var base_only: bool = bool(state.get("base_only", false))
	var has_variant: bool = state.has("full_scene_variant")
	var layers: Variant = state.get("layers", [])
	var has_layers: bool = layers is Array and not layers.is_empty()

	if base_only and (has_variant or has_layers):
		errors.append("state '%s' cannot combine base_only with artifacts." % state_id)
	if not base_only and not has_variant and not has_layers:
		errors.append("state '%s' must define base_only, full_scene_variant, or layers." % state_id)

	if has_variant:
		_validate_artifact(
			"state '%s' full_scene_variant" % state_id,
			state.get("full_scene_variant"),
			canvas_width,
			canvas_height,
			true,
			verify_files,
			errors,
		)

	if state.has("layers") and not layers is Array:
		errors.append("state '%s' layers must be an array." % state_id)
		return

	var slots := {}
	for layer_index in layers.size():
		var layer = layers[layer_index]
		var label := "state '%s' layer %d" % [state_id, layer_index]
		if not layer is Dictionary:
			errors.append("%s must be an object." % label)
			continue

		var slot := String(layer.get("slot", ""))
		if slot.is_empty():
			errors.append("%s slot must not be empty." % label)
		elif slots.has(slot):
			errors.append("state '%s' contains duplicate layer slot '%s'." % [state_id, slot])
		else:
			slots[slot] = true

		if not layer.has("z_index") or not layer["z_index"] is int:
			errors.append("%s z_index must be an integer." % label)

		_validate_artifact(label, layer, canvas_width, canvas_height, false, verify_files, errors)


static func _validate_artifact(
	label: String,
	artifact,
	canvas_width: int,
	canvas_height: int,
	allow_uniform_upscale: bool,
	verify_files: bool,
	errors: PackedStringArray,
) -> void:
	if not artifact is Dictionary:
		errors.append("%s must be an object." % label)
		return

	var path := String(artifact.get("path", ""))
	var sha := String(artifact.get("sha256", ""))
	var width := int(artifact.get("width", 0))
	var height := int(artifact.get("height", 0))

	if not path.begins_with(ANOMALY_IMAGE_ROOT) or ".." in path:
		errors.append("%s path must be below %s." % [label, ANOMALY_IMAGE_ROOT])
	if not _is_sha256(sha):
		errors.append("%s sha256 must be a lowercase 64-character SHA-256." % label)
	if width <= 0 or height <= 0:
		errors.append("%s width and height must be positive integers." % label)
	elif allow_uniform_upscale and not _is_uniform_integer_scale(
		width,
		height,
		canvas_width,
		canvas_height,
	):
		errors.append(
			"%s dimensions must match the source canvas or use a uniform integer upscale." % label,
		)
	elif not allow_uniform_upscale and (width != canvas_width or height != canvas_height):
		errors.append("%s dimensions must match the source canvas." % label)

	if verify_files:
		_validate_file(path, sha, width, height, label, errors)


static func _is_uniform_integer_scale(
	width: int,
	height: int,
	canvas_width: int,
	canvas_height: int,
) -> bool:
	if canvas_width <= 0 or canvas_height <= 0:
		return false
	if width % canvas_width != 0 or height % canvas_height != 0:
		return false
	return width / canvas_width == height / canvas_height


static func _validate_file(
	path: String,
	expected_sha: String,
	expected_width: int,
	expected_height: int,
	label: String,
	errors: PackedStringArray,
) -> void:
	if path.is_empty() or not FileAccess.file_exists(path):
		errors.append("%s file does not exist: %s" % [label, path])
		return

	if _is_sha256(expected_sha):
		var actual_sha := FileAccess.get_sha256(path)
		if actual_sha != expected_sha:
			errors.append("%s SHA-256 does not match the manifest." % label)

	var texture := load(path) as Texture2D
	if texture == null:
		errors.append("%s is not a readable imported texture." % label)
		return
	var texture_size := texture.get_size()
	if int(texture_size.x) != expected_width or int(texture_size.y) != expected_height:
		errors.append("%s image dimensions do not match the manifest." % label)


static func _require_nonempty_string(data: Dictionary, key: String, errors: PackedStringArray) -> String:
	var value := String(data.get(key, ""))
	if value.is_empty():
		errors.append("%s must be a non-empty string." % key)
	return value


static func _is_sha256(value: String) -> bool:
	if value.length() != 64:
		return false
	for character in value:
		if character not in "0123456789abcdef":
			return false
	return true


static func _result(manifest: Dictionary, errors: PackedStringArray) -> Dictionary:
	return {
		"manifest": manifest,
		"errors": errors,
		"is_valid": errors.is_empty(),
	}
