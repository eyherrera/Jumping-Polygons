extends CanvasLayer

func set_stats(percentage: int):
	$Control/VBoxContainer/ProgressLabel.text = "Progress: %d%%" % percentage
	# $Control/VBoxContainer/ProgressBar.value = percentage # Uncomment if you added a ProgressBar
	
	if GameManager:
		$Control/VBoxContainer/AttemptsLabel.text = "Total Attempts: %d" % GameManager.attempts

func _ready():
	$Control/VBoxContainer/HBoxContainer/RetryBtn.pressed.connect(_on_retry)
	$Control/VBoxContainer/HBoxContainer/MenuBtn.pressed.connect(_on_menu)

func _on_retry():
	get_tree().paused = false
	queue_free() # <--- IMPORTANT: Remove this screen before reloading!
	get_tree().reload_current_scene()

func _on_menu():
	get_tree().paused = false
	queue_free() # <--- IMPORTANT: Remove this screen before leaving!
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
