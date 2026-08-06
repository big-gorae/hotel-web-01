extends GdUnitTestSuite

const AnomalyAudioController := preload("res://scripts/horror/anomaly_audio_controller.gd")


func test_blanket_found_cue_prefers_the_recorded_japanese_voice() -> void:
	assert_bool(ResourceLoader.exists(AnomalyAudioController.BLANKET_FOUND_VOICE_PATH)).is_true()
	var controller = auto_free(AnomalyAudioController.new())
	add_child(controller)

	var stream: AudioStream = controller._stream_for_cue("blanket_found_japanese")

	assert_object(stream).is_not_null()
	assert_bool(stream is AudioStreamOggVorbis).is_true()


func test_recorded_anomaly_cues_replace_procedural_preview_tones() -> void:
	var expected_paths := {
		"baby_short_cry": AnomalyAudioController.BABY_WALLPAPER_CRY_PATH,
		"shower_curtain_move": AnomalyAudioController.SHOWER_CURTAIN_MOVE_PATH,
		"curtain_legs_reveal": AnomalyAudioController.CURTAIN_LEGS_REVEAL_PATH,
		"blanket_laugh_soft": AnomalyAudioController.BLANKET_LAUGH_SOFT_PATH,
		"blanket_laugh_distorted": AnomalyAudioController.BLANKET_LAUGH_DISTORTED_PATH,
		"footstep_echo": AnomalyAudioController.SHADOW_FOOTSTEP_SEQUENCE_PATH,
		"glass_face_barn_owl_call": AnomalyAudioController.FRONT_GLASS_FACE_BARN_OWL_PATH,
		"glass_face_barn_owl_call_distorted": AnomalyAudioController.FRONT_GLASS_FACE_BARN_OWL_DISTORTED_PATH,
	}
	var controller = auto_free(AnomalyAudioController.new())
	add_child(controller)

	for cue_id in expected_paths:
		var path := String(expected_paths[cue_id])
		assert_bool(ResourceLoader.exists(path)).is_true()
		var stream: AudioStream = controller._stream_for_cue(String(cue_id))
		assert_object(stream).is_not_null()
		assert_bool(stream is AudioStreamOggVorbis).is_true()


func test_glass_face_barn_owl_assets_use_one_clean_call_and_a_distorted_bell_variant() -> void:
	var controller = auto_free(AnomalyAudioController.new())
	add_child(controller)
	var clean_stream := controller._stream_for_cue("glass_face_barn_owl_call") as AudioStreamOggVorbis
	var distorted_stream := controller._stream_for_cue("glass_face_barn_owl_call_distorted") as AudioStreamOggVorbis

	assert_object(clean_stream).is_not_null()
	assert_float(clean_stream.get_length()).is_greater_equal(1.22)
	assert_float(clean_stream.get_length()).is_less_equal(1.26)
	assert_object(distorted_stream).is_not_null()
	assert_float(distorted_stream.get_length()).is_greater_equal(1.50)
	assert_float(distorted_stream.get_length()).is_less_equal(1.55)
	assert_float(controller._volume_for_cue("glass_face_barn_owl_call")).is_equal(0.0)
	assert_float(controller._volume_for_cue("glass_face_barn_owl_call_distorted")).is_equal(0.0)


func test_shadow_bell_echo_scream_and_heartbeat_are_available() -> void:
	var controller = auto_free(AnomalyAudioController.new())
	add_child(controller)

	assert_object(controller._stream_for_cue("desk_bell_echo")).is_not_null()
	assert_object(controller._stream_for_cue("shadow_scream")).is_not_null()

	controller.set_shadow_heartbeat_active(true)
	assert_bool(controller.is_shadow_heartbeat_active()).is_true()
	assert_object(controller._shadow_heartbeat_player.stream).is_not_null()
	assert_bool(controller._shadow_heartbeat_player.stream is AudioStreamWAV).is_true()

	controller.set_shadow_heartbeat_active(false)
	assert_bool(controller.is_shadow_heartbeat_active()).is_false()
	assert_object(controller._shadow_heartbeat_player.stream).is_null()


func test_bathtub_drain_and_mirror_washer_cues_are_substantial_one_shots() -> void:
	var controller = auto_free(AnomalyAudioController.new())
	add_child(controller)
	var drain := controller._stream_for_cue("bathtub_drain") as AudioStreamWAV
	var washer := controller._stream_for_cue("hell_mirror_washer_destroy") as AudioStreamWAV

	assert_object(drain).is_not_null()
	assert_object(washer).is_not_null()
	assert_int(drain.data.size()).is_greater(180000)
	assert_int(washer.data.size()).is_greater(150000)
	assert_int(drain.loop_mode).is_equal(AudioStreamWAV.LOOP_DISABLED)
	assert_int(washer.loop_mode).is_equal(AudioStreamWAV.LOOP_DISABLED)


func test_locked_door_handle_has_a_short_metallic_one_shot() -> void:
	var controller = auto_free(AnomalyAudioController.new())
	add_child(controller)
	var handle := controller._stream_for_cue("locked_door_handle") as AudioStreamWAV

	assert_object(handle).is_not_null()
	assert_int(handle.data.size()).is_greater(30000)
	assert_int(handle.data.size()).is_less(33000)
	assert_int(handle.loop_mode).is_equal(AudioStreamWAV.LOOP_DISABLED)
	assert_float(controller._volume_for_cue("locked_door_handle")).is_equal(-8.0)
