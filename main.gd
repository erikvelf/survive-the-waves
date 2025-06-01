# main.gd
extends Node # Or Node, if you don't need 3D properties directly on Main

# --- EXPORTED VARIABLES (Set these in the Godot Editor Inspector) ---
@export var enemy_small_scene: PackedScene
@export var enemy_medium_scene: PackedScene
@export var enemy_big_scene: PackedScene
@export var spawn_path: Path3D
@export var spawn_path_follow: PathFollow3D
@export var enemies_container: Node3D
@export var wave_timer: Timer # Timer for the delay BETWEEN waves

# --- SIGNALS ---
signal wave_started(wave_number) # Emitted when a wave's enemies begin spawning
signal wave_cleared(wave_number) # Emitted when all enemies of a wave are defeated
signal all_waves_completed

# --- WAVE CONFIGURATION ---
var wave_definitions = [
	{"small": 5, "medium": 0, "big": 0},      # Wave 1
	{"small": 10, "medium": 2, "big": 0},     # Wave 2
	{"small": 15, "medium": 5, "big": 0},     # Wave 3
	{"small": 0, "medium": 10, "big": 0},     # Wave 4
	{"small": 15, "medium": 5, "big": 0},     # Wave 3
	{"small": 100, "medium": 50, "big": 0}      # Final finishing wave
]

# --- STATE VARIABLES ---
var current_wave_index: int = -1 # Start at -1 so the first wave is 0
var enemies_alive_in_current_wave: int = 0
var game_active: bool = false # Is a wave currently active?

func _ready():
	# --- VALIDATION (same as before, good practice) ---
	if not enemy_small_scene or not enemy_medium_scene or not enemy_big_scene:
		printerr("ERROR: One or more enemy scenes are not assigned in Main.gd!")
		get_tree().quit(); return
	if not spawn_path or not spawn_path_follow:
		printerr("ERROR: Spawn path or path follow node not assigned in Main.gd!")
		get_tree().quit(); return
	if not enemies_container:
		printerr("ERROR: Enemies container node not assigned in Main.gd!")
		get_tree().quit(); return
	if not wave_timer:
		printerr("ERROR: WaveTimer node not assigned in Main.gd!")
		get_tree().quit(); return
	if spawn_path_follow.get_parent() != spawn_path:
		printerr("ERROR: SpawnPathFollow3D must be a direct child of SpawnPath3D.")
		get_tree().quit(); return
		
	# Connect the timer's timeout signal. This timer is now for the inter-wave delay.
	wave_timer.timeout.connect(_on_inter_wave_timer_timeout)

	# Start the game by preparing the first wave.
	# If you want an initial delay before the VERY first wave,
	# you could start a different timer here and have IT call _prepare_next_wave().
	# For now, we start wave 1 fairly quickly.
	print("Game starting. Preparing for first wave...")
	_prepare_next_wave()


# --- WAVE MANAGEMENT ---

func _prepare_next_wave():
	"""
	Increments the wave counter and initiates spawning for the new wave.
	Handles game completion if all waves are done.
	This is called either initially or after the inter-wave timer.
	"""
	current_wave_index += 1

	if current_wave_index < wave_definitions.size():
		var wave_data = wave_definitions[current_wave_index]
		print("Starting Wave ", current_wave_index + 1)
		emit_signal("wave_started", current_wave_index + 1) # Wave number is 1-based for UI
		spawn_wave(wave_data.get("small", 0), 
				   wave_data.get("medium", 0), 
				   wave_data.get("big", 0))
		game_active = true # The wave is now active
	else:
		# This case should generally not be reached here if logic is correct,
		# as _on_all_enemies_defeated handles the final "all_waves_completed".
		# But it's a fallback.
		print("All waves logic seems to have been passed. Game over or error.")
		game_active = false


func spawn_wave(small_count: int, medium_count: int, big_count: int):
	"""
	Spawns the specified number of each enemy type for the current wave.
	Connects their 'died' signal to track when they are defeated.
	"""
	enemies_alive_in_current_wave = 0 # Reset counter for the new wave

	for i in range(small_count):
		spawn_enemy(enemy_small_scene)
	for i in range(medium_count):
		spawn_enemy(enemy_medium_scene)
	for i in range(big_count):
		spawn_enemy(enemy_big_scene)
	
	print("Wave ", current_wave_index + 1, " spawned. Total enemies: ", enemies_alive_in_current_wave)
	
	# If a wave spawns 0 enemies (e.g., a pause wave, or misconfiguration)
	# this will immediately trigger wave completion.
	if enemies_alive_in_current_wave == 0 and game_active: # ensure wave was meant to be active
		print("Wave has no enemies, proceeding to wave cleared.")
		_on_all_enemies_defeated()


func spawn_enemy(enemy_scene: PackedScene):
	"""
	Helper function to instance an enemy, set its position, and connect its signal.
	"""
	if not enemy_scene:
		printerr("Attempted to spawn a null enemy scene.")
		return

	spawn_path_follow.progress_ratio = randf()
	var spawn_position = spawn_path_follow.global_position

	var enemy_instance = enemy_scene.instantiate()
	if not enemy_instance:
		printerr("Failed to instantiate enemy scene: ", enemy_scene.resource_path)
		return
		
	enemies_container.add_child(enemy_instance)
	enemy_instance.global_position = spawn_position

	if enemy_instance.has_signal("died"):
		enemy_instance.died.connect(_on_enemy_died)
		enemies_alive_in_current_wave += 1
	else:
		printerr("WARNING: Enemy scene ", enemy_scene.resource_path, " does not have a 'died' signal.")


# --- ENEMY DEATH AND WAVE COMPLETION HANDLING ---

func _on_enemy_died():
	"""
	Called when an enemy's 'died' signal is emitted.
	Decrements the count of live enemies and checks if the wave is finished.
	"""
	if not game_active: # Only process if a wave is supposed to be active
		# This might happen if an enemy dies after the wave is already marked as cleared
		# (e.g. a lingering projectile)
		print("Enemy died but wave is not active. Ignoring.")
		return

	enemies_alive_in_current_wave -= 1
	print("Enemy died. Enemies remaining in wave ", current_wave_index + 1, ": ", enemies_alive_in_current_wave)

	if enemies_alive_in_current_wave <= 0:
		_on_all_enemies_defeated()


func _on_all_enemies_defeated():
	"""
	Called when all enemies in the current wave are defeated.
	This is where the inter-wave delay timer will now be started.
	"""
	if not game_active: # Avoid double-triggering if already processed
		return
		
	print("Wave ", current_wave_index + 1, " cleared!")
	game_active = false # Mark current wave as no longer active
	emit_signal("wave_cleared", current_wave_index + 1) # Renamed signal for clarity

	# Check if that was the last wave
	if current_wave_index >= wave_definitions.size() - 1:
		print("All waves completed! YOU WIN!")
		emit_signal("all_waves_completed")
		# Potentially stop game, show victory screen, etc.
	else:
		# Not the last wave, so start the timer for the delay until the next wave.
		print("Starting 5-second timer for the next wave...")
		wave_timer.wait_time = 5.0 # 5-second delay
		wave_timer.start()


func _on_inter_wave_timer_timeout():
	"""
	Called when the WaveTimer (inter-wave delay) finishes.
	Proceeds to prepare and spawn the next wave.
	"""
	print("Inter-wave timer timed out. Preparing next wave.")
	_prepare_next_wave()


# --- UTILITY (Optional) ---
func _input(event):
	if event.is_action_pressed("ui_accept") and OS.is_debug_build():
		if game_active and enemies_alive_in_current_wave > 0:
			# If a wave is active, let's "kill all" for quick testing
			print("DEBUG: Forcing all enemies in current wave to die.")
			# This is a bit hacky for demo; proper way would be to call die() on each
			for enemy in enemies_container.get_children():
				if enemy.has_method("die"): # Check if it's one of our enemies
					enemy.call_deferred("die") # Call die safely
			# _on_all_enemies_defeated() will be called once all 'died' signals are processed
		elif not game_active and wave_timer.is_stopped() and current_wave_index < wave_definitions.size() -1 :
			 # If between waves (timer stopped) and not all waves done
			print("DEBUG: Forcing start of next wave (skipping timer).")
			_prepare_next_wave()
		elif not game_active and not wave_timer.is_stopped():
			print("DEBUG: Inter-wave timer is active. Forcing it to timeout.")
			wave_timer.stop() # Stop it
			_on_inter_wave_timer_timeout() # Manually call its timeout logic
