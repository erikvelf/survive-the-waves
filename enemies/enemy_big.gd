extends CharacterBody3D

signal died
signal boss_died

# ============================================================================
# CONSTANTS AND CONFIGURATION
# ============================================================================
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_group("Movement")
@export var movement_speed: float = 6.5
@export var rotation_speed: float = 1.0

@export_group("Combat")
@export var attack_windup_time: float = 0.8
@export var attack_active_time: float = 0.1

# ============================================================================
# NODE REFERENCES - Cached for performance
# ============================================================================
@onready var hurt_sound: AudioStreamPlayer = $HurtSound
@onready var animation_player: AnimationPlayer = $Model/AnimationPlayer
@onready var player_detector: Area3D = $PlayerDetector
@onready var hitbox: CollisionShape3D = $Hitbox/CollisionShape3D
@onready var hurtbox: CollisionShape3D = $Hurtbox/CollisionShape3D
@onready var attack_duration_timer: Timer = $AttackDurationTimer
@onready var enable_hitbox_timer: Timer = $EnableHitboxTimer
@onready var despawn_timer: Timer = $DespawnTimer
@onready var health_component = $Health

# ============================================================================
# STATE MANAGEMENT
# ============================================================================
enum EnemyState {
	MOVING_TO_PLAYER,      # Moving toward player
	ATTACKING,    # Currently in attack sequence
	DEAD          # Enemy is dead - all processes disabled
}

var current_state: EnemyState = EnemyState.MOVING_TO_PLAYER
var player: CharacterBody3D
var player_found: bool = false

# ============================================================================
# PHYSICS VARIABLES
# ============================================================================
var target_velocity: Vector3 = Vector3.ZERO
var target_rotation: float = 0.0

# ============================================================================
# INITIALIZATION
# ============================================================================
func _ready() -> void:
	"""Initialize enemy systems and validate setup"""
	_initialize_enemy()
	_find_and_cache_player()
	_validate_required_components()
	_setup_initial_state()

func _initialize_enemy() -> void:
	add_to_group("Boss")
	_set_hitbox_enabled(false)

func _find_and_cache_player() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0] as CharacterBody3D
		if player != null:
			player_found = true
		else:
			push_error("Enemy: Found player node but it's not a CharacterBody3D")
	else:
		push_error("Enemy: No player found in 'Player' group")

func _validate_required_components() -> void:
	var required_nodes = [
		"HurtSound", "Model/AnimationPlayer", "PlayerDetector",
		"Hitbox/CollisionShape3D", "AttackDurationTimer", 
		"EnableHitboxTimer", "DespawnTimer", "Health",
		"Hurtbox/CollisionShape3D"
	]
	
	for node_path in required_nodes:
		if not has_node(node_path):
			push_error("Enemy: Missing required node - " + node_path)

func _setup_initial_state() -> void:
	"""Configure initial enemy state"""
	current_state = EnemyState.MOVING_TO_PLAYER
	target_velocity = Vector3.ZERO

# ============================================================================
# PHYSICS PROCESSING - Pure physics execution
# ============================================================================
func _physics_process(delta: float) -> void:
	"""Handle physics simulation - movement and gravity only"""
	_apply_gravity(delta)
	
	# Skip all processing if dead
	if current_state == EnemyState.DEAD:
		return
		
	_execute_movement()
	_execute_rotation(delta)
	
	# Animation must loop continuously as required
	if current_state != EnemyState.ATTACKING:
		animation_player.play("idle", 0.5, 2.0)

func _apply_gravity(delta: float) -> void:
	"""Apply gravity when not grounded"""
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0

func _execute_movement() -> void:
	"""Execute the movement calculated by AI systems"""
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z
	move_and_slide()

func _execute_rotation(delta: float) -> void:
	"""Instantly rotate toward player without smoothing"""
	if player_found and player:
		var target_position = player.global_position
		target_position.y = global_position.y  # Lock Y to prevent tilting
		
		# Calculate direction to player
		var direction_to_player = (target_position - global_position).normalized()
		if direction_to_player.length() > 0.1:  # Avoid jitter when very close
			# Apply instant rotation - no smoothing, always face player immediately
			rotation.y = atan2(direction_to_player.x, direction_to_player.z)

# ============================================================================
# AI PROCESSING - Decision making and state management
# ============================================================================
func _process(delta: float) -> void:
	# Skip AI processing if dead
	if current_state == EnemyState.DEAD:
		return
		
	_update_ai_state()

func _update_ai_state() -> void:
	"""Process current AI state and determine actions"""
	match current_state:
		EnemyState.MOVING_TO_PLAYER:
			_handle_patrol_state()
		EnemyState.ATTACKING:
			_handle_attacking_state()
		EnemyState.DEAD:
			_handle_dead_state()

func _handle_patrol_state() -> void:
	"""AI logic for patrol/movement state"""
	if not player_found or not player:
		target_velocity = Vector3.ZERO
		return
	
	# Calculate movement toward player
	var direction_to_player = (player.global_position - global_position).normalized()
	direction_to_player.y = 0  # No vertical movement
	
	target_velocity = direction_to_player * movement_speed

func _handle_attacking_state() -> void:
	"""AI logic during attack sequence"""
	# Remain stationary during attack
	target_velocity = Vector3.ZERO
	# Continue facing player through rotation system

func _handle_dead_state() -> void:
	"""AI logic for dead state - no processing needed"""
	# All systems disabled, no AI processing required
	pass

func _enter_dead_state() -> void:
	"""Disable all enemy systems and enter dead state"""
	# Set state to dead to stop all AI processing
	current_state = EnemyState.DEAD
	
	# Stop all movement immediately
	target_velocity = Vector3.ZERO
	velocity = Vector3.ZERO
	
	# Disable combat systems
	_set_hitbox_enabled(false)
	_set_hurtbox_enabled(false)
	player_detector.monitoring = false
	
	# Disconnect hurtbox from damage processing to prevent taking damage when dead
	var hurtbox_node = $Hurtbox
	if hurtbox_node and hurtbox_node.has_signal("area_entered"):
		if hurtbox_node.is_connected("area_entered", hurtbox_node._on_area_entered):
			hurtbox_node.area_entered.disconnect(hurtbox_node._on_area_entered)
	
	# Stop all timers to prevent any delayed actions
	if attack_duration_timer.is_connected("timeout", _on_attack_duration_timer_timeout):
		attack_duration_timer.timeout.disconnect(_on_attack_duration_timer_timeout)
	if enable_hitbox_timer.is_connected("timeout", _on_enable_hitbox_timer_timeout):
		enable_hitbox_timer.timeout.disconnect(_on_enable_hitbox_timer_timeout)
	
	attack_duration_timer.stop()
	enable_hitbox_timer.stop()
	
	# Disable player detection to prevent new attacks
	if player_detector.is_connected("body_entered", _on_player_detector_body_entered):
		player_detector.body_entered.disconnect(_on_player_detector_body_entered)
	
	# Stop animations
	if animation_player:
		animation_player.stop()
	
	# Clear player reference to prevent any remaining interactions
	player_found = false
	player = null
	
	# Start despawn timer to remove enemy after death animation
	despawn_timer.wait_time = 4.9
	despawn_timer.one_shot = true
	despawn_timer.start()

# ============================================================================
# COMBAT SYSTEM - Attack sequence management
# ============================================================================
func _start_attack_sequence() -> void:
	"""Begin the attack sequence"""
	current_state = EnemyState.ATTACKING
	target_velocity = Vector3.ZERO
	
	# Play attack animation
	animation_player.play("standing_melee_attack_downward", 0.5, 1.0)
	
	# Start attack timing
	attack_duration_timer.wait_time = attack_windup_time
	attack_duration_timer.start()

func _complete_attack_sequence() -> void:
	"""Return to moving state after attack to resume chasing player"""
	current_state = EnemyState.MOVING_TO_PLAYER
	_set_hitbox_enabled(false)
	player_detector.monitoring = true

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================
func _set_hitbox_enabled(enabled: bool) -> void:
	"""Safely enable/disable the attack hitbox"""
	if hitbox:
		hitbox.set_deferred("disabled", not enabled)
		
func _set_hurtbox_enabled(enabled: bool) -> void:
	"""Safely enable/disable the attack hitbox"""
	if hurtbox:
		hurtbox.set_deferred("disabled", not enabled)
# ============================================================================
# SIGNAL HANDLERS - Event responses
# ============================================================================
func _on_player_detector_body_entered(body: Node3D) -> void:
	"""Handle player entering detection range"""
	# Ignore all input when dead
	if current_state == EnemyState.DEAD:
		return
		
	if body.is_in_group("Player") and not (body is Hitbox):
		_start_attack_sequence()

func _on_attack_duration_timer_timeout() -> void:
	"""Handle attack windup completion - enable hitbox"""
	# Ignore timer events when dead
	if current_state == EnemyState.DEAD:
		return
		
	player_detector.monitoring = false
	_set_hitbox_enabled(true)
	
	# Start timer for how long hitbox stays active
	enable_hitbox_timer.wait_time = attack_active_time
	enable_hitbox_timer.start()

func _on_enable_hitbox_timer_timeout() -> void:
	"""Handle end of attack - disable hitbox and return to detected state"""
	# Ignore timer events when dead
	if current_state == EnemyState.DEAD:
		return
		
	_complete_attack_sequence()

func _on_hurtbox_received_damage(damage: int) -> void:
	"""Handle taking damage from player"""
	# Ignore damage when already dead
	if current_state == EnemyState.DEAD:
		return
		
	hurt_sound.play()

func _on_health_health_depleted() -> void:
	"""Handle enemy death"""
	# Enter dead state to disable all systems
	_enter_dead_state()
	
	# Emit death signals
	died.emit()
	boss_died.emit()
	animation_player.play("death")
	# Remove enemy from scene
	#queue_free()

func _on_despawn_timer_timeout() -> void:
	"""Handle despawn timer completion - remove enemy from scene"""
	queue_free()
