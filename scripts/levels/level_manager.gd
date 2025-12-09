extends Node2D

## Manages the level state, including player character swapping (Cube/Ship) and camera tracking.

# -- SCENE CONFIGURATION --
@export_group("Scenes")
@export var cube_scene: PackedScene
@export var ship_scene: PackedScene

# -- CAMERA CONFIGURATION --
@export_group("Camera Settings")
@export var camera: Camera2D 
@export var smoothing_speed: float = 5.0

# -- INTERNAL STATE --
var current_player: Node2D

# -- LIFECYCLE --

func _ready():
	# Initialize reference to the starting player node
	current_player = $Player
	
	if current_player:
		print("LEVEL MANAGER: Found initial player: ", current_player.name)
	
	# Setup Camera
	if camera:
		if current_player:
			# Snap immediately to prevent visual drift on start
			camera.position = current_player.position
		
		# Enforce smoothing settings via code
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = smoothing_speed

func _process(_delta):
	# Manually update camera position to track the player
	if current_player and camera:
		camera.position = current_player.position

# -- PUBLIC METHODS --

## Called by portals to switch the player character mode.
func change_gamemode(new_mode: int, spawn_pos: Vector2):
	print("\n--- PORTAL TRIGGERED ---")
	
	if not current_player:
		return

	# Determine current state by name to prevent redundant swaps
	var is_currently_ship = "Ship" in current_player.name

	# 0 = CUBE
	if new_mode == 0:
		if is_currently_ship:
			_perform_swap(cube_scene, spawn_pos)
		
	# 1 = SHIP
	elif new_mode == 1:
		if not is_currently_ship:
			_perform_swap(ship_scene, spawn_pos)

# -- PRIVATE METHODS --

func _perform_swap(new_scene: PackedScene, spawn_pos: Vector2):
	if not new_scene:
		printerr("CRITICAL ERROR: Assign scenes in the LevelManager Inspector!")
		return

	# 1. Remove the old player
	current_player.queue_free()
	
	# 2. Instantiate the new player model
	var new_body = new_scene.instantiate()
	new_body.position = spawn_pos
	new_body.add_to_group("Player")
	
	# 3. Add to the scene safely on the main thread
	call_deferred("add_child", new_body)
	
	# 4. Update the reference for the camera to follow
	current_player = new_body
	print("Swapped Player Model!")
