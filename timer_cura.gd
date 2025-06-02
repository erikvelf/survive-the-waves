extends Timer

@export var boost: PackedScene

func _on_timeout() -> void:
	var prepared_boost = boost.instantiate()
	prepared_boost.position = Vector3(randi_range(-10, 10), 1, randi_range(-10, 10))
	add_child(prepared_boost)
