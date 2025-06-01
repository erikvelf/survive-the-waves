extends TextureProgressBar

@export var character: CharacterBody3D
@onready var health: Health = character.find_children("*", "Health")[0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(character)
	max_value = health.max_health
	value = health.health
	health.health_changed.connect(_update_bar)

func _update_bar(_diff: int):
	value = health.get_health()
