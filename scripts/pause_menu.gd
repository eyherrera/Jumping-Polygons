extends CanvasLayer

func _ready():
	# If your buttons are named the same as Game Over, this works.
	# If you renamed them (e.g. "ResumeBtn"), update the paths below.
	
	# "Retry" button -> RESUME Game
	if has_node("Control/VBoxContainer/HBoxContainer/RetryBtn"):
		$Control/VBoxContainer/HBoxContainer/RetryBtn.text = "Resume"
		$Control/VBoxContainer/HBoxContainer/RetryBtn.pressed.connect(_on_resume_pressed)
	
	# "Menu" button -> QUIT to Menu
	if has_node("Control/VBoxContainer/HBoxContainer/MenuBtn"):
		$Control/VBoxContainer/HBoxContainer/MenuBtn.pressed.connect(_on_menu_pressed)

	# Optional: Update Title
	if has_node("Control/VBoxContainer/Label"):
		$Control/VBoxContainer/Label.text = "Paused"

func _on_resume_pressed():
	# 1. Unpause the Tree
	get_tree().paused = false
	
	# 2. Manually Resume the Music
	# We search the current scene for the player to find the music sibling
	# (Since PauseMenu is in 'root', we can't use get_parent())
	var current_scene = get_tree().current_scene
	var music = current_scene.get_node_or_null("AudioStreamPlayer")
	if music:
		music.stream_paused = false
	
	# 3. Show HUD again
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud:
		hud.visible = true
	else:
		# Fallback: If group fails, look for it in the scene directly
		hud = current_scene.get_node_or_null("HUD")
		if hud: hud.visible = true
		
	# 4. Remove Pause Screen
	queue_free()

func _on_menu_pressed():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
