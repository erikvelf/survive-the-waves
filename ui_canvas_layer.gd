extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BossBars.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_boss_spawned() -> void:
	$BossBars.show()
