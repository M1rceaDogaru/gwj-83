extends CharacterBody2D

@export var speed = 500

func get_input():
	look_at(get_global_mouse_position())
	var delta = get_global_mouse_position() - transform.origin
	$Sprite2D.flip_v = delta.x < 0
	if delta.length() > 10:
		velocity = transform.x * speed
	else:
		velocity = Vector2.ZERO

func _physics_process(delta):
	get_input()
	move_and_slide()
