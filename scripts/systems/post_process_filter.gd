class_name HotelPostProcessFilter
extends ColorRect

const MIN_INTENSITY := 0.0
const MAX_INTENSITY := 2.0
const SHADER_CODE := """
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float saturation = 1.0;
uniform float contrast = 1.0;
uniform float brightness = 0.0;
uniform vec3 tint = vec3(1.0, 1.0, 1.0);
uniform float tint_strength = 0.0;
uniform float vignette_strength = 0.0;
uniform float vignette_softness = 0.5;
uniform float grain_strength = 0.0;
uniform float bloom_strength = 0.0;
uniform float static_strength = 0.0;
uniform float scanline_strength = 0.0;
uniform float roll_strength = 0.0;
uniform float rgb_offset_strength = 0.0;
uniform float effect_intensity = 1.0;
uniform float time_seed = 0.0;

float noise(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233)) + time_seed) * 43758.5453123);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float jitter = (noise(vec2(floor(uv.y * 180.0), floor(time_seed * 32.0))) - 0.5) * rgb_offset_strength * effect_intensity;
	vec4 shifted_source = vec4(
		texture(SCREEN_TEXTURE, uv + vec2(jitter, 0.0)).r,
		texture(SCREEN_TEXTURE, uv).g,
		texture(SCREEN_TEXTURE, uv - vec2(jitter, 0.0)).b,
		texture(SCREEN_TEXTURE, uv).a
	);
	vec3 original = texture(SCREEN_TEXTURE, uv).rgb;
	vec3 color = shifted_source.rgb;

	float luma = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(vec3(luma), color, saturation);
	color = (color - 0.5) * contrast + 0.5 + brightness;
	color = mix(color, color * tint, tint_strength);

	float bright = smoothstep(0.62, 1.0, max(max(color.r, color.g), color.b));
	color += bright * bloom_strength;

	float dist = distance(uv, vec2(0.5));
	float vignette = smoothstep(0.82 - vignette_softness, 0.82, dist);
	color *= 1.0 - vignette * vignette_strength;

	float fine_static = noise(vec2(uv.x * 840.0 + time_seed * 71.0, uv.y * 480.0 - time_seed * 19.0)) - 0.5;
	float line_static = noise(vec2(floor(uv.y * 360.0), floor(time_seed * 24.0))) - 0.5;
	float old_grain = noise(uv / SCREEN_PIXEL_SIZE) - 0.5;
	color += old_grain * grain_strength;
	color += (fine_static * 1.35 + line_static * 0.95) * static_strength * effect_intensity;

	float scanline = 0.5 + 0.5 * sin(uv.y * 1280.0);
	color *= 1.0 - scanline * scanline_strength * effect_intensity;

	float roll_center = fract(time_seed * 0.18);
	float roll_distance = min(abs(uv.y - roll_center), 1.0 - abs(uv.y - roll_center));
	float roll_band = 1.0 - smoothstep(0.0, 0.085, roll_distance);
	color += roll_band * roll_strength * effect_intensity;

	float safe_intensity = clamp(effect_intensity, 0.0, 2.0);
	color = mix(original, color, safe_intensity);
	COLOR = vec4(clamp(color, vec3(0.0), vec3(1.0)), shifted_source.a);
}
"""
const PRESET_NONE := "none"
const PRESET_DREARY_1 := "dreary_1"
const PRESET_SUBTLE_GRAIN := "subtle_grain"
const DEFAULT_PRESET := PRESET_DREARY_1
const PRESET_ORDER := [PRESET_NONE, PRESET_DREARY_1, PRESET_SUBTLE_GRAIN]
const PRESETS := {
	PRESET_NONE: {
		"display_name": "필터 없음",
		"saturation": 1.0,
		"contrast": 1.0,
		"brightness": 0.0,
		"tint": Vector3(1.0, 1.0, 1.0),
		"tint_strength": 0.0,
		"vignette_strength": 0.0,
		"vignette_softness": 0.5,
		"grain_strength": 0.0,
		"bloom_strength": 0.0,
		"static_strength": 0.0,
		"scanline_strength": 0.0,
		"roll_strength": 0.0,
		"rgb_offset_strength": 0.0,
	},
	PRESET_DREARY_1: {
		"display_name": "우중충한 필터 1",
		"saturation": 0.74,
		"contrast": 1.12,
		"brightness": -0.025,
		"tint": Vector3(1.0, 0.91, 0.70),
		"tint_strength": 0.18,
		"vignette_strength": 0.22,
		"vignette_softness": 0.40,
		"grain_strength": 0.026,
		"bloom_strength": 0.035,
		"static_strength": 0.0,
		"scanline_strength": 0.0,
		"roll_strength": 0.0,
		"rgb_offset_strength": 0.0,
	},
	PRESET_SUBTLE_GRAIN: {
		"display_name": "브라운관 지지직",
		"saturation": 0.82,
		"contrast": 1.14,
		"brightness": -0.025,
		"tint": Vector3(0.92, 1.0, 0.96),
		"tint_strength": 0.08,
		"vignette_strength": 0.12,
		"vignette_softness": 0.42,
		"grain_strength": 0.12,
		"bloom_strength": 0.0,
		"static_strength": 0.20,
		"scanline_strength": 0.18,
		"roll_strength": 0.055,
		"rgb_offset_strength": 0.0045,
	},
}

var current_preset := DEFAULT_PRESET
var filter_intensity := 1.0
var shader_material: ShaderMaterial
var elapsed_time := 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color.WHITE
	shader_material = _make_material()
	material = shader_material
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	apply_preset(current_preset)


func _process(delta: float) -> void:
	elapsed_time += delta
	if shader_material != null:
		shader_material.set_shader_parameter("time_seed", elapsed_time)


func apply_preset(preset_name: String) -> void:
	var safe_preset_name := preset_name if PRESETS.has(preset_name) else PRESET_NONE
	current_preset = safe_preset_name

	if shader_material == null:
		return

	var preset: Dictionary = PRESETS[safe_preset_name]
	_update_visibility()
	shader_material.set_shader_parameter("saturation", float(preset["saturation"]))
	shader_material.set_shader_parameter("contrast", float(preset["contrast"]))
	shader_material.set_shader_parameter("brightness", float(preset["brightness"]))
	shader_material.set_shader_parameter("tint", preset["tint"])
	shader_material.set_shader_parameter("tint_strength", float(preset["tint_strength"]))
	shader_material.set_shader_parameter("vignette_strength", float(preset["vignette_strength"]))
	shader_material.set_shader_parameter("vignette_softness", float(preset["vignette_softness"]))
	shader_material.set_shader_parameter("grain_strength", float(preset["grain_strength"]))
	shader_material.set_shader_parameter("bloom_strength", float(preset["bloom_strength"]))
	shader_material.set_shader_parameter("static_strength", float(preset["static_strength"]))
	shader_material.set_shader_parameter("scanline_strength", float(preset["scanline_strength"]))
	shader_material.set_shader_parameter("roll_strength", float(preset["roll_strength"]))
	shader_material.set_shader_parameter("rgb_offset_strength", float(preset["rgb_offset_strength"]))
	shader_material.set_shader_parameter("effect_intensity", filter_intensity)


func clear_filter() -> void:
	apply_preset(PRESET_NONE)


func set_filter_intensity(value: float) -> void:
	filter_intensity = clampf(value, MIN_INTENSITY, MAX_INTENSITY)
	if shader_material != null:
		shader_material.set_shader_parameter("effect_intensity", filter_intensity)
	_update_visibility()


func get_filter_intensity() -> float:
	return filter_intensity


func get_available_presets() -> Array:
	return PRESET_ORDER.duplicate()


func get_preset_display_name(preset_name: String) -> String:
	var safe_preset_name := preset_name if PRESETS.has(preset_name) else PRESET_NONE
	return String(PRESETS[safe_preset_name].get("display_name", safe_preset_name))


func _update_visibility() -> void:
	visible = current_preset != PRESET_NONE and filter_intensity > 0.0


func _make_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = SHADER_CODE

	var new_material := ShaderMaterial.new()
	new_material.shader = shader
	return new_material
