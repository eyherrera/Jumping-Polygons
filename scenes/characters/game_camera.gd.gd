extends Camera2D

@export var smoothing_speed : float = 10.0
@export var offset_x : float = 150.0  # Keep the player to the left

# We need a reference to the parent (The Player) because
# 'Top Level' makes us ignore the parent's position automatically.
@onready var player = get_parent()

func _ready():
	# Instantly snap to player start position so we don't drift in from 0,0
	global_position.x = player.global_position.x + offset_x
	global_position.y = player.global_position.y

func _physics_process(delta):
	if not player:
		return
		
	# 1. HARD LOCK X-AXIS
	# We set the x position directly. No lerp, no smoothing.
	# This eliminates horizontal blur/jitter completely.
	global_position.x = player.global_position.x + offset_x
	
	# 2. SMOOTH Y-AXIS
	# We use 'lerp' (Linear Interpolate) to smoothly move Y towards the player.
	# This gives you that nice "springy" feel when falling or jumping.
	var target_y = player.global_position.y
	global_position.y = lerp(global_position.y, target_y, smoothing_speed * delta)
