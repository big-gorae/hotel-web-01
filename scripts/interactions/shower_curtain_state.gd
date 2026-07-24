class_name HotelShowerCurtainState
extends RefCounted

const HOTSPOT_ID := "shower_curtain"
const FLAG_PREFIX := "bathroom.shower_curtain_closed."
const OPEN_CLICK_RECT := Rect2(0.425, 0.045, 0.205, 0.90)
const CLOSED_CLICK_RECT := Rect2(0.425, 0.045, 0.425, 0.90)

var flag_store = null


func setup(store) -> void:
	flag_store = store


func supports_scene(scene_data: Dictionary) -> bool:
	return not String(scene_data.get("curtain_closed_photo", "")).is_empty()


func is_closed(scene_id: String) -> bool:
	if flag_store == null:
		return false
	return flag_store.get_bool(flag_id_for_scene(scene_id), false)


func toggle(scene_id: String) -> bool:
	var closed := not is_closed(scene_id)
	if flag_store != null:
		flag_store.set_value(flag_id_for_scene(scene_id), closed)
	return closed


func photo_path(scene_id: String, scene_data: Dictionary) -> String:
	if is_closed(scene_id):
		return String(scene_data.get("curtain_closed_photo", scene_data.get("photo", "")))
	return String(scene_data.get("photo", ""))


func make_hotspot(scene_id: String) -> Dictionary:
	return make_hotspot_for_state(is_closed(scene_id))


func make_hotspot_for_state(closed: bool) -> Dictionary:
	return {
		"id": HOTSPOT_ID,
		"label": "Shower Curtain",
		"text": "Open the shower curtain." if closed else "Close the shower curtain.",
		"rect": CLOSED_CLICK_RECT if closed else OPEN_CLICK_RECT,
	}


func flag_id_for_scene(scene_id: String) -> String:
	return "%s%s" % [FLAG_PREFIX, scene_id]
