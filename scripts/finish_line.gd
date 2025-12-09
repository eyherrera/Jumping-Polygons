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
	
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud:
		hud.visible = false
	
	if level_complete_scene:
		# 1. Instantiate the UI
		var victory_screen = level_complete_scene.instantiate()
		
		# 2. Add it to the HUD or CanvasLayer (so it stays on screen)
		# We add it to the 'root' so it covers everything independent of the camera
		get_tree().root.add_child(victory_screen)
		
		# 3. Pause the game
		get_tree().paused = true
	else:
		printerr("Assign the LevelComplete.tscn in the FinishLine Inspector!")
