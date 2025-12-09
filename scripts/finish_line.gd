extends Area2D

## The UI scene to instantiate (Victory Screen) when the level is finished.
@export var level_complete_scene: PackedScene

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		win_level()

func win_level():
	print("Level Complete!")
	AudioManager.play_victory()
	
	# Hide the HUD so it doesn't overlap with the victory screen.
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud: 
		hud.visible = false
	
	# Pause the SceneTree to freeze physics and player movement.
	get_tree().paused = true 
	
	if level_complete_scene:
		# Use the singleton to handle the visual transition and instantiation.
		TransitionLayer.perform_transition(func():
			var victory_screen = level_complete_scene.instantiate()
			get_tree().root.add_child(victory_screen)
		)
	else:
		printerr("ERROR: 'level_complete_scene' is missing in the Inspector.")
