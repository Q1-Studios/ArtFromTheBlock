extends Node2D


var mousePositions: Array = []
var markerContainer: Node2D
var markerList: Array = []
var markerListBoolean: Array[bool]
const DISTANCE_THRESHOLD: int = 40
var totalDistancePoints: float = 0
var previousCursorPosition: Vector2 
var totalDistanceCursor: float = 0
var markerBoolean: Array[bool] = []
var allPointsReached: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	markerList = get_node("markerContainer").get_children()
	markerListBoolean.resize(markerList.size())
	markerListBoolean.fill(false)

	calctotalDistancePoints()
	print("total length of points ", totalDistancePoints)
	
	previousCursorPosition = markerList[0].global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) || totalDistanceCursor > totalDistancePoints || allPointsReached:
		return
	trackCursorDistance()
	mousePositions.append(event.global_position)
	queue_redraw()
	_checkPointProximity(event.global_position)
	

func _draw() -> void:
	for coord in mousePositions:
		draw_circle(coord, 10, Color.RED)


func _checkPointProximity(position) -> void:
	for each in markerList:
		if position.distance_to(each.global_position) < DISTANCE_THRESHOLD:
			print("Reached node " , each , " at: " , each.global_position)
			var index = markerList.find(each)
			markerListBoolean[index] = true
			printBooleans()
			checkAllPoints()

func checkAllPoints() -> void:
	if markerListBoolean.find(false) == -1:
		allPointsReached = true


func printBooleans() -> void:
	var i = 0
	for x in markerListBoolean.size():
		print("position ", i, ": ", markerListBoolean[i])
		i = i+1

func calctotalDistancePoints() -> void:
	var i = 0
	for x in markerList.size()-1:
		totalDistancePoints += markerList[i].global_position.distance_to(markerList[i+1].global_position)
		
	
func trackCursorDistance() -> void:
	var mousePosition = get_global_mouse_position()
	totalDistanceCursor += (mousePosition - previousCursorPosition).length()
	print(totalDistanceCursor)
	previousCursorPosition = mousePosition
	pass
