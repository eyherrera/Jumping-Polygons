extends CharacterBody2D

# -- SETTINGS --
@export var speed = 200.0
@export var jump_force = -360.0
@export var gravity = 2000.0
@export var rotation_speed = 6.0
@export var snap_speed = 20.0
@export var game_over_scene: PackedScene = preload("res://scenes/ui/game_over_layer.tscn")

@onready var sprite = $Sprite2D
@onready var ray_left = $FloorDetectors/RayLeft
@onready var ray_right = $FloorDetectors/RayRight
@onready var hazard_detector = $HazardDetector
@onready var spike_detector = $SpikeDetector

var is_grounded = false

func _ready():
	# 1. HazardDetector (Walls Only)
	# Mask 1 = World. We REMOVE Layer 3 (Spikes) from this detector.
	if hazard_detector:
		hazard_detector.collision_mask = 1 
		# Ensure signal is connected (if not done in editor)
		if not hazard_detector.body_entered.is_connected(_on_hazard_entered):
			hazard_detector.body_entered.connect(_on_hazard_entered)

	# 2. SpikeDetector (Spikes Only)
	# Mask 4 = Layer 3 (Deadly).
	if spike_detector:
		spike_detector.collision_mask = 4
		spike_detector.body_entered.connect(_on_hazard_entered)
	else:
		printerr("Player missing 'SpikeDetector' child node!")

	# 3. RayCast Exceptions
	ray_left.add_exception(self)
	ray_right.add_exception(self)

func _physics_process(delta):
	# 1. Apply Gravity
	velocity.y += gravity * delta
	
	# 2. Dynamic Floor Check (The "Makeshift" Logic)
	var current_fall_speed = velocity.y
	var distance_to_fall = current_fall_speed * delta
	var ray_length = max(10.0, distance_to_fall + 5.0)
	
	ray_left.target_position = Vector2(0, ray_length)
	ray_right.target_position = Vector2(0, ray_length)
	ray_left.force_raycast_update()
	ray_right.force_raycast_update()
	
	is_grounded = false
	
	if velocity.y > 0:
		var collision_point = null
		
		if ray_left.is_colliding():
			collision_point = ray_left.get_collision_point()
		elif ray_right.is_colliding():
			collision_point = ray_right.get_collision_point()
			
		if collision_point:
			var distance_from_feet = collision_point.y - global_position.y
			if distance_from_feet <= (8 + ray_length):
				global_position.y = collision_point.y - 8
				velocity.y = 0
				is_grounded = true

	# 3. Handle Jump
	if Input.is_action_pressed("jump") and is_grounded:
		velocity.y = jump_force
		is_grounded = false

	# 4. Move
	velocity.x = speed
	move_and_slide() 

	# 5. Rotation
	_handle_rotation(delta)

func _handle_rotation(delta):
	if not is_grounded:
		sprite.rotation += rotation_speed * delta
	else:
		var radian_step = PI / 2.0
		var target_rotation = round(sprite.rotation / radian_step) * radian_step
		sprite.rotation = lerp(sprite.rotation, target_rotation, snap_speed * delta)

# -- DEATH LOGIC --
# Both detectors connect here
func _on_hazard_entered(_body):
	die()

func die():
	print("Dead!")
	if GameManager:
		GameManager.add_attempt()
	
	var music = get_parent().get_node_or_null("AudioStreamPlayer")
	if music:
		music.stop()

	# Progress Calculation
	var percent = 0
	var finish_node = get_tree().get_first_node_in_group("FinishLine")
	if finish_node:
		var end_x = finish_node.global_position.x
		if end_x > 0:
			percent = int((global_position.x / end_x) * 100)
			percent = clamp(percent, 0, 99)
	
	# Show Game Over
	if game_over_scene:
		var go_screen = game_over_scene.instantiate()
		get_tree().root.add_child(go_screen)
		go_screen.set_stats(percent)
		get_tree().paused = true
	else:
		get_tree().reload_current_scene()
