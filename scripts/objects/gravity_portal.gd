extends Area2D

## A trigger zone that flips the player's gravity direction.

# -- CONFIGURATION --

## If true, sets gravity upwards (inverted).
## If false, sets gravity downwards (normal).
@export var is_inverted: bool = true

# -- LIFECYCLE --

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.has_method("change_gravity"):
		# Use call_deferred to safely modify physics state (gravity) 
		# after the current physics step completes.
		body.call_deferred("change_gravity", is_inverted)
