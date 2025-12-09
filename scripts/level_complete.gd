extends CanvasLayer

## Manages the post-level UI (Victory or Game Over), allowing the player to retry or exit.

# -- CONSTANTS --
const MAIN_MENU_PATH = "res://scenes/ui/main_menu.tscn"

# -- UI REFERENCES --
@onready var attempts_label: Label = $Control/VBoxContainer/AttemptsLabel
@onready var retry_btn: Button = $Control/VBoxContainer/RetryBtn
@onready var menu_btn: Button = $Control/VBoxContainer/MenuBtn

# -- LIFECYCLE --

func _ready():
	# Display the final attempt count if the manager is active.
	if GameManager:
		attempts_label.text = "Attempts: %d" % GameManager.attempts
	
	retry_btn.pressed.connect(_on_retry_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	
	# Auto-connect hover/click sounds.
	AudioManager.register_buttons(self)

# -- SIGNAL CALLBACKS --

func _on_retry_pressed():
	if GameManager:
		GameManager.reset_attempts()
	
	# Remove this UI so it doesn't block the screen during fade-out.
	queue_free()
	
	# Reload the current level.
	# Passing 'true' ensures the game unpauses after the transition completes.
	var current_level = get_tree().current_scene.scene_file_path
	TransitionLayer.change_scene(current_level, true)

func _on_menu_pressed():
	queue_free()
	
	# Return to main menu and unpause.
	TransitionLayer.change_scene(MAIN_MENU_PATH, true)
