extends Area2D

enum Mode { CUBE, SHIP }

# Choose this in the Inspector for each portal you place!
@export var target_mode: Mode = Mode.SHIP

func _ready():
	# Connect the signal via code to avoid manual wiring errors
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the object hitting us is the current player
	if body.is_in_group("Player"):
		# We call "change_gamemode" on the LEVEL root (the parent of the player)
		# We use call_deferred to ensure physics is done for this frame before swapping
		get_parent().call_deferred("change_gamemode", target_mode, body.position)
