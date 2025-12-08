extends CharacterBody2D

# -- SETTINGS --
@export var speed = 200.0           # Constant forward speed
@export var jump_force = -350.0     # Negative y is "up" in Godot
@export var gravity = 2000.0        # High gravity feels snappier for this genre
@export var rotation_speed = 3.0    # Visual rotation speed

# Get access to the visual sprite to rotate it
@onready var sprite = $Sprite2D

func _ready():
	# CRITICAL FIX: 
	# Ensure the HazardDetector can actually "see" the World layer (walls) 
	# to trigger death, not just the Deadly layer (spikes).
	# Layer 1 (World) = 1, Layer 3 (Deadly) = 4. Sum = 5.
	$HazardDetector.collision_mask = 5

func _physics_process(delta):
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		# Visual: Rotate cube when in air
		sprite.rotation += rotation_speed * delta
	else:
		# Visual: Reset rotation explicitly when on ground
		sprite.rotation = 0

	# 2. Auto-Run (Always move right)
	velocity.x = speed

	# 3. Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# 4. Move
	# NOTE: For the player to NOT stop on walls, your TileSet collisions
	# must be set to "One Way Collision = On". 
	# This allows the Big Square to clip into walls (horizontal pass-through)
	# but still land on top of them.
	move_and_slide()
	
	# REMOVED: Wall Collision Check
	# We rely entirely on HazardDetector clipping into the wall to kill us.

# Helper function to restart level
func die():
	print("Dead!") # Debug message
	get_tree().reload_current_scene()

func _on_hazard_detector_body_entered(body: Node2D) -> void:
	# This will now trigger for both Spikes (Deadly) AND Walls (World)
	# provided the HazardDetector mask includes Layer 1.
	die()
