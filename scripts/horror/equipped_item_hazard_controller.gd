class_name HotelEquippedItemHazardController
extends RefCounted

const AnomalyRegistry := preload("res://scripts/horror/anomaly_registry.gd")

signal hazard_started(item_id: String)
signal hazard_progress_changed(item_id: String, progress: float)
signal hazard_stopped(item_id: String)
signal death_requested(item_id: String)

const HELL_MIRROR_ID := "hell_mirror"

var fatal_hold_seconds := float(
	AnomalyRegistry.get_definition(HELL_MIRROR_ID).get("lifecycle", {}).get("fatal_seconds", 12.0)
)
var lethal_outcomes_enabled := true
var _equipped_item_id := ""
var _hazard_elapsed := 0.0


func bind_inventory(inventory_model) -> void:
	if inventory_model == null:
		return
	if not inventory_model.equipped_item_changed.is_connected(_on_equipped_item_changed):
		inventory_model.equipped_item_changed.connect(_on_equipped_item_changed)
	_on_equipped_item_changed(inventory_model.equipped_item)


func set_lethal_outcomes_enabled(value: bool) -> void:
	lethal_outcomes_enabled = value


func advance(delta: float) -> void:
	if _equipped_item_id != HELL_MIRROR_ID or delta <= 0.0:
		return
	_hazard_elapsed = minf(_hazard_elapsed + delta, fatal_hold_seconds)
	hazard_progress_changed.emit(_equipped_item_id, get_progress())
	if _hazard_elapsed >= fatal_hold_seconds and lethal_outcomes_enabled:
		death_requested.emit(_equipped_item_id)


func get_progress() -> float:
	if fatal_hold_seconds <= 0.0:
		return 0.0
	return clampf(_hazard_elapsed / fatal_hold_seconds, 0.0, 1.0)


func is_hazard_active() -> bool:
	return _equipped_item_id == HELL_MIRROR_ID


func _on_equipped_item_changed(item) -> void:
	var next_item_id := String(item.id) if item != null else ""
	if next_item_id == _equipped_item_id:
		return
	var previous_item_id := _equipped_item_id
	_equipped_item_id = next_item_id
	_hazard_elapsed = 0.0
	if previous_item_id == HELL_MIRROR_ID:
		hazard_stopped.emit(previous_item_id)
	if _equipped_item_id == HELL_MIRROR_ID:
		hazard_started.emit(_equipped_item_id)
		hazard_progress_changed.emit(_equipped_item_id, 0.0)
