extends GdUnitTestSuite

const TypewriterDialogueController := preload("res://scripts/dialogue/typewriter_dialogue_controller.gd")


func test_typewriter_reveals_then_first_continue_completes_line() -> void:
	var label = auto_free(Label.new())
	var indicator = auto_free(Label.new())
	var controller = auto_free(TypewriterDialogueController.new())
	controller.setup(label, indicator)
	controller.characters_per_second = 10.0
	controller.play_line("Hello.")

	assert_that(controller.is_typing()).is_true()
	assert_that(label.visible_characters).is_equal(0)
	assert_that(indicator.visible).is_false()

	controller._process(0.11)
	assert_that(controller.get_visible_character_count()).is_equal(1)
	assert_that(label.visible_characters).is_equal(1)

	assert_that(controller.reveal_all()).is_true()
	assert_that(controller.is_typing()).is_false()
	assert_that(controller.get_visible_character_count()).is_equal(6)
	assert_that(label.visible_characters).is_equal(-1)
	assert_that(indicator.visible).is_true()
	assert_that(indicator.text).is_equal("▼")
	assert_that(controller.reveal_all()).is_false()


func test_typewriter_waits_after_punctuation() -> void:
	var label = auto_free(Label.new())
	var indicator = auto_free(Label.new())
	var controller = auto_free(TypewriterDialogueController.new())
	controller.setup(label, indicator)
	controller.characters_per_second = 10.0
	controller.punctuation_delay = 0.1
	controller.play_line(".A")

	controller._process(0.1)
	assert_that(controller.get_visible_character_count()).is_equal(1)
	controller._process(0.1)
	assert_that(controller.get_visible_character_count()).is_equal(1)
	controller._process(0.1)
	assert_that(controller.get_visible_character_count()).is_equal(2)
	assert_that(indicator.visible).is_true()
