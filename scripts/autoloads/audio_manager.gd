extends Node

# -- AUDIO ASSETS --
var sfx_death = preload("res://assets/audio/death.wav")
var sfx_victory = preload("res://assets/audio/victory.mp3")
var sfx_select = preload("res://assets/audio/selection.wav")

# -- CORE FUNCTIONALITY --

## Plays a specific AudioStream.
## Creates a temporary AudioStreamPlayer, plays the sound, and cleans itself up.
func play_sfx(stream: AudioStream):
	var player = AudioStreamPlayer.new()
	
	# Set to PROCESS_MODE_ALWAYS so sounds (like UI clicks) continue 
	# to play even when the SceneTree is paused.
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	player.stream = stream
	player.bus = "SFX" 
	
	add_child(player)
	player.play()
	
	await player.finished
	player.queue_free()

# -- UTILITIES --

## Recursively finds all Buttons in the target node and connects them to the click sound.
## Prevents duplicate connections if the button is already connected.
func register_buttons(root_node: Node):
	for child in root_node.find_children("*", "Button", true, false):
		if not child.pressed.is_connected(play_button_click):
			child.pressed.connect(play_button_click)

# -- SPECIFIC SOUND TRIGGERS --

func play_death():
	play_sfx(sfx_death)

func play_victory():
	play_sfx(sfx_victory)

func play_button_click():
	play_sfx(sfx_select)
