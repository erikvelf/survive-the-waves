extends CharacterBody3D

var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity") # Default: 9.8 * 3 = 29.4
@onready var hurt_sound: AudioStreamPlayer = $HurtSound
@onready var player: CharacterBody3D = get_tree().get_nodes_in_group("Player")[0]
@onready var reaction: Timer
@export var has_slow_reaction: bool = false
@export var reaction_speed: float = 1
@export var speed = 2
@onready var player_position = Vector3(player.position.x, position.y, player.position.z) : set = set_player_position, get = get_player_position
@onready var animation = $EnemyBig/AnimationPlayer

@onready var player_detector = $PlayerDetector

@onready var hitbox: CollisionShape3D = $Hitbox/CollisionShape3D
var is_attacking = false

func set_player_position(new_player_position: Vector3):
	player_position = new_player_position

func get_player_position():
	return player_position

func set_is_hitbox_disabled(collision_shape: CollisionShape3D, value: bool):
	collision_shape.set_deferred("disabled", value)

func _ready() -> void:
	set_is_hitbox_disabled(hitbox, true)
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
		
	if not is_attacking:
		animation.play("Armature|mixamo_com|Layer0")
		# Calculate horizontal movement
		var forward_direction = -transform.basis.z
		velocity.x = forward_direction.x * speed
		velocity.z = forward_direction.z * speed

		move_and_slide()
	
		# If it has slow reaction, the timer will call move_to_player()
		if not has_slow_reaction:
			move_to_player()


func _on_player_detector_body_entered(body: Node3D) -> void:
	# Since the player wehn hitting, its hitbox renders and we dont want it to trigger our enemy
	if body.is_in_group("Player") and body is not Hitbox:
		is_attacking = true
		animation.play("standing_melee_attack_downward", -1, 1.0)
		$AttackDurationTimer.start()

func _on_attack_duration_timer_timeout() -> void:
	player_detector.monitoring = false
	$EnableHitboxTimer.start()
	set_is_hitbox_disabled(hitbox, false)


func _on_enable_hitbox_timer_timeout() -> void:
	player_detector.monitoring = true
	is_attacking = false
	set_is_hitbox_disabled(hitbox, true)
