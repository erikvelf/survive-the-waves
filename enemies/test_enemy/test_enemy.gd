extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var health = 220
@onready var hurtbox_timer = $HurtboxCooldownTimer
@onready var hurtbox = $Hurtbox
@onready var hurt_sound = $HurtSoundPlayer
@onready var die_timer = $DieTimer

func hurt(damage: int):
	print("Hurt")
	health -= damage
	disable_hurtbox()
	print("Health", health)

func disable_hurtbox(): # attivato quando picchiato
	hurtbox_timer.start()
	hurt_sound.play()
	hurtbox.set_deferred("disabled", true)

	
func enable_hurtbox():
	hurtbox.set_deferred("disabled", false)
	print("hurtbox enabled")

func _process(delta: float) -> void:
	if health <= 0:
		print("Enemy died")
		self.queue_free()

#func die():
	#print("test_enemy died")
	#self.queue_free()

#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()

	
