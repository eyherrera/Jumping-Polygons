extends CanvasLayer

# Path to main menu
const MAIN_MENU_PATH = "res://scenes/ui/main_menu.tscn"

func _ready():
	if GameManager:
		$Control/VBoxContainer/AttemptsLabel.text = "Attempts: %d" % GameManager.attempts
	
	$Control/VBoxContainer/RetryBtn.pressed.connect(_on_retry_pressed)
	$Control/VBoxContainer/MenuBtn.pressed.connect(_on_menu_pressed)

func _on_retry_pressed():
	if GameManager:
		GameManager.reset_attempts()
	queue_free()
	# Reload current level, unpause when safe
	var current_level = get_tree().current_scene.scene_file_path
	TransitionLayer.change_scene(current_level, true)

func _on_menu_pressed():
	queue_free()
	# Go to menu, unpause when safe
	TransitionLayer.change_scene(MAIN_MENU_PATH, true)
