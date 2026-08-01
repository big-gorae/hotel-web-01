extends SceneTree

const Localization := preload("res://scripts/localization.gd")
const HorrorCatalog := preload("res://scripts/horror/horror_catalog.gd")
const SAVE_PATH := "user://hotel_save.json"
const META_SAVE_PATH := "user://hotel_meta.json"

var preserved_files: Dictionary = {}


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_preserve_save()
	_clear_save()

	var packed: PackedScene = load("res://scenes/main.tscn")
	if packed == null:
		_fail("main scene failed to load")
		return
	var main = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.localization.set_language(Localization.Language.KOREAN)
	main._start_shift()
	await process_frame
	while main.is_intro_dialogue_active():
		main._advance_intro_dialogue()
	main._hide_menu()

	var preview_index := _find_anomaly_preview_index(main, "room_107_hanging_girl")
	if preview_index <= 0:
		_fail("hanging girl was missing from the anomaly preview selector")
		return
	main._on_debug_anomaly_selected(preview_index)
	await process_frame
	if main.current_scene_id != "laundry_room":
		_fail("hanging girl preview did not begin at the companion pickup")
		return
	var doll_hotspot := _find_hotspot(main, "laundry_room", "anomaly_pickup:hanging_girl_doll")
	if doll_hotspot.is_empty():
		_fail("cute doll did not appear on the laundry-room table")
		return
	main._hide_transient_dialogue()
	main._on_hotspot_pressed(doll_hotspot)
	if not main.inventory_model.has_item_id("cute_doll"):
		_fail("cute doll pickup did not enter inventory")
		return
	if main.transient_dialogue_panel.visible:
		_fail("cute doll pickup opened an explanatory popup")
		return
	var cute_doll = main.inventory_model.find_item_by_id("cute_doll")
	if not cute_doll.can_equip or not main.inventory_model.equip_item(cute_doll):
		_fail("cute doll could not be held in hand")
		return
	if main.inventory_model.equipped_item != cute_doll:
		_fail("equipping the cute doll did not update the held item")
		return
	if not String(cute_doll.icon_path).is_empty():
		_fail("cute doll referenced a newly generated image")
		return
	main.inventory_model.clear_equipped_item()
	if main.inventory_model.equipped_item != null:
		_fail("cute doll could not be put away before the conversation")
		return
	await process_frame
	if main.current_scene_id != "room_107_bed_nightstand":
		_fail("preview did not continue to room 107 after the doll pickup")
		return
	var girl_hotspot := _find_hotspot(main, "room_107_bed_nightstand", "anomaly_choice:hanging_girl")
	if girl_hotspot.is_empty():
		_fail("hanging wooden girl interaction was missing")
		return
	main._on_hotspot_pressed(girl_hotspot)
	if not main.choice_dialogue_overlay.visible:
		_fail("talk-or-ignore choice did not open")
		return
	if main.choice_dialogue_overlay._prompt_label.text != "목을 맨 목각 여자 인형이 이쪽을 보고 있다.":
		_fail("hanging girl entry prompt was not localized")
		return
	main._on_content_choice_selected("entry_talk")
	main._on_content_choice_selected("fun_no")
	if main.anomaly_content_runtime.current_state != "hostile":
		_fail("rejection did not change the hanging girl to hostile")
		return
	if main.choice_dialogue_overlay._prompt_label.text != "이 씨발새끼야.":
		_fail("the single angry profanity was not shown")
		return
	if not _choice_button_exists(main.choice_dialogue_overlay, "윌터는 재미있어 보인대"):
		_fail("Walter choice did not unlock while holding the doll")
		return
	main._on_content_choice_selected("walter")
	if main.choice_dialogue_overlay._prompt_label.text != "윌터가 누구야?":
		_fail("Walter follow-up prompt did not open")
		return
	main._hide_transient_dialogue()
	main._on_content_choice_selected("doll_friend")
	if not main.anomaly_content_runtime.current_event_id.is_empty():
		_fail("giving Walter did not resolve the hanging girl")
		return
	if main.inventory_model.has_item_id("cute_doll"):
		_fail("Walter was not consumed by the survival choice")
		return
	if main.choice_dialogue_overlay.visible:
		_fail("choice overlay remained open after survival")
		return
	if main.transient_dialogue_panel.visible:
		_fail("giving Walter opened an explanatory popup")
		return
	if not main.anomaly_content_runtime.has_lingering_hanging_girl("room_107_bed_nightstand"):
		_fail("hanging girl did not remain in Room 107 for the rest of the day")
		return
	if not main.anomaly_presentation_layer.visible or not main.anomaly_presentation_layer.is_rendering_artifact():
		_fail("resolved hanging girl was not still rendered in Room 107")
		return
	main.show_scene("corridor", false)
	main.show_scene("room_107_bed_nightstand", false)
	await process_frame
	if not main.anomaly_presentation_layer.visible or not main.anomaly_presentation_layer.is_rendering_artifact():
		_fail("hanging girl disappeared after leaving and returning during the same day")
		return

	main.anomaly_content_runtime.force_event("room_107_hanging_girl")
	main.anomaly_content_runtime.advance(
		main.anomaly_content_runtime.INTER_EVENT_COOLDOWN_SECONDS + 0.1
	)
	main.show_scene("room_107_bed_nightstand", false)
	await process_frame
	girl_hotspot = _find_hotspot(main, "room_107_bed_nightstand", "anomaly_choice:hanging_girl")
	main._on_hotspot_pressed(girl_hotspot)
	main._on_content_choice_selected("entry_talk")
	main._on_content_choice_selected("fun_yes")
	if main.choice_dialogue_overlay._prompt_label.text != "밧줄이 목을 조였다.":
		_fail("fatal physiological narration did not begin")
		return
	main.anomaly_content_runtime.finish_fatal_narrative()
	await process_frame
	if not main.horror_event_manager.is_jumpscare_active():
		_fail("fatal narration did not trigger game over")
		return
	if main.jumpscare_controller.current_presentation == null:
		_fail("hanging girl jumpscare presentation was missing")
		return
	var texture_path := String(main.jumpscare_controller.current_presentation.source_texture.resource_path)
	if texture_path != HorrorCatalog.HANGING_GIRL_REFERENCE:
		_fail("hanging girl jumpscare did not use the wooden doll image")
		return
	if not main.jumpscare_controller.current_presentation.subject.texture is AtlasTexture:
		_fail("hanging girl jumpscare still presented the entire room photograph")
		return
	if main.jumpscare_controller.current_presentation.lunge_zoom != 7.0:
		_fail("hanging girl jumpscare did not lunge into the face")
		return

	main.jumpscare_controller.stop()
	_restore_save()
	print("smoke hanging girl flow passed")
	quit(0)


func _find_hotspot(main, scene_id: String, hotspot_id: String) -> Dictionary:
	var hotspots: Array = main._scene_hotspots(scene_id, main.HOTEL_SCENES[scene_id])
	for hotspot in hotspots:
		if hotspot is Dictionary and String(hotspot.get("id", "")) == hotspot_id:
			return hotspot
	return {}


func _find_anomaly_preview_index(main, event_id: String) -> int:
	for index in main.debug_anomaly_selector.item_count:
		var metadata = main.debug_anomaly_selector.get_item_metadata(index)
		if metadata != null and str(metadata) == event_id:
			return index
	return -1


func _choice_button_exists(overlay, text: String) -> bool:
	for child in overlay._choice_box.get_children():
		if child is Button and String(child.text).trim_prefix("✓ ") == text:
			return true
	return false


func _preserve_save() -> void:
	for path in [SAVE_PATH, META_SAVE_PATH]:
		if FileAccess.file_exists(path):
			var save_file := FileAccess.open(path, FileAccess.READ)
			preserved_files[path] = save_file.get_as_text() if save_file != null else ""


func _clear_save() -> void:
	for path in [SAVE_PATH, META_SAVE_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _restore_save() -> void:
	for path in [SAVE_PATH, META_SAVE_PATH]:
		if preserved_files.has(path):
			var save_file := FileAccess.open(path, FileAccess.WRITE)
			if save_file != null:
				save_file.store_string(String(preserved_files[path]))
		elif FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _fail(message: String) -> void:
	_restore_save()
	push_error(message)
	quit(1)
