extends CanvasLayer

## Manages the in-game Pause Menu.
## Handles resuming the game, quitting to the menu, and displaying current progress.

# -- CONSTANTS --
const MAIN_MENU_PATH = "res://scenes/ui/main_menu.tscn"

# -- LIFECYCLE --

func _ready():
	_setup_buttons()
	AudioManager.register_buttons(self)

# -- PRIVATE METHODS --

func _setup_buttons():
	# Check for "Retry" button (repurposed here as "Resume")
	if has_node("Control/VBoxContainer/HBoxContainer/RetryBtn"):
		var resume_btn = $Control/VBoxContainer/HBoxContainer/RetryBtn
		resume_btn.text = "Resume"
		resume_btn.pressed.connect(_on_resume_pressed)
	
	# Check for "Menu" button
	if has_node("Control/VBoxContainer/HBoxContainer/MenuBtn"):
		$Control/VBoxContainer/HBoxContainer/MenuBtn.pressed.connect(_on_menu_pressed)

# -- PUBLIC METHODS --

## Populates the pause screen with current level stats.
## Safe to call even if some UI elements are missing from the scene.
func set_stats(percentage: int):
	# Update Progress Label
	if has_node("Control/VBoxContainer/ProgressLabel"):
		$Control/VBoxContainer/ProgressLabel.text = "Progress: %d%%" % percentage
	
	# Update Progress Bar
	if has_node("Control/VBoxContainer/ProgressBar"):
		$Control/VBoxContainer/ProgressBar.value = percentage
	
	# Update Attempts Label
	if has_node("Control/VBoxContainer/AttemptsLabel") and GameManager:
		$Control/VBoxContainer/AttemptsLabel.text = "Total Attempts: %d" % GameManager.attempts

# -- SIGNAL CALLBACKS --

func _on_resume_pressed():
	# 1. Unpause the game logic
	get_tree().paused = false
	
	# 2. Manually resume the level music
	# We search the current scene root since the PauseMenu is a child of root, not the level.
	var current_scene = get_tree().current_scene
	var music = current_scene.get_node_or_null("AudioStreamPlayer")
	if music:
		music.stream_paused = false
	
	# 3. Restore the HUD
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud:
		hud.visible = true
	else:
		# Fallback: Look for HUD by name if the group isn't assigned
		hud = current_scene.get_node_or_null("HUD")
		if hud: 
			hud.visible = true
		
	# 4. Close this menu
	queue_free()

func _on_menu_pressed():
	# Remove the menu immediately to clear the screen for the fade-out
	queue_free()
	
	# Trigger transition. 
	# Passing 'true' ensures the TransitionLayer unpauses the tree after the fade-out.
	TransitionLayer.change_scene(MAIN_MENU_PATH, true)
