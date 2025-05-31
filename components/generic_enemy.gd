extends CharacterBody3D

@onready var hurt_sound: AudioStreamPlayer = $HurtSound
@onready var player: CharacterBody3D = get_tree().get_nodes_in_group("Player")[0]

func _on_hurtbox_received_damage(damage: int) -> void:
	hurt_sound.play()

func _physics_process(delta: float) -> void:
	look_at(Vector3(player.position.x, position.y, player.position.z))
