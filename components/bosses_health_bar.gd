# BossHealthBar.gd
extends TextureProgressBar

var health_node: Health

func bind_health(health: Health):
	health_node = health
	max_value = health.max_health
	value = health.health
	health.health_changed.connect(_on_health_changed)

func _on_health_changed(_diff: int):
	if is_instance_valid(health_node):
		value = health_node.health
