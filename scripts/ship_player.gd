extends CharacterBody2D

# -- CONFIGURATION --
@export var forward_speed: float = 200.0
@export var upward_thrust: float = 1500.0 
@export var ship_gravity: float = 1000.0 
@export var max_fall_speed: float = 600.0
@export var max_rise_speed: float = 600.0
@export var rotation_sensitivity: float = 0.10

func _ready():
	# 1. Setup Wall Detector (Small Box -> World Layer)
	# It allows grazing floors/ceilings but kills on deep wall impacts.
	var wall_detector = $WallDetector
	if wall_detector:
		wall_detector.body_entered.connect(_on_hazard_entered)
	else:
		printerr("Ship missing 'WallDetector' child node!")

	# 2. Setup Spike Detector (Big Box -> Deadly Layer)
	# It kills immediately if ANY part of the ship touches a spike.
	var spike_detector = $SpikeDetector
	if spike_detector:
		spike_detector.body_entered.connect(_on_hazard_entered)
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
	# The Main CollisionShape (Big) handles sliding on floors/ceilings here.
	move_and_slide()
	
	# 5. Visual Flair
	rotation = lerp_angle(rotation, velocity.y * rotation_sensitivity * delta, 10 * delta)

# -- DEATH LOGIC --
func die():
	print("Ship Crashed!")
	get_tree().reload_current_scene()

func _on_hazard_entered(_body):
	# This triggers if Small Box hits a Wall OR Big Box hits a Spike
	die()
