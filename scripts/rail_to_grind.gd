extends Path3D

@export var rail_follower = preload("res://Scenes/rail_follower.tscn")
@export var point_total: int = 20
 
@onready var path_3d = $"."
@onready var path_curve = curve


var hasSpawnedPoints = false
var pointCount: float = 0
 
 
# Called when the node enters the scene tree for the first time.
func _ready():
	populate_rail()
	
func _process(_delta):
	pass
 
func populate_rail():
	var path_length = curve.get_baked_length()
	var spacing = path_length / 19
	var current_distance = 0
	var staring_progress = 0.001
	for i in range(point_total):
		var object_instance = rail_follower.instantiate()
		object_instance.progress = staring_progress
		add_child(object_instance)
		staring_progress += 5
		current_distance += spacing
		pointCount += 1.0
		if i == point_total:
			hasSpawnedPoints = true
