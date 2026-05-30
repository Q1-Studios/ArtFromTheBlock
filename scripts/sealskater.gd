extends CharacterBody3D
@onready var movementController := %MovementController
@onready var grindingController := %GrindingController

signal graffiti_fuel_updated(amount: float)

func _physics_process(_delta: float) -> void:
	grindingController.handle_grinding()
	movementController.handle_movement(self)
	move_and_slide()
