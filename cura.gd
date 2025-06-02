extends Node3D

@export var healing: int = 30

func _process(delta: float) -> void:
	rotate(Vector3.UP, 1 * delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("Player"):
		var health: Health = body.get_node("Health")
		health.set_health(health.health + healing)
		var audio_player = $AudioStreamPlayer
		
		audio_player.play()
		audio_player.connect("finished", Callable(self, "_on_sound_finished"))  # Wait for sound to finish
		$Area3D.monitoring = false  # Prevent double healing
		$Model.hide()

func _on_sound_finished():
	queue_free()
