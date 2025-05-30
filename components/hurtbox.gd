class_name Hurtbox
extends Area3D

signal received_damage(damage: int)
@export var health: Health

func _ready() -> void:
	connect("area_entered", self._on_area_entered)

func _on_area_entered(hitbox) -> void:
	# check if the hitbox is really a hitbox and not a body
	if hitbox != null && hitbox is Hitbox:
		health.set_health(health.health - hitbox.damage)
		received_damage.emit(hitbox.damage)
		print("I have to be damaged ", owner.name, " My health is: ", health.health)
