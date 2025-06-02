extends Label

@export var main: Node
@onready var wave_definitions = main.wave_definitions


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_wave_started(wave_number: Variant) -> void:
	text = "Wave " + str(wave_number) + "/" + str(wave_definitions.size())
