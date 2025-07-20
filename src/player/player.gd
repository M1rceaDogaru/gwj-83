extends CharacterBody2D

class_name Player

@export var trail_length = 20            # Fixed number of trail segments
@export var trail_scale = 0.25           # Trail scale
@export var trail_spawn_interval = 0.025 # Trail spawn interval (seconds)
@export var trail_texture: Texture2D     # Trail texture
@export var tail_texture: Texture2D      # Texture for tail segment
@export var middle_texture: Texture2D    # Texture for 10th segment

@export var head_scale_mult = 0.4

@export var score_to_level2 = 5
@export var level2_player_scale = 1.6
@export var score_to_level3 = 70
@export var level3_player_scale = 2.7
@export var score_to_level4 = 120
@export var level4_player_scale = 3.8
@export var score_to_level5 = 250
@export var level5_player_scale = 6.9
@export var score_to_level6 = 800
@export var level6_player_scale = 12.5
@export var score_to_level7 = 2000
@export var level7_player_scale = 18.0
@export var score_to_level8 = 4500
@export var level8_player_scale = 32.0
@export var score_to_level9 = 9000
@export var level9_player_scale = 55.0
@export var score_to_level10 = 13000

@export var bite_sounds : Array[Resource]

@export var hurt_sounds : Array[Resource]

var trail_sprites = []                   # Stores generated trail sprites
var last_rotation = 0                    # Stores last rotation angle
var last_position = Vector2.ZERO         # Track previous position
var can_spawn = true                     # Control if spawning is allowed

var level = 1

var level1_mouse_lead = 50
var level1_speed = 500
var level1_head_scale = 0.4
var level1_collider_radius = 40
var level1_collider_height = 180
var level1_trail_scale = 0.25
var level1_trail_spawn_interval = 0.025

var mouse_lead = level1_mouse_lead
var speed = level1_speed

var max_health = 3
var cur_health = 3
var invincible_time = 1.0
var is_invincible = false

var rng = RandomNumberGenerator.new()

signal player_eat(score_after_eating: int)
signal player_health_change(cur_health: int)
signal player_level_up(level: int)

func set_max_health(health: int):
	max_health = health
	cur_health = health

func try_grow() -> void:
	var player_score = get_meta("Score")
	if level <= 1 and player_score >= score_to_level2:
		level = 2
		grow_to_scale(level2_player_scale)
	elif level <= 2 and player_score >= score_to_level3:
		level = 3
		grow_to_scale(level3_player_scale)
	elif level <= 3 and player_score >= score_to_level4:
		level = 4
		grow_to_scale(level4_player_scale)
		gain_health()
	elif level <= 4 and player_score >= score_to_level5:
		level = 5
		grow_to_scale(level5_player_scale)
	elif level <= 5 and player_score >= score_to_level6:
		level = 6
		grow_to_scale(level6_player_scale)
	elif level <= 6 and player_score >= score_to_level7:
		level = 7
		grow_to_scale(level7_player_scale)
		gain_health()
	elif level <= 7 and player_score >= score_to_level8:
		level = 8
		grow_to_scale(level8_player_scale)
	elif level <= 8 and player_score >= score_to_level9:
		level = 9
		grow_to_scale(level9_player_scale)
	elif level <= 9 and player_score >= score_to_level10:
		level = 10
		gain_health()
		gain_health()
		player_level_up.emit(level)

func grow_to_scale(level_scale) -> void:
	$GrowAudioStreamPlayer.play()
	player_level_up.emit(level)
	
	mouse_lead = level_scale * level1_mouse_lead
	speed = level_scale * level1_speed
	$Sprite2D.scale = Vector2.ONE * level_scale * level1_head_scale * head_scale_mult
	$CollisionShape2D.shape.radius = level_scale * level1_collider_radius
	$CollisionShape2D.shape.height = level_scale * level1_collider_height
	trail_scale = level_scale * level1_trail_scale
	trail_spawn_interval = level_scale * level1_trail_spawn_interval

func eat(score:int) -> void:
	if score >= 500:
		$EatAudioStreamPlayer.stream = bite_sounds[3]
	elif score >= 120:
		$EatAudioStreamPlayer.stream = bite_sounds[2]
	elif score >= 10:
		$EatAudioStreamPlayer.stream = bite_sounds[1]
	else:
		$EatAudioStreamPlayer.stream = bite_sounds[0]
	$EatAudioStreamPlayer.play()
	var player_score = get_meta("Score")
	set_meta("Score", player_score+score)
	try_grow()
	player_eat.emit(player_score)

func take_damage() -> void:
	if not is_invincible:
		var hurt_sound = hurt_sounds[rng.randi_range(0,hurt_sounds.size()-1)]
		$HurtAudioStreamPlayer.stream = hurt_sound
		$HurtAudioStreamPlayer.play()
		cur_health -= 1
		is_invincible = true
		$InvincibilityTimer.start(invincible_time)
		player_health_change.emit(cur_health)

func gain_health() -> void:
	cur_health = min(max_health, cur_health+1)
	player_health_change.emit(cur_health)

# Helper function to create trail sprites
func _create_trail_sprite(pos: Vector2, rot: float) -> Sprite2D:
	var new_sprite = Sprite2D.new()
	new_sprite.texture = trail_texture
	new_sprite.position = pos
	new_sprite.rotation = rot
	new_sprite.scale = Vector2.ONE * trail_scale
	new_sprite.z_index = -1
	get_parent().add_child.call_deferred(new_sprite)
	return new_sprite

func _ready():
	rng.randomize()
	
	$TrailTimer.wait_time = trail_spawn_interval
	$TrailTimer.start()
	
	# Record initial position
	last_position = position
	
	# Create initial fixed-length trail at starting position
	for i in range(trail_length):
		var new_sprite = _create_trail_sprite(position, rotation)
		trail_sprites.append(new_sprite)
	
	# Update only tail and 10th segment after initialization
	update_segment_sprites()

func get_input():
	# Face toward mouse position
	look_at(get_global_mouse_position())
	var delta = get_global_mouse_position() - global_position
	
	# Flip sprite based on move direction so that we always face up
	$Sprite2D.flip_v = delta.x < 0
	
	# Move only if mouse is sufficiently far
	if delta.length() > mouse_lead:
		velocity = transform.x * speed
	else:
		velocity = Vector2.ZERO
	
	# Update rotation tracking
	last_rotation = rotation

func _physics_process(delta):
	get_input()
	
	# Always call move_and_slide to ensure movement
	move_and_slide()
	
	# Check if position has changed
	if position.distance_to(last_position) > 1:
		# Position changed, update last position and allow spawning
		last_position = position
		can_spawn = true
	else:
		# Position unchanged, disable spawning
		can_spawn = false
	
	# Flicker when damaged
	if is_invincible:
		$Sprite2D.set_visible(randi_range(0,1))
	else:
		$Sprite2D.set_visible(true)

func _on_timer_timeout():
	# Only spawn if we're moving
	if not can_spawn:
		return
	
	# Create new head sprite at current position
	var new_sprite = _create_trail_sprite(position, last_rotation)
	
	# Remove oldest sprite if we have enough segments
	if trail_sprites.size() >= trail_length:
		if is_instance_valid(trail_sprites[0]):
			trail_sprites[0].queue_free()
		trail_sprites.pop_front()
	
	trail_sprites.append(new_sprite)
	update_segment_sprites()

func update_segment_sprites():
	if trail_sprites.size() > 0:
		for i in range(0, trail_sprites.size()):
			trail_sprites[i].texture = trail_texture
			trail_sprites[i].scale = Vector2.ONE * trail_scale * (0.99 ** (trail_length-i))
	
	# Only update tail segment (index 0) if we have tail texture
	if trail_sprites.size() > 0 and tail_texture != null:
		trail_sprites[0].texture = tail_texture
	
	# Only update 10th segment (index 9) if we have middle texture
	if trail_sprites.size() > 9 and middle_texture != null:
		trail_sprites[9].texture = middle_texture

func _on_invincibility_timer_timeout() -> void:
	is_invincible = false
