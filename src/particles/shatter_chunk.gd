extends Node2D

@export var lifetime := 5.0
@export var slowdown_duration := 2.0
@export var sink_rate := 100.0
@onready var sprite = $Sprite2D
var trail

var velocity := Vector2.ZERO
var angular_velocity := 0.0
var trail_timer := 0.0

func _ready():
	trail = $Line2D.duplicate()
	get_tree().current_scene.add_child(trail)
	
	sprite.modulate = Color.RED
	sprite.modulate.a = 1.0
	trail.clear_points()

	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, lifetime)
	tween.parallel().tween_property(trail, "modulate:a", 0.0, lifetime)
	tween.tween_callback(Callable(trail, "queue_free"))
	tween.tween_callback(Callable(self, "queue_free"))

func _physics_process(delta):
	position += velocity * delta
	velocity.x = velocity.move_toward(Vector2.ZERO, 100 * delta).x
	velocity.y = clampf(velocity.y + sink_rate * delta, -100, sink_rate)
	angular_velocity = lerp(angular_velocity, 0.0, delta / slowdown_duration)
	rotation_degrees += angular_velocity * delta

	# Update blood trail
	trail_timer += delta
	if trail_timer > 0.02:
		trail.width = 10 * $Sprite2D.scale.x
		trail_timer = 0.0
		trail.add_point(global_position)
