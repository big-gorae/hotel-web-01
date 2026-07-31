extends GdUnitTestSuite

const HorrorCatalog := preload("res://scripts/horror/horror_catalog.gd")
const ImagePresentationScene := preload("res://scenes/horror/image_jumpscare_presentation.tscn")


func test_user_reference_images_drive_pig_mask_and_fake_mother_jumpscares() -> void:
	var definitions_by_id := {}
	for definition in HorrorCatalog.build_definitions():
		definitions_by_id[definition.id] = definition

	var pig = definitions_by_id["room_105_closet_woman"]
	var mother = definitions_by_id["room_106_abandoned_child"]
	assert_str(pig.jumpscare_image_path).is_equal(HorrorCatalog.PIG_MASK_REFERENCE)
	assert_str(mother.jumpscare_image_path).is_equal(HorrorCatalog.FAKE_MOTHER_REFERENCE)
	assert_bool(ResourceLoader.exists(pig.jumpscare_image_path)).is_true()
	assert_bool(ResourceLoader.exists(mother.jumpscare_image_path)).is_true()
	assert_str(pig.presentation_scene_path).is_equal(HorrorCatalog.IMAGE_JUMPSCARE_SCENE)
	assert_str(mother.presentation_scene_path).is_equal(HorrorCatalog.IMAGE_JUMPSCARE_SCENE)
	assert_str(pig.jumpscare_fit_mode).is_equal("cover")
	assert_float(pig.jumpscare_initial_zoom).is_equal_approx(1.02, 0.001)
	assert_vector(pig.jumpscare_focus_point).is_equal(Vector2(0.5, 0.3))
	assert_float(pig.jumpscare_hold_seconds).is_equal_approx(0.15, 0.001)
	assert_float(pig.jumpscare_lunge_seconds).is_equal_approx(0.13, 0.001)
	assert_float(pig.jumpscare_lunge_zoom).is_equal_approx(2.05, 0.001)
	assert_float(pig.jumpscare_duration).is_equal_approx(1.4, 0.001)
	assert_float(pig.jumpscare_initial_shake).is_equal_approx(2.0, 0.001)
	assert_float(pig.jumpscare_lunge_shake).is_equal_approx(2.0, 0.001)
	assert_float(pig.jumpscare_audio_volume_db).is_equal_approx(-10.0, 0.001)
	assert_str(mother.jumpscare_fit_mode).is_equal("contain")
	assert_float(mother.jumpscare_initial_zoom).is_equal_approx(1.02, 0.001)
	assert_vector(mother.jumpscare_focus_point).is_equal(Vector2(0.5, 0.44))
	assert_float(mother.jumpscare_hold_seconds).is_equal_approx(0.25, 0.001)
	assert_float(mother.jumpscare_lunge_seconds).is_equal_approx(0.15, 0.001)
	assert_float(mother.jumpscare_lunge_zoom).is_equal_approx(2.0, 0.001)
	assert_float(mother.jumpscare_duration).is_equal_approx(1.4, 0.001)
	assert_float(mother.jumpscare_initial_shake).is_equal_approx(2.0, 0.001)
	assert_float(mother.jumpscare_lunge_shake).is_equal_approx(10.0, 0.001)
	assert_float(mother.jumpscare_audio_volume_db).is_equal_approx(-5.0, 0.001)
	assert_str(pig.jumpscare_audio_profile).is_equal(mother.jumpscare_audio_profile)
	assert_str(pig.jumpscare_audio_path).is_empty()
	assert_str(mother.jumpscare_audio_path).is_empty()


func test_image_jumpscare_reveals_immediately_and_has_a_second_lunge_phase() -> void:
	var definition
	for candidate in HorrorCatalog.build_definitions():
		if candidate.id == "room_105_closet_woman":
			definition = candidate
			break
	assert_object(definition).is_not_null()

	var presentation = auto_free(ImagePresentationScene.instantiate())
	add_child(presentation)
	presentation.play(definition)

	assert_bool(presentation.playing).is_true()
	assert_object(presentation.subject.texture).is_not_null()
	assert_float(presentation.initial_zoom).is_equal_approx(1.02, 0.001)
	assert_float(definition.jumpscare_hold_seconds).is_equal_approx(0.15, 0.001)
	assert_float(definition.jumpscare_lunge_zoom).is_greater(definition.jumpscare_initial_zoom)
	assert_object(presentation.audio_player.stream).is_not_null()
	assert_int(presentation.audio_player.stream.data.size()).is_greater(0)

	await get_tree().create_timer(0.10, true, false, true).timeout
	assert_bool(presentation.lunge_started).is_false()
	await get_tree().create_timer(0.10, true, false, true).timeout
	assert_bool(presentation.lunge_started).is_true()
	presentation.stop()


func test_fake_mother_preserves_the_original_portrait_ratio_over_a_full_backdrop() -> void:
	var definition
	for candidate in HorrorCatalog.build_definitions():
		if candidate.id == "room_106_abandoned_child":
			definition = candidate
			break
	var presentation = auto_free(ImagePresentationScene.instantiate())
	add_child(presentation)
	presentation.play(definition)

	assert_int(presentation.subject.stretch_mode).is_equal(TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	assert_object(presentation.backdrop_subject.texture).is_same(presentation.subject.texture)
	assert_float(presentation.initial_zoom).is_equal_approx(1.02, 0.001)
	presentation.stop()


func test_hanging_girl_crops_out_the_room_then_lunges_into_the_face() -> void:
	var definition
	for candidate in HorrorCatalog.build_definitions():
		if candidate.id == "room_107_hanging_girl":
			definition = candidate
			break
	assert_object(definition).is_not_null()
	assert_str(definition.jumpscare_image_path).is_equal(HorrorCatalog.HANGING_GIRL_REFERENCE)
	assert_bool(ResourceLoader.exists(definition.jumpscare_image_path)).is_true()
	assert_str(definition.presentation_scene_path).is_equal(HorrorCatalog.IMAGE_JUMPSCARE_SCENE)
	assert_str(definition.jumpscare_fit_mode).is_equal("contain")
	assert_vector(definition.jumpscare_focus_point).is_equal(Vector2(0.5, 0.36))
	assert_that(definition.jumpscare_source_rect).is_equal(
		HorrorCatalog.JUMPSCARE_SOURCE_RECT_BY_EVENT["room_107_hanging_girl"]
	)
	assert_float(definition.jumpscare_lunge_zoom).is_equal_approx(7.0, 0.001)

	var presentation = auto_free(ImagePresentationScene.instantiate())
	add_child(presentation)
	presentation.play(definition)

	assert_object(presentation.source_texture).is_not_null()
	assert_str(presentation.source_texture.resource_path).is_equal(HorrorCatalog.HANGING_GIRL_REFERENCE)
	assert_bool(presentation.subject.texture is AtlasTexture).is_true()
	assert_object(presentation.backdrop_subject.texture).is_same(presentation.subject.texture)
	assert_vector(presentation.focus_point).is_equal(Vector2(0.5, 0.36))
	assert_float(presentation.lunge_zoom).is_equal_approx(7.0, 0.001)
	presentation.stop()
