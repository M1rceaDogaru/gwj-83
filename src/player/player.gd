extends CharacterBody2D

@export var speed = 500

func get_input():
	look_at(get_global_mouse_position())
	velocity = transform.x * speed

func _physics_process(delta):
	get_input()
	move_and_slide()
