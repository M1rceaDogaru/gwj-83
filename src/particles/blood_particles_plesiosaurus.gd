extends GPUParticles2D

@export var red_particles: ParticleProcessMaterial
@export var grey_particles: ParticleProcessMaterial

func _ready() -> void:
	process_material = red_particles if Shatterer.has_blood else grey_particles
