extends Area2D

@export var required_score_to_eat: int = 60

@export var move_speed: float = 800.0
@export var move_distance: float = 400.0
@export var pause_time: float = 2.0
@export var slow_speed: float = 15.0

var score
var is_moving: bool = false
var distance_moved: float = 0.0
var timer: float = 0.0
var move_direction: int = 1

func _ready() -> void:
	score = get_meta("Score")
	
	var is_facing_right = get_meta("IsFacingRight")
	move_direction = 1 if is_facing_right else -1
	$Sprite2D.flip_h = !is_facing_right

# Use physics process for movement as it's frame-independent
func _physics_process(delta: float) -> void:
	#TODO use a timer with a speed curve for smoother motion
	if is_moving:
		# Calculate movement for this frame
		var movement = move_speed * move_direction * delta
		position.x += movement
		distance_moved += abs(movement)
		
		# Check if we've moved enough
		if distance_moved >= move_distance:
			is_moving = false
			distance_moved = 0.0
			timer = 0.0
	else:
		# Count pause time
		timer += delta
		position.x += slow_speed * move_direction * delta
		if timer >= pause_time:
			is_moving = true

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
