extends Node

var transition_layer: CanvasLayer
var current_scene_container: Control
var new_scene_container: Control
var transition_duration = 0.5
var is_transitioning = false

func _ready():
	transition_layer = CanvasLayer.new()
	add_child(transition_layer)
	transition_layer.layer = 100 

	current_scene_container = Control.new()
	new_scene_container = Control.new()
	transition_layer.add_child(current_scene_container)
	transition_layer.add_child(new_scene_container)

	current_scene_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	new_scene_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	transition_layer.visible = false

func slide_to_scene(scene_path: String, direction: String = "right"):
	if is_transitioning:
		return
	
	is_transitioning = true
	transition_layer.visible = true

	var current_scene = get_tree().current_scene
	
	var new_scene_resource = load(scene_path)
	var new_scene = new_scene_resource.instantiate()

	get_tree().root.remove_child(current_scene)
	current_scene_container.add_child(current_scene)

	new_scene_container.add_child(new_scene)

	var screen_width = get_viewport().get_visible_rect().size.x
	
	match direction:
		"right":
			current_scene_container.position.x = 0
			new_scene_container.position.x = screen_width
		"left":
			current_scene_container.position.x = 0
			new_scene_container.position.x = -screen_width

	var tween = create_tween()
	tween.set_parallel(true)

	match direction:
		"right":
			tween.tween_property(current_scene_container, "position:x", -screen_width, transition_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(new_scene_container, "position:x", 0, transition_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		"left":
			tween.tween_property(current_scene_container, "position:x", screen_width, transition_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(new_scene_container, "position:x", 0, transition_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	
	_finalize_transition(new_scene, current_scene)

func _finalize_transition(new_scene: Node, old_scene: Node):
	current_scene_container.remove_child(old_scene)
	new_scene_container.remove_child(new_scene)

	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
	old_scene.queue_free()
	
	current_scene_container.position = Vector2.ZERO
	new_scene_container.position = Vector2.ZERO
	
	transition_layer.visible = false
	is_transitioning = false

func go_to_main_menu():
	slide_to_scene("res://scenes/MainMenu.tscn", "left")

func go_to_level_select():
	slide_to_scene("res://scenes/LevelSelect.tscn", "right")

func go_to_level(level_path: String):
	slide_to_scene(level_path, "right")
