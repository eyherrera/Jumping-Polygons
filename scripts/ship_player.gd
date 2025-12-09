extends CharacterBody2D

## Ship Controller for the "Fly" game mode.
## Handles thrust-based vertical movement (hold to fly up, release to fall).

# -- MOVEMENT SETTINGS --
@export_group("Movement")
@export var forward_speed: float = 200.0
@export var upward_thrust: float = 1500.0 
@export var ship_gravity: float = 1000.0 
@export var max_fall_speed: float = 600.0
@export var max_rise_speed: float = 600.0

# -- VISUAL SETTINGS --
@export_group("Visuals")
@export var rotation_sensitivity: float = 0.10

# -- DEPENDENCIES --
@export_group("Dependencies")
@export var game_over_scene: PackedScene = preload("res://scenes/ui/game_over_layer.tscn")

# -- NODES --
# We reference the Sprite specifically to rotate it independently of the collision box.
@onready var sprite: Sprite2D = $Sprite2D
@onready var wall_detector: Area2D = $WallDetector
@onready var spike_detector: Area2D = $SpikeDetector

# -- LIFECYCLE --

func _ready():
	# Setup Wall Detector (Detects Layer 1: World)
	if wall_detector:
		wall_detector.collision_mask = 1 
		if not wall_detector.body_entered.is_connected(_on_hazard_entered):
			wall_detector.body_entered.connect(_on_hazard_entered)
	else:
		printerr("WARNING: Ship is missing 'WallDetector' child node!")

	# Setup Spike Detector (Detects Layer 3: Deadly)
	if spike_detector:
		spike_detector.collision_mask = 4 
		if not spike_detector.body_entered.is_connected(_on_hazard_entered):
			spike_detector.body_entered.connect(_on_hazard_entered)
	else:
		printerr("WARNING: Ship is missing 'SpikeDetector' child node!")

func _physics_process(delta):
	# 1. Constant Forward Movement
	velocity.x = forward_speed
	
	# 2. Vertical Movement
	# Holding jump subtracts Y (Go Up), releasing adds Y (Gravity Down)
	if Input.is_action_pressed("jump"):
		velocity.y -= upward_thrust * delta
	else:
		velocity.y += ship_gravity * delta
	
	# 3. Clamp Vertical Speed
	# Prevents the ship from accelerating infinitely up or down
	velocity.y = clamp(velocity.y, -max_rise_speed, max_fall_speed)
	
	# 4. Apply Movement
	# We rely on the rectangular CollisionShape2D (sliding) rather than rotation
	move_and_slide()
	
	# 5. Visual Flair
	_handle_visual_rotation(delta)

# -- HELPER METHODS --

func _handle_visual_rotation(delta: float):
	if sprite:
		# Rotate the sprite based on vertical velocity.
		# Note: The physical hitbox stays flat to prevent snagging on ceilings.
		var target_rotation = velocity.y * rotation_sensitivity * delta
		sprite.rotation = lerp_angle(sprite.rotation, target_rotation, 10 * delta)

func _on_hazard_entered(_body):
	die()

func die():
	print("Ship Crashed!")
	AudioManager.play_death()
	
	# Update Global Stats
	if GameManager:
		GameManager.add_attempt()
	
	# Stop Music
	var music = get_parent().get_node_or_null("AudioStreamPlayer")
	if music:
		music.stop()

	# Calculate Progress %
	var percent = 0
	var finish_node = get_tree().get_first_node_in_group("FinishLine")
	
	if finish_node:
		var end_x = finish_node.global_position.x
		var current_x = global_position.x
		
		if end_x > 0:
			percent = int((current_x / end_x) * 100)
			percent = clamp(percent, 0, 99) 
	
	# Instantiate Game Over Screen
	if game_over_scene:
		var go_screen = game_over_scene.instantiate()
		get_tree().root.add_child(go_screen)
		go_screen.set_stats(percent)
		
		get_tree().paused = true
	else:
		get_tree().reload_current_scene()
