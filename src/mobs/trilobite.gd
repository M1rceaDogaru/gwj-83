extends Area2D

@export var required_score_to_eat = 0
@export var npc_required_score_to_eat = 10
@export var speed_min = 2.0
@export var speed_max = 4.0

var score
var velocity

func _ready() -> void:
	score = get_meta("Score")
	velocity = Vector2(randf_range(speed_min, speed_max), 0.0)
	
	var is_facing_right = get_meta("IsFacingRight")
	velocity = velocity if is_facing_right else velocity * -1
	$Sprite2D.flip_h = !is_facing_right
	if !is_facing_right:
		$VisibleOnScreenNotifier2D.position.x = -$VisibleOnScreenNotifier2D.position.x
		$CollisionShape2D.position.x = -$CollisionShape2D.position.x

# Use physics process for movement as it's frame-independent
func _physics_process(delta: float) -> void:
	transform.origin += velocity

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	var other_score = area.get_meta("Score")
	var other_is_carnivorous = area.get_meta("Score")
	if other_score >= npc_required_score_to_eat and other_is_carnivorous:
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var player := body as Player
		var player_score = player.get_meta("Score")
		if player_score >= required_score_to_eat:
			player.eat(score)
			queue_free()
