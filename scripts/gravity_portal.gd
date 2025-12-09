extends Area2D

# CHECKED = Gravity UP (Inverted)
# UNCHECKED = Gravity DOWN (Normal)
@export var is_inverted: bool = true

func _ready():
	# Connect the signal if not already connected in the editor
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("change_gravity"):
		# Call deferred to ensure physics loop finishes this frame before flipping
		body.call_deferred("change_gravity", is_inverted)
