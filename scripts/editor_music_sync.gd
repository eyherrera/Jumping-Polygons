@tool
extends Node2D

## Editor tool to visualize music synchronization against player movement.
## It projects where the player will be based on the music timestamp.

# -- CONFIGURATION --

## The speed of the player in pixels per second. 
## Ensure this matches the value in your player controller.
@export var player_speed: float = 200.0 

## Reference to the AudioStreamPlayer containing the level music.
@export var music_player: AudioStreamPlayer

# -- EDITOR CONTROLS --

## Toggle to start/stop the preview simulation.
@export var preview_active: bool = false:
	set(value):
		preview_active = value
		if preview_active:
			start_preview()
		else:
			stop_preview()

# -- INTERNAL STATE --
var preview_timer: float = 0.0
var is_running: bool = false

# -- LIFECYCLE --

func _ready():
	# Ensure this tool cleans itself up in a real game build.
	if not Engine.is_editor_hint():
		queue_free()

func _process(delta):
	# Only run logic if in editor and preview is toggled on.
	if Engine.is_editor_hint() and is_running:
		preview_timer += delta
		
		# Auto-stop if the song finishes.
		if music_player and not music_player.playing:
			preview_active = false 
			
		# Request redraw to animate the play head line.
		queue_redraw()

func _draw():
	# Draw the "Start Marker" (Static Green Line) at this node's position.
	draw_line(Vector2(0, -1000), Vector2(0, 1000), Color.GREEN, 2.0)
	
	# Draw the "Play Head" (Moving Red Line).
	if is_running:
		var distance_traveled = preview_timer * player_speed
		
		# Draw the moving time line.
		draw_line(Vector2(distance_traveled, -1000), Vector2(distance_traveled, 1000), Color.RED, 2.0)
		
		# Draw a ghost representation of the player.
		draw_rect(Rect2(distance_traveled, -16, 32, 32), Color(1, 0, 0, 0.3))

# -- LOGIC --

func start_preview():
	if not music_player:
		print("ERROR: Assign the MusicPlayer node in the Inspector!")
		preview_active = false
		return
	
	# Calculate start timestamp: Time = Distance / Speed
	# This allows you to drag the tool to a specific X position to preview that part of the song.
	var start_time = global_position.x / player_speed
	
	music_player.play(max(0.0, start_time))
	
	preview_timer = 0.0
	is_running = true
	print("Previewing music from: ", start_time, "s")

func stop_preview():
	if music_player:
		music_player.stop()
	
	is_running = false
	preview_timer = 0.0
	queue_redraw()
