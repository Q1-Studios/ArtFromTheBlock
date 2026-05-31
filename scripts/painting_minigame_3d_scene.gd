extends Node3D

@onready var minigameScene: PackedScene = load("res://scenes/paintingMinigame3D.tscn")

var orbArray: Array

var tempScene

var miniGame
signal passPointsToParentSignal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	orbArray = get_node("../orbs").get_children()
	connectSignals()

func connectSignals() -> void:
	for each in orbArray:
		each.signalGameLevel.connect(_on_minigame_orb_signal_game_level)
		
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("spawnSceneDeleteLater"):
		#addMinigameScene()
	#pass

func addMinigameScene() -> void:
	tempScene = minigameScene.instantiate()
	add_child(tempScene)
	tempScene.gameOver.connect(removeMinigameScene)
	print("gameover signal recievbed")
	tempScene.passPoints.connect(passPointsToParent)

func removeMinigameScene() -> void:
	remove_child(tempScene)

func passPointsToParent(pointsReached: int) -> void:
	print("recieved from 3d minigame in main: ", pointsReached)
	passPointsToParentSignal.emit(pointsReached)
	print("sending to parent in main new: ", pointsReached)
	


func _on_minigame_orb_signal_game_level() -> void:
	print("start game")
	addMinigameScene()
