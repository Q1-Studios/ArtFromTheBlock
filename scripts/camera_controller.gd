extends Node

@export var joystick_sensitivity: float = 3.0
@export var camera_reset_speed: float = 5.0 
@export var default_vertical_angle: float = -40.0

@onready var camera_pivot = %CameraPivot
@onready var spring_arm = %CameraPivot/SpringArm3D


func _process(delta):
	handle_camera_rotation(delta)

func handle_camera_rotation(delta):
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	
	if look_dir.length() > 0.05:
		
		camera_pivot.rotate_y(-look_dir.x * joystick_sensitivity * delta)
		spring_arm.rotate_x(-look_dir.y * joystick_sensitivity * delta)
		
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-80), deg_to_rad(-1))
	else:
		camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, 0.0, camera_reset_speed * delta)
		
		spring_arm.rotation.x = lerp_angle(spring_arm.rotation.x, deg_to_rad(default_vertical_angle), camera_reset_speed * delta)
