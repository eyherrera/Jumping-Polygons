extends Area2D

## Interactive Jump Orb.
## Allows the player to perform a mid-air jump when inside this area.

# -- CONFIGURATION --

## The vertical velocity applied to the player when this orb is used.
@export var jump_force: float = -360.0

## If true, the orb can be used multiple times without breaking.
## If false, it likely disables after one use (logic handled by Player or visual state).
@export var multi_use: bool = false

# -- LIFECYCLE --

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# -- SIGNAL CALLBACKS --

func _on_body_entered(body: Node2D):
	print("entered orb")
	# Register this orb with the player so they know they can click to jump.
	if body.has_method("register_orb"):
		body.register_orb(self)

func _on_body_exited(body: Node2D):
	print("exited orb")
	# Deregister the orb so the player can no longer use it.
	if body.has_method("unregister_orb"):
		body.unregister_orb(self)

# -- PUBLIC METHODS --

## Called by the Player script when the jump is successfully triggered.
func activate_visuals():
	# Simple "pulse" animation upon activation.
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(2.0, 2.0), 0.15)
	
	# Logic preserved: Returns to 0.8 scale (slightly smaller than 1.0).
	tween.tween_property($Sprite2D, "scale", Vector2(0.8, 0.8), 0.15)
