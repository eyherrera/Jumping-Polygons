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
	# 1. Remove this UI so it doesn't block the transition
	queue_free()
	
	# 2. Transition
	# We pass 'true' to unpause AFTER the screen is black
	var current_scene_path = get_tree().current_scene.scene_file_path
	TransitionLayer.change_scene(current_scene_path, true)

func _on_menu():
	queue_free()
	# Pass 'true' to unpause AFTER the screen is black
	TransitionLayer.change_scene("res://scenes/ui/main_menu.tscn", true)
