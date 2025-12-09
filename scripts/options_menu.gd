extends CanvasLayer

@onready var music_slider = $Control/VBoxContainer/MusicSlider
@onready var sfx_slider = $Control/VBoxContainer/SFXSlider
@onready var back_btn = $Control/VBoxContainer/BackBtn

func _ready():
	back_btn.pressed.connect(_on_back_pressed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Load current values from AudioServer so sliders match reality
	var music_idx = AudioServer.get_bus_index("Music")
	var sfx_idx = AudioServer.get_bus_index("SFX")
	
	# Convert dB back to Linear (0-1) for the slider
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_idx))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_idx))

func _on_music_volume_changed(value: float):
	var bus_idx = AudioServer.get_bus_index("Music")
	# Convert Linear (0-1) to dB
	# If value is 0, linear_to_db returns -infinity (Mute), which is perfect.
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_sfx_volume_changed(value: float):
	var bus_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_back_pressed():
	TransitionLayer.perform_transition(func():
		queue_free()) # The transition hides the screen, we delete this menu, then it reveals the Main Menu
