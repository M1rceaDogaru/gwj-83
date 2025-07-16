extends Node2D

@export var mobs: Array[MobSpawnConfig]

func _ready():
	$MobTimer.start()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob_to_spawn = get_weighted_mob_to_spawn()
	var mob = mob_to_spawn.creature.instantiate()

	var spawn_from_left = randi() % 2 == 0
	var mob_spawn_location
	# Choose a random location on Path2D.
	if spawn_from_left:
		mob_spawn_location = $MobSpawnPathLeft/MobSpawnLocation
	else:
		mob_spawn_location = $MobSpawnPathRight/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	var direction = mob_spawn_location.rotation
	mob.set_meta("IsFacingRight", direction < 0)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func get_weighted_mob_to_spawn() -> MobSpawnConfig:
	var total_weight = 0.0
	for config in mobs:
		total_weight += config.weight

	if total_weight == 0:
		return null

	var choice = randf() * total_weight
	var current = 0.0

	for config in mobs:
		current += config.weight
		if choice <= current:
			return config

	return mobs.back()  # Fallback
