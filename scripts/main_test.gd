extends Node2D

var playerPoints: float = 0
var currentlyDisplayedPoints: float = 0

@export var pointLabelSpeed: float = 20

@onready var pointsHUD = $HUD/PointsAmount
@onready var game_timer = %GameTimer
@onready var game_timer_label = %timerLabel

@onready var points_sfx: AudioStreamPlayer = $PointsSFX

var sandbox = false

func _enter_tree() -> void:
	FloorPainter.initialize()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sandbox = GameManger.is_sandbox
	game_timer_label.text = "∞"
	if not sandbox:
		game_timer.start(GameManger.game_time)
		
func _process(delta: float) -> void:
	if not sandbox:
		game_timer_label.text = str(int(round(game_timer.time_left)))
	
	if not playerPoints == currentlyDisplayedPoints:
		if not points_sfx.playing:
			points_sfx.play()
		
		currentlyDisplayedPoints += delta * pointLabelSpeed
		if currentlyDisplayedPoints > playerPoints:
			currentlyDisplayedPoints = playerPoints
		
		pointsHUD.text = str(int(currentlyDisplayedPoints))
	else: 
		points_sfx.stop()

func _input(event: InputEvent) -> void:
	if  Input.is_key_pressed(KEY_ESCAPE):
		ScoreManager.fetch_online_scoreboard()
		GameManger.last_score = -1.0
		get_tree().change_scene_to_file("res://scenes/meu3D.tscn")


func _on_sealskater_graffiti_fuel_updated(amount: float) -> void:
	pass


func _on_sealskater_spray_can_amount_consumed_for_points(points: float) -> void:
	playerPoints += points

func _on_node_2d_pass_points(pointsReached: int) -> void:
	print("parent in 3d recieved points: ", pointsReached)
	playerPoints += pointsReached


func _on_game_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/meu3D.tscn")
	GameManger.last_score = playerPoints
	ScoreManager.add_score(GameManger.username, playerPoints)
