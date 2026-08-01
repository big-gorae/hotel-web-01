extends GdUnitTestSuite

const Manifest := preload("res://scripts/horror/anomaly_presentation_manifest.gd")
const VALID_SHA := "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"


func test_valid_full_canvas_layer_manifest() -> void:
	var manifest := _valid_manifest()

	assert_that(Manifest.validate_dict(manifest)).is_empty()


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


func test_all_mvp_manifests_match_their_real_source_and_artifact_files() -> void:
	for filename in [
		"laundry_red_washer.json",
		"laundry_baby_face_surfaces.json",
		"room_106_abandoned_child.json",
		"vacant_room_blanket_child.json",
		"room_108_tv_ghost.json",
		"room_108_entrails_bathtub.json",
		"room_107_empty_hanging_rope.json",
		"bathroom_shower_legs.json",
		"bathroom_shower_legs_room_106.json",
		"bathroom_shower_legs_room_107.json",
		"bathroom_shower_legs_room_108.json",
		"front_monitor_ghost.json",
		"front_glass_face.json",
		"room_109_open_door.json",
	]:
		var result := Manifest.load_and_validate(
			"res://resource/anomaly_manifests/%s" % filename,
			true,
		)
		assert_bool(result["is_valid"]).override_failure_message(
			"%s: %s" % [filename, result["errors"]],
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
