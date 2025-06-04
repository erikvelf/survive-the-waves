extends Control

func _ready() -> void:
	hide()

func _on_main_all_waves_completed() -> void:
	show()
