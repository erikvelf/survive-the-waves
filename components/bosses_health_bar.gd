extends TextureProgressBar

@onready var bosses: Array[CharacterBody3D]
var bosses_health = []

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#print("Bosses found: ", bosses)
	#if bosses_health != null:
		#print("Health", bosses_health[0])
		#var first_boss_health: Health = bosses_health[0]
		#max_value = first_boss_health.max_health
		#value = first_boss_health.health
		#first_boss_health.health_changed.connect(_update_bar)


func _update_bar(_diff: int):
	#print("Boss health updated: ", bosses_health)
	value = bosses_health[0].get_health()

func _on_main_boss_spawned() -> void:
	#bosses = get_tree().get_nodes_in_group("Boss")
	#set_bosses(bosses)
	var bosses = get_tree().get_nodes_in_group("Boss")
	#var bosses_health: Array[Health] = []
	print("Boss signal received, bosses: ", bosses)

	for boss in bosses:
		if boss.has_node("Health"):
			var health_node = boss.get_node("Health")
			if health_node is Health:
				bosses_health.append(health_node)
	print("Bosses health", bosses_health)
	
	#if bosses_health.size() > 0:
		#print("Health", bosses_health[0])
		#var first_boss_health: Health = bosses_health[0]
		#max_value = first_boss_health.max_health
		#value = first_boss_health.health
		#first_boss_health.health_changed.connect(_update_bar)
	var first_boss_health = bosses_health[0]
	max_value = first_boss_health.max_health
	value = first_boss_health.health
	print("First boss health: ", first_boss_health.health)
	first_boss_health.health_changed.connect(_update_bar)
