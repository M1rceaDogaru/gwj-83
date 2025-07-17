extends Node2D

@export var level1_mobs: Array[MobSpawnConfig]
@export var level2_mobs: Array[MobSpawnConfig]
@export var level3_mobs: Array[MobSpawnConfig]
@export var level4_mobs: Array[MobSpawnConfig]
@export var level5_mobs: Array[MobSpawnConfig]

@export var level1_camera_zoom = 0.5

@export var level2_camera_scale = 1.5
@export var level5_camera_scale = 3.5

@export var level2_spawn_offset = 160
@export var level5_spawn_offset = 1400

@export var camera_zoom_time = 20.0 # Larger value means slower zoom

@export var score_to_level2 = 20
@export var score_to_level3 = 40
@export var score_to_level4 = 140
@export var score_to_level5 = 180

@export var level2_spawn_wait_time = 0.75
@export var level3_spawn_wait_time = 0.70
@export var level4_spawn_wait_time = 0.75
@export var level5_spawn_wait_time = 0.5

var level = 1

var level1_mob_spawn_path_left_point_positions
var level1_mob_spawn_path_right_point_positions

var level2_camera_zoom
var level2_zoom_delta
var level5_camera_zoom
var level5_zoom_delta

var first_spawn_in_level = true

func _ready():
	$MobTimer.start()
	
	level2_camera_zoom = level1_camera_zoom / level2_camera_scale
	level2_zoom_delta = (level1_camera_zoom - level2_camera_zoom) / camera_zoom_time
	level5_camera_zoom = level1_camera_zoom / level5_camera_scale
	level5_zoom_delta = (level1_camera_zoom - level5_camera_zoom) / camera_zoom_time
	
	level1_mob_spawn_path_left_point_positions = [
		$MobSpawnPathLeft.curve.get_point_position(0),
		$MobSpawnPathLeft.curve.get_point_position(1)
	]
	level1_mob_spawn_path_right_point_positions = [
		$MobSpawnPathRight.curve.get_point_position(0),
		$MobSpawnPathRight.curve.get_point_position(1)
	]
	
func _physics_process(delta):
	if level == 2:
		var zoom_result = max($Camera2D.zoom.x - level2_zoom_delta, level2_camera_zoom)
		$Camera2D.zoom = Vector2.ONE * zoom_result
	elif level == 5:
		var zoom_result = max($Camera2D.zoom.x - level5_zoom_delta, level5_camera_zoom)
		$Camera2D.zoom = Vector2.ONE * zoom_result

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob_to_spawn
	if first_spawn_in_level:
		mob_to_spawn = get_mobs()[-1]
		first_spawn_in_level = false
	else:
		mob_to_spawn = get_weighted_mob_to_spawn()
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

func get_mobs() -> Array[MobSpawnConfig]:
	var mobs
	if level == 1:
		mobs = level1_mobs
	elif level == 2:
		mobs = level2_mobs
	elif level == 3:
		mobs = level3_mobs
	elif level == 4:
		mobs = level4_mobs
	elif level == 5:
		mobs = level5_mobs
	return mobs

func get_weighted_mob_to_spawn() -> MobSpawnConfig:
	var mobs = get_mobs()
	
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

func _on_player_player_eat(score_after_eating: int) -> void:
	if level <= 1 and score_after_eating >= score_to_level2:
		level = 2
		_update_spawn(level2_camera_scale, level2_spawn_offset)
		$MobTimer.wait_time = level2_spawn_wait_time
		first_spawn_in_level = true
	if level <= 2 and score_after_eating >= score_to_level3:
		level = 3
		$MobTimer.wait_time = level3_spawn_wait_time
		first_spawn_in_level = true
	if level <= 3 and score_after_eating >= score_to_level4:
		level = 4
		$MobTimer.wait_time = level4_spawn_wait_time
		first_spawn_in_level = true
	if level <= 4 and score_after_eating >= score_to_level5:
		level = 5
		_update_spawn(level5_camera_scale, level5_spawn_offset)
		$MobTimer.wait_time = level5_spawn_wait_time
		first_spawn_in_level = true

func _update_spawn(level_scale, level_offset):
		$MobSpawnPathLeft.curve.set_point_position(0, level1_mob_spawn_path_left_point_positions[0] * level_scale - Vector2(level_offset, 0))
		$MobSpawnPathLeft.curve.set_point_position(1, level1_mob_spawn_path_left_point_positions[1] * level_scale - Vector2(level_offset, 0))
		$MobSpawnPathRight.curve.set_point_position(0, level1_mob_spawn_path_right_point_positions[0] * level_scale + Vector2(level_offset, 0))
		$MobSpawnPathRight.curve.set_point_position(1, level1_mob_spawn_path_right_point_positions[1] * level_scale + Vector2(level_offset, 0))
