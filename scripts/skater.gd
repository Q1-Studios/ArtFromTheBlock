extends RigidBody3D

 
#--RAIL GRINDING VARIABLES--
@onready var rail_grind_node = null
@onready var countdown_for_next_grind = 1.0
@onready var countdown_for_next_grind_time_left = 1.0
@onready var grind_timer_complete = true
@onready var start_grind_timer = false
@onready var grind_ray: ShapeCast3D = $GrindShapeCast

var detached_from_rail: bool = false
var grinding: bool = false
var lerp_speed: float = 0.8

signal toggle_grinding(is_grinding: bool)
 
func _physics_process(delta: float) -> void:
	rail_grinding(delta)
 
#GRINDING
func rail_grinding(delta):
	if not grinding and grind_timer_complete:
		if is_colliding_with_rail():
			start_grinding(delta)
	
	if grinding and rail_grind_node:
		grind_timer_complete = false
		rail_grind_node.chosen = true
		if not rail_grind_node.direction_selected:
			rail_grind_node.forward = player_is_facing_same_direction_as(rail_grind_node)
			rail_grind_node.direction_selected = true
		update_player_position(delta)
		if rail_grind_node.detach or Input.is_action_pressed("Jump"):
			detach_from_rail()
 
#enables you to use multiple rays
func is_colliding_with_rail() -> bool:
	if !grind_ray.is_colliding():
		return false
		
	var collider = grind_ray.get_collider(0)
	print(collider)
	if collider and collider.is_in_group("Rail"):
		print("Collided with rail")
		return true
	
	return false
 
func start_grinding(delta):
	grinding = true
	emit_signal("toggle_grinding", true)
	var grind_rail = grind_ray.get_collider(0).get_parent()
	rail_grind_node = find_nearest_rail_follower(global_position, grind_rail)
	# Calculate angle to the normal
	var normal = rail_grind_node.global_position
	var target_transform = transform.looking_at(global_position - normal, Vector3.UP)
	transform.basis = transform.basis.slerp(target_transform.basis, 0.1)
	update_player_position(delta)
 
func update_player_position(delta):
	if position and rail_grind_node:
		position = lerp(position, rail_grind_node.position, delta * lerp_speed)
 
func detach_from_rail():
	detached_from_rail = true
	rail_grind_node.detach = false
	reset_player_states_after_detach()
 
func reset_player_states_after_detach():
	grinding = false
	detach_rail() #needed regardless of state machine
 
func detach_rail():
	rail_grind_node.chosen = false
	rail_grind_node.detach = false
	position = rail_grind_node.global_position
	start_grind_timer = true
	rail_grind_node.progress = rail_grind_node.origin_point
	detached_from_rail = false
	emit_signal("toggle_grinding", false)
 
func player_is_facing_same_direction_as(path_follow: PathFollow3D) -> bool:
	var player_forward = -global_transform.basis.z.normalized()
	var path_follow_forward = -path_follow.global_transform.basis.z.normalized()
	var dot_product = player_forward.dot(path_follow_forward)
	const THRESHOLD = 0.5
	return abs(dot_product - 1.0) < THRESHOLD
 
func grind_timer(delta):
	if start_grind_timer:
		if countdown_for_next_grind_time_left > 0:
			countdown_for_next_grind_time_left -= delta
			if countdown_for_next_grind_time_left <= 0:
				if Input.is_action_pressed("Forward"):
					Input.action_release("Forward")
				countdown_for_next_grind_time_left = countdown_for_next_grind
				grind_timer_complete = true
				start_grind_timer = false
 
func find_nearest_rail_follower(player_position, rail_node):
	var nearest_node = null
	var min_distance = INF
	for node in rail_node.get_children():
		if node.is_in_group("rail_follower"):
			var distance = player_position.distance_to(node.global_transform.origin)
			if distance < min_distance:
				min_distance = distance
				nearest_node = node
	return nearest_node
 
#END GRINDING
