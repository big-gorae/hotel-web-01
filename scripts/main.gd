extends Control

const START_SCENE_ID := "front_desk"
const PARALLAX_PADDING := 48.0
const PARALLAX_STRENGTH := 18.0
const TITLE_VISIBLE_SECONDS := 2.0
const TITLE_FADE_SECONDS := 1.0

const IDLE_STYLE := {
	"bg": Color(1.0, 1.0, 1.0, 0.05),
	"border": Color(1.0, 1.0, 1.0, 0.22),
}
const HOVER_STYLE := {
	"bg": Color(1.0, 0.82, 0.28, 0.2),
	"border": Color(1.0, 0.82, 0.28, 0.9),
}
const PRESS_STYLE := {
	"bg": Color(0.25, 0.72, 1.0, 0.22),
	"border": Color(0.45, 0.82, 1.0, 0.95),
}
const HIDDEN_STYLE := {
	"bg": Color(1.0, 1.0, 1.0, 0.0),
	"border": Color(1.0, 1.0, 1.0, 0.0),
}

const HOTEL_SCENES := {
	"front_desk": {
		"title": "Front Desk",
		"photo": "res://resource/front_desk.png",
		"intro": "The night clerk's counter is quiet. Notes, a phone, and the old monitor are ready for clues.",
		"exits": [
			{"label": "Corridor", "target": "corridor"},
			{"label": "Laundry Room", "target": "laundry_room"},
			{"label": "Guest Room", "target": "guest_room"},
		],
		"hotspots": [
			{
				"id": "front_left_edge",
				"label": "Laundry",
				"rect": Rect2(0.000, 0.000, 0.075, 1.000),
				"target": "laundry_room",
			},
			{
				"id": "front_right_edge",
				"label": "Corridor",
				"rect": Rect2(0.925, 0.000, 0.075, 1.000),
				"target": "corridor",
			},
			{
				"id": "desk_bell",
				"label": "Bell",
				"rect": Rect2(0.407, 0.407, 0.075, 0.095),
				"text": "The bell gives a thin ring that hangs in the lobby for a second.",
			},
			{
				"id": "phone",
				"label": "Phone",
				"rect": Rect2(0.020, 0.690, 0.180, 0.260),
				"text": "The desk phone still works. The last extension dialed was 105.",
			},
			{
				"id": "logbook",
				"label": "Logbook",
				"rect": Rect2(0.390, 0.745, 0.245, 0.190),
				"text": "Guest names, room numbers, and a few rushed pencil marks fill the page.",
			},
			{
				"id": "monitor",
				"label": "Monitor",
				"rect": Rect2(0.760, 0.300, 0.220, 0.390),
				"text": "The reservation screen is still open, but several entries are hard to read.",
			},
			{
				"id": "front_door",
				"label": "Exit Door",
				"rect": Rect2(0.330, 0.020, 0.235, 0.500),
				"target": "corridor",
			},
		],
	},
	"corridor": {
		"title": "Corridor",
		"photo": "res://resource/corridor.png",
		"intro": "The outside corridor is damp and dim. Each numbered door could hide a different lead.",
		"exits": [
			{"label": "Front Desk", "target": "front_desk"},
			{"label": "Exterior Stairs", "target": "exterior_stairs"},
			{"label": "Guest Room", "target": "guest_room"},
		],
		"hotspots": [
			{
				"id": "corridor_left_edge",
				"label": "Front Desk",
				"rect": Rect2(0.000, 0.000, 0.075, 1.000),
				"target": "front_desk",
			},
			{
				"id": "corridor_bottom_edge",
				"label": "Stairs",
				"rect": Rect2(0.000, 0.860, 1.000, 0.140),
				"target": "exterior_stairs",
			},
			{
				"id": "room_105",
				"label": "Room 105",
				"rect": Rect2(0.080, 0.135, 0.145, 0.475),
				"target": "guest_room",
			},
			{
				"id": "room_106",
				"label": "Room 106",
				"rect": Rect2(0.302, 0.155, 0.102, 0.395),
				"target": "guest_room",
			},
			{
				"id": "walkway_lights",
				"label": "Lights",
				"rect": Rect2(0.245, 0.155, 0.085, 0.170),
				"text": "The corridor lamps flicker at uneven intervals.",
			},
			{
				"id": "parking_lot",
				"label": "Parking Lot",
				"rect": Rect2(0.830, 0.290, 0.165, 0.355),
				"text": "Wet pavement reflects the motel lights. A car engine ticks as it cools.",
			},
		],
	},
	"guest_room": {
		"title": "Guest Room",
		"photo": "res://resource/guest_room.png",
		"intro": "A modest room with the curtains half closed. The bed, window, and door are the main points of interest.",
		"exits": [
			{"label": "Corridor", "target": "corridor"},
			{"label": "Bathroom View", "target": "bathroom_view"},
			{"label": "Front Desk", "target": "front_desk"},
		],
		"hotspots": [
			{
				"id": "room_left_edge",
				"label": "Turn",
				"rect": Rect2(0.000, 0.680, 0.105, 0.240),
				"target": "bathroom_view",
			},
			{
				"id": "room_right_edge",
				"label": "Turn",
				"rect": Rect2(0.905, 0.000, 0.095, 1.000),
				"target": "bathroom_view",
			},
			{
				"id": "room_door",
				"label": "Door",
				"rect": Rect2(0.000, 0.090, 0.135, 0.540),
				"target": "corridor",
			},
			{
				"id": "window",
				"label": "Window",
				"rect": Rect2(0.222, 0.147, 0.205, 0.350),
				"text": "The window faces the parking lot. The glass is cold to the touch.",
			},
			{
				"id": "bed",
				"label": "Bed",
				"rect": Rect2(0.308, 0.465, 0.660, 0.390),
				"text": "The bedspread has been pulled tight, but one corner is slightly tucked under.",
			},
			{
				"id": "lamp",
				"label": "Lamp",
				"rect": Rect2(0.610, 0.335, 0.120, 0.230),
				"text": "The lamp is warm, making the room feel smaller than it is.",
			},
		],
	},
	"bathroom_view": {
		"title": "Bathroom View",
		"photo": "res://resource/bathroom_view.png",
		"intro": "From this angle the bathroom, closet door, television, and bed are all within reach.",
		"exits": [
			{"label": "Guest Room", "target": "guest_room"},
			{"label": "Guest Bathroom", "target": "guest_bathroom"},
			{"label": "Corridor", "target": "corridor"},
		],
		"hotspots": [
			{
				"id": "bathroom_left_edge",
				"label": "Turn",
				"rect": Rect2(0.000, 0.000, 0.095, 1.000),
				"target": "guest_room",
			},
			{
				"id": "bathroom_right_edge",
				"label": "Turn",
				"rect": Rect2(0.925, 0.000, 0.075, 1.000),
				"target": "guest_room",
			},
			{
				"id": "bathroom_sink",
				"label": "Bathroom",
				"rect": Rect2(0.458, 0.260, 0.220, 0.325),
				"target": "guest_bathroom",
			},
			{
				"id": "closet_door",
				"label": "Closet",
				"rect": Rect2(0.640, 0.220, 0.126, 0.500),
				"text": "The closet door is closed, but the knob is polished from frequent use.",
			},
			{
				"id": "television",
				"label": "TV",
				"rect": Rect2(0.795, 0.435, 0.170, 0.240),
				"text": "The television reflects the room back at you in a warped curve.",
			},
			{
				"id": "nightstand",
				"label": "Nightstand",
				"rect": Rect2(0.270, 0.585, 0.145, 0.170),
				"text": "A phone sits beside the bed. The room card is missing.",
			},
			],
		},
		"guest_bathroom": {
			"title": "Guest Bathroom",
			"photo": "res://resource/guest_bathroom.png",
			"intro": "The bathroom is cramped and bright. The mirror, sink, tub, and door are all close together.",
			"exits": [
				{"label": "Bathroom View", "target": "bathroom_view"},
				{"label": "Guest Room", "target": "guest_room"},
			],
			"hotspots": [
				{
					"id": "bathroom_door",
					"label": "Door",
					"rect": Rect2(0.835, 0.000, 0.165, 1.000),
					"target": "bathroom_view",
				},
				{
					"id": "bathroom_mirror",
					"label": "Mirror",
					"rect": Rect2(0.000, 0.000, 0.225, 0.520),
					"text": "The mirror is worn at the edges, blurring the room behind you.",
				},
				{
					"id": "bathroom_sink",
					"label": "Sink",
					"rect": Rect2(0.000, 0.560, 0.395, 0.280),
					"text": "A small tube rests near the sink. The counter is stained from years of use.",
				},
				{
					"id": "bathroom_tub",
					"label": "Tub",
					"rect": Rect2(0.455, 0.120, 0.340, 0.760),
					"text": "The shower curtain hangs still. The tub is dry.",
				},
			],
		},
		"laundry_room": {
			"title": "Laundry Room",
			"photo": "res://resource/laundry_room.png",
			"intro": "The laundry room hums under fluorescent light. Machines line the walls and the exit is behind you.",
			"exits": [
				{"label": "Front Desk", "target": "front_desk"},
			],
			"hotspots": [
				{
					"id": "laundry_bottom_edge",
					"label": "Exit",
					"rect": Rect2(0.000, 0.880, 1.000, 0.120),
					"target": "front_desk",
				},
				{
					"id": "laundry_machines",
					"label": "Machines",
					"rect": Rect2(0.630, 0.410, 0.340, 0.370),
					"text": "The machines are silent, but one lid has been left open.",
				},
				{
					"id": "laundry_rules",
					"label": "Rules",
					"rect": Rect2(0.505, 0.260, 0.100, 0.150),
					"text": "Laundry rules are posted beside the window in small print.",
				},
				{
					"id": "detergent",
					"label": "Detergent",
					"rect": Rect2(0.175, 0.465, 0.185, 0.130),
					"text": "Detergent bottles sit near the sink, lined up like someone left in a hurry.",
				},
			],
		},
		"exterior_stairs": {
			"title": "Exterior Stairs",
			"photo": "res://resource/exterior_stairs.png",
			"intro": "The exterior stairs cut across the motel wall. Wet asphalt spreads out below.",
			"exits": [
				{"label": "Corridor", "target": "corridor"},
			],
			"hotspots": [
				{
					"id": "stairs_right_edge",
					"label": "Corridor",
					"rect": Rect2(0.900, 0.000, 0.100, 1.000),
					"target": "corridor",
				},
				{
					"id": "metal_stairs",
					"label": "Stairs",
					"rect": Rect2(0.295, 0.085, 0.440, 0.815),
					"text": "The metal stairs creak under light pressure.",
				},
				{
					"id": "parking_lot_light",
					"label": "Parking Lot",
					"rect": Rect2(0.000, 0.300, 0.250, 0.470),
					"text": "The parking lot is quiet except for the buzz of the lamp.",
				},
			],
		},
	}

var current_scene_id := START_SCENE_ID
var current_texture: Texture2D
var hotspot_buttons: Array[Button] = []
var show_hotspots := false
var show_chat := true
var show_navigation := false
var mouse_position := Vector2.ZERO
var title_tween: Tween

var photo: TextureRect
var hotspot_layer: Control
var title_panel: PanelContainer
var title_label: Label
var bottom_panel: PanelContainer
var message_label: Label
var nav_bar: HBoxContainer
var hotspot_toggle: Button
var chat_toggle: Button
var navigation_toggle: Button


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	get_tree().root.size_changed.connect(_update_layout)
	_build_ui()
	show_scene(START_SCENE_ID)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position
		_update_layout()


func show_scene(scene_id: String) -> void:
	if not HOTEL_SCENES.has(scene_id):
		push_warning("Unknown hotel scene: %s" % scene_id)
		return

	current_scene_id = scene_id
	var scene_data: Dictionary = HOTEL_SCENES[current_scene_id]
	current_texture = load(scene_data["photo"]) as Texture2D
	photo.texture = current_texture
	title_label.text = scene_data["title"]
	_show_title_banner()
	_set_message(scene_data["intro"])
	_build_hotspots(scene_data["hotspots"])
	_build_navigation(scene_data["exits"])
	_update_layout()


func _build_ui() -> void:
	photo = TextureRect.new()
	photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(photo)

	hotspot_layer = Control.new()
	hotspot_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hotspot_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(hotspot_layer)

	title_panel = PanelContainer.new()
	title_panel.position = Vector2(18.0, 18.0)
	title_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.78), Color(1.0, 1.0, 1.0, 0.10), 8))
	add_child(title_panel)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	title_panel.add_child(title_label)

	var corner_panel := PanelContainer.new()
	corner_panel.anchor_left = 1.0
	corner_panel.anchor_right = 1.0
	corner_panel.anchor_top = 0.0
	corner_panel.anchor_bottom = 0.0
	corner_panel.offset_left = -184.0
	corner_panel.offset_top = 18.0
	corner_panel.offset_right = -18.0
	corner_panel.offset_bottom = 66.0
	corner_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.78), Color(1.0, 1.0, 1.0, 0.10), 8))
	add_child(corner_panel)

	var corner_row := HBoxContainer.new()
	corner_row.add_theme_constant_override("separation", 8)
	corner_panel.add_child(corner_row)

	hotspot_toggle = _make_debug_button("▣", "Show click areas", _toggle_hotspots)
	corner_row.add_child(hotspot_toggle)

	chat_toggle = _make_debug_button("💬", "Hide chat panel", _toggle_chat)
	corner_row.add_child(chat_toggle)

	navigation_toggle = _make_debug_button("🧭", "Show quick travel buttons", _toggle_navigation)
	corner_row.add_child(navigation_toggle)

	bottom_panel = PanelContainer.new()
	bottom_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_panel.offset_left = 18.0
	bottom_panel.offset_top = -150.0
	bottom_panel.offset_right = -18.0
	bottom_panel.offset_bottom = -18.0
	bottom_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.035, 0.04, 0.82), Color(1.0, 1.0, 1.0, 0.10), 8))
	add_child(bottom_panel)

	var bottom_layout := VBoxContainer.new()
	bottom_layout.add_theme_constant_override("separation", 10)
	bottom_panel.add_child(bottom_layout)

	message_label = Label.new()
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	bottom_layout.add_child(message_label)

	nav_bar = HBoxContainer.new()
	nav_bar.add_theme_constant_override("separation", 8)
	bottom_layout.add_child(nav_bar)

	_apply_chat_display()
	_apply_navigation_display()
	_sync_debug_toggles()


func _build_hotspots(hotspots: Array) -> void:
	for button in hotspot_buttons:
		button.queue_free()
	hotspot_buttons.clear()

	for hotspot in hotspots:
		var button := Button.new()
		button.text = hotspot["label"]
		button.tooltip_text = hotspot.get("text", hotspot["label"])
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.set_meta("hotspot", hotspot)
		button.add_theme_font_size_override("font_size", 15)
		button.pressed.connect(_on_hotspot_pressed.bind(hotspot))
		hotspot_layer.add_child(button)
		hotspot_buttons.append(button)

	_apply_hotspot_display()


func _build_navigation(exits: Array) -> void:
	for child in nav_bar.get_children():
		child.queue_free()

	for exit_data in exits:
		var button := Button.new()
		button.text = exit_data["label"]
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(show_scene.bind(exit_data["target"]))
		nav_bar.add_child(button)

	_apply_navigation_display()


func _on_hotspot_pressed(hotspot: Dictionary) -> void:
	if hotspot.has("target"):
		show_scene(hotspot["target"])
		return

	_set_message(hotspot.get("text", hotspot["label"]))


func _toggle_hotspots() -> void:
	show_hotspots = not show_hotspots
	_apply_hotspot_display()


func _toggle_chat() -> void:
	show_chat = not show_chat
	_apply_chat_display()


func _toggle_navigation() -> void:
	show_navigation = not show_navigation
	_apply_navigation_display()


func _apply_hotspot_display() -> void:
	_sync_debug_toggles()

	for button in hotspot_buttons:
		var hotspot: Dictionary = button.get_meta("hotspot")
		if show_hotspots:
			button.text = hotspot["label"]
			button.tooltip_text = hotspot.get("text", hotspot["label"])
			button.add_theme_stylebox_override("normal", _make_panel_style(IDLE_STYLE["bg"], IDLE_STYLE["border"], 5))
			button.add_theme_stylebox_override("hover", _make_panel_style(HOVER_STYLE["bg"], HOVER_STYLE["border"], 5))
			button.add_theme_stylebox_override("pressed", _make_panel_style(PRESS_STYLE["bg"], PRESS_STYLE["border"], 5))
			button.add_theme_color_override("font_color", Color(1.0, 0.96, 0.78))
			button.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.62))
		else:
			button.text = ""
			button.tooltip_text = ""
			button.add_theme_stylebox_override("normal", _make_panel_style(HIDDEN_STYLE["bg"], HIDDEN_STYLE["border"], 5))
			button.add_theme_stylebox_override("hover", _make_panel_style(HIDDEN_STYLE["bg"], HIDDEN_STYLE["border"], 5))
			button.add_theme_stylebox_override("pressed", _make_panel_style(HIDDEN_STYLE["bg"], HIDDEN_STYLE["border"], 5))
			button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.0))
			button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 0.0))


func _apply_chat_display() -> void:
	bottom_panel.visible = show_chat
	_sync_debug_toggles()


func _apply_navigation_display() -> void:
	nav_bar.visible = show_navigation
	_sync_debug_toggles()


func _sync_debug_toggles() -> void:
	if hotspot_toggle == null:
		return

	hotspot_toggle.button_pressed = show_hotspots
	hotspot_toggle.tooltip_text = "Hide click areas" if show_hotspots else "Show click areas"
	_style_debug_button(hotspot_toggle, show_hotspots)

	chat_toggle.button_pressed = show_chat
	chat_toggle.tooltip_text = "Hide chat panel" if show_chat else "Show chat panel"
	_style_debug_button(chat_toggle, show_chat)

	navigation_toggle.button_pressed = show_navigation
	navigation_toggle.tooltip_text = "Hide quick travel buttons" if show_navigation else "Show quick travel buttons"
	_style_debug_button(navigation_toggle, show_navigation)


func _set_message(message: String) -> void:
	message_label.text = message


func _update_layout() -> void:
	if photo == null:
		return

	var viewport_size := get_viewport_rect().size
	var offset := _get_parallax_offset(viewport_size)
	photo.position = Vector2(-PARALLAX_PADDING, -PARALLAX_PADDING) + offset
	photo.size = viewport_size + Vector2(PARALLAX_PADDING * 2.0, PARALLAX_PADDING * 2.0)
	_position_title_panel()
	_update_hotspot_layout()


func _update_hotspot_layout() -> void:
	if current_texture == null:
		return

	var image_rect := _get_photo_draw_rect()
	for button in hotspot_buttons:
		var hotspot: Dictionary = button.get_meta("hotspot")
		var normalized_rect: Rect2 = hotspot["rect"]
		button.position = image_rect.position + normalized_rect.position * image_rect.size
		button.size = normalized_rect.size * image_rect.size


func _get_photo_draw_rect() -> Rect2:
	var texture_size: Vector2 = current_texture.get_size()
	var scale: float = maxf(photo.size.x / texture_size.x, photo.size.y / texture_size.y)
	var draw_size: Vector2 = texture_size * scale
	var draw_position: Vector2 = photo.position + (photo.size - draw_size) * 0.5
	return Rect2(draw_position, draw_size)


func _get_parallax_offset(viewport_size: Vector2) -> Vector2:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return Vector2.ZERO

	var normalized_mouse := (mouse_position / viewport_size) - Vector2(0.5, 0.5)
	return -normalized_mouse * PARALLAX_STRENGTH


func _show_title_banner() -> void:
	_position_title_panel()

	if title_tween != null:
		title_tween.kill()

	title_panel.visible = true
	title_panel.modulate.a = 1.0
	title_tween = create_tween()
	title_tween.tween_interval(TITLE_VISIBLE_SECONDS)
	title_tween.tween_property(title_panel, "modulate:a", 0.0, TITLE_FADE_SECONDS)
	title_tween.finished.connect(_hide_title_banner)


func _hide_title_banner() -> void:
	title_panel.visible = false
	title_tween = null


func _position_title_panel() -> void:
	if title_panel == null:
		return

	title_panel.size = title_panel.get_combined_minimum_size()
	title_panel.position = Vector2(18.0, 18.0)


func _make_debug_button(icon: String, tooltip: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = icon
	button.tooltip_text = tooltip
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(40.0, 32.0)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(callback)
	return button


func _style_debug_button(button: Button, enabled: bool) -> void:
	var background := Color(0.25, 0.72, 1.0, 0.24) if enabled else Color(1.0, 1.0, 1.0, 0.05)
	var border := Color(0.45, 0.82, 1.0, 0.85) if enabled else Color(1.0, 1.0, 1.0, 0.18)
	button.add_theme_stylebox_override("normal", _make_panel_style(background, border, 6))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(1.0, 0.82, 0.28, 0.20), Color(1.0, 0.82, 0.28, 0.85), 6))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.25, 0.72, 1.0, 0.30), Color(0.45, 0.82, 1.0, 0.95), 6))
	button.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 0.72) if enabled else Color(0.95, 0.95, 0.95, 0.50))


func _make_panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style
