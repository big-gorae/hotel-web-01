class_name HotelRuleBookPageCatalog
extends RefCounted

const IMAGE_ROOT := "res://resource/images/rule_book"
const IMAGE_EXTENSIONS := ["png", "webp", "jpg", "jpeg"]


static func get_candidate_paths(day: int, language_code := "") -> Array[String]:
	var safe_day := maxi(day, 1)
	var filename := "day_%02d" % safe_day
	var candidates: Array[String] = []
	var safe_language := String(language_code).strip_edges().to_lower()

	if not safe_language.is_empty() and not safe_language.contains("/") and not safe_language.contains("."):
		for extension in IMAGE_EXTENSIONS:
			candidates.append("%s/%s/%s.%s" % [IMAGE_ROOT, safe_language, filename, extension])

	for extension in IMAGE_EXTENSIONS:
		candidates.append("%s/%s.%s" % [IMAGE_ROOT, filename, extension])
	return candidates


static func resolve_page_image_path(day: int, language_code := "") -> String:
	for path in get_candidate_paths(day, language_code):
		if ResourceLoader.exists(path, "Texture2D"):
			return path
	return ""
