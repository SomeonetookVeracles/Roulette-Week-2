extends Control

func _ready():
	print("Level menu loaded")
	_connect_buttons()

func _connect_buttons():
	var buttons = _find_all_buttons(self)
	
	for button in buttons:
		if not button.pressed.is_connected(_on_button_pressed):
			button.pressed.connect(_on_button_pressed.bind(button))
			print("Connected button: ", button.name)

func _find_all_buttons(node: Node) -> Array:
	var buttons = []
	if node is Button:
		buttons.append(node)
	for child in node.get_children():
		buttons.append_array(_find_all_buttons(child))
	return buttons

func _on_button_pressed(button: Button):
	print("Button pressed: ", button.name)
	
	if "back" in button.name.to_lower():
		_go_to_main_menu()
	elif "1" in button.name or "tutorial" in button.name.to_lower():
		_go_to_tutorial()
	elif "2" in button.name:
		_go_to_level("Level2")
	elif "3" in button.name:
		_go_to_level("Level3")
	elif "4" in button.name:
		_go_to_level("Level4")
	elif "5" in button.name:
		_go_to_level("Level5")
	else:
		print("Unknown button, going to main menu")
		_go_to_main_menu()

func _go_to_main_menu():
	print("Going to main menu")
	get_tree().change_scene_to_file("res://scenes/meta/MainMenu.tscn")

func _go_to_tutorial():
	print("Going to tutorial")
	if ResourceLoader.exists("res://scenes/levels/Tutorial.tscn"):
		get_tree().change_scene_to_file("res://scenes/levels/Tutorial.tscn")
	else:
		print("Tutorial scene not found, creating empty scene")
		var tutorial_scene = PackedScene.new()
		var tutorial_root = Control.new()
		tutorial_root.name = "Tutorial"
		
		var label = Label.new()
		label.text = "Tutorial Scene\n\nPress ESC to go back to main menu"
		label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		tutorial_root.add_child(label)
		
		get_tree().root.add_child(tutorial_root)
		get_tree().current_scene.queue_free()
		get_tree().current_scene = tutorial_root

func _go_to_level(level_name: String):
	print("Going to level: ", level_name)
	var level_path = "res://scenes/levels/" + level_name + ".tscn"
	
	if ResourceLoader.exists(level_path):
		get_tree().change_scene_to_file(level_path)
	else:
		print("Level not found: ", level_path)
		print("Creating placeholder level")
		var level_scene = Control.new()
		level_scene.name = level_name
		
		var label = Label.new()
		label.text = level_name + " Scene\n\nPress ESC to go back to level select"
		label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		level_scene.add_child(label)
		
		get_tree().root.add_child(level_scene)
		get_tree().current_scene.queue_free()
		get_tree().current_scene = level_scene
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_go_to_main_menu()
