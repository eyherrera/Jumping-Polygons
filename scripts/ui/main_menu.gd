extends Control

## Manages the Main Menu, handling level selection, options, and quitting.

# -- SCENE CONFIGURATION --
const LEVEL_1_PATH = "res://scenes/levels/level_1.tscn" 
const LEVEL_2_PATH = "res://scenes/levels/level_2.tscn" 
const LEVEL_3_PATH = "res://scenes/levels/level_3.tscn"

# Used for instantiating the menu as an overlay
const OPTIONS_MENU_SCENE = preload("res://scenes/ui/options_menu.tscn")
# kept for reference if needed for scene swapping
const OPTIONS_MENU_PATH = "res://scenes/ui/options_menu.tscn"

# -- UI REFERENCES --
@onready var level_1_btn = $LevelContainer/Level1Btn
@onready var level_2_btn = $LevelContainer/Level2Btn
@onready var level_3_btn = $LevelContainer/Level3Btn
@onready var quit_btn = $QuitBtn

# -- LIFECYCLE --

func _ready():
	# Reset session stats when returning to the menu
	if GameManager:
		GameManager.reset_attempts()

	# Connect guaranteed buttons
	level_1_btn.pressed.connect(_on_level_1_pressed)
	level_2_btn.pressed.connect(_on_level_2_pressed)
	level_3_btn.pressed.connect(_on_level_3_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	# Connect Options button safely (only if it exists in the current scene tree)
	if has_node("LevelContainer/OptionsBtn"):
		$LevelContainer/OptionsBtn.pressed.connect(_on_options_btn_pressed)
	
	# Auto-connect hover/click sounds
	AudioManager.register_buttons(self)

# -- SIGNAL CALLBACKS --

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
	# Use the TransitionLayer to visually fade, then instantiate the options menu
	TransitionLayer.perform_transition(func():
		var options = OPTIONS_MENU_SCENE.instantiate()
		add_child(options)
	)
