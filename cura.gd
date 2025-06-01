extends Node3D

@export var healing: int = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate(Vector3.UP, 0.01) # rotate the boost


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		var health: Health = body.get_node("Health")
		health.set_health(health.health + healing)
		queue_free()
			
