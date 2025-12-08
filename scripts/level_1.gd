extends Node2D

# -- ASSIGN THESE IN THE INSPECTOR --
@export var cube_scene: PackedScene
@export var ship_scene: PackedScene
@export var camera: Camera2D 

# Store the current player instance
var current_player: Node2D

func _ready():
	# Find the starting player in the scene
	current_player = $Player # Or whatever your player node is named
	
	# Important: The Camera should NOT be inside the player, 
	# or it will be deleted when we swap!
	if camera:
		camera.position = current_player.position

func _process(delta):
	# Make the camera follow the current player manually
	# (This prevents camera deletion when swapping players)
	if current_player and camera:
		camera.position.x = current_player.position.x
		# Optional: Lock Y or follow Y depending on your game style

# -- THE SWAPPING LOGIC --
func change_gamemode(new_mode: int, spawn_pos: Vector2):
	# 0 = CUBE, 1 = SHIP (Matches the Enum in the portal)
	
	# 1. Don't swap if we are already in that mode!
	# (We check the filename or a custom variable)
	if new_mode == 0 and "Ship" in current_player.name:
		_perform_swap(cube_scene, spawn_pos)
		
	elif new_mode == 1 and not "Ship" in current_player.name:
		_perform_swap(ship_scene, spawn_pos)

func _perform_swap(new_scene: PackedScene, spawn_pos: Vector2):
	# 1. Remove the old player
	current_player.queue_free()
	
	# 2. Spawn the new player
	var new_body = new_scene.instantiate()
	new_body.position = spawn_pos
	new_body.add_to_group("Player") # Ensure it's in the group
	
	# 3. Add to the scene
	add_child(new_body)
	
	# 4. Update reference
	current_player = new_body
	
	print("Swapped Player Model!")
