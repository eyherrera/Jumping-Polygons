extends Control

# Define your level paths here. 
# Make sure these files exist, or the game will crash when clicked!
const LEVEL_1_PATH = "res://scenes/levels/level_1.tscn"
const LEVEL_2_PATH = "res://scenes/levels/level_2.tscn" 
const LEVEL_3_PATH = "res://scenes/levels/level_3.tscn"

func _ready():
	# Connect signals via code to keep things clean
	$LevelContainer/Level1Btn.pressed.connect(_on_level_1_pressed)
	$LevelContainer/Level2Btn.pressed.connect(_on_level_2_pressed)
	$LevelContainer/Level3Btn.pressed.connect(_on_level_3_pressed)
	$QuitBtn.pressed.connect(_on_quit_pressed)

func _on_level_1_pressed():
	get_tree().change_scene_to_file(LEVEL_1_PATH)

func _on_level_2_pressed():
	#print("Level 2 not implemented yet!")
	get_tree().change_scene_to_file(LEVEL_2_PATH)

func _on_level_3_pressed():
	#print("Level 3 not implemented yet!")
	get_tree().change_scene_to_file(LEVEL_3_PATH)

func _on_quit_pressed():
	get_tree().quit()
