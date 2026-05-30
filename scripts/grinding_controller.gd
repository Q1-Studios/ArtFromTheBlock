extends Node
class_name GrindingController

 
#--RAIL GRINDING VARIABLES--
@onready var rail_grind_node: RailFollower = null

@export var grind_ray: ShapeCast3D
@export var player: CharacterBody3D

var grinding: bool = false
var can_grind: bool = true

signal toggle_grinding(is_grinding: bool)
 
#GRINDING
func handle_grinding(): 
	if can_grind and not grinding and is_colliding_with_rail():
		start_grinding()
	
	if grinding and rail_grind_node:
		rail_grind_node.chosen = true
		if rail_grind_node.detach or Input.is_action_pressed("jump"):
			detach_from_rail()
		
		update_player_position()
 
#enables you to use multiple rays
func is_colliding_with_rail() -> bool:
	if !grind_ray.is_colliding():
		return false
		
	var collider = grind_ray.get_collider(0)
	return collider and collider.is_in_group("Rail")
 
func start_grinding():
	grinding = true
	var grind_rail: Rail = grind_ray.get_collider(0).get_parent()
	
	# Find closest PathFollow3D and set its offset to the ones closest to the player
	rail_grind_node = find_nearest_rail_follower(grind_rail)
	rail_grind_node.progress_direction = get_grind_direction(grind_rail)
	var closest_offset = grind_rail.curve.get_closest_offset(player.global_position)
	rail_grind_node.progress = closest_offset
	
	# Update players rotation and position
	rotate_player_for_grinding()
	update_player_position()
	emit_signal("toggle_grinding", true)
	
func rotate_player_for_grinding():
	# Turn player 45 degrees to the rail
	var path_forward = rail_grind_node.global_transform.basis.z * rail_grind_node.progress_direction
	# Rotate the forward vector 90 degrees around Y axis
	var perpendicular = path_forward.rotated(Vector3.UP, PI / 2)
	player.global_transform = player.global_transform.looking_at(player.global_position + perpendicular, Vector3.UP)
	
func update_player_position():
	player.global_position = rail_grind_node.global_position
 
func detach_from_rail():
	can_grind = false
	grinding = false
	rail_grind_node.chosen = false
	rail_grind_node.detach = false
	emit_signal("toggle_grinding", false)
	
	# reset can_grind after timeout
	await get_tree().create_timer(1.0).timeout
	can_grind = true
 
func get_grind_direction(grind_rail: Rail) -> float:
	var player_forward = -player.global_transform.basis.z.normalized()
	
	var local_rail_start_pos: Vector3 = grind_rail.curve.get_point_position(0)
	var global_rail_start_pos: Vector3 = grind_rail.to_global(local_rail_start_pos)
	var direction_to_rail_start = player.global_position.direction_to(global_rail_start_pos)
	var dot_product = player_forward.dot(direction_to_rail_start)
	return -1.0 if dot_product > 0.0 else 1.0
 
func find_nearest_rail_follower(rail_node) -> RailFollower:
	var nearest_node = null
	var min_distance = INF
	for node in rail_node.get_children():
		if node.is_in_group("rail_follower"):
			var distance = player.global_position.distance_to(node.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest_node = node
				
	return nearest_node as RailFollower
