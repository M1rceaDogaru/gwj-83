extends Area2D

@export var required_score_to_eat = 17000
@export var npc_required_score_to_eat = 100000
@export var speed_min = 70.0
@export var speed_max = 130

@export var rotation_speed = 2.0

var score
var follower: PathFollow2D

var last_position: Vector2 = Vector2.ZERO

signal creature_die(position: Vector2)

func _ready() -> void:
	score = get_meta("Score")
	follower = get_tree().get_first_node_in_group("BossPath")

# Use physics process for movement as it's frame-independent
func _physics_process(delta: float) -> void:
	follower.progress += speed_max
	#look_at(last_position)
	#rotate(deg_to_rad(180))
	rotation = lerp_angle(rotation, (last_position - global_position).normalized().angle(), delta * rotation_speed)
	last_position = global_position

func _on_area_entered(area: Area2D) -> void:
	var other_score = area.get_meta("Score")
	var other_is_carnivorous = area.get_meta("IsCarnivorous")
	if other_is_carnivorous and other_score >= npc_required_score_to_eat:
		creature_die.emit(position)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var player := body as Player
		var player_score = player.get_meta("Score")
		if player_score >= required_score_to_eat:
			player.eat(score)
			creature_die.emit(position)
			queue_free()
		else:
			player.take_damage()
