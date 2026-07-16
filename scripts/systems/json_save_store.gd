class_name HotelJsonSaveStore
extends RefCounted


static func load_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var save_file := FileAccess.open(path, FileAccess.READ)
	if save_file == null:
		push_warning("Failed to open save file: %s" % path)
		return {}

	var parsed = JSON.parse_string(save_file.get_as_text())
	if not parsed is Dictionary:
		push_warning("Ignoring invalid save file: %s" % path)
		return {}

	return parsed


static func write_dictionary_atomic(path: String, data: Dictionary) -> bool:
	var temporary_path := "%s.tmp" % path
	var backup_path := "%s.bak" % path
	_remove_if_present(temporary_path)
	_remove_if_present(backup_path)

	var save_file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if save_file == null:
		push_warning("Failed to open temporary save file: %s" % temporary_path)
		return false

	save_file.store_string(JSON.stringify(data, "\t"))
	save_file.flush()
	save_file = null

	var target_absolute := ProjectSettings.globalize_path(path)
	var temporary_absolute := ProjectSettings.globalize_path(temporary_path)
	var backup_absolute := ProjectSettings.globalize_path(backup_path)
	if FileAccess.file_exists(path):
		var backup_error := DirAccess.rename_absolute(target_absolute, backup_absolute)
		if backup_error != OK:
			push_warning("Failed to protect existing save file: %s" % path)
			_remove_if_present(temporary_path)
			return false

	var replace_error := DirAccess.rename_absolute(temporary_absolute, target_absolute)
	if replace_error != OK:
		push_warning("Failed to replace save file: %s" % path)
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(backup_absolute, target_absolute)
		_remove_if_present(temporary_path)
		return false

	_remove_if_present(backup_path)
	return true


static func _remove_if_present(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
