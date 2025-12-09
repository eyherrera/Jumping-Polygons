extends CanvasLayer

@onready var progress_bar = $Control/ProgressBar
@onready var attempt_label = $Control/AttemptLabel
@onready var pause_btn = $Control/PauseBtn

# We need references to calculate progress
var player: Node2D
var finish_line: Node2D
var level_start_x: float = 0.0

func _ready():
	# 1. Setup Pause Button
	pause_btn.pressed.connect(_on_pause_pressed)
	
	# 2. Show Attempts (From GameManager)
	if GameManager:
		attempt_label.text = "Attempt %d" % GameManager.attempts

	# 3. Find Player and Finish Line automatically
	# We wait one frame to ensure the level has fully loaded
	await get_tree().process_frame
	
	# Find player (assuming they are in the "Player" group or named "Player")
	player = get_tree().get_first_node_in_group("Player")
	if not player:
		# Fallback: Try to find by name in the current scene
		player = get_parent().get_node_or_null("Player")
		
	# Find Finish Line (using the group we set up earlier)
	finish_line = get_tree().get_first_node_in_group("FinishLine")

func _process(_delta):
	# 1. Check if we lost the player (Swapped characters)
	if not is_instance_valid(player):
		# Try to find the new player immediately
		player = get_tree().get_first_node_in_group("Player")

	# 2. Update Progress (Only if we have a valid player)
	if player and finish_line:
		var end_x = finish_line.global_position.x
		var current_x = player.global_position.x
		
		if end_x > 0:
			var percent = (current_x / end_x) * 100
			progress_bar.value = percent

func _on_pause_pressed():
	# Pause the game
	get_tree().paused = true
	
	# OPTIONAL: Spawn a Pause Menu scene here if you have one
	# For now, we assume you might just want to stop the game or show a simple menu.
	# If you want a full menu, we can create a separate "PauseMenu.tscn".
	print("Game Paused")
