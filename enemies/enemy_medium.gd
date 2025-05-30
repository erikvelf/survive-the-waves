extends Node3D

# THIS NODE EXISTS ONLY 
func _on_health_health_depeleted() -> void:
	queue_free()
