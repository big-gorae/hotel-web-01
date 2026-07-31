class_name HotelHoldInteractionController
extends RefCounted

signal hold_started(hold_id: String, duration_seconds: float)
signal progress_changed(hold_id: String, progress: float)
signal hold_cancelled(hold_id: String)
signal hold_completed(hold_id: String)

const INTERRUPT_RESET := "reset"
const INTERRUPT_PAUSE := "pause"

var active_hold_id := ""
var duration_seconds := 0.0
var elapsed_seconds := 0.0
var interrupt_policy := INTERRUPT_RESET
var held := false


func begin(hold_id: String, duration: float, new_interrupt_policy := INTERRUPT_RESET) -> bool:
	if hold_id.is_empty() or duration <= 0.0:
		return false
	if is_active():
		cancel()

	active_hold_id = hold_id
	duration_seconds = duration
	elapsed_seconds = 0.0
	interrupt_policy = new_interrupt_policy if new_interrupt_policy in [INTERRUPT_RESET, INTERRUPT_PAUSE] else INTERRUPT_RESET
	held = true
	hold_started.emit(active_hold_id, duration_seconds)
	progress_changed.emit(active_hold_id, 0.0)
	return true


func set_held(value: bool) -> void:
	if not is_active() or held == value:
		return

	held = value
	if not held and interrupt_policy == INTERRUPT_RESET:
		elapsed_seconds = 0.0
		progress_changed.emit(active_hold_id, 0.0)


func advance(delta: float) -> void:
	if not is_active() or not held or delta <= 0.0:
		return

	elapsed_seconds = minf(elapsed_seconds + delta, duration_seconds)
	var completed_id := active_hold_id
	progress_changed.emit(completed_id, get_progress())
	if elapsed_seconds < duration_seconds:
		return

	_clear()
	hold_completed.emit(completed_id)


func cancel() -> void:
	if not is_active():
		return

	var cancelled_id := active_hold_id
	_clear()
	hold_cancelled.emit(cancelled_id)


func is_active() -> bool:
	return not active_hold_id.is_empty()


func get_progress() -> float:
	if duration_seconds <= 0.0:
		return 0.0
	return clampf(elapsed_seconds / duration_seconds, 0.0, 1.0)


func _clear() -> void:
	active_hold_id = ""
	duration_seconds = 0.0
	elapsed_seconds = 0.0
	interrupt_policy = INTERRUPT_RESET
	held = false
