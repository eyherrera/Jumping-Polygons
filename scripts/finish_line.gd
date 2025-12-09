extends Area2D

# We will load the completion screen scene directly here to spawn it
@export var level_complete_scene: PackedScene

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		win_level()

func win_level():
	print("Level Complete!")
	AudioManager.play_victory()
	
	# Hide HUD immediately
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud: hud.visible = false
	
	# Pause immediately so player stops moving
	get_tree().paused = true 
	
	if level_complete_scene:
		# Use the Overlay Transition!
		TransitionLayer.perform_transition(func():
			var victory_screen = level_complete_scene.instantiate()
			get_tree().root.add_child(victory_screen)
		)
	else:
		printerr("Assign the LevelComplete.tscn in the FinishLine Inspector!")
