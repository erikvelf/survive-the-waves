extends CharacterBody3D

@onready var hurt_sound: AudioStreamPlayer = $HurtSound
@onready var player: CharacterBody3D = get_tree().get_nodes_in_group("Player")[0]
@export var speed = 4

func _on_hurtbox_received_damage(damage: int) -> void:
	hurt_sound.play()

func _process(_delta: float) -> void:
	var player_postition = Vector3(player.position.x, position.y, player.position.z)
	##var direction = (player_postition - position).normalized()
	##velocity = direction * speed
	#velocity = Vector3.FORWARD * speed
	#look_at(player_postition, Vector3.UP)
	#move_and_slide()

	# Rotate the enemy to face the player
	look_at(player_postition)  # Rotate around Y-axis (up vector)

	# Calculate the forward direction based on the rotation
	var forward_direction = -transform.basis.z  # The forward direction is along the negative Z-axis in local space

	# Set the velocity in the direction the enemy is facing
	velocity = forward_direction * speed  # Multiply by speed to get movement velocity

	# Move the enemy using the calculated velocity
	move_and_slide()
#
