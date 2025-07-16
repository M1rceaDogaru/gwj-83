extends Area2D

var velocity

func _ready() -> void:
	velocity = Vector2(randf_range(2.0, 4.0), 0.0)
	
	var is_facing_right = get_meta("IsFacingRight")
	velocity = velocity if is_facing_right else velocity * -1
	$Sprite2D.flip_h = !is_facing_right

func _process(delta: float) -> void:
	transform.origin += velocity

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	print(area.name)

func _on_body_entered(body: Node2D) -> void:
	print(body.name)
