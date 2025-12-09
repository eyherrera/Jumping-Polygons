extends Control

# Define your level paths here. 
# Make sure these files exist, or the game will crash when clicked!
const LEVEL_1_PATH = "res://scenes/levels/level_1.tscn" 
const LEVEL_2_PATH = "res://scenes/levels/level_2.tscn" 
const LEVEL_3_PATH = "res://scenes/levels/level_3.tscn"
const OPTIONS_MENU_PATH = "res://scenes/ui/options_menu.tscn"
const OPTIONS_MENU_SCENE = preload("res://scenes/ui/options_menu.tscn")

func _ready():
	if GameManager:
		GameManager.reset_attempts()
	# Connect signals via code to keep things clean
	$LevelContainer/Level1Btn.pressed.connect(_on_level_1_pressed)
	$LevelContainer/Level2Btn.pressed.connect(_on_level_2_pressed)
	$LevelContainer/Level3Btn.pressed.connect(_on_level_3_pressed)
	$QuitBtn.pressed.connect(_on_quit_pressed)
	
	if has_node("LevelContainer/OptionsBtn"): # Adjust path to where you put it
		$LevelContainer/OptionsBtn.pressed.connect(_on_options_btn_pressed)

func _on_level_1_pressed():
	TransitionLayer.change_scene(LEVEL_1_PATH)

func _on_level_2_pressed():
	print("Level 2 not implemented yet!")
	TransitionLayer.change_scene(LEVEL_2_PATH)

func _on_level_3_pressed():
	print("Level 3 not implemented yet!")
	TransitionLayer.change_scene(LEVEL_3_PATH)

func _on_quit_pressed():
	get_tree().quit()

func _on_options_btn_pressed():
	# We pass a "lambda" function (the code block) to the transition manager
	TransitionLayer.perform_transition(func():
		var options = OPTIONS_MENU_SCENE.instantiate()
		add_child(options)
)
