extends Control

# References to UI elements
@onready var start_button = $VBoxContainer/StartButton
@onready var options_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var title_label = $VBoxContainer/TitleLabel

func _ready():
	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Optional: Add hover effects
	_setup_button_hover_effects()

func _on_start_pressed():
	# Change to game scene
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
	
func _on_options_pressed():
	# Change to options menu
	get_tree().change_scene_to_file("res://scenes/OptionsMenu.tscn")
	
func _on_quit_pressed():
	# Quit the game
	get_tree().quit()

func _setup_button_hover_effects():
	# Add hover sound effects or visual feedback
	for button in [start_button, options_button, quit_button]:
		button.mouse_entered.connect(_on_button_hover.bind(button))

func _on_button_hover(button: Button):
	# Optional: Play hover sound or add visual effect
	button.modulate = Color(1.2, 1.2, 1.2, 1.0)
	
	# Create a tween for smooth color transition back
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color.WHITE, 0.1)

# Optional: Handle keyboard navigation
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if start_button.has_focus():
			_on_start_pressed()
		elif options_button.has_focus():
			_on_options_pressed()
		elif quit_button.has_focus():
			_on_quit_pressed()
