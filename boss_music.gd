extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_boss_spawned() -> void:
	play()




func _on_main_wave_started(wave_number: Variant) -> void:
	var bosses = get_tree().get_nodes_in_group("Boss")
	if bosses != null:
		stop()
