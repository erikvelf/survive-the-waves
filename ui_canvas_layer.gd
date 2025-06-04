extends CanvasLayer

# Vertical spacing between stacked boss bars
var bar_offset = 30

# Padding from the top of the container
var top_padding = 5

# Reference to the container node that holds all boss health bars
@onready var boss_bars_container = $BossBars

# Reference to the health bar scene (assigned in the editor)
@export var boss_health_bar_scene: PackedScene

# Dictionary to track which boss node is linked to which health bar
var boss_to_bar = {}  # boss_node: health_bar_instance

func _ready() -> void:
	# Initially hide the container until bosses spawn
	boss_bars_container.hide()


### Called when a single boss spawns ###
func _on_boss_spawned(boss: Node) -> void:
	# Check if the boss has a Health node and hasn’t already been added
	if boss.has_node("Health") and not boss_to_bar.has(boss):
		var health_node = boss.get_node("Health")
		if health_node is Health:
			# Create a new health bar from the PackedScene
			var bar = boss_health_bar_scene.instantiate()
			
			# Add the health bar to the container
			boss_bars_container.add_child(bar)

			# Bind the health bar to the boss's Health node
			bar.bind_health(health_node)

			# Track the bar for this boss
			boss_to_bar[boss] = bar

			# Recalculate positions to stack bars
			_update_bar_positions()

			# Show the container (in case it's hidden)
			boss_bars_container.show()


### Called when multiple bosses spawn (e.g. at the start of a wave) ###
func _on_main_boss_spawned() -> void:
	# Ensure the bar container is visible
	boss_bars_container.show()
	
	# Get all boss nodes in the "Boss" group
	var bosses = get_tree().get_nodes_in_group("Boss")

	# Add a bar for each boss (without duplication)
	for boss in bosses:
		_on_boss_spawned(boss)  # Reuse the logic


### Positions all boss bars vertically with padding ###
func _update_bar_positions() -> void:
	var i = 0  # Index for calculating vertical offset

	for boss in boss_to_bar.keys():
		var bar = boss_to_bar[boss]

		# Position the bar (x = 0 to align left, adjust if centering)
		bar.position = Vector2(0, top_padding + i * bar_offset)
		i += 1


### Optional: Remove the bar when a specific boss dies ###
func _on_boss_died(boss: Node) -> void:
	if boss_to_bar.has(boss):
		var bar = boss_to_bar[boss]

		# Safely remove the bar from the scene
		bar.queue_free()

		# Remove the boss from the dictionary
		boss_to_bar.erase(boss)

		# Reposition remaining bars
		_update_bar_positions()

		# Hide the container if no bars remain
		if boss_to_bar.empty():
			boss_bars_container.hide()


### Called when a wave ends to clear all boss bars ###
func _on_main_wave_cleared(wave_number: Variant) -> void:
	# Free all health bar instances
	for bar in boss_to_bar.values():
		if is_instance_valid(bar):
			bar.queue_free()

	# Clear the boss-to-bar tracking dictionary
	boss_to_bar.clear()

	# Hide the bar container
	boss_bars_container.hide()
