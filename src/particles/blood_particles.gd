extends GPUParticles2D

@export var duration = 1

func _ready() -> void:
	$Timer.start(duration)

func _process(delta: float) -> void:
	var color = process_material.color
	process_material.color = Color(color.r, color.g, color.b, $Timer.time_left/duration)

func _on_timer_timeout() -> void:
	queue_free()
