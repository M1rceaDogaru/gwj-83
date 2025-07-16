extends Area2D

@export var score: int = 5
@export var required_score_to_eat: int = 5

var velocity

func _ready() -> void:
	velocity = Vector2(randf_range(3.0, 6.0), 0.0)
	
	var is_facing_right = get_meta("IsFacingRight")
	velocity = velocity if is_facing_right else velocity * -1
	$Sprite2D.flip_h = !is_facing_right

# Use physics process for movement as it's frame-independent
func _physics_process(delta: float) -> void:
	transform.origin += velocity

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	print(area.name)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var player := body as Player
		var player_score = player.get_meta("Score")
		if player_score >= required_score_to_eat:
			player.set_meta("Score", player_score+score)
			player.try_grow()
			queue_free()
