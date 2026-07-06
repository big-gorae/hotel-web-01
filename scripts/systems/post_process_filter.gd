class_name HotelPostProcessFilter
extends ColorRect

const SHADER_CODE := "shader_type canvas_item;\nuniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;\nuniform float saturation = 1.0;\nuniform float contrast = 1.0;\nuniform float brightness = 0.0;\nuniform vec3 tint = vec3(1.0, 1.0, 1.0);\nuniform float tint_strength = 0.0;\nuniform float vignette_strength = 0.0;\nuniform float vignette_softness = 0.5;\nuniform float grain_strength = 0.0;\nuniform float bloom_strength = 0.0;\nuniform float time_seed = 0.0;\nfloat noise(vec2 uv) {\n\treturn fract(sin(dot(uv, vec2(12.9898, 78.233)) + time_seed) * 43758.5453123);\n}\nvoid fragment() {\n\tvec2 uv = SCREEN_UV;\n\tvec4 source = texture(SCREEN_TEXTURE, uv);\n\tvec3 color = source.rgb;\n\tfloat luma = dot(color, vec3(0.299, 0.587, 0.114));\n\tcolor = mix(vec3(luma), color, saturation);\n\tcolor = (color - 0.5) * contrast + 0.5 + brightness;\n\tcolor = mix(color, color * tint, tint_strength);\n\tfloat bright = smoothstep(0.62, 1.0, max(max(color.r, color.g), color.b));\n\tcolor += bright * bloom_strength;\n\tfloat dist = distance(uv, vec2(0.5));\n\tfloat vignette = smoothstep(0.82 - vignette_softness, 0.82, dist);\n\tcolor *= 1.0 - vignette * vignette_strength;\n\tfloat grain = noise(uv / SCREEN_PIXEL_SIZE) - 0.5;\n\tcolor += grain * grain_strength;\n\tCOLOR = vec4(clamp(color, vec3(0.0), vec3(1.0)), source.a);\n}\n"
const PRESET_NONE := "none"
const PRESET_DREARY_1 := "dreary_1"
const DEFAULT_PRESET := PRESET_DREARY_1
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
	},
}

var current_preset := DEFAULT_PRESET
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
	visible = safe_preset_name != PRESET_NONE
	shader_material.set_shader_parameter("saturation", float(preset["saturation"]))
	shader_material.set_shader_parameter("contrast", float(preset["contrast"]))
	shader_material.set_shader_parameter("brightness", float(preset["brightness"]))
	shader_material.set_shader_parameter("tint", preset["tint"])
	shader_material.set_shader_parameter("tint_strength", float(preset["tint_strength"]))
	shader_material.set_shader_parameter("vignette_strength", float(preset["vignette_strength"]))
	shader_material.set_shader_parameter("vignette_softness", float(preset["vignette_softness"]))
	shader_material.set_shader_parameter("grain_strength", float(preset["grain_strength"]))
	shader_material.set_shader_parameter("bloom_strength", float(preset["bloom_strength"]))


func clear_filter() -> void:
	apply_preset(PRESET_NONE)


func _make_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = SHADER_CODE

	var new_material := ShaderMaterial.new()
	new_material.shader = shader
	return new_material
