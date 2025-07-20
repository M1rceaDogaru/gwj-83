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

func _on_settings_open_button_button_up() -> void:
	$VolumeControl.visible = true
	$VolumeControl/Blood/CheckButton.button_pressed = Shatterer.has_blood

func _on_settings_close_button_button_up() -> void:
	$VolumeControl.visible = false

func _on_blood_button_toggled(toggled_on: bool) -> void:
	Shatterer.has_blood = toggled_on
