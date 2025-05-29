extends CharacterBody3D


const SPEED = 7.0
const JUMP_VELOCITY = 4.5
const DAMAGE = 40
@onready var pivot = $Pivot # Gira la camera dentro il giocatore
@export var sensibility = 0.1
@onready var playerAnimation: AnimationPlayer = $PlayerModel/AnimationPlayer # Nodo animazione dentro al PlayerModel
@onready var hitbox: Area3D = $Hitbox

func attack():
	var enemies = hitbox.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.has_method("hurt"):
			enemy.hurt(DAMAGE)

func setStateIdle():
	playerAnimation.play("Armature|Walk", 0.05) # 0.05 sarebbero il passaggio da un animazione all altra in maniera liscia

func setStateAttack():
	playerAnimation.play("attack", 0.05, 1.2)
	attack()

func _ready() -> void:
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
		setStateAttack() # Riproduci animazione 'attack' in velocita 2x
	else:
		playerAnimation.play("Armature|Walk", -1) # Animazione default
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_right", "move_left", "move_back", "move_forward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
