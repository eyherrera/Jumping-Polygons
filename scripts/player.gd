extends CharacterBody2D

# -- SETTINGS --
@export var speed = 400.0           # Constant forward speed
@export var jump_force = -550.0     # Negative y is "up" in Godot
@export var gravity = 2000.0        # High gravity feels snappier for this genre
@export var rotation_speed = 3.0    # Visual rotation speed

# Get access to the visual sprite to rotate it
@onready var sprite = $Sprite2D

func _physics_process(delta):
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		# Visual: Rotate cube when in air
		sprite.rotation += rotation_speed * delta
	else:
		# Visual: Reset rotation explicitly when on ground (optional, keeps it clean)
		# To snap to nearest 90 degrees, we'd need more math, 
		# but for now let's just let it roll or reset to 0:
		sprite.rotation = 0

	# 2. Auto-Run (Always move right)
	velocity.x = speed

	# 3. Handle Jump
	# We use "ui_accept" (Space/Enter) by default
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	# 4. Move
	move_and_slide()
	
	# 5. Wall Collision Check (Optional fail-safe)
	# Even if the small hitbox doesn't trigger, hitting a wall 
	# usually means we stopped moving, which kills the run.
	if is_on_wall():
		die()

# Helper function to restart level
func die():
	print("Dead!") # Debug message
	get_tree().reload_current_scene()


func _on_hazard_detector_body_entered(body: Node2D) -> void:
	die()
