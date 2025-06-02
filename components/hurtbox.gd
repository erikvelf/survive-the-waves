class_name Hurtbox
extends Area3D

signal received_damage(damage: int)
@onready var health: Health = $"../Health"

@onready var disable_hurtbox: Timer = Timer.new() # Timer to disable hurtbox for disable_hurtbox_time seconds
@export var disable_hurtbox_time: float = 0.5

func _ready() -> void:
	add_child(disable_hurtbox)
	connect("area_entered", self._on_area_entered)
	disable_hurtbox.connect("timeout", activate_hurtbox)
	disable_hurtbox.one_shot = false

func _on_area_entered(hitbox) -> void:
	# check if the hitbox is really a hitbox and not a body
	if hitbox != null && hitbox is Hitbox:
		health.set_health(health.health - hitbox.damage)
		received_damage.emit(hitbox.damage)
		#print("I have to be damaged ", owner.name, " My health is: ", health.health)
		disable_hurtbox_temporarely(disable_hurtbox_time)
		
func set_is_hurtbox_disabled(value: bool):
	$CollisionShape3D.set_deferred("disabled", value)

func activate_hurtbox():
	set_is_hurtbox_disabled(false)
	#print("Activated hitbox")

## Disable hurtbox when hit, so you take damage gradually
func disable_hurtbox_temporarely(time: float):
	# Checks for reusing the timer
	set_is_hurtbox_disabled(true)
	disable_hurtbox.start(time)
