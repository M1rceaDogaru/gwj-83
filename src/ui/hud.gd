extends CanvasLayer

signal restart()
signal quit()

func _on_restart_button_up() -> void:
	restart.emit()


func _on_quit_button_up() -> void:
	quit.emit()
