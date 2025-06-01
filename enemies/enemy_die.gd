extends Node3D

signal died

@onready var health: Health = $GenericEnemy/Health

func _ready() -> void:
	health.health_depeleted.connect(_on_health_depleted)

func _on_health_depleted():
	print("I am dead")
	if not is_queued_for_deletion(): # prevent double signal emmition
		emit_signal("died")
		queue_free()
		
