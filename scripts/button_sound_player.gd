extends Node

@export_group("Internal")
@export var hover_sound: AudioStreamPlayer
@export var click_sound: AudioStreamPlayer

var parent: BaseButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	parent.focus_entered.connect(_on_parent_focus_entered)
	parent.pressed.connect(_on_parent_pressed)

func _on_parent_focus_entered() -> void:
	hover_sound.play()

func _on_parent_pressed() -> void:
	click_sound.play()
