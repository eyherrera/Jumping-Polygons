extends Area2D

## Triggers a game mode switch (e.g., Cube to Ship) when the player passes through.

enum Mode { CUBE, SHIP }

# -- CONFIGURATION --

## The target mode to apply when the player enters this portal.
@export var target_mode: Mode = Mode.SHIP

# -- LIFECYCLE --

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		# We use call_deferred to safely change state after the current 
		# physics frame ensures no collisions or calculations are interrupted.
		get_parent().call_deferred("change_gamemode", target_mode, body.position)
