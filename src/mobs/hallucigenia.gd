extends Area2D

@export var score: int = 10
@export var required_score_to_eat: int = 20

var velocity

func _ready() -> void:
	velocity = Vector2(randf_range(1.0, 2.0), 0.0)
	var ocean_floor = get_tree().get_first_node_in_group("OceanFloor")
	global_position.y = ocean_floor.global_position.y
	
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
			player.eat(score)
			queue_free()
		else:
			player.take_damage()
