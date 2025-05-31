extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate(Vector3.UP, 0.01) # rotate the boost


func _on_area_3d_body_entered(body: Node3D) -> void:
	queue_free()
