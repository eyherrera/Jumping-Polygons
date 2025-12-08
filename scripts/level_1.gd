extends Node2D

# -- ASSIGN THESE IN THE INSPECTOR --
@export var cube_scene: PackedScene
@export var ship_scene: PackedScene
@export var camera: Camera2D 

# Store the current player instance
var current_player: Node2D

func _ready():
	# Find the starting player in the scene
	current_player = $Player
	
	if current_player:
		print("LEVEL MANAGER: Found initial player: ", current_player.name)
	else:
		printerr("LEVEL MANAGER CRITICAL ERROR: Could not find node named 'Player' in the scene tree!")

	# Important: The Camera should NOT be inside the player
	if camera and current_player:
		camera.position = current_player.position

func _process(delta):
	# Make the camera follow the current player manually
	if current_player and camera:
		camera.position.x = current_player.position.x

# -- THE SWAPPING LOGIC --
func change_gamemode(new_mode: int, spawn_pos: Vector2):
	print("\n--- PORTAL TRIGGERED ---")
	print("Requesting Mode: ", new_mode, " (0 = Cube, 1 = Ship)")
	
	if not current_player:
		printerr("ERROR: current_player variable is null! Cannot swap.")
		return

	print("Current Player Name is: '", current_player.name, "'")

	# Logic check
	var is_currently_ship = "Ship" in current_player.name
	print("Is currently Ship? ", is_currently_ship)

	# 0 = CUBE
	if new_mode == 0:
		if is_currently_ship:
			print("Match found! Swapping to CUBE scene...")
			_perform_swap(cube_scene, spawn_pos)
		else:
			print("Ignored: Requested Cube, but we are NOT a Ship (already Cube?).")
		
	# 1 = SHIP
	elif new_mode == 1:
		if not is_currently_ship:
			print("Match found! Swapping to SHIP scene...")
			_perform_swap(ship_scene, spawn_pos)
		else:
			print("Ignored: Requested Ship, but we ARE already a Ship.")

func _perform_swap(new_scene: PackedScene, spawn_pos: Vector2):
	if not new_scene:
		printerr("CRITICAL ERROR: The 'cube_scene' or 'ship_scene' slot is EMPTY in the Inspector!")
		return

	print("Spawning new body...")
	
	# 1. Remove the old player
	current_player.queue_free()
	
	# 2. Spawn the new player
	var new_body = new_scene.instantiate()
	new_body.position = spawn_pos
	new_body.add_to_group("Player")
	
	# 3. Add to the scene
	call_deferred("add_child", new_body)
	
	# 4. Update reference immediately (so camera doesn't break next frame)
	current_player = new_body
	
	print("Swap SUCCESS! New player created.")
