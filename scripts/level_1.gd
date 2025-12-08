extends Node2D

# -- ASSIGN THESE IN THE INSPECTOR --
@export var cube_scene: PackedScene
@export var ship_scene: PackedScene
@export var camera: Camera2D 
@export var attempt_label: Label

# -- SETTINGS --
@export var smoothing_speed: float = 5.0

# Store the current player instance
var current_player: Node2D

func _ready():
	# 1. Update the Attempt Counter UI
	if attempt_label:
		# Use the global GameManager to get the current count
		attempt_label.text = "Attempt %d" % GameManager.attempts
	
	# 2. Find the starting player in the scene
	current_player = $Player
	
	if current_player:
		print("LEVEL MANAGER: Found initial player: ", current_player.name)
	
	# -- CAMERA SETUP --
	if camera:
		if current_player:
			# Teleport camera to player immediately (so we don't drift from 0,0 at start)
			camera.position = current_player.position
		
		# Enable smoothing via code so you don't have to hunt for it in Inspector
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = smoothing_speed

func _process(delta):
	# Follow the player on BOTH axes now
	if current_player and camera:
		camera.position = current_player.position

# -- THE SWAPPING LOGIC --
func change_gamemode(new_mode: int, spawn_pos: Vector2):
	print("\n--- PORTAL TRIGGERED ---")
	
	if not current_player:
		return

	# Logic check to prevent redundant swaps
	var is_currently_ship = "Ship" in current_player.name

	# 0 = CUBE
	if new_mode == 0:
		if is_currently_ship:
			_perform_swap(cube_scene, spawn_pos)
		
	# 1 = SHIP
	elif new_mode == 1:
		if not is_currently_ship:
			_perform_swap(ship_scene, spawn_pos)

func _perform_swap(new_scene: PackedScene, spawn_pos: Vector2):
	if not new_scene:
		printerr("CRITICAL ERROR: Assign scenes in the Inspector!")
		return

	# 1. Remove the old player
	current_player.queue_free()
	
	# 2. Spawn the new player
	var new_body = new_scene.instantiate()
	new_body.position = spawn_pos
	new_body.add_to_group("Player")
	
	# 3. Add to the scene
	call_deferred("add_child", new_body)
	
	# 4. Update reference
	current_player = new_body
	print("Swapped Player Model!")
