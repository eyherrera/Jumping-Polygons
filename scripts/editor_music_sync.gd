@tool
extends Node2D

# -- CONFIGURATION --
# Set this to MATCH your player script exactly!
@export var player_speed: float = 200.0 

# Drag your AudioStreamPlayer node here in the inspector
@export var music_player: AudioStreamPlayer

# -- EDITOR CONTROLS --
# Clicking this checkbox in the Inspector starts the preview
@export var preview_active: bool = false:
	set(value):
		preview_active = value
		if preview_active:
			start_preview()
		else:
			stop_preview()

# -- INTERNAL VARIABLES --
var preview_timer: float = 0.0
var is_running: bool = false

func _ready():
	# Stop the tool from running automatically when the game starts normally
	if not Engine.is_editor_hint():
		queue_free()

func _process(delta):
	# Only run logic if we are in the editor and the "switch" is on
	if Engine.is_editor_hint() and is_running:
		preview_timer += delta
		
		# If the music stops (song ended), stop the preview
		if music_player and not music_player.playing:
			preview_active = false # This triggers the setter to stop
			
		# Force a redraw every frame to animate the line
		queue_redraw()

func _draw():
	# 1. Draw the "Start Marker" (Static Line)
	# This shows where the music will start from (the node's position)
	draw_line(Vector2(0, -1000), Vector2(0, 1000), Color.GREEN, 2.0)
	
	# 2. Draw the "Play Head" (Moving Line)
	if is_running:
		# Calculate how far the player would have moved by now
		var distance_traveled = preview_timer * player_speed
		var end_pos_x = distance_traveled
		
		# Draw a red line moving forward
		draw_line(Vector2(end_pos_x, -1000), Vector2(end_pos_x, 1000), Color.RED, 2.0)
		
		# Optional: Draw a ghost box representing the player
		draw_rect(Rect2(end_pos_x, -16, 32, 32), Color(1, 0, 0, 0.3))

func start_preview():
	if not music_player:
		print("ERROR: Assign the MusicPlayer node in the Inspector!")
		preview_active = false
		return
	
	# 1. Calculate the timestamp based on X position
	# Time = Distance / Speed
	var start_time = global_position.x / player_speed
	
	# 2. Start the music
	# We use max(0, ...) to prevent crashing if you drag it behind the start line
	music_player.play(max(0.0, start_time))
	
	# 3. Start the visualizer
	preview_timer = 0.0
	is_running = true
	print("Previewing music from: ", start_time, "s")

func stop_preview():
	if music_player:
		music_player.stop()
	
	is_running = false
	preview_timer = 0.0
	queue_redraw() # Redraw one last time to reset lines
