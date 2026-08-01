class_name HotelGameMode
extends RefCounted

const STORY := "story"
const INFINITY := "infinity"
const ALL: Array[String] = [STORY, INFINITY]


static func normalize(mode_id: String) -> String:
	var safe_mode := String(mode_id).strip_edges().to_lower()
	return safe_mode if ALL.has(safe_mode) else STORY


static func is_infinity(mode_id: String) -> bool:
	return normalize(mode_id) == INFINITY
