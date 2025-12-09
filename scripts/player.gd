extends CharacterBody2D

# -- SETTINGS --
@export var speed = 200.0
@export var jump_force = -360.0
@export var gravity: float = 2000.0
@export var rotation_speed = 6.0
@export var snap_speed = 20.0
@export var game_over_scene: PackedScene = preload("res://scenes/ui/game_over_layer.tscn")

@onready var sprite = $Sprite2D
@onready var floor_detectors = $FloorDetectors 
@onready var ray_left = $FloorDetectors/RayLeft
@onready var ray_right = $FloorDetectors/RayRight
@onready var hazard_detector = $HazardDetector
@onready var spike_detector = $SpikeDetector

var is_grounded = false
var current_orb = null 
var jump_button_released = true

# THIS IS THE IMPORTANT LINE:
var gravity_direction: int = 1

func _ready():
	if hazard_detector:
		hazard_detector.collision_mask = 1 
		if not hazard_detector.body_entered.is_connected(_on_hazard_entered):
			hazard_detector.body_entered.connect(_on_hazard_entered)

	if spike_detector:
		spike_detector.collision_mask = 4
		spike_detector.body_entered.connect(_on_hazard_entered)

	ray_left.add_exception(self)
	ray_right.add_exception(self)

# -- GRAVITY LOGIC --
func change_gravity(inverted: bool):
	if inverted:
		gravity_direction = -1
		floor_detectors.rotation_degrees = 180 # Rays point UP
		sprite.flip_v = true                   # Visual flip
	else:
		gravity_direction = 1
		floor_detectors.rotation_degrees = 0   # Rays point DOWN
		sprite.flip_v = false

	# Safety Bump: Push player slightly out of the floor/ceiling to prevent snagging during the flip
	#position.y -= 10 * gravity_direction
	velocity.y = 0 # Reset vertical momentum for a cleaner switch

# -- ORB LOGIC --
func register_orb(orb_node):
	current_orb = orb_node
	if Input.is_action_pressed("jump") and jump_button_released:
		attempt_orb_jump()

func unregister_orb(orb_node):
	if current_orb == orb_node:
		current_orb = null

func _physics_process(delta):
	if Input.is_action_just_released("jump"):
		jump_button_released = true
	
	# 1. Apply Gravity (Directional)
	# Normal (1): Adds positive Y (Down)
	# Inverted (-1): Adds negative Y (Up)
	velocity.y += gravity * gravity_direction * delta
	
	# 2. Dynamic Floor Check
	var current_fall_speed = velocity.y
	var distance_to_fall = current_fall_speed * delta
	
	# Use ABS() because falling UP produces negative distance
	var ray_length = max(10.0, abs(distance_to_fall) + 5.0)
	
	# RayCasts are children of FloorDetectors. Since we rotated FloorDetectors,
	# positive Y here means "Forward" relative to the detector (Down or Up).
	ray_left.target_position = Vector2(0, ray_length)
	ray_right.target_position = Vector2(0, ray_length)
	ray_left.force_raycast_update()
	ray_right.force_raycast_update()
	
	is_grounded = false
	
	# Only check for landing if we are falling in the direction of gravity
	# Normal: vel > 0. Inverted: vel < 0.
	if velocity.y * gravity_direction > 0:
		var collision_point = null
		if ray_left.is_colliding():
			collision_point = ray_left.get_collision_point()
		elif ray_right.is_colliding():
			collision_point = ray_right.get_collision_point()
			
		if collision_point:
			# Calculate vertical distance to floor
			var diff = collision_point.y - global_position.y
			# Normalize distance based on direction
			var distance_from_feet = diff * gravity_direction
			
			if distance_from_feet <= (8 + ray_length):
				# Snap Position
				# Normal: Floor is below (positive Y), we snap UP (-8)
				# Inverted: Floor is above (negative Y), we snap DOWN (+8)
				global_position.y = collision_point.y - (8 * gravity_direction)
				velocity.y = 0
				is_grounded = true

	# 3. Jump Logic
	
	# Check if mouse is over a button (UI)
	var is_hovering_ui = get_viewport().gui_get_hovered_control() != null
	
	# PRIORITY 1: ORB JUMP
	# Add "and not is_hovering_ui" to the condition
	if Input.is_action_just_pressed("jump") and current_orb and not is_hovering_ui:
		attempt_orb_jump()
		
	# PRIORITY 2: FLOOR JUMP
	# Add "and not is_hovering_ui" to the condition
	elif Input.is_action_pressed("jump") and is_grounded and not is_hovering_ui:
		velocity.y = jump_force * gravity_direction
		is_grounded = false
		jump_button_released = false

	# 4. Move
	velocity.x = speed
	move_and_slide() 

	# 5. Rotation
	_handle_rotation(delta)

func attempt_orb_jump():
	if current_orb:
		# Orbs push you "Up" (Away from gravity)
		velocity.y = current_orb.jump_force * gravity_direction
		current_orb.activate_visuals()
		is_grounded = false
		jump_button_released = false 
		
		if not current_orb.multi_use:
			current_orb = null

func _handle_rotation(delta):
	if not is_grounded:
		# Rotate the visual sprite
		# We multiply by gravity_direction to rotate "forward" regardless of gravity
		sprite.rotation += rotation_speed * delta * gravity_direction
	else:
		var radian_step = PI / 2.0
		var target_rotation = round(sprite.rotation / radian_step) * radian_step
		sprite.rotation = lerp(sprite.rotation, target_rotation, snap_speed * delta)

func _on_hazard_entered(_body):
	die()

func die():
	
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud:
		hud.visible = false
	
	print("Dead!")
	if GameManager:
		GameManager.add_attempt()
	
	var music = get_parent().get_node_or_null("AudioStreamPlayer")
	if music:
		music.stop()

	var percent = 0
	var finish_node = get_tree().get_first_node_in_group("FinishLine")
	if finish_node:
		var end_x = finish_node.global_position.x
		if end_x > 0:
			percent = int((global_position.x / end_x) * 100)
			percent = clamp(percent, 0, 99)
	
	if game_over_scene:
		var go_screen = game_over_scene.instantiate()
		get_tree().root.add_child(go_screen)
		go_screen.set_stats(percent)
		get_tree().paused = true
	else:
		get_tree().reload_current_scene()
