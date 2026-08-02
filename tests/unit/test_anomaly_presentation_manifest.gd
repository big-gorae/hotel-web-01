extends GdUnitTestSuite

const Manifest := preload("res://scripts/horror/anomaly_presentation_manifest.gd")
const HorrorCatalog := preload("res://scripts/horror/horror_catalog.gd")
const VALID_SHA := "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"


func test_valid_full_canvas_layer_manifest() -> void:
	var manifest := _valid_manifest()

	assert_that(Manifest.validate_dict(manifest)).is_empty()


func test_accepts_uniform_integer_upscale_for_full_scene_variant() -> void:
	var manifest := _valid_manifest()
	manifest["states"]["active"] = {
		"full_scene_variant": {
			"path": "res://resource/images/anomalies/front_monitor_ghost/front_desk/visible.webp",
			"sha256": VALID_SHA,
			"width": 3070,
			"height": 2048,
		},
	}

	assert_that(Manifest.validate_dict(manifest)).is_empty()


func test_rejects_nonuniform_upscale_for_full_scene_variant() -> void:
	var manifest := _valid_manifest()
	manifest["states"]["active"] = {
		"full_scene_variant": {
			"path": "res://resource/images/anomalies/front_monitor_ghost/front_desk/visible.webp",
			"sha256": VALID_SHA,
			"width": 3070,
			"height": 1024,
		},
	}

	assert_that(Manifest.validate_dict(manifest)).contains(
		"state 'active' full_scene_variant dimensions must match the source canvas or use a uniform integer upscale.",
	)


func test_rejects_scene_source_mismatch_and_invalid_hash() -> void:
	var manifest := _valid_manifest()
	manifest["source_path"] = "res://resource/images/corridor.png"
	manifest["source_sha256"] = "not-a-hash"

	var errors := Manifest.validate_dict(manifest)

	assert_that(errors).contains("source_path does not match HotelSceneCatalog for front_desk.")
	assert_that(errors).contains("source_sha256 must be a lowercase 64-character SHA-256.")


func test_rejects_layer_with_wrong_canvas_size_and_duplicate_slot() -> void:
	var manifest := _valid_manifest()
	var first_layer: Dictionary = manifest["states"]["active"]["layers"][0]
	first_layer["width"] = 320
	manifest["states"]["active"]["layers"].append(first_layer.duplicate(true))

	var errors := Manifest.validate_dict(manifest)

	assert_that(errors).contains("state 'active' layer 0 dimensions must match the source canvas.")
	assert_that(errors).contains("state 'active' contains duplicate layer slot 'monitor_ghost'.")


func test_rejects_base_only_state_with_artifacts() -> void:
	var manifest := _valid_manifest()
	manifest["states"]["active"]["base_only"] = true

	assert_that(Manifest.validate_dict(manifest)).contains(
		"state 'active' cannot combine base_only with artifacts.",
	)


func test_missing_manifest_file_returns_structured_result() -> void:
	var result := Manifest.load_and_validate("res://resource/anomaly_manifests/does_not_exist.json")

	assert_that(result["is_valid"]).is_false()
	assert_that(result["manifest"]).is_empty()
	assert_that(result["errors"]).contains(
		"Manifest file does not exist: res://resource/anomaly_manifests/does_not_exist.json",
	)


func test_all_runtime_manifests_match_their_real_source_and_artifact_files() -> void:
	var catalog_event_ids := {}
	for definition in HorrorCatalog.build_definitions():
		catalog_event_ids[definition.id] = true
	var filenames := DirAccess.get_files_at("res://resource/anomaly_manifests")
	filenames.sort()
	for filename in filenames:
		if filename.get_extension().to_lower() != "json" or filename == "schema.json":
			continue
		var result := Manifest.load_and_validate(
			"res://resource/anomaly_manifests/%s" % filename,
			true,
		)
		assert_bool(result["is_valid"]).override_failure_message(
			"%s: %s" % [filename, result["errors"]],
		).is_true()
		var event_id := String(result["manifest"].get("event_id", ""))
		assert_bool(catalog_event_ids.has(event_id)).override_failure_message(
			"%s references an event missing from HotelHorrorCatalog: %s" % [filename, event_id],
		).is_true()


func _valid_manifest() -> Dictionary:
	return {
		"schema_version": 1,
		"event_id": "front_desk_monitor_ghost",
		"source_scene_id": "front_desk",
		"source_path": "res://resource/images/front_desk.png",
		"source_sha256": VALID_SHA,
		"canvas": {
			"width": 1535,
			"height": 1024,
		},
		"states": {
			"active": {
				"layers": [
					{
						"slot": "monitor_ghost",
						"path": "res://resource/images/anomalies/front_desk_monitor_ghost/front_desk/active.png",
						"sha256": VALID_SHA,
						"width": 1535,
						"height": 1024,
						"z_index": 20,
					},
				],
			},
			"resolved": {
				"base_only": true,
			},
		},
	}
