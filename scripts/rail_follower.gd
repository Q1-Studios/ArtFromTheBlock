extends PathFollow3D
class_name RailFollower

const UPPER_PROGRESS_BOUND: float = 0.999
const LOWER_PROGRESS_BOUND: float = 0.002
 
@onready var path_follow_3d = $"."
@onready var path_3d = $".."
@onready var origin_point = null
@onready var chosen = false
@onready var forward = true
@onready var direction_selected = false
@onready var detach = false

@export var move_speed = 8.0

var grinding = false
var local_starting_progress = 0.0
 
# Called when the node enters the scene tree for the first time.
func _ready():
	origin_point = path_follow_3d.progress
 
func _process(delta):
	if grinding:
		if forward:
			path_follow_3d.progress += move_speed * delta
		elif !forward:
			path_follow_3d.progress -= move_speed * delta
 
		var current_progress_ratio = path_follow_3d.get_progress_ratio()
		print(progress_ratio)
		
		if current_progress_ratio <= LOWER_PROGRESS_BOUND or current_progress_ratio >= UPPER_PROGRESS_BOUND:
			detach = true
			grinding = false
			direction_selected = false
			
	if has_node("Sealskater") or chosen:
		grinding = true
	else:
		grinding = false
		path_follow_3d.progress = origin_point
		direction_selected = false
