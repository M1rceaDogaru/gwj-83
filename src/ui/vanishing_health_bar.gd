extends ProgressBar

@export var pause_time = 0.5
@export var health_vanish_time = 1.0

var target_value = max_value
var value_delta = 0.0
var vanishing = false

func _on_progress_bar_value_changed(health_value: float) -> void:
	target_value = health_value
	value_delta = value - health_value
	vanishing = false
	$Timer.start(pause_time)

func _process(delta: float) -> void:
	if vanishing:
		if value > target_value:
			value -= value_delta * (delta/health_vanish_time)
		else:
			value = target_value
			vanishing = false

func _on_timer_timeout() -> void:
	vanishing = true
