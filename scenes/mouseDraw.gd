extends Node2D


var mousePositions: Array = []
var markerContainer: Node2D
var markerList: Array = []
var markerListBoolean: Array[bool]
const DISTANCE_THRESHOLD: int = 10

var markerBoolean: Array[bool] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	markerList = get_node("markerContainer").get_children()
	markerListBoolean.resize(markerList.size())
	markerListBoolean.fill(false)

	for x in markerList:
		print(x.position)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	
	mousePositions.append(event.position)
	queue_redraw()
	_checkDistance(event.position)
	

func _draw() -> void:
	for coord in mousePositions:
		draw_circle(coord, 10, Color.RED)


func _checkDistance(position) -> void:
	for each in markerList:
		if position.distance_to(each.global_position) < DISTANCE_THRESHOLD:
			print("Reached node " , each , " at: " , each.global_position)
			var index = markerList.find(each)
			markerListBoolean[index] = true
			printBooleans()
			

func printBooleans() -> void:
	var i = 0
	for x in markerListBoolean:
		print("position ", i, markerListBoolean[i])
		i = i+1
