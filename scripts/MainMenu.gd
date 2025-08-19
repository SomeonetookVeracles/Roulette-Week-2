extends Control
@onready var start_button = $VBoxContainer/StartButton
@onready var options_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var title_label = $VBoxContainer/TitleLabel
func _ready():
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_setup_button_hover_effects()
func _on_start_pressed():
	SceneTransition.slide_to_scene("res://scenes/meta/levelMenu.tscn", "right")
func _on_options_pressed():
	SceneTransition.slide_to_scene("res://scenes/OptionsMenu.tscn", "down")
func _on_quit_pressed():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	await tween.finished
	get_tree().quit()
func _setup_button_hover_effects():
	for button in [start_button, options_button, quit_button]:
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_exit.bind(button))
func _on_button_hover(button: Button):
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.1)
func _on_button_exit(button: Button):
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color.WHITE, 0.1)
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if start_button.has_focus():
			_on_start_pressed()
		elif options_button.has_focus():
			_on_options_pressed()
		elif quit_button.has_focus():
			_on_quit_pressed()
