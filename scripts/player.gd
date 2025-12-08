extends CharacterBody2D

# -- SETTINGS --
@export var speed = 200.0
@export var jump_force = -360.0
@export var gravity = 2000.0
@export var rotation_speed = 6.0
@export var snap_speed = 20.0

@onready var sprite = $Sprite2D
@onready var ray_left = $FloorDetectors/RayLeft
@onready var ray_right = $FloorDetectors/RayRight

var is_grounded = false

func _ready():
	# Ensure HazardDetector works (Layer 1=World, Layer 3=Deadly)
	$HazardDetector.collision_mask = 5
	# Ensure rays ignore the player's own collider
	ray_left.add_exception(self)
	ray_right.add_exception(self)

func _physics_process(delta):
	# 1. Apply Gravity first
	velocity.y += gravity * delta
	
	# 2. Dynamic Floor Check
	# We predict how far we will fall this frame.
	# We add a small 'margin' (e.g. 5 pixels) to ensure we detect the floor just before we hit it.
	var current_fall_speed = velocity.y
	var distance_to_fall = current_fall_speed * delta
	var ray_length = max(10.0, distance_to_fall + 5.0) # Never shorter than 10px
	
	# Update RayCasts to look exactly that far ahead
	ray_left.target_position = Vector2(0, ray_length)
	ray_right.target_position = Vector2(0, ray_length)
	ray_left.force_raycast_update()
	ray_right.force_raycast_update()
	
	is_grounded = false
	
	# Only bother checking floor if we are actually falling
	if velocity.y > 0:
		var collision_point = null
		
		if ray_left.is_colliding():
			collision_point = ray_left.get_collision_point()
		elif ray_right.is_colliding():
			collision_point = ray_right.get_collision_point()
			
		if collision_point:
			# Visual smoothing:
			# Only snap if we are actually close to the ground (within falling distance)
			# This prevents snapping to a block 50px below you if you just jumped over it.
			var distance_from_feet = collision_point.y - global_position.y
			
			# (Adjust '8' to half your sprite height)
			# We check if the floor is within the distance we tried to cover this frame
			if distance_from_feet <= (8 + ray_length):
				global_position.y = collision_point.y - 8
				velocity.y = 0
				is_grounded = true

	# 3. Handle Jump
	if Input.is_action_pressed("jump") and is_grounded:
		velocity.y = jump_force
		is_grounded = false

	# 4. Manual Movement
	velocity.x = speed
	move_and_slide() 

	# 5. Visual Rotation
	_handle_rotation(delta)

func _handle_rotation(delta):
	if not is_grounded:
		sprite.rotation += rotation_speed * delta
	else:
		var radian_step = PI / 2.0
		var target_rotation = round(sprite.rotation / radian_step) * radian_step
		sprite.rotation = lerp(sprite.rotation, target_rotation, snap_speed * delta)

# -- DEATH LOGIC --
func die():
	print("Dead!")
	GameManager.add_attempt()
	get_tree().reload_current_scene()

func _on_hazard_detector_body_entered(body: Node2D) -> void:
	die()
