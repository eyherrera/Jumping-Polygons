extends CharacterBody2D

# -- CONFIGURATION --
@export var forward_speed: float = 200.0
@export var upward_thrust: float = 1500.0 
@export var ship_gravity: float = 1000.0 
@export var max_fall_speed: float = 600.0
@export var max_rise_speed: float = 600.0
@export var rotation_sensitivity: float = 0.10

# Reference the Sprite to rotate it independently of the physics box
# This prevents the hitbox from tilting and snagging on ceilings
@onready var sprite = $Sprite2D
@onready var wall_detector = $WallDetector
@onready var spike_detector = $SpikeDetector
@export var game_over_scene: PackedScene = preload("res://scenes/ui/game_over_layer.tscn")

func _ready():
	# 1. Setup Wall Detector (Small Box -> World Layer)
	# Only triggers death if the ship crashes DEEP into a wall (past the main collider)
	if wall_detector:
		wall_detector.body_entered.connect(_on_hazard_entered)
		# Ensure it specifically detects World (Layer 1)
		wall_detector.collision_mask = 1 
	else:
		printerr("Ship missing 'WallDetector' child node!")

	# 2. Setup Spike Detector (Big Box -> Deadly Layer)
	# Kills immediately if touching a spike (Layer 3/Value 4)
	if spike_detector:
		spike_detector.body_entered.connect(_on_hazard_entered)
		# Ensure it specifically detects Deadly (Layer 3 - usually bit value 4)
		spike_detector.collision_mask = 4 
	else:
		printerr("Ship missing 'SpikeDetector' child node!")

func _physics_process(delta):
	# 1. Constant Forward Movement
	velocity.x = forward_speed
	
	# 2. Vertical Movement (The Ship Logic)
	if Input.is_action_pressed("jump"):
		velocity.y -= upward_thrust * delta
	else:
		velocity.y += ship_gravity * delta
	
	# 3. Clamp Velocity
	velocity.y = clamp(velocity.y, -max_rise_speed, max_fall_speed)
	
	# 4. Move
	# The Main CollisionShape (16x16) handles sliding on floors/ceilings.
	# Because we are NOT rotating the body, it will slide smoothly.
	move_and_slide()
	
	# 5. Visual Flair - Rotate ONLY the sprite
	# We use the sprite's rotation property, keeping the physics box flat.
	if sprite:
		var target_rotation = velocity.y * rotation_sensitivity * delta
		sprite.rotation = lerp_angle(sprite.rotation, target_rotation, 10 * delta)

# -- DEATH LOGIC --
func die():
	print("Dead!")
	
	# 1. Update Global Counter
	if GameManager:
		GameManager.add_attempt()
	
	# 2. Stop Music
	# We assume the AudioStreamPlayer is a sibling named "AudioStreamPlayer" in the level
	var music = get_parent().get_node_or_null("AudioStreamPlayer")
	if music:
		music.stop()

	# 3. Calculate Progress
	var percent = 0
	var finish_node = get_tree().get_first_node_in_group("FinishLine")
	
	if finish_node:
		var start_x = 0.0 # Assuming level starts at 0
		var end_x = finish_node.global_position.x
		var current_x = global_position.x
		
		if end_x > 0:
			percent = int((current_x / end_x) * 100)
			percent = clamp(percent, 0, 99) # Cap at 99% if we died
	
	# 4. Show Game Over Screen
	if game_over_scene:
		var go_screen = game_over_scene.instantiate()
		get_tree().root.add_child(go_screen)
		go_screen.set_stats(percent)
		
		# 5. Pause Game
		get_tree().paused = true
	else:
		# Fallback if no screen assigned
		get_tree().reload_current_scene()

func _on_hazard_entered(_body):
	# This triggers if WallDetector hits a Wall OR SpikeDetector hits a Spike
	die()
