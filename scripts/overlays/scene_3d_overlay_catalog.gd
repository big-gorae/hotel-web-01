class_name HotelScene3DOverlayCatalog
extends RefCounted


static func build_definitions() -> Array[Dictionary]:
	return [
		{
			"id": "room_105_bathtub_dripping_gaze",
			"scene_id": "room_105_bathroom",
			"model_path": "res://resource/3d_models/dripping_gaze/dripping_gaze.glb",
			"camera_size": 4.0,
			"model_position": Vector3(2.05, -0.58, 0.0),
			"model_rotation_degrees": Vector3(-7.0, -24.0, 0.0),
			"target_height": 1.05,
			"scale_multiplier": 1.0,
			"light_energy": 1.15,
		},
	]
