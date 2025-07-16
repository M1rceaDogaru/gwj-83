extends Node2D

@export var mob_scene: PackedScene

func _ready():
	$MobTimer.start()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

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
