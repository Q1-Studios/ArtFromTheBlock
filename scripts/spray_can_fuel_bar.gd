extends ProgressBar

@onready var stylebox: StyleBoxFlat

func _ready() -> void:
	stylebox = get_theme_stylebox("fill", "ProgressBar") as StyleBoxFlat
	
func _on_sealskater_spray_can_changed_color(color: Color) -> void:
	print("Changed color of Stylebox: {0}, {1}".format([stylebox, color]))
	if stylebox:
		stylebox.bg_color = color
