extends CanvasLayer

@onready var color_rect = $ColorRect
var active_tween: Tween # Track the currently running tween

func _ready():
	color_rect.visible = false
	color_rect.material.set_shader_parameter("progress", 0.0)

# 1. SCENE CHANGE (Level -> Menu, Menu -> Level)
func change_scene(target_path: String, should_unpause: bool = false):
	_start_transition_in()
	
	# Wait for the "pixelate in" to finish
	if active_tween: await active_tween.finished
	
	get_tree().change_scene_to_file(target_path)
	
	if should_unpause:
		get_tree().paused = false
		
	_start_transition_out()

# 2. OVERLAY ACTION (Pause Menu, Options, Level Complete)
func perform_transition(middle_action: Callable):
	_start_transition_in()
	
	if active_tween: await active_tween.finished
	
	middle_action.call()
	
	# Small delay to ensure UI is ready
	await get_tree().create_timer(0.1).timeout
	
	_start_transition_out()

# --- HELPER FUNCTIONS (Handle the math & interruption) ---

func _start_transition_in():
	color_rect.visible = true
	
	# SMART FIX: If a tween is already running (e.g. user clicked fast), kill it!
	if active_tween: active_tween.kill()
	
	active_tween = create_tween()
	active_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # Ignore pause
	
	# Get current progress (in case we interrupted halfway)
	var current_val = color_rect.material.get_shader_parameter("progress")
	
	# Animate from CURRENT value to 1.0 (Fully Pixelated)
	# We adjust duration based on how much distance is left so it doesn't feel slow
	var duration = 0.5 * (1.0 - current_val)
	active_tween.tween_property(color_rect.material, "shader_parameter/progress", 1.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

func _start_transition_out():
	if active_tween: active_tween.kill()
	
	active_tween = create_tween()
	active_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	active_tween.tween_property(color_rect.material, "shader_parameter/progress", 0.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	await active_tween.finished
	color_rect.visible = false
