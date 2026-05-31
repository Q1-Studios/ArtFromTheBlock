extends TextureButton

@export var init_grab_focus: bool = false
var normal_texture: Texture2D
var hover_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	normal_texture = texture_normal
	hover_texture = texture_hover
	
	mouse_entered.connect(_on_mouse_entered)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	
	if init_grab_focus:
		grab_focus()


func _on_mouse_entered() -> void:
	texture_hover = hover_texture
	grab_focus()

func _on_focus_entered() -> void:
	texture_hover = hover_texture
	texture_normal = texture_hover

func _on_focus_exited() -> void:
	texture_normal = normal_texture
	texture_hover = normal_texture
