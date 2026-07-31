extends GdUnitTestSuite

const Scheduler := preload("res://scripts/horror/anomaly_scheduler.gd")


func test_only_one_of_ten_queued_events_becomes_active() -> void:
	var scheduler = Scheduler.new()
	for index in 10:
		scheduler.enqueue("event_%02d" % index)

	assert_that(scheduler.active_anomaly_id).is_equal("event_00")
	assert_int(scheduler.pending_anomaly_queue.size()).is_equal(9)


func test_priority_orders_pending_events_without_preempting_active_event() -> void:
	var scheduler = Scheduler.new()
	scheduler.enqueue("recurrence", 10)
	scheduler.enqueue("phenomenon", 20)
	scheduler.enqueue("story_event", 100)

	assert_that(scheduler.active_anomaly_id).is_equal("recurrence")
	assert_that(scheduler.pending_anomaly_queue.map(
		func(entry: Dictionary): return entry["event_id"],
	)).contains_exactly(["story_event", "phenomenon"])


func test_completed_event_holds_next_event_until_cooldown_finishes() -> void:
	var scheduler = Scheduler.new()
	scheduler.enqueue("first")
	scheduler.enqueue("second")

	assert_that(scheduler.complete_active("first", 2.0)).is_true()
	scheduler.advance(1.9)
	assert_that(scheduler.active_anomaly_id).is_empty()

	scheduler.advance(0.1)
	assert_that(scheduler.active_anomaly_id).is_equal("second")


func test_conflicted_event_stays_queued_while_compatible_event_starts() -> void:
	var scheduler = Scheduler.new()
	scheduler.set_blocked_conflict_tags(["room_108_forbidden"])
	scheduler.enqueue("blocked_story", 100, ["room_108_forbidden"])
	scheduler.enqueue("safe_phenomenon", 10)

	assert_that(scheduler.active_anomaly_id).is_equal("safe_phenomenon")
	assert_that(scheduler.pending_anomaly_queue[0]["event_id"]).is_equal("blocked_story")


func test_export_import_preserves_active_queue_and_cooldown() -> void:
	var source = Scheduler.new()
	source.enqueue("active")
	source.enqueue("queued", 50, ["occupied_room"])
	source.set_blocked_conflict_tags(["occupied_room"])

	var restored = Scheduler.new()
	restored.import_state(source.export_state())

	assert_that(restored.active_anomaly_id).is_equal("active")
	assert_that(restored.pending_anomaly_queue).is_equal(source.pending_anomaly_queue)
	assert_that(restored.blocked_conflict_tags).contains_exactly(["occupied_room"])


func test_duplicate_event_id_is_rejected_across_active_and_queue() -> void:
	var scheduler = Scheduler.new()

	assert_that(scheduler.enqueue("same")).is_true()
	assert_that(scheduler.enqueue("same")).is_false()
	assert_int(scheduler.pending_anomaly_queue.size()).is_equal(0)
