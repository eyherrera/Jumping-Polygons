extends CanvasLayer

## Manages the in-game HUD, including the progress bar, attempt counter, and pause menu triggering.

# -- UI REFERENCES --
@onready var progress_bar: ProgressBar = $Control/ProgressBar
@onready var attempt_label: Label = $Control/AttemptLabel
@onready var pause_btn: Button = $Control/PauseBtn

# -- CONFIGURATION --
@export var pause_menu_scene: PackedScene

# -- STATE --
var player: Node2D
var finish_line: Node2D
var level_start_x: float = 0.0

# -- LIFECYCLE --

func _ready():
	pause_btn.pressed.connect(_on_pause_pressed)
	
	if GameManager:
		attempt_label.text = "Attempt %d" % GameManager.attempts

	# Wait one frame to ensure all level nodes are fully initialized before searching.
	await get_tree().process_frame
	_find_level_objects()

func _process(_delta):
	# Handle dynamic character swapping (Cube -> Ship, etc.)
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player")

	# Update progress bar
	if player and finish_line:
		var end_x = finish_line.global_position.x
		var current_x = player.global_position.x
		
		# Calculate percentage based on X position relative to the finish line
		if end_x > 0:
			var percent = (current_x / end_x) * 100
			progress_bar.value = percent

# -- PRIVATE METHODS --

func _find_level_objects():
	# Priority 1: Find by Group
	player = get_tree().get_first_node_in_group("Player")
	
	# Priority 2: Fallback to finding by name in the parent scene
	if not player:
		player = get_parent().get_node_or_null("Player")
		
	finish_line = get_tree().get_first_node_in_group("FinishLine")

func _on_pause_pressed():
	get_tree().paused = true
	
	# Manually pause the level music if found in the parent scene
	var music = get_parent().get_node_or_null("AudioStreamPlayer")
	if music:
		music.stream_paused = true
	
	visible = false 
	
	if pause_menu_scene:
		var pause_menu = pause_menu_scene.instantiate()
		get_tree().root.add_child(pause_menu)
		
		# Pass the current progress to the pause menu so it can display the percentage
		if pause_menu.has_method("set_stats"):
			pause_menu.set_stats(int(progress_bar.value))
	else:
		printerr("ERROR: Pause Menu Scene is not assigned in the HUD Inspector.")
