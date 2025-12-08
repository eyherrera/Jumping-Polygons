extends CanvasLayer

# Path to main menu
const MAIN_MENU_PATH = "res://scenes/ui/main_menu.tscn"

func _ready():
	if GameManager:
		$Control/VBoxContainer/AttemptsLabel.text = "Attempts: %d" % GameManager.attempts
	
	$Control/VBoxContainer/RetryBtn.pressed.connect(_on_retry_pressed)
	$Control/VBoxContainer/MenuBtn.pressed.connect(_on_menu_pressed)

func _on_retry_pressed():
	get_tree().paused = false 
	queue_free() # Remove this UI instance immediately
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false 
	queue_free() # Remove this UI instance immediately
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
