extends CanvasLayer

func set_stats(percentage: int):
	# 1. Update the Text
	$Control/VBoxContainer/ProgressLabel.text = "Progress: %d%%" % percentage
	
	# 2. Update the Bar (Value should be 0-100)
	# Make sure your ProgressBar node is inside the VBoxContainer and named "ProgressBar"
	$Control/VBoxContainer/ProgressBar.value = percentage
	
	if GameManager:
		$Control/VBoxContainer/AttemptsLabel.text = "Total Attempts: %d" % GameManager.attempts

func _ready():
	$Control/VBoxContainer/HBoxContainer/RetryBtn.pressed.connect(_on_retry)
	$Control/VBoxContainer/HBoxContainer/MenuBtn.pressed.connect(_on_menu)

func _on_retry():
	get_tree().paused = false
	queue_free()
	get_tree().reload_current_scene()

func _on_menu():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
