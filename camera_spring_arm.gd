extends SpringArm3D

@export var mouse_sensibility: float = 0.004

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Input.mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#rotation.y -= event.relative.x * mouse_sensibility
		rotation.y -= event.relative.x * mouse_sensibility
		rotation.y = wrapf(rotation.y, 0.0, TAU)
		#owner.rotation.y -= event.relative.x * mouse_sensibility
		#owner.rotation.x -= event.relative.y * mouse_sensibility
		rotation.x -= event.relative.y * mouse_sensibility
		rotation.x = clamp(rotation.x, -PI/2, PI/4)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
