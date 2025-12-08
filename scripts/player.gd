extends CharacterBody2D

# -- SETTINGS --
@export var speed = 200.0           # Constant forward speed
@export var jump_force = -350.0     # Negative y is "up" in Godot
@export var gravity = 2000.0        # High gravity feels snappier for this genre
@export var rotation_speed = 6.0    # Visual rotation speed (in air)
@export var snap_speed = 20.0       # How fast it aligns to 90 degrees on land

# Get access to the visual sprite to rotate it
@onready var sprite = $Sprite2D

func _ready():
	# CRITICAL FIX: Ensure HazardDetector sees walls (Layer 1) and Spikes (Layer 3)
	$HazardDetector.collision_mask = 5

func _physics_process(delta):
	# 1. Apply Gravity and Rotation
	if not is_on_floor():
		velocity.y += gravity * delta
		# Visual: Rotate continuously when in air
		sprite.rotation += rotation_speed * delta
	else:
		# Visual: Smoothly snap to the closest 90-degree angle (PI/2 radians)
		var radian_step = PI / 2.0
		var target_rotation = round(sprite.rotation / radian_step) * radian_step
		
		# lerp_angle is better than lerp for rotation, but since we are handling
		# cumulative rotation > 360 degrees, standard lerp works fine here to 
		# keep it spinning "forward" to the next step.
		sprite.rotation = lerp(sprite.rotation, target_rotation, snap_speed * delta)

	# 2. Auto-Run
	velocity.x = speed

	# 3. Handle Jump
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# 4. Move (Requires TileSet "One Way Collision" on ground to not stop player)
	move_and_slide()

# Helper function to restart level
func die():
	print("Dead!")
	get_tree().reload_current_scene()

func _on_hazard_detector_body_entered(body: Node2D) -> void:
	die()
