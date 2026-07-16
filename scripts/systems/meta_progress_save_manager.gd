class_name HotelMetaProgressSaveManager
extends RefCounted

const JsonSaveStore := preload("res://scripts/systems/json_save_store.gd")

const SAVE_VERSION := 1
const SAVE_PATH := "user://hotel_meta.json"

var collection_state: Dictionary = {}


func load_save_data() -> void:
	var save_data := JsonSaveStore.load_dictionary(SAVE_PATH)
	var version := int(save_data.get("version", 0))
	if version > SAVE_VERSION:
		push_warning("Meta save version %d is newer than supported version %d." % [version, SAVE_VERSION])
		collection_state = {}
		return

	var stored_collection = save_data.get("horror_collection", {})
	collection_state = stored_collection.duplicate(true) if stored_collection is Dictionary else {}


func save_collection_state(state: Dictionary) -> bool:
	collection_state = state.duplicate(true)
	return JsonSaveStore.write_dictionary_atomic(SAVE_PATH, {
		"version": SAVE_VERSION,
		"horror_collection": collection_state,
	})


func get_collection_state() -> Dictionary:
	return collection_state.duplicate(true)
