class_name Health
extends Node

signal max_health_changed(diff: int)
signal health_changed(diff: int)
signal health_depeleted

@export var max_health: int = 100 : set = set_max_health, get = get_max_health
@export var immortality: bool = false

var immortality_timer: Timer = null
@onready var health: int = max_health


# Max Health setters and getters
func set_max_health(value: int):
	var clamped_value = 1 if value <= 0 else value
	
	# Emmit signal that max health changed if it really changed
	if not clamped_value == max_health:
		max_health = value
		var diff = clamped_value - max_health
		max_health_changed.emit(diff)
	
	if health > max_health:
		health = max_health

func get_max_health():
	return max_health

# Immortality setters and getters
## Render entity immortal for some time in seconds
func set_temporary_immortality(time: float):
	# Checks for reusing the timer
	if immortality == null:
		immortality_timer = Timer.new()
		immortality_timer.one_shot = true
		add_child(immortality_timer)
	
	if immortality_timer.timeout.is_connected(set_immortality):
		immortality_timer.timeout.disconnect(set_immortality)
	
	immortality = true
	immortality_timer.set_wait_time(time)
	immortality_timer.timeout.connect(set_immortality(false))
	immortality_timer.start()
	

func set_immortality(value: bool):
	immortality = value

func get_immortality():
	return immortality

# Health setters and getters
func set_health(value: int):
	if value < health and immortality:
		return
	
	var clamped_value = clampi(value, 0, max_health)
	if clamped_value != health:
		var diff = clamped_value - health
		health = clamped_value
		health_changed.emit(diff)
		
	if health == 0:
		health_depeleted.emit()

func get_health():
	return health

	
