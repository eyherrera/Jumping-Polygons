extends CharacterBody2D

# -- CONFIGURATION --
@export var forward_speed: float = 300.0

# "Thrust" is how fast it gains upward speed (The Engine)
@export var upward_thrust: float = 1500.0 

# "Gravity" is how fast it falls when you let go
@export var ship_gravity: float = 1000.0 

# Cap the vertical speed so you don't fly off screen instantly
@export var max_fall_speed: float = 600.0
@export var max_rise_speed: float = 600.0

# Visual rotation amount
@export var rotation_sensitivity: float = 0.05

func _physics_process(delta):
	# 1. Constant Forward Movement
	velocity.x = forward_speed
	
	# 2. Vertical Movement (The Ship Logic)
	if Input.is_action_pressed("jump"):
		# Apply Upward Force (Acceleration)
		velocity.y -= upward_thrust * delta
	else:
		# Apply Gravity (Acceleration Down)
		velocity.y += ship_gravity * delta
	
	# 3. Clamp Velocity (Terminal Velocity)
	# This ensures the momentum doesn't get uncontrollable
	velocity.y = clamp(velocity.y, -max_rise_speed, max_fall_speed)
	
	# 4. Move
	move_and_slide()
	
	# 5. Visual Flair: Rotate based on vertical speed
	# Nose goes up when rising, down when falling
	rotation = lerp_angle(rotation, velocity.y * rotation_sensitivity * delta, 10 * delta)
