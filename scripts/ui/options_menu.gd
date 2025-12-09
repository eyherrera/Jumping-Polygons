extends CanvasLayer

## Manages game settings, specifically Music and SFX volume control.

# -- UI REFERENCES --
@onready var music_slider: Slider = $Control/VBoxContainer/MusicSlider
@onready var sfx_slider: Slider = $Control/VBoxContainer/SFXSlider
@onready var back_btn: Button = $Control/VBoxContainer/BackBtn

# -- LIFECYCLE --

func _ready():
	# UI Connections
	back_btn.pressed.connect(_on_back_pressed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Sync UI with current AudioServer state
	_initialize_sliders()
	
	# Add hover/click sounds
	AudioManager.register_buttons(self)

# -- PRIVATE METHODS --

func _initialize_sliders():
	# Get bus indices
	var music_idx = AudioServer.get_bus_index("Music")
	var sfx_idx = AudioServer.get_bus_index("SFX")
	
	# Convert current dB volume back to Linear (0.0 to 1.0) for the slider display.
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_idx))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_idx))

# -- SIGNAL CALLBACKS --

func _on_music_volume_changed(value: float):
	var bus_idx = AudioServer.get_bus_index("Music")
	
	# Convert Linear slider value (0-1) to Decibels (dB).
	# Note: linear_to_db(0) correctly returns -inf (Mute).
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_sfx_volume_changed(value: float):
	var bus_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_back_pressed():
	# Use the transition layer to smoothly exit the menu.
	TransitionLayer.perform_transition(func():
		queue_free()
	)
