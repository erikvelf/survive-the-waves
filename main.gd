extends Node

var cura_scene  = preload("res://cura.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_cura_timeout() -> void:
	var cura = cura_scene.instantiate()
	
	cura.position = Vector3(randi_range(-10, 10), 1, randi_range(-10, 10))
	add_child(cura)
