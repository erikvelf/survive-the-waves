extends CharacterBody3D

@onready var hurt_sound: AudioStreamPlayer = $HurtSound

func _on_hurtbox_received_damage(damage: int) -> void:
	hurt_sound.play()
	
