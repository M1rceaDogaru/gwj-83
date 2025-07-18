extends Area2D

@export var required_score_to_eat = 2000
@export var npc_required_score_to_eat = 500
@export var speed_min = 17.0
@export var speed_max = 20.0
@export var chase_time = 1.2
@export var chase_speed = 32.0
@export var cooldown_time = 99.0

var score
var velocity

var target: Node2D
var is_chasing := false
var can_chase := true

var initial_is_facing_right: bool

func _ready() -> void:
	score = get_meta("Score")
	velocity = Vector2(randf_range(speed_min, speed_max), 0.0)
	
	initial_is_facing_right = get_meta("IsFacingRight")
	velocity = velocity if initial_is_facing_right else velocity * -1
	set_facing(initial_is_facing_right)

func set_facing(is_facing_right):
	$Sprite2D.flip_h = !is_facing_right
	if !is_facing_right:
		$VisibleOnScreenNotifier2D.position.x = -$VisibleOnScreenNotifier2D.position.x
		$CollisionShape2D.position.x = -$CollisionShape2D.position.x
		$DetectionZone/CollisionShape2D.position.x = -$CollisionShape2D.position.x

# Use physics process for movement as it's frame-independent
func _physics_process(delta: float) -> void:
	if target:
		transform.origin += transform.origin.direction_to(target.transform.origin) * chase_speed
		set_facing(transform.origin.x < target.transform.origin.x)
	else:
		transform.origin += velocity
		set_facing(initial_is_facing_right)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	var other_score = area.get_meta("Score")
	var other_is_carnivorous = area.get_meta("IsCarnivorous")
	if other_is_carnivorous and other_score >= npc_required_score_to_eat:
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
			
func _on_detection_zone_entered(body: Node2D) -> void:
	var player_score = body.get_meta("Score")
	if not is_chasing and can_chase and player_score < required_score_to_eat:
		start_chase(body)
		
func start_chase(body: Node2D) -> void:
	target = body
	is_chasing = true
	$ChaseTimer.start(chase_time)

func _on_chase_timer_timeout() -> void:
	if is_chasing:
		is_chasing = false
		can_chase = false
		target = null
		$ChaseTimer.start(cooldown_time)
	elif not can_chase:
		can_chase = true
