extends Node

# -- PRELOAD YOUR SOUNDS HERE --
# Adjust paths if your files are in a different folder!
var sfx_death = preload("res://assets/audio/death.wav")
var sfx_victory = preload("res://assets/audio/victory.mp3")
var sfx_select = preload("res://assets/audio/selection.wav")

func play_sfx(stream: AudioStream):
	# Create a temporary player for this specific sound
	var player = AudioStreamPlayer.new()
	
	# --- THIS IS THE FIX ---
	# Tell this specific sound player to IGNORE the game pause
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	# -----------------------
	
	player.stream = stream
	player.bus = "SFX" 
	
	add_child(player)
	player.play()
	
	await player.finished
	player.queue_free()

# -- HELPER FUNCTIONS --
func play_death():
	play_sfx(sfx_death)

func play_victory():
	play_sfx(sfx_victory)

func play_button_click():
	play_sfx(sfx_select)

# Utility to auto-connect all buttons in a scene
func register_buttons(root_node: Node):
	for child in root_node.find_children("*", "Button", true, false):
		if not child.pressed.is_connected(play_button_click):
			child.pressed.connect(play_button_click)
