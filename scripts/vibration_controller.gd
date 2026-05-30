extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _start_vibration(weight: float, time: float = 0.0):
	var joypads = Input.get_connected_joypads()
	for joypadIdx in joypads:
		Input.start_joy_vibration(joypadIdx, weight, weight, time)

func _stop_vibration():
	var joypads = Input.get_connected_joypads()
	for joypadIdx in joypads:
		Input.stop_joy_vibration(joypadIdx)


func _on_toggle_grinding(is_grinding: bool) -> void:
	if is_grinding:
		_start_vibration(0.5)
	else:
		_stop_vibration()


func _on_trick_mode_controller_trick_sequence_success() -> void:
	_start_vibration(1.0, 1.0)
	
	
func _on_trick_mode_controller_trick_sequence_failure() -> void:
	_start_vibration(0.8, 0.3)
