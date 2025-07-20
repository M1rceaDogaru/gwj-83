extends ColorRect

func fade_out(duration := 1.0):
	color.a = 0.0
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "color:a", 1.0, duration)
	await tween.finished

func fade_in(duration := 1.0):
	color.a = 1.0
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "color:a", 0.0, duration)
	await tween.finished
	visible = false
