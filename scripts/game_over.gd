extends CanvasLayer

## Handles the display and interaction of the Level Complete / Game Over screen.

# -- UI REFERENCES --
@onready var progress_label: Label = $Control/VBoxContainer/ProgressLabel
@onready var progress_bar: ProgressBar = $Control/VBoxContainer/ProgressBar
@onready var attempts_label: Label = $Control/VBoxContainer/AttemptsLabel
@onready var retry_btn: Button = $Control/VBoxContainer/HBoxContainer/RetryBtn
@onready var menu_btn: Button = $Control/VBoxContainer/HBoxContainer/MenuBtn

# -- LIFECYCLE --

func _ready():
	retry_btn.pressed.connect(_on_retry)
	menu_btn.pressed.connect(_on_menu)
	
	# Connects hover/click sounds automatically
	AudioManager.register_buttons(self)

# -- PUBLIC METHODS --

## Populates the UI with stats. Should be called immediately after instantiating this scene.
func set_stats(percentage: int):
	progress_label.text = "Progress: %d%%" % percentage
	progress_bar.value = percentage
	
	if GameManager:
		attempts_label.text = "Total Attempts: %d" % GameManager.attempts

# -- SIGNAL CALLBACKS --

func _on_retry():
	# Remove this UI immediately so it doesn't block the transition or input.
	queue_free()
	
	# Reload current scene. 
	# Passing 'true' ensures the game unpauses after the fade-out completes.
	var current_scene_path = get_tree().current_scene.scene_file_path
	TransitionLayer.change_scene(current_scene_path, true)

func _on_menu():
	queue_free()
	TransitionLayer.change_scene("res://scenes/ui/main_menu.tscn", true)
