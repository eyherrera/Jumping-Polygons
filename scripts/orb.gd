extends Area2D

# Configurable settings per orb
@export var jump_force: float = -360.0  # Default to a slightly higher jump than normal
@export var multi_use: bool = false     # Can you hit it multiple times in one pass?

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	print("entered orb")
	# We check if the body has our new function (which we will write next)
	if body.has_method("register_orb"):
		body.register_orb(self)

func _on_body_exited(body):
	print("exited orb")
	if body.has_method("unregister_orb"):
		body.unregister_orb(self)

# Visual flair called by the player when they successfully jump
func activate_visuals():
	# Simple "pulse" animation
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(2.0, 2.0), 0.15)
	tween.tween_property($Sprite2D, "scale", Vector2(0.8, 0.8), 0.15) # Return to normal size
	
#	if not multi_use:
		# Optional: Hide or darken if it's single-use
#		$Sprite2D.modulate.a = 0.5
