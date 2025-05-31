extends CharacterBody3D

@onready var hurt_sound: AudioStreamPlayer = $HurtSound
@onready var player: CharacterBody3D = get_tree().get_nodes_in_group("Player")[0]
@onready var reaction: Timer
@export var has_slow_reaction: bool = false
@export var reaction_speed: float = 1
@export var speed = 4
@onready var player_position = Vector3(player.position.x, position.y, player.position.z) : set = set_player_position, get = get_player_position

func set_player_position(new_player_position: Vector3):
	player_position = new_player_position

func get_player_position():
	return player_position

func _ready() -> void:
	if has_slow_reaction:
		print("I have slow reaction")
		reaction = Timer.new()
		reaction.autostart = true
		reaction.connect("timeout", move_to_player)
		reaction.wait_time = reaction_speed
		add_child(reaction)
		reaction.start()


func move_to_player():
	player_position = Vector3(player.position.x, position.y, player.position.z)
	look_at(player_position)  # Rotate around Y-axis (up vector)


func _on_hurtbox_received_damage(damage: int) -> void:
	hurt_sound.play()

#func move_and_rotate_to_player():
	#var player_postition = Vector3(player.position.x, position.y, player.position.z)
	## Rotate the enemy to face the player
	#look_at(player_postition)  # Rotate around Y-axis (up vector)
#
	## Calculate the forward direction based on the rotation
	#var forward_direction = -transform.basis.z  # The forward direction is along the negative Z-axis in local space
#
	## Set the velocity in the direction the enemy is facing
	#velocity = forward_direction * speed  # Multiply by speed to get movement velocity
#
	## Move the enemy using the calculated velocity
	#move_and_slide()

#func _rotate_to_player(playerPosition: Vector3):
	#look_at(playerPosition)

func _process(_delta: float) -> void:
	# Rotate the enemy to face the player
	# look_at(player_position)  # Rotate around Y-axis (up vector)
	if not has_slow_reaction:
		move_to_player()

	# Calculate the forward direction based on the rotation
	var forward_direction = -transform.basis.z  # The forward direction is along the negative Z-axis in local space
	## Set the velocity in the direction the enemy is facing
	velocity = forward_direction * speed  # Multiply by speed to get movement velocity
#
	## Move the enemy using the calculated velocity
	move_and_slide()
##
