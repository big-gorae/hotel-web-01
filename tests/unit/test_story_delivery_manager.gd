extends GdUnitTestSuite

const StoryDeliveryManager := preload("res://scripts/story/story_delivery_manager.gd")


func test_story_is_distributed_across_all_seven_days() -> void:
	var story := StoryDeliveryManager.new()
	story.start_new_run()
	for day in range(1, 8):
		assert_bool(story.prepare_day(day)).override_failure_message("missing story for day %d" % day).is_true()
		var beat := story.get_current_beat()
		assert_str(String(beat.get("content_key", ""))).starts_with("story.day.%d." % day)
		while story.has_active_sequence():
			story.advance()

	assert_int(story.completed_story_beat_ids.size()).is_equal(8)


func test_completed_day_does_not_replay() -> void:
	var story := StoryDeliveryManager.new()
	story.prepare_day(2)
	story.advance()

	assert_bool(story.prepare_day(2)).is_false()


func test_sequence_resumes_from_saved_step_boundary() -> void:
	var story := StoryDeliveryManager.new()
	story.prepare_day(1)
	story.advance()
	var state := story.export_state()

	var restored := StoryDeliveryManager.new()
	restored.import_state(state)

	assert_bool(restored.has_active_sequence()).is_true()
	assert_int(restored.get_current_step()).is_equal(2)
	assert_str(String(restored.get_current_beat().get("id", ""))).is_equal("story.player_claims_sister_identity")
