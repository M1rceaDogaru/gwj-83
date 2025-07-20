extends GPUParticles2D

@export var duration = 1

@export var red_particles: ParticleProcessMaterial
@export var green_particles: ParticleProcessMaterial

func _ready() -> void:
	process_material = red_particles if Shatterer.has_blood else green_particles
	emitting = true
	$Timer.start(duration)

func _on_timer_timeout() -> void:
	queue_free()
