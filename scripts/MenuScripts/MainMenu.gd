extends Control

# References to UI elements - these might be null if paths are wrong
@onready var start_button = get_node_or_null("VBoxContainer/StartButton")
@onready var options_button = get_node_or_null("VBoxContainer/SettingsButton")
@onready var quit_button = get_node_or_null("VBoxContainer/QuitButton")
@onready var title_label = get_node_or_null("VBoxContainer/TitleLabel")

func _ready():
	print("=== MAIN MENU DEBUG ===")
	_debug_scene_structure()
	_connect_buttons_safely()

func _debug_scene_structure():
	print("Checking button paths:")
	print("  Start button: ", start_button)
	print("  Options button: ", options_button) 
	print("  Quit button: ", quit_button)
	print("  Title label: ", title_label)
	
	print("All children in scene:")
	_print_children(self, 0)

func _print_children(node: Node, depth: int):
	var indent = ""
	for i in range(depth):
		indent += "  "
	print(indent + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		_print_children(child, depth + 1)

func _connect_buttons_safely():
	# Connect buttons only if they exist
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
		print("✅ Start button connected")
	else:
		print("❌ Start button not found")
	
	if options_button:
		options_button.pressed.connect(_on_options_pressed)
		print("✅ Options button connected")
	else:
		print("❌ Options button not found")
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		print("✅ Quit button connected")
	else:
		print("❌ Quit button not found")
	
	# Try to find buttons with different names/paths
	_try_alternative_paths()
	
	# Set up hover effects for found buttons
	_setup_button_hover_effects()

func _try_alternative_paths():
	# Try common alternative button paths
	var alternative_paths = [
		"StartButton",
		"SettingsButton", 
		"QuitButton",
		"PlayButton",
		"OptionsButton",
		"ExitButton"
	]
	
	for path in alternative_paths:
		var button = get_node_or_null(path)
		if button and button is Button:
			print("Found alternative button: ", path)
			if not button.pressed.is_connected(_on_any_button_pressed):
				button.pressed.connect(_on_any_button_pressed.bind(button))

func _on_any_button_pressed(button: Button):
	print("Alternative button pressed: ", button.name)
	var button_text = button.text.to_lower()
	var button_name = button.name.to_lower()
	
	if "start" in button_text or "play" in button_text or "start" in button_name:
		_on_start_pressed()
	elif "settings" in button_text or "options" in button_text or "settings" in button_name or "options" in button_name:
		_on_options_pressed()
	elif "quit" in button_text or "exit" in button_text or "quit" in button_name or "exit" in button_name:
		_on_quit_pressed()

func _on_start_pressed():
	print("Start button functionality")
	# Use simple scene change for now to test
	get_tree().change_scene_to_file("res://scenes/meta/levelMenu.tscn")
	
func _on_options_pressed():
	print("Options button functionality")
	# Create a simple options scene if it doesn't exist
	if ResourceLoader.exists("res://scenes/OptionsMenu.tscn"):
		get_tree().change_scene_to_file("res://scenes/OptionsMenu.tscn")
	else:
		print("Options menu not found, staying in main menu")
	
func _on_quit_pressed():
	print("Quit button functionality")
	get_tree().quit()

func _setup_button_hover_effects():
	# Add hover effects for any buttons that exist
	var buttons = [start_button, options_button, quit_button]
	for button in buttons:
		if button:
			button.mouse_entered.connect(_on_button_hover.bind(button))
			button.mouse_exited.connect(_on_button_exit.bind(button))

func _on_button_hover(button: Button):
	if button:
		var tween = create_tween()
		tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.1)

func _on_button_exit(button: Button):
	if button:
		var tween = create_tween()
		tween.tween_property(button, "modulate", Color.WHITE, 0.1)

# Handle keyboard navigation
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if start_button and start_button.has_focus():
			_on_start_pressed()
		elif options_button and options_button.has_focus():
			_on_options_pressed()
		elif quit_button and quit_button.has_focus():
			_on_quit_pressed()
