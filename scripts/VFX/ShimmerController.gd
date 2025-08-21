# UniversalShimmer.gd - Works as child of any node type
extends Node

# Simple shimmer effects that work anywhere
@export var grid_width := 20
@export var grid_height := 15
@export var cell_size := Vector2(32, 32)
@export var overlay_position := Vector2.ZERO

var shimmer_canvas: CanvasLayer
var shimmer_rect: ColorRect
var shimmer_material: ShaderMaterial

func _ready():
	_create_shimmer_overlay()
	print("✅ Universal shimmer ready! Press TAB to test effects")

func _create_shimmer_overlay():
	# Create a CanvasLayer that floats above everything
	shimmer_canvas = CanvasLayer.new()
	shimmer_canvas.layer = 10  # Above most UI
	get_tree().root.add_child(shimmer_canvas)
	
	# Create the shimmer rectangle
	shimmer_rect = ColorRect.new()
	shimmer_rect.size = Vector2(grid_width * cell_size.x, grid_height * cell_size.y)
	shimmer_rect.position = overlay_position
	shimmer_rect.color = Color.TRANSPARENT
	shimmer_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shimmer_canvas.add_child(shimmer_rect)
	
	# Try to load shader
	_setup_shader()

func _setup_shader():
	var shader = load("res://shaders/TripPyGridShader.gdshader")
	if shader:
		shimmer_material = ShaderMaterial.new()
		shimmer_material.shader = shader
		
		# Default settings
		shimmer_material.set_shader_parameter("intensity", 1.0)
		shimmer_material.set_shader_parameter("speed", 2.0)
		shimmer_material.set_shader_parameter("effect_type", 0)
		shimmer_material.set_shader_parameter("grid_size", Vector2(grid_width, grid_height))
		shimmer_material.set_shader_parameter("color_shift_enabled", true)
		
		shimmer_rect.material = shimmer_material
		print("✅ Shader loaded successfully!")
	else:
		print("❌ No shader found - using fallback color animation")
		_use_color_fallback()

func _use_color_fallback():
	# Simple color-based shimmer if no shader
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(shimmer_rect, "modulate", Color.RED, 1.0)
	tween.tween_property(shimmer_rect, "modulate", Color.BLUE, 1.0)
	tween.tween_property(shimmer_rect, "modulate", Color.GREEN, 1.0)
	tween.tween_property(shimmer_rect, "modulate", Color.YELLOW, 1.0)

func _input(event):
	if event.is_action_pressed("ui_focus_next"):  # Tab
		if shimmer_material:
			var current_effect = shimmer_material.get_shader_parameter("effect_type")
			var new_effect = (current_effect + 1) % 8
			shimmer_material.set_shader_parameter("effect_type", new_effect)
			print("Effect: ", new_effect)

# Easy drug effect presets
func apply_drug_effect(effect_name: String):
	if not shimmer_material:
		return
	
	match effect_name.to_lower():
		"sober":
			shimmer_rect.visible = false
		"mild":
			shimmer_rect.visible = true
			shimmer_material.set_shader_parameter("effect_type", 2)  # Breathing
			shimmer_material.set_shader_parameter("intensity", 0.5)
		"trippy":
			shimmer_rect.visible = true
			shimmer_material.set_shader_parameter("effect_type", 6)  # Kaleidoscope
			shimmer_material.set_shader_parameter("intensity", 1.5)
		"chaos":
			shimmer_rect.visible = true
			shimmer_material.set_shader_parameter("effect_type", 3)  # Chaos
			shimmer_material.set_shader_parameter("intensity", 2.0)

# Position the overlay
func set_position(pos: Vector2):
	if shimmer_rect:
		shimmer_rect.position = pos

func set_size(size: Vector2):
	if shimmer_rect:
		shimmer_rect.size = size

# Clean up when node is removed
func _exit_tree():
	if shimmer_canvas and is_instance_valid(shimmer_canvas):
		shimmer_canvas.queue_free()
