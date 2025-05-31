extends Node3D



func _on_health_health_depeleted() -> void:
	queue_free()
