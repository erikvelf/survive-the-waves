extends CharacterBody3D

const MAX_SPEED: float = 7.0
const MIN_SPEED: float = 5.0
var speed: float = 7.0
const JUMP_VELOCITY = 5 # 4.5
@export var damage: int
@onready var pivot = $Pivot # Gira la camera dentro il giocatore
@export var sensibility = 0.1
@onready var playerModel: Node3D = $PlayerModel
@onready var playerAnimation: AnimationPlayer = $PlayerModel/AnimationPlayer # Nodo animazione dentro al PlayerModel
#@onready var hitbox: Hitbox = $Hitbox
@onready var hitbox: CollisionShape3D = $Hitbox/CollisionShape3D

# Sistema di togliere il hitbox quando non stai menando i mob
func set_is_hitbox_disabled(collision_shape: CollisionShape3D, value: bool):
	collision_shape.set_deferred("disabled", value)
	

func go_attack():
	playerAnimation.play("attack", 0.05, 1.2)
	set_is_hitbox_disabled(hitbox, false)

func go_idle():
	playerAnimation.play("Armature|Walk", -1) # Animazione default
	#playerAnimation.play("Armature|Walk", 0.05) # 0.05 sarebbero il passaggio da un animazione all altra in maniera liscia
	set_is_hitbox_disabled(hitbox, true)

func _ready() -> void:
	$Hitbox.damage = damage
	add_to_group("Player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Nascondi cursore per giocare

func _input(event):
	# Gira l'intero Player nodo (CharacterBody3D)
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensibility))
		pivot.rotate_x(deg_to_rad(event.relative.y * sensibility))
		# La camera si muove su e giu massimo tra -45 e 45 gradi
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-45), deg_to_rad((45)))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("attack"):
		go_attack() # Riproduci animazione 'attack' in velocita 2x
	else:
		go_idle()
	
	if Input.is_action_pressed("left_shift"):
		speed = MIN_SPEED
	else:
		speed = MAX_SPEED
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_right", "move_left", "move_back", "move_forward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
		
