extends GPUParticles2D

@export var duration = 1

func _ready() -> void:
	$Timer.start(duration)

func _on_timer_timeout() -> void:
	queue_free()
