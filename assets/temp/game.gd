extends Node2D

@onready var grid = $Control/GridContainer
@onready var button_1= $Control/GridContainer/TextureButton1
@onready var button_2= $Control/GridContainer/TextureButton2
@onready var button_3= $Control/GridContainer/TextureButton3
@onready var button_4= $Control/GridContainer/TextureButton4
@onready var button_5= $Control/GridContainer/TextureButton5
@onready var button_6= $Control/GridContainer/TextureButton6
@onready var button_7= $Control/GridContainer/TextureButton7
@onready var button_8= $Control/GridContainer/TextureButton8
@onready var empty_tile_button= $Control/GridContainer/TextureButton9
@onready var moves_label = $Control/MovesLabel
@onready var time_label = $Control/TimeLabel
@onready var start_btn = $Control/StartBtn
@onready var win_overlay = $Control/WinOverlay
@onready var click_snd = $ClickSnd
@onready var win_snd = $WinSnd

const GRID_SIZE = 3
var tiles = []

# Start with the empty tile in the bottom-right
var empty_tile = Vector2i(GRID_SIZE - 1, GRID_SIZE - 1)  

var is_game_started = false
var is_game_finished = false
var moves = 0
var time = 0
var formatted_time = 0

func _ready() -> void:
	$Control/BlackOverlay.visible = false
	time_label.visible = false
	moves_label.visible = false
	setup_board()
	
func _process(delta: float) -> void:
	# Time
	if !is_game_finished and is_game_started:
		time += delta
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	formatted_time = "%02d:%02d" % [minutes, seconds]
	time_label.text = str(formatted_time)

	# Moves count
	moves_label.text = "Moves: " + str(moves)
	
func setup_board():
	tiles.clear()
	var buttons = [button_1, button_2, button_3, button_4, button_5, button_6, button_7, button_8, empty_tile_button]
	
	# Place tiles in fixed order (1 to 8)
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var index = y * GRID_SIZE + x
			tiles.append(buttons[index])

	update_grid_visual()
	
func shuffle_board():
	var rng = RandomNumberGenerator.new()
	var tile_values = [1, 2, 3, 4, 5, 6, 7, 8, 0]
	tile_values.shuffle()
	
	# Ensure the puzzle is solvable
	while !is_solvable(tile_values):
		tile_values.shuffle()
		
	# Rebuild the tiles array with the shuffled values
	tiles.clear()
	for i in range(tile_values.size()):
		if tile_values[i] == 0:
			tiles.append(empty_tile_button)
			empty_tile = Vector2i(i % GRID_SIZE, i / GRID_SIZE)
		else:
			tiles.append(get_node("Control/GridContainer/TextureButton" + str(tile_values[i])))
	
	update_grid_visual()
		
# Solvability check function
func is_solvable(arr) -> bool:
	var inversions = 0
	for i in range(arr.size()):
		for j in range(i + 1, arr.size()):
			if arr[i] != 0 and arr[j] != 0 and arr[i] > arr[j]:
				inversions += 1

	# For a 3x3 grid, puzzle is solvable if inversions count is even
	return inversions % 2 == 0
	
func handle_tile_press(button: TextureButton) -> void:
	var tile_index = tiles.find(button)
	# Ignore if button is not found
	if tile_index == -1:
		return 
		
	var x = tile_index % GRID_SIZE
	var y = tile_index / GRID_SIZE
	var pos = Vector2i(x, y)
	
	# Move only if adjacent and if win condition is not achieved
	if !is_game_finished and is_game_started:
		if pos.distance_to(empty_tile) == 1: 
			moves += 1
			move_tile(pos)
			check_win_condition()
	
func move_tile(tile_pos):
	click_snd.play()
	var tile_index = tile_pos.y * GRID_SIZE + tile_pos.x
	var empty_index = empty_tile.y * GRID_SIZE + empty_tile.x
	
	# Swap references in the array
	var moving_tile = tiles[tile_index]
	
	# The old tile position becomes empty
	tiles[tile_index] = empty_tile_button   
	
	# Move the tile to the empty position
	tiles[empty_index] = moving_tile  

	grid.move_child(moving_tile, empty_index)	
	grid.move_child(empty_tile_button, tile_index)
	
	# Update empty tile position
	empty_tile = tile_pos

func update_grid_visual():
	for i in range(GRID_SIZE * GRID_SIZE):
		grid.move_child(tiles[i], i)

func check_win_condition():
	var correct_order = [button_1, button_2, button_3, button_4, button_5, button_6, button_7, button_8, empty_tile_button]
	# Compare current tile arrangement with the correct order
	if tiles == correct_order and !is_game_finished:
		# If all tiles are in order, player wins
		win_snd.play()
		is_game_finished = true
		is_game_started = false
		win_overlay.visible = true
		moves_label.visible = false
		time_label.visible = false
		$Control/BlackOverlay.visible = false
		$Control/WinOverlay/WinTimeLabel.text = "Time: " + str(formatted_time)
		$Control/WinOverlay/WinMovesLabel.text = "Moves: " + str(moves)
		
		# debug
		print("You win!")
		print("Your time was:", formatted_time)
		print("Moves used:", moves)

func _on_texture_button_8_pressed() -> void:
	handle_tile_press(button_8)

func _on_texture_button_7_pressed() -> void:
	handle_tile_press(button_7)

func _on_texture_button_6_pressed() -> void:
	handle_tile_press(button_6)
	
func _on_texture_button_5_pressed() -> void:
	handle_tile_press(button_5)

func _on_texture_button_4_pressed() -> void:
	handle_tile_press(button_4)

func _on_texture_button_3_pressed() -> void:
	handle_tile_press(button_3)

func _on_texture_button_2_pressed() -> void:
	handle_tile_press(button_2)

func _on_texture_button_1_pressed() -> void:
	handle_tile_press(button_1)

func _on_shuffle_pressed() -> void:
	# reset time and moves
	time = 0
	moves = 0
	
	click_snd.play()
	empty_tile_button.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	win_overlay.visible = false
	moves_label.visible = true
	time_label.visible = true
	$Control/BlackOverlay.visible = true
	if win_snd.is_playing():
		win_snd.stop()
	setup_board()

func _on_start_btn_pressed() -> void:
	# reset time and moves
	click_snd.play()
	time = 0
	moves = 0
	
	empty_tile_button.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	empty_tile_button.disabled = true
	win_overlay.visible = false
	moves_label.visible = true
	time_label.visible = true
	$Control/BlackOverlay.visible = true
	shuffle_board()
	is_game_finished = false
	is_game_started = true
