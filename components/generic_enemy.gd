extends CharacterBody3D

var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity") # Default: 9.8 * 3 = 29.4
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
		reaction = Timer.new()
		reaction.autostart = true
		reaction.connect("timeout", move_to_player)
		reaction.wait_time = reaction_speed
		add_child(reaction)
		reaction.start()

func move_to_player():
	var target_pos = player.global_transform.origin
	target_pos.y = global_transform.origin.y  # Lock Y position
	look_at(target_pos, Vector3.UP)

func _on_hurtbox_received_damage(damage: int) -> void:
	hurt_sound.play()

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0

	# Calculate horizontal movement
	var forward_direction = -transform.basis.z
	velocity.x = forward_direction.x * speed
	velocity.z = forward_direction.z * speed

	move_and_slide()
	
	# If it has slow reaction, the timer will call move_to_player()
	if not has_slow_reaction:
		move_to_player()
