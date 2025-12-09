extends CharacterBody2D

## Main controller for the Cube game mode.
## Handles constant forward movement, jumping, gravity flipping, and death logic.

# -- MOVEMENT SETTINGS --
@export_group("Movement")
@export var speed: float = 200.0
@export var jump_force: float = -360.0
@export var gravity: float = 2000.0
@export var rotation_speed: float = 6.0
@export var snap_speed: float = 20.0

# -- SCENE REFERENCES --
@export_group("Dependencies")
@export var game_over_scene: PackedScene = preload("res://scenes/ui/game_over_layer.tscn")

# -- NODES --
@onready var sprite: Sprite2D = $Sprite2D
@onready var floor_detectors: Node2D = $FloorDetectors 
@onready var ray_left: RayCast2D = $FloorDetectors/RayLeft
@onready var ray_right: RayCast2D = $FloorDetectors/RayRight
@onready var hazard_detector: Area2D = $HazardDetector
@onready var spike_detector: Area2D = $SpikeDetector

# -- INTERNAL STATE --
var is_grounded: bool = false
var current_orb: Area2D = null 
var jump_button_released: bool = true

# 1 = Normal (Down), -1 = Inverted (Up)
var gravity_direction: int = 1

# -- LIFECYCLE --

func _ready():
	# Setup Hazard Collisions (Mask 1 = Walls/Default)
	if hazard_detector:
		hazard_detector.collision_mask = 1 
		if not hazard_detector.body_entered.is_connected(_on_hazard_entered):
			hazard_detector.body_entered.connect(_on_hazard_entered)

	# Setup Spike Collisions (Mask 4 = Spikes/Hazards)
	if spike_detector:
		spike_detector.collision_mask = 4
		spike_detector.body_entered.connect(_on_hazard_entered)

	# Prevent rays from detecting the player itself
	ray_left.add_exception(self)
	ray_right.add_exception(self)

func _physics_process(delta):
	# Track input state to prevent holding jump button for auto-jump
	if Input.is_action_just_released("jump"):
		jump_button_released = true
	
	# 1. Apply Gravity (Directional)
	velocity.y += gravity * gravity_direction * delta
	
	# 2. Dynamic Floor Check (Raycasting)
	_handle_ground_detection(delta)

	# 3. Jump Logic
	_handle_jump_input()

	# 4. Movement Application
	velocity.x = speed
	move_and_slide() 

	# 5. Visual Rotation
	_handle_rotation(delta)

# -- PHYSICS HELPERS --

func _handle_ground_detection(delta: float):
	var current_fall_speed = velocity.y
	var distance_to_fall = current_fall_speed * delta
	
	# Extend ray length dynamically based on fall speed to prevent tunneling
	var ray_length = max(10.0, abs(distance_to_fall) + 5.0)
	
	# Update Ray positions
	ray_left.target_position = Vector2(0, ray_length)
	ray_right.target_position = Vector2(0, ray_length)
	ray_left.force_raycast_update()
	ray_right.force_raycast_update()
	
	is_grounded = false
	
	# Only snap to floor if we are falling towards it
	if velocity.y * gravity_direction > 0:
		var collision_point = null
		
		if ray_left.is_colliding():
			collision_point = ray_left.get_collision_point()
		elif ray_right.is_colliding():
			collision_point = ray_right.get_collision_point()
			
		if collision_point:
			# Calculate distance from feet to floor
			var diff = collision_point.y - global_position.y
			var distance_from_feet = diff * gravity_direction
			
			# If close enough, snap position to floor
			if distance_from_feet <= (8 + ray_length):
				global_position.y = collision_point.y - (8 * gravity_direction)
				velocity.y = 0
				is_grounded = true

func _handle_jump_input():
	# Prevent jumping if clicking UI buttons (Pause, etc.)
	var is_hovering_ui = get_viewport().gui_get_hovered_control() != null
	if is_hovering_ui:
		return
		
	# PRIORITY 1: ORB JUMP
	if Input.is_action_just_pressed("jump") and current_orb:
		attempt_orb_jump()
		
	# PRIORITY 2: FLOOR JUMP
	elif Input.is_action_pressed("jump") and is_grounded:
		velocity.y = jump_force * gravity_direction
		is_grounded = false
		jump_button_released = false

func _handle_rotation(delta: float):
	if not is_grounded:
		# Spin while in air
		sprite.rotation += rotation_speed * delta * gravity_direction
	else:
		# Snap to nearest 90 degrees when landing
		var radian_step = PI / 2.0
		var target_rotation = round(sprite.rotation / radian_step) * radian_step
		sprite.rotation = lerp(sprite.rotation, target_rotation, snap_speed * delta)

# -- MECHANICS --

## Called by Gravity Portals.
func change_gravity(inverted: bool):
	if inverted:
		gravity_direction = -1
		floor_detectors.rotation_degrees = 180 # Rays point UP
		sprite.flip_v = true                   # Visual flip
	else:
		gravity_direction = 1
		floor_detectors.rotation_degrees = 0   # Rays point DOWN
		sprite.flip_v = false

	# Reset vertical momentum for a clean switch
	velocity.y = 0

## Called by Orbs when entering their area.
func register_orb(orb_node):
	current_orb = orb_node
	# Allow buffer jump if player presses jump slightly early
	if Input.is_action_pressed("jump") and jump_button_released:
		attempt_orb_jump()

## Called by Orbs when exiting their area.
func unregister_orb(orb_node):
	if current_orb == orb_node:
		current_orb = null

func attempt_orb_jump():
	if current_orb:
		velocity.y = current_orb.jump_force * gravity_direction
		current_orb.activate_visuals()
		is_grounded = false
		jump_button_released = false 
		
		if not current_orb.multi_use:
			current_orb = null

# -- DAMAGE & DEATH --

func _on_hazard_entered(_body):
	die()

func die():
	print("Player Died")
	AudioManager.play_death()
	
	# Hide HUD
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud:
		hud.visible = false
	
	# Update Global Stats
	if GameManager:
		GameManager.add_attempt()
	
	# Stop Music
	var music = get_parent().get_node_or_null("AudioStreamPlayer")
	if music:
		music.stop()

	# Calculate Percentage for Game Over Screen
	var percent = 0
	var finish_node = get_tree().get_first_node_in_group("FinishLine")
	if finish_node:
		var end_x = finish_node.global_position.x
		if end_x > 0:
			percent = int((global_position.x / end_x) * 100)
			percent = clamp(percent, 0, 99)
	
	# Show Game Over Screen
	if game_over_scene:
		var go_screen = game_over_scene.instantiate()
		get_tree().root.add_child(go_screen)
		go_screen.set_stats(percent)
		get_tree().paused = true
	else:
		# Fallback if no screen assigned
		get_tree().reload_current_scene()
