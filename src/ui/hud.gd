extends CanvasLayer

signal restart()
signal quit()
signal start()

func _on_restart_button_up() -> void:
	restart.emit()


func _on_quit_button_up() -> void:
	quit.emit()


func _on_start_button_up() -> void:
	start.emit()
