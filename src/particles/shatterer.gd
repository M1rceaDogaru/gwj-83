extends Node

@export var has_blood := true

@onready var blood_particles = preload("res://particles/blood_particles.tscn")
@onready var shatter_chunk_scene = preload("res://particles/shatter_chunk.tscn")
@onready var icon = preload("res://sprites/icon.svg")
@onready var bubble_particles = preload("res://particles/bubble_particles.tscn")

func _ready() -> void:
	# Poor man's shader compilation. Fixes stutter on first bite on web builds
	var scene = get_tree().current_scene
	var blood = blood_particles.instantiate() as GPUParticles2D
	blood.position = Vector2(10000, 10000)
	scene.add_child(blood)
	
	var sprite = Sprite2D.new()
	sprite.texture = icon
	sprite.position = Vector2(10000, 10000)
	scene.add_child(sprite)
	
	var bubble = bubble_particles.instantiate() as GPUParticles2D
	bubble.position = Vector2(10000, 10000)
	scene.add_child(bubble)
	bubble.amount = randi_range(3,5)

func shatter(sprite: Sprite2D):
	var tex = sprite.texture
	if not tex: return

	var grid_size = 4
	var chunk_w = tex.get_width() / grid_size
	var chunk_h = tex.get_height() / grid_size

	for y in range(grid_size):
		for x in range(grid_size):
			if randi() % 2 == 0:
				continue
			var chunk = shatter_chunk_scene.instantiate()
			chunk.global_position = sprite.global_position + Vector2(x - grid_size / 2.0, y - grid_size / 2.0) * chunk_w * sprite.scale
			get_tree().current_scene.add_child(chunk)

			# Assign texture and region
			chunk.sprite.texture = tex
			chunk.sprite.region_enabled = true
			chunk.sprite.region_rect = Rect2(x * chunk_w, y * chunk_h, chunk_w, chunk_h)
			chunk.sprite.scale = sprite.scale

			# Direction-biased velocity with randomness
			var random_offset = Vector2(randf() - 0.5, randf() - 0.5).normalized()
			chunk.velocity = sprite.scale / 2 * random_offset * randf_range(150, 300)

			# Add spin
			chunk.angular_velocity = randf_range(-720, 720)  # degrees/sec
