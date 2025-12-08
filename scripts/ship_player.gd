extends CharacterBody2D

# -- CONFIGURATION --
@export var forward_speed: float = 200.0
@export var upward_thrust: float = 1500.0 
@export var ship_gravity: float = 1000.0 
@export var max_fall_speed: float = 600.0
@export var max_rise_speed: float = 600.0
@export var rotation_sensitivity: float = 0.05

func _ready():
	# Ensure the HazardDetector scans for Walls (1) and Spikes (4) -> Value 5
	# Connect the signal if you didn't do it in the editor
	var detector = $HazardDetector
	detector.collision_mask = 5 
	if not detector.body_entered.is_connected(_on_hazard_detector_body_entered):
		detector.body_entered.connect(_on_hazard_detector_body_entered)

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
	move_and_slide()
	
	# 5. Visual Flair
	rotation = lerp_angle(rotation, velocity.y * rotation_sensitivity * delta, 10 * delta)

# -- DEATH LOGIC --
func die():
	print("Ship Crashed!")
	get_tree().reload_current_scene()

func _on_hazard_detector_body_entered(_body):
	# If we hit anything in the 'deadly' mask (Walls or Spikes), we die.
	die()
