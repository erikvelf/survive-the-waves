extends Control

@onready var label: Label = $Label
@export var main: Node
var total_enemies: int = 0

func _ready() -> void:
	label.text = ""

func update_enemies_counter(remained: int, total: int):
	var text = "Enemies remained: {remained}/{total}".format({ "remained": remained, "total": total})
	label.text = text

func _on_main_wave_started(wave_number: Variant) -> void:
	#if not wave_number < 1:
	total_enemies = get_total_enemies(main.wave_definitions[wave_number - 1])
	update_enemies_counter(total_enemies, total_enemies)

func get_total_enemies(wave: Dictionary) -> int:
	var total := 0
	total += wave.get("small", 0)
	total += wave.get("medium", 0)
	total += wave.get("big", 0)
	return total

func _on_main_enemies_remained(count: Variant) -> void:
	update_enemies_counter(count, total_enemies)
