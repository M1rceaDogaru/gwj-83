extends Camera2D

var shake_amount: float = 0.0
var shake_decay: float = 3.5

func _process(delta):
	if shake_amount > 0:
		var offset_x = randf_range(-shake_amount, shake_amount)
		var offset_y = randf_range(-shake_amount, shake_amount)
		offset = Vector2(offset_x, offset_y)

		shake_amount = lerp(shake_amount, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO
		
	var mouse_world = get_global_mouse_position()
	var aim_offset = mouse_world.normalized() * min(50, mouse_world.length() * 0.2)
	global_position = global_position.lerp(aim_offset, 10 * delta)

func trigger_shake(amount: float):
	shake_amount = max(shake_amount, amount)
