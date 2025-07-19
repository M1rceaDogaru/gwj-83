extends Area2D

@export var speed = 130

# controls the run away speed when the player nibbles on the boss
# the boss is invincible when running away
@export var boost_speed = 250
@export var boost_time = 4

@export var rotation_speed = 3.0
@export var health = 10

var score
var follower: PathFollow2D

var last_position: Vector2 = Vector2.ZERO
var current_speed: float

signal creature_die(position: Vector2)
signal health_changed(value)

func _ready() -> void:
	current_speed = speed
	score = get_meta("Score")
	follower = get_tree().get_first_node_in_group("BossPath")

# Use physics process for movement as it's frame-independent
func _physics_process(delta: float) -> void:
	follower.progress += current_speed
	rotation = lerp_angle(rotation, (last_position - global_position).normalized().angle(), delta * rotation_speed)
	last_position = global_position

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# player always takes damage from this part of the boss
		var player := body as Player
		player.take_damage()

func _on_damageable_body_entered(body: Node2D) -> void:
	if body.name == "Player" and current_speed == speed:
		var player := body as Player
		var player_score = player.get_meta("Score")
		player.eat(score)
		health -= 1
		health_changed.emit(health)
		if health <= 0:
			creature_die.emit(position)
			queue_free()
		else:
			# run away from the player
			current_speed = boost_speed
			$BoostTimer.start(boost_time)

func _on_boost_timer_timeout() -> void:
	current_speed = speed
