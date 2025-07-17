extends Area2D

@export var required_score_to_eat = 60
@export var speed_min = 6.0
@export var speed_max = 8.0

var score
var velocity

func _ready() -> void:
	score = get_meta("Score")
	velocity = Vector2(randf_range(speed_min, speed_max), 0.0)
	
	var is_facing_right = get_meta("IsFacingRight")
	velocity = velocity if is_facing_right else velocity * -1
	$Sprite2D.flip_h = !is_facing_right

# Use physics process for movement as it's frame-independent
func _physics_process(delta: float) -> void:
	transform.origin += velocity

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var player := body as Player
		var player_score = player.get_meta("Score")
		if player_score >= required_score_to_eat:
			player.eat(score)
			queue_free()
		else:
			player.take_damage()
