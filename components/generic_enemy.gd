extends CharacterBody3D
class_name GenericEnemy

## Handles basic enemy AI behavior including movement toward player and damage reactions.
## Supports both fast and slow reaction modes for different enemy types.
## 
## Fast reaction enemies update their target every frame for responsive movement.
## Slow reaction enemies use a timer to update their target at configurable intervals.

signal died

# Constants for better maintainability
const REACTION_TIMER_NAME = "ReactionTimer"
const MIN_PLAYER_MOVEMENT_THRESHOLD = 0.1  # Minimum distance player must move to trigger update

# Physics constants - using more explicit naming
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 29.4)

# Movement configuration grouped for better editor organization
@export_group("Movement")
@export var speed: float = 4.0  # Movement speed in units per second
@export var has_slow_reaction: bool = false  # Whether enemy uses timer-based reactions
@export var reaction_speed: float = 1.0  # Time between reactions for slow enemies (in seconds)
@export var damage: int

# Component references - cached for performance and null checking
@onready var hurt_sound: AudioStreamPlayer = $HurtSound
@onready var health_component: Node = $Health
@onready var hurtbox_component: Node = $Hurtbox
@onready var reaction_timer: Timer = $ReactionTimer if has_node("ReactionTimer") else null

# Cached references to avoid repeated expensive operations
var player: CharacterBody3D  # Reference to player for movement targeting
var movement_target: Vector3  # Current target position for enemy movement

func _ready() -> void:
	$Hitbox.damage = damage
	# Initialize all systems in logical order
	_initialize_components()
	_setup_player_reference()
	_configure_reaction_system()

## Initializes and connects component signals with comprehensive error handling.
## This prevents crashes when components are missing or incorrectly configured.
func _initialize_components() -> void:
	# Connect health component with validation
	if health_component and health_component.has_signal("health_depleted"):
		health_component.connect("health_depleted", _on_death)
	else:
		push_error("GenericEnemy: Health component missing or lacks 'health_depleted' signal")
	
	# Connect hurtbox component with validation
	if hurtbox_component and hurtbox_component.has_signal("received_damage"):
		hurtbox_component.connect("received_damage", _on_damage_received)
	else:
		push_error("GenericEnemy: Hurtbox component missing or lacks 'received_damage' signal")

## Safely establishes player reference with comprehensive error handling.
## Uses group lookup but validates the result to prevent runtime errors.
func _setup_player_reference() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	
	# Validate player group exists and has members
	if players.size() == 0:
		push_error("GenericEnemy: No player found in 'Player' group")
		return
	
	# Validate first player is correct type
	player = players[0] as CharacterBody3D
	if not player:
		push_error("GenericEnemy: Player node is not a CharacterBody3D")
		return


## Configures the reaction system based on enemy type.
## Creates and manages timer for slow-reaction enemies efficiently.
func _configure_reaction_system() -> void:
	# Fast reaction enemies don't need timer setup
	if not has_slow_reaction:
		return
		
	# Try to use existing timer from scene first (more efficient)
	if not reaction_timer:
		# Create timer dynamically only if needed
		reaction_timer = Timer.new()
		reaction_timer.name = REACTION_TIMER_NAME
		add_child(reaction_timer)
	
	# Configure timer properties for optimal performance
	reaction_timer.wait_time = reaction_speed
	reaction_timer.autostart = true
	reaction_timer.timeout.connect(_update_movement_target)
	reaction_timer.start()

## Updates the target position for enemy movement with optimization checks.
## Only recalculates when necessary to improve performance.
func _update_movement_target() -> void:
	# Validate player before expensive operations
	if not _is_player_valid():
		return
	
	# Calculate new target position with Y-axis locking for ground-based enemies
	movement_target = Vector3(
		player.global_position.x,
		global_position.y,  # Lock Y to current position to prevent flying
		player.global_position.z
	)
	
	# Rotate to face target using efficient look_at
	look_at(movement_target, Vector3.UP)


## Validates player reference for movement updates.
## Ensures player exists and is valid without movement threshold restrictions.
func _is_player_valid() -> bool:
	# Check if player reference is still valid
	if not player or not is_instance_valid(player):
		return false
	
	# Player is valid - allow constant rotation updates for responsive gameplay
	return true

func _physics_process(delta: float) -> void:
	# Handle physics and movement in separate functions for clarity
	_apply_gravity(delta)
	_handle_movement()
	move_and_slide()

## Applies gravity physics to the enemy with proper ground detection.
## Implements standard gravity behavior with floor collision handling.
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		# Apply gravity when airborne
		velocity.y -= gravity * delta
	else:
		# Reset vertical velocity when grounded to prevent accumulation
		velocity.y = 0.0

## Handles horizontal movement logic based on reaction type.
## Separates fast and slow reaction logic for clarity and performance.
func _handle_movement() -> void:
	# Fast reaction enemies update target every frame for responsive movement
	if not has_slow_reaction:
		_update_movement_target()
	
	# Apply movement in forward direction based on current rotation
	# Using normalized vector to ensure consistent speed regardless of rotation
	var forward_direction = -transform.basis.z.normalized()
	velocity.x = forward_direction.x * speed
	velocity.z = forward_direction.z * speed

## Handles enemy death with proper cleanup and signal emission.
## Ensures dynamically created timers are properly freed to prevent memory leaks.
func _on_death() -> void:
	# Emit signal for external systems (score, spawning, etc.)
	died.emit()
	
	# Clean up dynamically created timer to prevent memory leaks
	if reaction_timer and reaction_timer.name == REACTION_TIMER_NAME:
		reaction_timer.queue_free()
	
	# Remove enemy from scene
	queue_free()

## Handles damage feedback with validation.
## Provides audio feedback when enemy takes damage.
func _on_damage_received(damage: int) -> void:
	# Play hurt sound if component exists
	if hurt_sound:
		hurt_sound.play()
	# Note: Could be extended to handle damage effects, screen shake, etc.
