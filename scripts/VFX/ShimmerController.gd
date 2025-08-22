extends Node2D

# Pure Visual Trippy Shader Effect - No Input Blocking
# Attach this script to any Node2D to add subtle trippy visual effects

@export var effect_intensity: float = 0.3
@export var color_shift_speed: float = 1.0
@export var wave_frequency: float = 2.0
@export var distortion_strength: float = 0.02
@export var enable_effect: bool = true

var shader_material: ShaderMaterial
var background_node: Node2D

# Pure visual shader that doesn't block input
var trippy_shader_code = """
shader_type canvas_item;
render_mode blend_add;

uniform float intensity : hint_range(0.0, 1.0) = 0.3;
uniform float time_scale : hint_range(0.1, 3.0) = 1.0;
uniform float wave_frequency : hint_range(0.5, 10.0) = 2.0;
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
uniform float color_shift_speed : hint_range(0.1, 5.0) = 1.0;

float noise(vec2 pos) {
	return fract(sin(dot(pos, vec2(12.9898, 78.233))) * 43758.5453);
}

float smooth_noise(vec2 pos) {
	vec2 i = floor(pos);
	vec2 f = fract(pos);
	f = f * f * (3.0 - 2.0 * f);
	
	float a = noise(i);
	float b = noise(i + vec2(1.0, 0.0));
	float c = noise(i + vec2(0.0, 1.0));
	float d = noise(i + vec2(1.0, 1.0));
	
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void vertex() {
	// Make sure we cover the full screen
	VERTEX = (VERTEX / SCREEN_PIXEL_SIZE) * 2.0 - 1.0;
}

void fragment() {
	vec2 screen_uv = SCREEN_UV;
	float time = TIME * time_scale;
	
	// Create flowing wave patterns across screen
	vec2 wave_pos = screen_uv * wave_frequency + time * 0.3;
	float wave1 = sin(wave_pos.x + time) * 0.5 + 0.5;
	float wave2 = cos(wave_pos.y + time * 0.7) * 0.5 + 0.5;
	float wave3 = sin(wave_pos.x * 1.5 + wave_pos.y * 0.8 + time * 1.2) * 0.5 + 0.5;
	
	// Combine waves
	float wave_pattern = (wave1 + wave2 + wave3) / 3.0;
	
	// Add flowing noise
	float noise_val = smooth_noise(screen_uv * 6.0 + time * 0.4);
	wave_pattern = mix(wave_pattern, noise_val, 0.4);
	
	// Create shifting colors
	float hue_base = time * color_shift_speed + wave_pattern * 3.14159;
	vec3 color_effect = vec3(
		sin(hue_base) * 0.5 + 0.5,
		sin(hue_base + 2.094) * 0.5 + 0.5,
		sin(hue_base + 4.188) * 0.5 + 0.5
	);
	
	// Create dynamic mask for interesting patterns
	float mask = smoothstep(0.2, 0.8, wave_pattern);
	mask *= smoothstep(0.1, 0.9, noise_val);
	
	// Pulse effect
	float pulse = (sin(time * 1.8) * 0.3 + 0.7);
	
	// Final color with very low intensity
	vec3 final_color = color_effect * mask * pulse;
	float alpha = intensity * 0.08 * mask;  // Very low alpha
	
	COLOR = vec4(final_color, alpha);
}
"""

func _ready():
	if enable_effect:
		setup_visual_effect()

func setup_visual_effect():
	# Create a simple Node2D for the visual effect only
	background_node = Node2D.new()
	background_node.name = "TrippyEffect"
	background_node.z_index = -1000  # Behind everything
	
	# Add to tree but don't make it a child of anything that handles input
	get_tree().root.add_child.call_deferred(background_node)
	
	# Create the shader
	var shader = Shader.new()
	shader.code = trippy_shader_code
	
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	
	# Apply to this node instead of creating UI
	self.material = shader_material
	
	# Make this node cover a large area but be non-interactive
	self.scale = Vector2(1000, 1000)  # Large scale to cover screen
	
	# Set initial shader parameters
	update_shader_parameters()
	
	print("Pure visual trippy effect applied - no input blocking!")

func update_shader_parameters():
	if shader_material:
		shader_material.set_shader_parameter("intensity", effect_intensity)
		shader_material.set_shader_parameter("time_scale", color_shift_speed)
		shader_material.set_shader_parameter("wave_frequency", wave_frequency)
		shader_material.set_shader_parameter("distortion_strength", distortion_strength)
		shader_material.set_shader_parameter("color_shift_speed", color_shift_speed)

func _process(_delta):
	# Update shader parameters if they've changed
	if shader_material:
		update_shader_parameters()

# Override input functions to make sure this node doesn't handle any input
func _input(_event):
	pass  # Don't handle any input

func _unhandled_input(_event):
	pass  # Don't handle any input

func _gui_input(_event):
	pass  # Don't handle any input

# Public functions to control the effect
func set_effect_intensity(value: float):
	effect_intensity = clamp(value, 0.0, 1.0)
	update_shader_parameters()

func set_color_shift_speed(value: float):
	color_shift_speed = clamp(value, 0.1, 5.0)
	update_shader_parameters()

func set_wave_frequency(value: float):
	wave_frequency = clamp(value, 0.5, 10.0)
	update_shader_parameters()

func set_distortion_strength(value: float):
	distortion_strength = clamp(value, 0.0, 0.1)
	update_shader_parameters()

func toggle_effect():
	enable_effect = !enable_effect
	self.visible = enable_effect

func pulse_effect(duration: float = 2.0, max_intensity: float = 0.6):
	if not shader_material:
		return
	
	var original_intensity = effect_intensity
	var tween = create_tween()
	tween.tween_method(set_effect_intensity, original_intensity, max_intensity, duration * 0.5)
	tween.tween_method(set_effect_intensity, max_intensity, original_intensity, duration * 0.5)

func flash_effect(flash_intensity: float = 0.8, flash_duration: float = 0.3):
	if not shader_material:
		return
	
	var original_intensity = effect_intensity
	var tween = create_tween()
	tween.tween_method(set_effect_intensity, original_intensity, flash_intensity, flash_duration * 0.1)
	tween.tween_method(set_effect_intensity, flash_intensity, original_intensity, flash_duration * 0.9)

# Gentle wave effect
func gentle_wave(duration: float = 4.0):
	if not shader_material:
		return
	
	var original_frequency = wave_frequency
	var tween = create_tween()
	tween.tween_method(set_wave_frequency, original_frequency, original_frequency * 1.8, duration * 0.5)
	tween.tween_method(set_wave_frequency, original_frequency * 1.8, original_frequency, duration * 0.5)

# Subtle color wash
func color_wash(duration: float = 3.0):
	if not shader_material:
		return
	
	var original_speed = color_shift_speed
	var tween = create_tween()
	tween.tween_method(set_color_shift_speed, original_speed, original_speed * 2.2, duration * 0.3)
	tween.tween_method(set_color_shift_speed, original_speed * 2.2, original_speed, duration * 0.7)

# Cleanup
func _exit_tree():
	if background_node and is_instance_valid(background_node):
		background_node.queue_free()

# Preset modes
func subtle_mode():
	set_effect_intensity(0.15)
	set_color_shift_speed(0.8)
	set_wave_frequency(1.2)

func medium_mode():
	set_effect_intensity(0.3)
	set_color_shift_speed(1.5)
	set_wave_frequency(2.0)

func intense_mode():
	set_effect_intensity(0.5)
	set_color_shift_speed(2.2)
	set_wave_frequency(3.5)

# Example usage
func start_level_effect():
	subtle_mode()
	pulse_effect(2.0, 0.4)

func hit_effect():
	flash_effect(0.5, 0.15)

func boss_entrance():
	medium_mode()
	color_wash(4.0)

func power_up_effect():
	gentle_wave(3.0)
