class_name HotelAnomalyVisualOverlay
extends Control

const UI_FONT := preload("res://resource/fonts/NanumGothic-Regular.ttf")

var _presentation_state: Dictionary = {}
var _current_scene_id := ""
var _photo_rect := Rect2()
var _suppressed := false
var _shadow_flicker_seconds := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false


func _process(delta: float) -> void:
	if (
		String(_presentation_state.get("event_id", "")) != "hotel_following_shadow"
		or String(_presentation_state.get("state", "")) != "bell_distressed"
	):
		return
	_shadow_flicker_seconds += maxf(delta, 0.0)
	queue_redraw()


func set_scene(scene_id: String) -> void:
	_current_scene_id = scene_id
	_sync_visibility()


func set_photo_rect(value: Rect2) -> void:
	_photo_rect = value
	queue_redraw()


func apply_presentation_state(state: Dictionary) -> void:
	var was_distressed := (
		String(_presentation_state.get("event_id", "")) == "hotel_following_shadow"
		and String(_presentation_state.get("state", "")) == "bell_distressed"
	)
	_presentation_state = state.duplicate(true)
	var is_distressed := (
		String(_presentation_state.get("event_id", "")) == "hotel_following_shadow"
		and String(_presentation_state.get("state", "")) == "bell_distressed"
	)
	if is_distressed and not was_distressed:
		_shadow_flicker_seconds = 0.0
	_sync_visibility()


func set_suppressed(value: bool) -> void:
	_suppressed = value
	_sync_visibility()


func _sync_visibility() -> void:
	var event_id := String(_presentation_state.get("event_id", ""))
	var scene_id := String(_presentation_state.get("scene_id", ""))
	var uses_artifact_accent := (
		_suppressed
		and event_id == "room_107_hanging_girl"
		and String(_presentation_state.get("state", "")) == "hostile"
		and _current_scene_id == "room_107_bed_nightstand"
	)
	visible = (
		(not _suppressed or uses_artifact_accent)
		and not event_id.is_empty()
		and (
			scene_id == _current_scene_id
			or event_id == "hotel_following_shadow"
			or (event_id == "room_107_hanging_girl" and _current_scene_id == "laundry_room")
		)
	)
	queue_redraw()


func _draw() -> void:
	if not visible or _photo_rect.size.x <= 0.0:
		return
	var event_id := String(_presentation_state.get("event_id", ""))
	var state := String(_presentation_state.get("state", "visible"))
	match event_id:
		"front_monitor_ghost":
			_draw_screen_ghost(Rect2(0.405, 0.285, 0.185, 0.205), state)
		"front_glass_face":
			_draw_face(_map_rect(Rect2(0.485, 0.145, 0.095, 0.365)), state == "hostile")
		"front_die_sign":
			_draw_die_sign()
		"corridor_red_room_light":
			_draw_red_light()
		"corridor_blood_puddle":
			_draw_blood_puddle()
		"laundry_baby_face_surfaces":
			_draw_baby_surfaces()
		"room_107_human_skin_towel":
			_draw_skin_towel()
		"stairs_hell_arrow":
			_draw_hell_arrow()
		"room_105_grotesque_portrait":
			_draw_portrait()
		"room_108_tv_ghost":
			_draw_screen_ghost(Rect2(0.655, 0.295, 0.205, 0.230), state)
		"bathroom_shower_legs":
			if bool(_presentation_state.get("curtain_legs_visible", false)):
				_draw_shower_legs()
		"room_107_empty_hanging_rope":
			_draw_rope()
		"room_105_bloody_handprint_mirror":
			_draw_handprints()
		"room_106_horrific_mirror":
			_draw_horrific_mirror()
		"room_108_entrails_bathtub":
			_draw_entrails()
		"room_109_open_door":
			_draw_open_door()
		"room_107_hanging_girl":
			if _current_scene_id == "laundry_room":
				if not bool(_presentation_state.get("hanging_girl_doll_taken", false)):
					_draw_cute_doll()
			elif _suppressed:
				if state == "hostile":
					_draw_hanging_girl_angry_eyes()
			else:
				_draw_hanging_girl(int(_presentation_state.get("entity_stage", 0)))
				if state == "hostile":
					_draw_hanging_girl_angry_eyes()
		"hotel_following_shadow":
			_draw_shadow_flicker(state)
		"laundry_red_washer":
			_draw_red_washer()
		"room_106_abandoned_child":
			_draw_abandoned_child()
		"vacant_room_blanket_child":
			_draw_blanket_child()
		"room_105_closet_pig_man":
				_draw_closet_pig_man(state)


func get_shadow_flicker_alpha() -> float:
	if (
		String(_presentation_state.get("event_id", "")) != "hotel_following_shadow"
		or String(_presentation_state.get("state", "")) != "bell_distressed"
	):
		return 0.0
	var pattern := [0.0, 0.72, 0.16, 0.88, 0.05, 0.58]
	var index := int(_shadow_flicker_seconds / 0.075) % pattern.size()
	return float(pattern[index])


func _draw_shadow_flicker(state: String) -> void:
	if state != "bell_distressed":
		return
	var alpha := get_shadow_flicker_alpha()
	if alpha <= 0.0:
		return
	draw_rect(_photo_rect, Color(0.015, 0.0, 0.0, alpha), true)


func _map_rect(normalized: Rect2) -> Rect2:
	return Rect2(
		_photo_rect.position + normalized.position * _photo_rect.size,
		normalized.size * _photo_rect.size
	)


func _draw_screen_ghost(normalized: Rect2, state: String) -> void:
	var rect := _map_rect(normalized)
	draw_rect(rect, Color(0.02, 0.02, 0.025, 0.88), true)
	var hostile := state == "hostile"
	var center := rect.get_center()
	var radius := minf(rect.size.x, rect.size.y) * (0.30 if hostile else 0.23)
	_draw_face(Rect2(center - Vector2(radius, radius * 1.18), Vector2(radius * 2.0, radius * 2.36)), hostile)
	var line_count := 11
	for index in line_count:
		var y := rect.position.y + rect.size.y * float(index) / float(line_count)
		var alpha := 0.28 if index % 2 == 0 else 0.12
		draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), Color(0.88, 0.90, 0.86, alpha), 1.0)


func _draw_face(rect: Rect2, hostile: bool) -> void:
	var center := rect.get_center()
	var skin := Color(0.72, 0.72, 0.68, 0.92) if not hostile else Color(0.91, 0.76, 0.68, 0.96)
	_draw_oval(center, rect.size * Vector2(0.46, 0.48), skin)
	var eye_y := center.y - rect.size.y * 0.11
	var eye_dx := rect.size.x * 0.17
	var eye_radius := maxf(2.0, rect.size.x * (0.045 if not hostile else 0.075))
	for x in [center.x - eye_dx, center.x + eye_dx]:
		draw_circle(Vector2(x, eye_y), eye_radius * 1.7, Color(0.04, 0.025, 0.025, 0.96))
		draw_circle(Vector2(x, eye_y), eye_radius * 0.48, Color(0.92, 0.08, 0.06, 0.96) if hostile else Color(0.84, 0.84, 0.78, 0.92))
	var mouth_rect := Rect2(
		Vector2(center.x - rect.size.x * (0.25 if hostile else 0.13), center.y + rect.size.y * 0.12),
		Vector2(rect.size.x * (0.50 if hostile else 0.26), rect.size.y * (0.15 if hostile else 0.08))
	)
	draw_rect(mouth_rect, Color(0.08, 0.01, 0.015, 0.98), true)
	if hostile:
		for index in 6:
			var tooth_x := mouth_rect.position.x + mouth_rect.size.x * (float(index) + 0.5) / 6.0
			draw_line(Vector2(tooth_x, mouth_rect.position.y), Vector2(tooth_x, mouth_rect.end.y), Color(0.86, 0.80, 0.68, 0.88), 1.0)


func _draw_oval(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in 48:
		var angle := TAU * float(index) / 48.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)


func _draw_die_sign() -> void:
	var rect := _map_rect(Rect2(0.255, 0.185, 0.195, 0.155))
	draw_rect(rect, Color(0.82, 0.78, 0.64, 0.92), true)
	var font_size := maxi(22, int(rect.size.y * 0.55))
	draw_string(UI_FONT, Vector2(rect.position.x + rect.size.x * 0.18, rect.position.y + rect.size.y * 0.72), "죽어", HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(0.55, 0.0, 0.0, 0.98))


func _draw_red_light() -> void:
	var rect := _map_rect(Rect2(0.625, 0.125, 0.115, 0.130))
	for step in range(8, 0, -1):
		var alpha := 0.025 * float(9 - step)
		draw_circle(rect.get_center(), rect.size.x * 0.12 * float(step), Color(1.0, 0.0, 0.0, alpha))
	draw_circle(rect.get_center(), rect.size.x * 0.24, Color(1.0, 0.015, 0.01, 0.96))


func _draw_blood_puddle() -> void:
	var rect := _map_rect(Rect2(0.250, 0.710, 0.430, 0.180))
	_draw_oval(rect.get_center(), rect.size * Vector2(0.48, 0.30), Color(0.34, 0.0, 0.0, 0.88))
	draw_circle(rect.position + rect.size * Vector2(0.78, 0.52), rect.size.y * 0.18, Color(0.45, 0.0, 0.0, 0.78))


func _draw_baby_surfaces() -> void:
	var closed: Array = _presentation_state.get("closed_surfaces", [])
	var rects := {
		"floor": Rect2(0.0, 0.67, 1.0, 0.33),
		"ceiling": Rect2(0.0, 0.0, 1.0, 0.17),
		"left": Rect2(0.0, 0.15, 0.25, 0.55),
		"front": Rect2(0.25, 0.15, 0.50, 0.55),
		"right": Rect2(0.75, 0.15, 0.25, 0.55),
	}
	for surface_id in rects:
		if closed.has(surface_id):
			continue
		var surface_rect := _map_rect(rects[surface_id])
		draw_rect(surface_rect, Color(0.50, 0.38, 0.32, 0.52), true)
		var columns := maxi(2, int(surface_rect.size.x / 82.0))
		var rows := maxi(1, int(surface_rect.size.y / 74.0))
		for y in rows:
			for x in columns:
				var cell := Vector2(surface_rect.size.x / columns, surface_rect.size.y / rows)
				var face_center := surface_rect.position + Vector2((x + 0.5) * cell.x, (y + 0.5) * cell.y)
				var face_size := minf(cell.x, cell.y) * 0.34
				_draw_face(Rect2(face_center - Vector2(face_size, face_size), Vector2(face_size * 2.0, face_size * 2.0)), true)


func _draw_skin_towel() -> void:
	var rect := _map_rect(Rect2(0.675, 0.245, 0.145, 0.365))
	draw_rect(rect, Color(0.66, 0.40, 0.34, 0.94), true)
	for index in 5:
		var y := rect.position.y + rect.size.y * (float(index) + 0.5) / 5.0
		draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y + sin(index) * 9.0), Color(0.30, 0.04, 0.035, 0.78), 2.0)


func _draw_hell_arrow() -> void:
	var rect := _map_rect(Rect2(0.285, 0.235, 0.365, 0.255))
	draw_rect(rect.grow(22.0), Color(0.9, 0.0, 0.0, 0.16), true)
	var points := PackedVector2Array([
		Vector2(rect.position.x, rect.position.y + rect.size.y * 0.32),
		Vector2(rect.position.x + rect.size.x * 0.62, rect.position.y + rect.size.y * 0.32),
		Vector2(rect.position.x + rect.size.x * 0.62, rect.position.y),
		Vector2(rect.end.x, rect.position.y + rect.size.y * 0.5),
		Vector2(rect.position.x + rect.size.x * 0.62, rect.end.y),
		Vector2(rect.position.x + rect.size.x * 0.62, rect.position.y + rect.size.y * 0.68),
		Vector2(rect.position.x, rect.position.y + rect.size.y * 0.68),
	])
	draw_colored_polygon(points, Color(1.0, 0.0, 0.0, 0.94))


func _draw_portrait() -> void:
	var rect := _map_rect(Rect2(0.095, 0.195, 0.195, 0.270))
	draw_rect(rect.grow(7.0), Color(0.14, 0.065, 0.025, 0.96), true)
	draw_rect(rect, Color(0.02, 0.015, 0.012, 0.96), true)
	_draw_face(rect.grow(-rect.size.x * 0.12), true)


func _draw_shower_legs() -> void:
	var rect := _map_rect(Rect2(0.405, 0.155, 0.345, 0.655))
	var base_y := rect.end.y - rect.size.y * 0.05
	for x_ratio in [0.42, 0.58]:
		var x: float = rect.position.x + rect.size.x * float(x_ratio)
		draw_line(Vector2(x, base_y), Vector2(x + rect.size.x * 0.05, base_y - rect.size.y * 0.32), Color(0.56, 0.52, 0.48, 0.96), rect.size.x * 0.075)
		_draw_oval(Vector2(x - rect.size.x * 0.02, base_y), Vector2(rect.size.x * 0.10, rect.size.y * 0.025), Color(0.48, 0.45, 0.42, 0.96))


func _draw_rope() -> void:
	var rect := _map_rect(Rect2(0.355, 0.045, 0.215, 0.620))
	var x := rect.get_center().x
	draw_line(Vector2(x, rect.position.y), Vector2(x, rect.position.y + rect.size.y * 0.62), Color(0.44, 0.34, 0.20, 0.96), 7.0)
	draw_arc(Vector2(x, rect.position.y + rect.size.y * 0.76), rect.size.x * 0.20, -PI * 0.25, PI * 1.65, 42, Color(0.44, 0.34, 0.20, 0.96), 7.0)


func _draw_handprints() -> void:
	var rect := _map_rect(Rect2(0.185, 0.145, 0.295, 0.340))
	for index in 10:
		var cell_x := index % 4
		var cell_y := index / 4
		var center := rect.position + Vector2(rect.size.x * (0.15 + cell_x * 0.24), rect.size.y * (0.20 + cell_y * 0.31))
		draw_circle(center, rect.size.x * 0.045, Color(0.56, 0.0, 0.0, 0.86))
		for finger in 5:
			var angle := lerpf(-2.65, -0.48, float(finger) / 4.0)
			draw_line(center, center + Vector2(cos(angle), sin(angle)) * rect.size.x * 0.10, Color(0.56, 0.0, 0.0, 0.86), 3.0)


func _draw_horrific_mirror() -> void:
	var rect := _map_rect(Rect2(0.185, 0.145, 0.295, 0.340))
	draw_rect(rect, Color(0.08, 0.0, 0.015, 0.72), true)
	_draw_face(rect.grow(-rect.size.x * 0.22), true)


func _draw_entrails() -> void:
	var rect := _map_rect(Rect2(0.405, 0.455, 0.410, 0.390))
	draw_rect(rect, Color(0.26, 0.0, 0.0, 0.74), true)
	for index in 12:
		var start := rect.position + Vector2(rect.size.x * fmod(index * 0.37, 1.0), rect.size.y * fmod(index * 0.61, 1.0))
		var end := rect.position + Vector2(rect.size.x * fmod(index * 0.73 + 0.2, 1.0), rect.size.y * fmod(index * 0.43 + 0.3, 1.0))
		draw_line(start, end, Color(0.68, 0.12, 0.10, 0.94), 11.0, true)


func _draw_open_door() -> void:
	var rect := _map_rect(Rect2(0.735, 0.285, 0.055, 0.325))
	draw_rect(rect, Color(0.0, 0.0, 0.0, 0.98), true)


func _draw_hanging_girl(stage: int) -> void:
	var rect := _map_rect(Rect2(0.35, 0.025, 0.30, 0.88))
	var center_x := rect.get_center().x
	var head_center := Vector2(center_x, rect.position.y + rect.size.y * 0.23)
	draw_line(Vector2(center_x, rect.position.y), Vector2(center_x, head_center.y - rect.size.y * 0.09), Color(0.30, 0.22, 0.14, 0.96), 5.0)
	_draw_face(Rect2(head_center - Vector2(rect.size.x * 0.105, rect.size.y * 0.10), Vector2(rect.size.x * 0.21, rect.size.y * 0.20)), true)
	var shoulder_y := head_center.y + rect.size.y * 0.12
	var body_end_y := shoulder_y + rect.size.y * 0.24
	draw_line(Vector2(center_x, shoulder_y), Vector2(center_x, body_end_y), Color(0.18, 0.12, 0.14, 0.98), rect.size.x * 0.16)
	var extension := rect.size.y * 0.095 * stage
	for direction in [-1.0, 1.0]:
		draw_line(
			Vector2(center_x + direction * rect.size.x * 0.07, shoulder_y),
			Vector2(center_x + direction * rect.size.x * 0.20, body_end_y + extension),
			Color(0.64, 0.55, 0.50, 0.96),
			rect.size.x * 0.055
		)
		draw_line(
			Vector2(center_x + direction * rect.size.x * 0.055, body_end_y),
			Vector2(center_x + direction * rect.size.x * 0.09, body_end_y + rect.size.y * 0.24 + extension),
			Color(0.64, 0.55, 0.50, 0.96),
			rect.size.x * 0.065
		)


func _draw_hanging_girl_angry_eyes() -> void:
	var left_eye := _photo_rect.position + Vector2(0.688, 0.306) * _photo_rect.size
	var right_eye := _photo_rect.position + Vector2(0.713, 0.306) * _photo_rect.size
	var outer_radius := maxf(_photo_rect.size.x * 0.0062, 3.0)
	var inner_radius := outer_radius * 0.34
	for eye_center in [left_eye, right_eye]:
		draw_circle(eye_center, outer_radius, Color(0.015, 0.0, 0.0, 0.98))
		draw_circle(eye_center, inner_radius, Color(0.72, 0.015, 0.0, 1.0))


func _draw_cute_doll() -> void:
	var rect := _map_rect(Rect2(0.125, 0.440, 0.080, 0.130))
	var center_x := rect.get_center().x
	var head_center := Vector2(center_x, rect.position.y + rect.size.y * 0.25)
	var wood_dark := Color(0.24, 0.13, 0.07, 1.0)
	var wood_mid := Color(0.50, 0.32, 0.18, 1.0)
	var cloth := Color(0.18, 0.25, 0.16, 1.0)
	_draw_oval(
		Vector2(rect.get_center().x, rect.end.y - rect.size.y * 0.025),
		Vector2(rect.size.x * 0.30, rect.size.y * 0.055),
		Color(0.035, 0.020, 0.012, 0.42),
	)
	draw_circle(head_center, rect.size.x * 0.18, wood_mid)
	draw_circle(head_center + Vector2(-rect.size.x * 0.06, 0.0), rect.size.x * 0.018, wood_dark)
	draw_circle(head_center + Vector2(rect.size.x * 0.06, 0.0), rect.size.x * 0.018, wood_dark)
	draw_arc(
		head_center + Vector2(0.0, rect.size.y * 0.025),
		rect.size.x * 0.05,
		0.18,
		PI - 0.18,
		12,
		wood_dark,
		maxf(rect.size.x * 0.012, 1.0),
	)
	var shoulder_y := rect.position.y + rect.size.y * 0.43
	var waist_y := rect.position.y + rect.size.y * 0.70
	var half_width := rect.size.x * 0.16
	draw_colored_polygon(PackedVector2Array([
		Vector2(center_x - half_width, shoulder_y),
		Vector2(center_x + half_width, shoulder_y),
		Vector2(center_x + half_width * 0.75, waist_y),
		Vector2(center_x - half_width * 0.75, waist_y),
	]), cloth)
	for direction in [-1.0, 1.0]:
		draw_line(
			Vector2(center_x + direction * half_width * 0.85, shoulder_y),
			Vector2(center_x + direction * rect.size.x * 0.25, waist_y),
			wood_mid,
			maxf(rect.size.x * 0.035, 1.0),
		)
		draw_line(
			Vector2(center_x + direction * half_width * 0.45, waist_y),
			Vector2(center_x + direction * rect.size.x * 0.10, rect.end.y - rect.size.y * 0.05),
			wood_mid,
			maxf(rect.size.x * 0.04, 1.0),
		)


func _draw_red_washer() -> void:
	# Emergency fallback when the registered full-scene artifact is unavailable.
	# Keep it inside the rear washer glass instead of tinting the whole machine row.
	var rect := _map_rect(Rect2(0.610, 0.528, 0.041, 0.116))
	_draw_oval(rect.get_center(), rect.size * Vector2(0.48, 0.49), Color(0.20, 0.0, 0.0, 0.96))
	for index in 5:
		var fold_center := rect.position + rect.size * Vector2(
			0.32 + 0.13 * float(index % 3),
			0.27 + 0.18 * float(index),
		)
		_draw_oval(fold_center, rect.size * Vector2(0.23, 0.11), Color(0.66, 0.015, 0.02, 0.92))
	draw_arc(rect.get_center(), rect.size.x * 0.47, -1.2, 1.1, 20, Color(0.94, 0.12, 0.10, 0.72), 2.0)


func _draw_abandoned_child() -> void:
	var rect := _map_rect(Rect2(0.46, 0.52, 0.18, 0.30))
	var center := rect.get_center()
	var mother_rect := Rect2(
		Vector2(center.x - rect.size.x * 0.85, rect.position.y - rect.size.y * 1.05),
		Vector2(rect.size.x * 1.70, rect.size.y * 1.80)
	)
	draw_line(
		Vector2(mother_rect.get_center().x, mother_rect.position.y + mother_rect.size.y * 0.38),
		Vector2(mother_rect.get_center().x, mother_rect.end.y),
		Color(0.72, 0.74, 0.71, 0.30),
		mother_rect.size.x * 0.26
	)
	_draw_oval(
		Vector2(mother_rect.get_center().x, mother_rect.position.y + mother_rect.size.y * 0.20),
		Vector2(mother_rect.size.x * 0.19, mother_rect.size.y * 0.16),
		Color(0.72, 0.74, 0.71, 0.34)
	)
	draw_line(Vector2(center.x, center.y), Vector2(center.x, rect.end.y), Color(0.12, 0.08, 0.07, 0.92), rect.size.x * 0.24)
	_draw_face(Rect2(center - Vector2(rect.size.x * 0.28, rect.size.y * 0.34), Vector2(rect.size.x * 0.56, rect.size.y * 0.50)), false)


func _draw_blanket_child() -> void:
	var rect := _map_rect(Rect2(0.245, 0.455, 0.505, 0.335))
	var mound := PackedVector2Array()
	for index in 40:
		var angle := PI + PI * float(index) / 39.0
		mound.append(Vector2(
			rect.get_center().x + cos(angle) * rect.size.x * 0.42,
			rect.end.y + sin(angle) * rect.size.y * 0.80
		))
	mound.append(Vector2(rect.end.x, rect.end.y))
	mound.append(Vector2(rect.position.x, rect.end.y))
	draw_colored_polygon(mound, Color(0.57, 0.53, 0.47, 0.94))


func _draw_closet_pig_man(state: String) -> void:
	var rect := _map_rect(Rect2(0.655, 0.175, 0.185, 0.555))
	var gap_width := rect.size.x * (0.20 if state == "door_open" else 0.34)
	var gap := Rect2(Vector2(rect.get_center().x - gap_width * 0.5, rect.position.y), Vector2(gap_width, rect.size.y))
	draw_rect(gap, Color(0.0, 0.0, 0.0, 0.98), true)
	if state == "face":
		var face_rect := Rect2(
			Vector2(gap.position.x - gap.size.x * 0.35, gap.position.y + gap.size.y * 0.20),
			Vector2(gap.size.x * 1.70, gap.size.y * 0.25)
		)
		_draw_face(face_rect, true)
