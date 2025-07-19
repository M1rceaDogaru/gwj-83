extends HSlider

@export var audio_bus_name: String

@onready var _bus := AudioServer.get_bus_index(audio_bus_name)

var multiplier

func _ready() -> void:
	multiplier = max_value / 3
	value = db_to_linear(AudioServer.get_bus_volume_db(_bus)) * multiplier

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value / multiplier))
